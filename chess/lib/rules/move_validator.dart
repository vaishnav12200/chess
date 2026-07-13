import '../board/board.dart';
import '../engine/game_state.dart';
import '../pieces/piece_movement.dart';
import '../types/piece.dart';
import '../types/piece_color.dart';
import '../types/square.dart';
import '../types/move.dart';
import '../types/piece_type.dart';

class MoveValidator {
  static List<Move> getLegalMoves(ChessGameState state) {
    final legalMoves = <Move>[];
    final board = state.board;
    final currentColor = state.currentTurn;

    for (var file = 0; file < 8; file++) {
      for (var rank = 0; rank < 8; rank++) {
        final square = Square(file, rank);
        final piece = board.getPiece(square);
        
        if (piece != null && piece.color == currentColor) {
          final pseudoMoves = PieceMovement.getPseudoLegalMoves(board, square, piece);
          
          for (final target in pseudoMoves) {
            final move = _createMove(state, square, target, piece);
            if (move != null && _isLegalMove(state, move)) {
              legalMoves.add(move);
            }
          }
        }
      }
    }

    // Add castling moves
    legalMoves.addAll(_getCastlingMoves(state));

    return legalMoves;
  }

  static Move? _createMove(ChessGameState state, Square from, Square to, Piece piece) {
    final board = state.board;
    final targetPiece = board.getPiece(to);
    final isCapture = targetPiece != null;
    final isEnPassant = state.enPassantSquare == to && piece.type == PieceType.pawn;
    
    MoveType moveType = MoveType.normal;
    if (isCapture) {
      moveType = MoveType.capture;
    } else if (isEnPassant) {
      moveType = MoveType.enPassant;
    } else if (piece.type == PieceType.pawn && (to.rank - from.rank).abs() == 2) {
      moveType = MoveType.doublePawn;
    }

    // Check for promotion
    final promotionRank = piece.color == PieceColor.white ? 7 : 0;
    if (piece.type == PieceType.pawn && to.rank == promotionRank) {
      return Move(
        from: from,
        to: to,
        type: MoveType.promotion,
        promotionPiece: PieceType.queen,
      );
    }

    return Move(from: from, to: to, type: moveType);
  }

  static bool _isLegalMove(ChessGameState state, Move move) {
    final simulatedState = _simulateMove(state, move);
    return !isInCheck(simulatedState, state.currentTurn);
  }

  static ChessGameState _simulateMove(ChessGameState state, Move move) {
    final board = state.board.copy();
    final piece = board.getPiece(move.from)!;
    
    // Handle en passant capture
    if (move.type == MoveType.enPassant) {
      final captureSquare = Square(move.to.file, move.from.rank);
      board.setPiece(captureSquare, null);
    }
    
    // Move the piece
    board.movePiece(move.from, move.to);
    
    // Handle promotion
    if (move.type == MoveType.promotion && move.promotionPiece != null) {
      board.setPiece(move.to, piece.copyWith(type: move.promotionPiece));
    }
    
    return state.copyWith(board: board);
  }

  static bool isInCheck(ChessGameState state, PieceColor color) {
    final kingSquare = state.board.findKing(color);
    if (kingSquare == null) return false;
    
    return isSquareAttacked(state, kingSquare, color.opposite);
  }

