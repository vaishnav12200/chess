import '../board/board.dart';
import '../engine/game_state.dart';
import '../engine/move_executor.dart';
import '../rules/move_validator.dart';
import '../types/game_state.dart';
import '../types/piece_color.dart';
import '../types/piece_type.dart';
import '../types/square.dart';

class GameStateDetector {
  static GameState detectGameState(ChessGameState state) {
    final legalMoves = MoveValidator.getLegalMoves(state);
    
    if (legalMoves.isEmpty) {
      if (MoveValidator.isInCheck(state, state.currentTurn)) {
        // Checkmate
        final winner = state.currentTurn == PieceColor.white ? 'Black' : 'White';
        return GameState(
          status: GameStatus.checkmate,
          winner: winner,
        );
      } else {
        // Stalemate
        return const GameState(status: GameStatus.stalemate);
      }
    }
    
    // Check for insufficient material
    if (isInsufficientMaterial(state)) {
      return const GameState(status: GameStatus.drawByInsufficientMaterial);
    }
    
    // Check for fifty-move rule
    if (state.halfMoveClock >= 100) {
      return const GameState(status: GameStatus.drawByFiftyMoveRule);
    }
    
    // Check for threefold repetition
    if (isThreefoldRepetition(state)) {
      return const GameState(status: GameStatus.drawByThreefoldRepetition);
    }
    
    return const GameState(status: GameStatus.inProgress);
  }
  
  static bool isInsufficientMaterial(ChessGameState state) {
    final whitePieces = state.board.getPieces(PieceColor.white);
    final blackPieces = state.board.getPieces(PieceColor.black);
    
    // King vs King
    if (whitePieces.length == 1 && blackPieces.length == 1) {
      return true;
    }
    
    // King + minor piece vs King
    if ((whitePieces.length == 2 && blackPieces.length == 1) ||
        (whitePieces.length == 1 && blackPieces.length == 2)) {
      final pieces = whitePieces.length > blackPieces.length ? whitePieces : blackPieces;
      final hasMinorPiece = pieces.any((p) => 
        p.type == PieceType.knight || p.type == PieceType.bishop);
      
      if (hasMinorPiece) {
        // Check if it's just king + knight or king + bishop
        final minorPieces = pieces.where((p) => 
          p.type == PieceType.knight || p.type == PieceType.bishop).toList();
        
        if (minorPieces.length == 1) {
          return true;
        }
      }
    }
    
    // King + bishop vs King + bishop (same color squares)
    if (whitePieces.length == 2 && blackPieces.length == 2) {
      final whiteBishop = whitePieces.firstWhere(
        (p) => p.type == PieceType.bishop,
        orElse: () => whitePieces.first,
      );
      final blackBishop = blackPieces.firstWhere(
        (p) => p.type == PieceType.bishop,
        orElse: () => blackPieces.first,
      );
      
      if (whiteBishop.type == PieceType.bishop && blackBishop.type == PieceType.bishop) {
        // Check if bishops are on same color squares
        final whiteSquare = state.board.findKing(PieceColor.white);
        final blackSquare = state.board.findKing(PieceColor.black);
        
        if (whiteSquare != null && blackSquare != null) {
          final whiteColor = (whiteSquare.file + whiteSquare.rank) % 2;
          final blackColor = (blackSquare.file + blackSquare.rank) % 2;
          
          if (whiteColor == blackColor) {
            return true;
          }
        }
      }
    }
    
    return false;
  }
  
  static bool isThreefoldRepetition(ChessGameState state) {
    if (state.moveHistory.length < 6) return false;
    
    final currentBoard = _boardToString(state.board);
    var repetitions = 1;
    
    // Check previous positions
    for (var i = state.moveHistory.length - 1; i >= 0; i--) {
      // Reconstruct board at this point
      final reconstructedState = _reconstructState(state, i);
      final boardString = _boardToString(reconstructedState.board);
      
      if (boardString == currentBoard) {
        repetitions++;
        if (repetitions >= 3) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  static String _boardToString(Board board) {
    final buffer = StringBuffer();
    for (var rank = 0; rank < 8; rank++) {
      for (var file = 0; file < 8; file++) {
        final piece = board.getPiece(Square(file, rank));
        if (piece == null) {
          buffer.write('.');
        } else {
          buffer.write(piece.toString());
        }
      }
    }
    return buffer.toString();
  }
  
  static ChessGameState _reconstructState(ChessGameState state, int moveIndex) {
    var reconstructed = ChessGameState.initial();
    
    for (var i = 0; i <= moveIndex && i < state.moveHistory.length; i++) {
      reconstructed = MoveExecutor.executeMove(reconstructed, state.moveHistory[i]);
    }
    
    return reconstructed;
  }
}
