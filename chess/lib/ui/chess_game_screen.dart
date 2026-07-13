import 'package:flutter/material.dart';
import '../engine/game_state.dart';
import '../engine/move_executor.dart';
import '../rules/move_validator.dart';
import '../rules/game_state_detector.dart';
import '../types/square.dart';
import '../types/move.dart';
import '../types/piece_type.dart';
import '../types/piece_color.dart';
import '../types/piece.dart';
import '../types/game_state.dart';
import 'board_widget.dart';
import 'player_info_panel.dart';
import 'horizontal_move_history.dart';
import 'bottom_nav_bar.dart';
import 'promotion_dialog.dart';

class ChessGameScreen extends StatefulWidget {
  const ChessGameScreen({super.key});

  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  late ChessGameState _gameState;
  Square? _selectedSquare;
  List<Square> _legalMoves = [];
  final List<ChessGameState> _history = [];
  int _historyIndex = 0;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _gameState = ChessGameState.initial();
    _history.add(_gameState);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = _history[_historyIndex];
    final lastMove = gameState.moveHistory.isNotEmpty
        ? gameState.moveHistory.last
        : null;
    final gameStatus = GameStateDetector.detectGameState(gameState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          _buildTurnIndicator(gameState),
          const SizedBox(width: 16),
        ],
      ),
      body: gameStatus.isGameOver
          ? _buildGameOverScreen(gameStatus)
          : _buildGameScreen(gameState, lastMove),
    );
  }

  Widget _buildTurnIndicator(ChessGameState gameState) {
    return Row(
      children: [
        Icon(
          gameState.currentTurn == PieceColor.white
              ? Icons.circle
              : Icons.circle_outlined,
          color: gameState.currentTurn == PieceColor.white
              ? Colors.white
              : Colors.black,
        ),
        const SizedBox(width: 8),
        Text(
          gameState.currentTurn == PieceColor.white ? 'White' : 'Black',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGameScreen(ChessGameState gameState, Move? lastMove) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // Board
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BoardWidget(
                    gameState: gameState,
                    selectedSquare: _selectedSquare,
                    legalMoves: _legalMoves,
                    lastMove: lastMove,
                    onSquareTap: _onSquareTap,
                  ),
                ),
              ),
              // Move history
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MoveHistoryWidget(gameState: gameState),
                ),
              ),
            ],
          ),
        ),
        // Game controls
        Padding(
          padding: const EdgeInsets.all(16),
          child: GameControls(
            onNewGame: _newGame,
            onUndo: _undo,
            onRedo: _redo,
            onFlipBoard: _flipBoard,
            canUndo: _historyIndex > 0,
            canRedo: _historyIndex < _history.length - 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverScreen(GameState gameStatus) {
    String message;
    Color color;

    switch (gameStatus.status) {
      case GameStatus.checkmate:
        message = 'Checkmate! ${gameStatus.winner} wins!';
        color = Colors.green;
        break;
      case GameStatus.stalemate:
        message = 'Stalemate! Draw.';
        color = Colors.orange;
        break;
      case GameStatus.drawByInsufficientMaterial:
        message = 'Draw by insufficient material.';
        color = Colors.orange;
        break;
      case GameStatus.drawByFiftyMoveRule:
        message = 'Draw by fifty-move rule.';
        color = Colors.orange;
        break;
      case GameStatus.drawByThreefoldRepetition:
        message = 'Draw by threefold repetition.';
        color = Colors.orange;
        break;
      default:
        message = 'Game Over';
        color = Colors.grey;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _newGame,
            icon: const Icon(Icons.refresh),
            label: const Text('New Game'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _onSquareTap(Square square) {
    final gameState = _history[_historyIndex];

    // If a piece is selected and user taps a legal move
    if (_selectedSquare != null && _legalMoves.contains(square)) {
      _makeMove(_selectedSquare!, square);
      return;
    }

    final piece = gameState.board.getPiece(square);
    // If tapping on own piece, select it
    if (piece != null && piece.color == gameState.currentTurn) {
      setState(() {
        _selectedSquare = square;
        _legalMoves = _getLegalMovesForSquare(gameState, square);
      });
      return;
    }

    // Deselect
    setState(() {
      _selectedSquare = null;
      _legalMoves = [];
    });
  }

  List<Square> _getLegalMovesForSquare(ChessGameState state, Square square) {
    final piece = state.board.getPiece(square);
    if (piece == null) return [];

    final allLegalMoves = MoveValidator.getLegalMoves(state);
    return allLegalMoves
        .where((move) => move.from == square)
        .map((move) => move.to)
        .toList();
  }

  Future<void> _makeMove(Square from, Square to) async {
    final gameState = _history[_historyIndex];
    final allLegalMoves = MoveValidator.getLegalMoves(gameState);
    final move = allLegalMoves.firstWhere(
      (m) => m.from == from && m.to == to,
    );

    // Handle promotion
    if (move.type == MoveType.promotion) {
      final promotionPiece = await _showPromotionDialog();
      if (promotionPiece == null) {
        setState(() {
          _selectedSquare = null;
          _legalMoves = [];
        });
        return;
      }

      final promotionMove = move.copyWith(promotionPiece: promotionPiece);
      final newState = MoveExecutor.executeMove(gameState, promotionMove);
      _updateHistory(newState);
    } else {
      final newState = MoveExecutor.executeMove(gameState, move);
      _updateHistory(newState);
    }

    setState(() {
      _selectedSquare = null;
      _legalMoves = [];
    });
  }

  Future<PieceType?> _showPromotionDialog() async {
    return showDialog<PieceType>(
      context: context,
      builder: (context) => const PromotionDialog(),
    );
  }

  void _updateHistory(ChessGameState newState) {
    setState(() {
      // Remove any future states if we're not at the end
      if (_historyIndex < _history.length - 1) {
        _history.removeRange(_historyIndex + 1, _history.length);
      }
      _history.add(newState);
      _historyIndex = _history.length - 1;
    });
  }

  void _newGame() {
    setState(() {
      _gameState = ChessGameState.initial();
      _history.clear();
      _history.add(_gameState);
      _historyIndex = 0;
      _selectedSquare = null;
      _legalMoves = [];
    });
  }

  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _selectedSquare = null;
        _legalMoves = [];
      });
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        _selectedSquare = null;
        _legalMoves = [];
      });
    }
  }

  void _flipBoard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }
}
