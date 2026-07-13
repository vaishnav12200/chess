import 'dart:async';
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
  final int timeControl; // in minutes
  final bool showDirectionHints;

  const ChessGameScreen({
    super.key,
    required this.timeControl,
    required this.showDirectionHints,
  });

  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  late ChessGameState _gameState;
  Square? _selectedSquare;
  List<Square> _legalMoves = [];
  final List<ChessGameState> _history = [];
  int _historyIndex = 0;

  // Timer
  late int _whiteTimeRemaining;
  late int _blackTimeRemaining;
  Timer? _timer;

  // Player info
  final String _whitePlayerName = 'Player1';
  final int _whitePlayerRating = 1500;
  final String _whitePlayerCountry = 'IN';

  final String _blackPlayerName = 'Player2';
  final int _blackPlayerRating = 1450;
  final String _blackPlayerCountry = 'IN';

  @override
  void initState() {
    super.initState();
    _gameState = ChessGameState.initial();
    _history.add(_gameState);
    
    // Initialize timers
    _whiteTimeRemaining = widget.timeControl * 60;
    _blackTimeRemaining = widget.timeControl * 60;
    
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_gameState.currentTurn == PieceColor.white) {
            _whiteTimeRemaining--;
          } else {
            _blackTimeRemaining--;
          }
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final gameState = _history[_historyIndex];
    final lastMove = gameState.moveHistory.isNotEmpty
        ? gameState.moveHistory.last
        : null;
    final gameStatus = GameStateDetector.detectGameState(gameState);

    return Scaffold(
      backgroundColor: Colors.white,
      body: gameStatus.isGameOver
          ? _buildGameOverScreen(gameStatus)
          : _buildGameScreen(gameState, lastMove),
    );
  }

  Widget _buildGameScreen(ChessGameState gameState, Move? lastMove) {
    return Column(
      children: [
        // Top player info (Black)
        PlayerInfoPanel(
          name: _blackPlayerName,
          rating: _blackPlayerRating,
          countryCode: _blackPlayerCountry,
          capturedPieces: _getCapturedPieces(gameState, PieceColor.black),
          timeRemaining: _formatTime(_blackTimeRemaining),
          isTop: true,
        ),
        // Horizontal move history
        HorizontalMoveHistory(gameState: gameState),
        // Chess board
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BoardWidget(
                gameState: gameState,
                selectedSquare: _selectedSquare,
                legalMoves: _legalMoves,
                lastMove: lastMove,
                onSquareTap: _onSquareTap,
                showDirectionHints: widget.showDirectionHints,
              ),
            ),
          ),
        ),
        // Bottom player info (White)
        PlayerInfoPanel(
          name: _whitePlayerName,
          rating: _whitePlayerRating,
          countryCode: _whitePlayerCountry,
          capturedPieces: _getCapturedPieces(gameState, PieceColor.white),
          timeRemaining: _formatTime(_whiteTimeRemaining),
          isTop: false,
        ),
        // Bottom navigation bar
        ChessBottomNavBar(
          onBack: _undo,
          onForward: _redo,
          canGoBack: _historyIndex > 0,
          canGoForward: _historyIndex < _history.length - 1,
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

  @override
  void didUpdateWidget(ChessGameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart timer if time control changes
    if (oldWidget.timeControl != widget.timeControl) {
      _timer?.cancel();
      _whiteTimeRemaining = widget.timeControl * 60;
      _blackTimeRemaining = widget.timeControl * 60;
      _startTimer();
    }
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

  List<Piece> _getCapturedPieces(ChessGameState state, PieceColor color) {
    // Get pieces captured by this color (opponent's pieces that were captured)
    final opponentColor = color.opposite;
    return state.capturedPieces.where((p) => p.color == opponentColor).toList();
  }
}
