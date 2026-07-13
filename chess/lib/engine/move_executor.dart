import '../board/board.dart';
import '../engine/game_state.dart';
import '../types/piece_color.dart';
import '../types/piece_type.dart';
import '../types/square.dart';
import '../types/move.dart';
import '../types/piece.dart';

class MoveExecutor {
  static ChessGameState executeMove(ChessGameState state, Move move) {
    final board = state.board.copy();
    final piece = board.getPiece(move.from)!;
    final capturedPiece = board.getPiece(move.to);
    
    final newCapturedPieces = List<Piece>.from(state.capturedPieces);
    final newMoveHistory = List<Move>.from(state.moveHistory)..add(move);
    
    // Handle capture
    if (capturedPiece != null) {
      newCapturedPieces.add(capturedPiece);
    }
    
    // Handle en passant capture
    if (move.type == MoveType.enPassant) {
      final captureSquare = Square(move.to.file, move.from.rank);
      final enPassantPiece = board.getPiece(captureSquare);
      if (enPassantPiece != null) {
        newCapturedPieces.add(enPassantPiece);
        board.setPiece(captureSquare, null);
      }
    }
    
    // Move the piece
    board.movePiece(move.from, move.to);
    
    // Handle promotion
    if (move.type == MoveType.promotion && move.promotionPiece != null) {
      board.setPiece(move.to, piece.copyWith(type: move.promotionPiece));
    }
    
    // Handle castling
    if (move.type == MoveType.castlingKingside || move.type == MoveType.castlingQueenside) {
      _executeCastling(board, move);
    }
    
    // Update piece moved status
    final movedPiece = board.getPiece(move.to);
    if (movedPiece != null) {
      board.setPiece(move.to, movedPiece.withMoved());
    }
    
    // Update castling rights
    final newCastlingRights = _updateCastlingRights(state, move, board);
    
    // Update en passant square
    Square? newEnPassantSquare;
    if (move.type == MoveType.doublePawn) {
      final direction = piece.color == PieceColor.white ? 1 : -1;
      newEnPassantSquare = Square(move.from.file, move.from.rank + direction);
    }
    
    // Update move clocks
    int newHalfMoveClock = state.halfMoveClock;
    int newFullMoveNumber = state.fullMoveNumber;
    
    if (piece.type == PieceType.pawn || capturedPiece != null || move.type == MoveType.enPassant) {
      newHalfMoveClock = 0;
    } else {
      newHalfMoveClock++;
    }
    
    if (state.currentTurn == PieceColor.black) {
      newFullMoveNumber++;
    }
    
    return state.copyWith(
      board: board,
      currentTurn: state.opponent,
      castlingRights: newCastlingRights,
      enPassantSquare: newEnPassantSquare,
      halfMoveClock: newHalfMoveClock,
      fullMoveNumber: newFullMoveNumber,
      moveHistory: newMoveHistory,
      capturedPieces: newCapturedPieces,
    );
  }

  static void _executeCastling(Board board, Move move) {
    final rank = move.from.rank;
    
    if (move.type == MoveType.castlingKingside) {
      // Move rook from file 7 to file 5
      final rookFrom = Square(7, rank);
      final rookTo = Square(5, rank);
      board.movePiece(rookFrom, rookTo);
    } else if (move.type == MoveType.castlingQueenside) {
      // Move rook from file 0 to file 3
      final rookFrom = Square(0, rank);
      final rookTo = Square(3, rank);
      board.movePiece(rookFrom, rookTo);
    }
  }

  static CastlingRights _updateCastlingRights(
    ChessGameState state,
    Move move,
    Board board,
  ) {
    var rights = state.castlingRights;
    final piece = board.getPiece(move.to);
    
    // If king moves, remove all castling rights for that color
    if (piece != null && piece.type == PieceType.king) {
      if (piece.color == PieceColor.white) {
        rights = rights.copyWith(whiteKingside: false, whiteQueenside: false);
      } else {
        rights = rights.copyWith(blackKingside: false, blackQueenside: false);
      }
    }
    
    // If rook moves, remove castling rights for that side
    if (piece != null && piece.type == PieceType.rook) {
      if (move.from.file == 0 && move.from.rank == 0) {
        rights = rights.copyWith(whiteQueenside: false);
      } else if (move.from.file == 7 && move.from.rank == 0) {
        rights = rights.copyWith(whiteKingside: false);
      } else if (move.from.file == 0 && move.from.rank == 7) {
        rights = rights.copyWith(blackQueenside: false);
      } else if (move.from.file == 7 && move.from.rank == 7) {
        rights = rights.copyWith(blackKingside: false);
      }
    }
    
    // If a rook is captured, remove castling rights for that side
    if (move.to.file == 0 && move.to.rank == 0) {
      rights = rights.copyWith(whiteQueenside: false);
    } else if (move.to.file == 7 && move.to.rank == 0) {
      rights = rights.copyWith(whiteKingside: false);
    } else if (move.to.file == 0 && move.to.rank == 7) {
      rights = rights.copyWith(blackQueenside: false);
    } else if (move.to.file == 7 && move.to.rank == 7) {
      rights = rights.copyWith(blackKingside: false);
    }
    
    return rights;
  }
}