  static bool isSquareAttacked(ChessGameState state, Square square, PieceColor byColor) {
    final board = state.board;
    
    // Check for pawn attacks
    final pawnDirection = byColor == PieceColor.white ? -1 : 1;
    for (final fileOffset in [-1, 1]) {
      final pawnSquare = Square(square.file + fileOffset, square.rank + pawnDirection);
      if (pawnSquare.isValid) {
        final piece = board.getPiece(pawnSquare);
        if (piece != null && piece.type == PieceType.pawn && piece.color == byColor) {
          return true;
        }
      }
    }
    
    // Check for knight attacks
    for (final offset in KnightMovement.offsets) {
      final knightSquare = square + offset;
      if (knightSquare.isValid) {
        final piece = board.getPiece(knightSquare);
        if (piece != null && piece.type == PieceType.knight && piece.color == byColor) {
          return true;
        }
      }
    }
    
    // Check for king attacks
    for (final offset in KingMovement.offsets) {
      final kingSquare = square + offset;
      if (kingSquare.isValid) {
        final piece = board.getPiece(kingSquare);
        if (piece != null && piece.type == PieceType.king && piece.color == byColor) {
          return true;
        }
      }
    }
    
    // Check for sliding piece attacks (bishop, rook, queen)
    for (final direction in BishopMovement.directions) {
      var current = square + direction;
      while (current.isValid) {
        final piece = board.getPiece(current);
        if (piece != null) {
          if (piece.color == byColor && 
              (piece.type == PieceType.bishop || piece.type == PieceType.queen)) {
            return true;
          }
          break;
        }
        current = current + direction;
      }
    }
    
    for (final direction in RookMovement.directions) {
      var current = square + direction;
      while (current.isValid) {
        final piece = board.getPiece(current);
        if (piece != null) {
          if (piece.color == byColor && 
              (piece.type == PieceType.rook || piece.type == PieceType.queen)) {
            return true;
          }
          break;
        }
        current = current + direction;
      }
    }
    
    return false;
  }

  static List<Move> _getCastlingMoves(ChessGameState state) {
    final moves = <Move>[];
    final color = state.currentTurn;
    
    if (isInCheck(state, color)) return moves;
    
    final kingSquare = state.board.findKing(color);
    if (kingSquare == null) return moves;
    
    final kingPiece = state.board.getPiece(kingSquare);
    if (kingPiece == null || kingPiece.hasMoved) return moves;
    
    final rights = state.castlingRights;
    
    // Kingside castling
    if (rights.canCastleKingside(color)) {
      if (_canCastleKingside(state, kingSquare)) {
        moves.add(Move(
          from: kingSquare,
          to: Square(kingSquare.file + 2, kingSquare.rank),
          type: MoveType.castlingKingside,
        ));
      }
    }
    
    // Queenside castling
    if (rights.canCastleQueenside(color)) {
      if (_canCastleQueenside(state, kingSquare)) {
        moves.add(Move(
          from: kingSquare,
          to: Square(kingSquare.file - 2, kingSquare.rank),
          type: MoveType.castlingQueenside,
        ));
      }
    }
    
    return moves;
  }

  static bool _canCastleKingside(ChessGameState state, Square kingSquare) {
    final board = state.board;
    final color = state.currentTurn;
    
    // Check squares between king and rook are empty
    final fSquare = Square(kingSquare.file + 1, kingSquare.rank);
    final gSquare = Square(kingSquare.file + 2, kingSquare.rank);
    
    if (!board.isEmpty(fSquare) || !board.isEmpty(gSquare)) return false;
    
    // Check rook hasn't moved
    final rookSquare = Square(kingSquare.file + 3, kingSquare.rank);
    final rook = board.getPiece(rookSquare);
    if (rook == null || rook.type != PieceType.rook || rook.color != color || rook.hasMoved) {
      return false;
    }
    
    // Check king doesn't pass through check
    final tempState = state.copyWith(board: board.copy());
    tempState.board.movePiece(kingSquare, fSquare);
    if (isInCheck(tempState, color)) return false;
    
    return true;
  }

  static bool _canCastleQueenside(ChessGameState state, Square kingSquare) {
    final board = state.board;
    final color = state.currentTurn;
    
    // Check squares between king and rook are empty
    final dSquare = Square(kingSquare.file - 1, kingSquare.rank);
    final cSquare = Square(kingSquare.file - 2, kingSquare.rank);
    final bSquare = Square(kingSquare.file - 3, kingSquare.rank);
    
    if (!board.isEmpty(dSquare) || !board.isEmpty(cSquare) || !board.isEmpty(bSquare)) {
      return false;
    }
    
    // Check rook hasn't moved
    final rookSquare = Square(kingSquare.file - 4, kingSquare.rank);
    final rook = board.getPiece(rookSquare);
    if (rook == null || rook.type != PieceType.rook || rook.color != color || rook.hasMoved) {
      return false;
    }
    
    // Check king doesn't pass through check
    final tempState = state.copyWith(board: board.copy());
    tempState.board.movePiece(kingSquare, dSquare);
    if (isInCheck(tempState, color)) return false;
    
    return true;
  }
}
