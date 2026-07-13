import '../engine/game_state.dart';
import '../engine/move_executor.dart';
import '../rules/move_validator.dart';
import '../rules/game_state_detector.dart';
import '../types/move.dart';
import '../types/piece_type.dart';
import '../types/game_state.dart';
import '../types/square.dart';

class MoveNotation {
  static String toNotation(ChessGameState state, Move move) {
    final board = state.board;
    final piece = board.getPiece(move.from)!;
    final capturedPiece = board.getPiece(move.to);
    final isCheck = _isCheckAfterMove(state, move);
    final isCheckmate = _isCheckmateAfterMove(state, move);
    
    String notation = '';
    
    // Castling
    if (move.type == MoveType.castlingKingside) {
      notation = 'O-O';
    } else if (move.type == MoveType.castlingQueenside) {
      notation = 'O-O-O';
    } else {
      // Piece letter (except pawn)
      if (piece.type != PieceType.pawn) {
        notation += _getPieceLetter(piece.type);
      }
      
      // Disambiguation if needed
      notation += _getDisambiguation(state, move);
      
      // Capture
      if (move.type == MoveType.capture || 
          move.type == MoveType.enPassant ||
          capturedPiece != null) {
        if (piece.type == PieceType.pawn) {
          notation += move.from.notation[0]; // File letter
        }
        notation += 'x';
      }
      
      // Destination square
      notation += move.to.notation;
      
      // Promotion
      if (move.type == MoveType.promotion && move.promotionPiece != null) {
        notation += '=${_getPieceLetter(move.promotionPiece!)}';
      }
    }
    
    // Check/Checkmate
    if (isCheckmate) {
      notation += '#';
    } else if (isCheck) {
      notation += '+';
    }
    
    return notation;
  }
  
  static String _getPieceLetter(PieceType type) {
    switch (type) {
      case PieceType.knight:
        return 'N';
      case PieceType.bishop:
        return 'B';
      case PieceType.rook:
        return 'R';
      case PieceType.queen:
        return 'Q';
      case PieceType.king:
        return 'K';
      case PieceType.pawn:
        return '';
    }
  }
  
  static String _getDisambiguation(ChessGameState state, Move move) {
    final board = state.board;
    final piece = board.getPiece(move.from)!;
    final color = piece.color;
    
    // Find all pieces of same type that can move to target
    final candidates = <Square>[];
    for (var file = 0; file < 8; file++) {
      for (var rank = 0; rank < 8; rank++) {
        final square = Square(file, rank);
        final candidate = board.getPiece(square);
        
        if (candidate != null && 
            candidate.type == piece.type && 
            candidate.color == color &&
            (square.file != move.from.file || square.rank != move.from.rank)) {
          
          // Check if this piece can also move to the target
          // Simplified check - in a full implementation, we'd use the move validator
          candidates.add(square);
        }
      }
    }
    
    if (candidates.isEmpty) return '';
    
    // Check if file alone disambiguates
    final uniqueFile = candidates.every((c) => c.file != move.from.file);
    if (uniqueFile) {
      return move.from.notation[0];
    }
    
    // Check if rank alone disambiguates
    final uniqueRank = candidates.every((c) => c.rank != move.from.rank);
    if (uniqueRank) {
      return move.from.notation[1];
    }
    
    // Need both file and rank
    return move.from.notation;
  }
  
  static bool _isCheckAfterMove(ChessGameState state, Move move) {
    // Simulate the move and check for check
    final newState = _simulateMove(state, move);
    return MoveValidator.isInCheck(newState, newState.currentTurn);
  }
  
  static bool _isCheckmateAfterMove(ChessGameState state, Move move) {
    final newState = _simulateMove(state, move);
    final gameState = GameStateDetector.detectGameState(newState);
    return gameState.status == GameStatus.checkmate;
  }
  
  static ChessGameState _simulateMove(ChessGameState state, Move move) {
    return MoveExecutor.executeMove(state, move);
  }
}
