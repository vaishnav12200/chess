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
  final String whitePlayerName;
  final String blackPlayerName;

  const ChessGameScreen({
    super.key,
    required this.timeControl,
    required this.showDirectionHints,
    this.whitePlayerName = 'Player 1',
    this.blackPlayerName = 'Player 2',
  });

  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  final List<ChessGameState> _history = [];
  int _historyIndex = 0;
  Square? _selectedSquare;
  List<Square> _legalMoves = [];

  late int _whiteTimeRemaining;
  late int _blackTimeRemaining;
  Timer? _timer;
  // null = no timeout loss yet; PieceColor = who lost on time
  PieceColor? _timeoutLoser;

  ChessGameState get _currentState => _history[_historyIndex];

  @override
  void initState() {
    super.initState();
    _history.add(ChessGameState.initial());
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
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final gameStatus = GameStateDetector.detectGameState(_currentState);
      if (gameStatus.isGameOver || _timeoutLoser != null) {
        _timer?.cancel();
        return;
      }
      setState(() {
        if (_currentState.currentTurn == PieceColor.white) {
          _whiteTimeRemaining--;
          if (_whiteTimeRemaining <= 0) {
            _whiteTimeRemaining = 0;
            _handleTimeout(PieceColor.white);
          }
        } else {
          _blackTimeRemaining--;
          if (_blackTimeRemaining <= 0) {
            _blackTimeRemaining = 0;
            _handleTimeout(PieceColor.black);
          }
        }
      });
    });
  }

  void _handleTimeout(PieceColor loser) {
    _timer?.cancel();
    // Draw if opponent has insufficient material to mate
    final winner = loser == PieceColor.white ? PieceColor.black : PieceColor.white;
    final opponentPieces = _currentState.board.getPieces(winner);
    final isInsufficient = opponentPieces.length == 1; // only king
    if (isInsufficient) {
      // Draw — don't set a loser, show draw message via a flag
      setState(() => _timeoutLoser = loser); // reuse flag; handle in UI
    } else {
      setState(() => _timeoutLoser = loser);
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final lastMove =
        _currentState.moveHistory.isNotEmpty ? _currentState.moveHistory.last : null;
    final gameStatus = GameStateDetector.detectGameState(_currentState);
    final isOver = gameStatus.isGameOver || _timeoutLoser != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isOver
          ? _buildGameOverScreen(gameStatus)
          : _buildGameScreen(_currentState, lastMove),
    );
  }

  Widget _buildGameScreen(ChessGameState gameState, Move? lastMove) {
    final isWhiteTurn = gameState.currentTurn == PieceColor.white;
    return Column(
      children: [
        PlayerInfoPanel(
          name: widget.blackPlayerName,
          rating: 0,
          countryCode: '',
          capturedPieces: _getCapturedPieces(gameState, PieceColor.black),
          timeRemaining: _formatTime(_blackTimeRemaining),
          isTop: true,
          isActive: !isWhiteTurn,
        ),
        HorizontalMoveHistory(gameState: gameState),
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
        PlayerInfoPanel(
          name: widget.whitePlayerName,
          rating: 0,
          countryCode: '',
          capturedPieces: _getCapturedPieces(gameState, PieceColor.white),
          timeRemaining: _formatTime(_whiteTimeRemaining),
          isTop: false,
          isActive: isWhiteTurn,
        ),
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

    if (_timeoutLoser != null) {
      final opponentPieces = _currentState.board
          .getPieces(_timeoutLoser == PieceColor.white ? PieceColor.black : PieceColor.white);
      if (opponentPieces.length == 1) {
        message = 'Draw — insufficient material to win on time.';
        color = Colors.orange;
      } else {
        final winnerName = _timeoutLoser == PieceColor.white
            ? widget.blackPlayerName
            : widget.whitePlayerName;
        message = '$winnerName wins on time!';
        color = Colors.green;
      }
    } else {
      switch (gameStatus.status) {
        case GameStatus.checkmate:
          final winnerName = gameStatus.winner == 'White'
              ? widget.whitePlayerName
              : widget.blackPlayerName;
          message = 'Checkmate! $winnerName wins!';
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
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
    final gameState = _currentState;
    if (_selectedSquare != null && _legalMoves.contains(square)) {
      _makeMove(_selectedSquare!, square);
      return;
    }
    final piece = gameState.board.getPiece(square);
    if (piece != null && piece.color == gameState.currentTurn) {
      setState(() {
        _selectedSquare = square;
        _legalMoves = _getLegalMovesForSquare(gameState, square);
      });
      return;
    }
    setState(() {
      _selectedSquare = null;
      _legalMoves = [];
    });
  }

  List<Square> _getLegalMovesForSquare(ChessGameState state, Square square) {
    if (state.board.getPiece(square) == null) return [];
    return MoveValidator.getLegalMoves(state)
        .where((m) => m.from == square)
        .map((m) => m.to)
        .toList();
  }

  Future<void> _makeMove(Square from, Square to) async {
    final gameState = _currentState;
    final move = MoveValidator.getLegalMoves(gameState)
        .firstWhere((m) => m.from == from && m.to == to);

    ChessGameState newState;
    if (move.type == MoveType.promotion) {
      final promotionPiece = await _showPromotionDialog();
      if (promotionPiece == null) {
        setState(() {
          _selectedSquare = null;
          _legalMoves = [];
        });
        return;
      }
      newState = MoveExecutor.executeMove(gameState, move.copyWith(promotionPiece: promotionPiece));
    } else {
      newState = MoveExecutor.executeMove(gameState, move);
    }

    setState(() {
      if (_historyIndex < _history.length - 1) {
        _history.removeRange(_historyIndex + 1, _history.length);
      }
      _history.add(newState);
      _historyIndex = _history.length - 1;
      _selectedSquare = null;
      _legalMoves = [];
    });
  }

  Future<PieceType?> _showPromotionDialog() =>
      showDialog<PieceType>(context: context, builder: (_) => const PromotionDialog());

  void _newGame() {
    _timer?.cancel();
    setState(() {
      _history
        ..clear()
        ..add(ChessGameState.initial());
      _historyIndex = 0;
      _selectedSquare = null;
      _legalMoves = [];
      _whiteTimeRemaining = widget.timeControl * 60;
      _blackTimeRemaining = widget.timeControl * 60;
      _timeoutLoser = null;
    });
    _startTimer();
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
    return state.capturedPieces.where((p) => p.color == color.opposite).toList();
  }
}
