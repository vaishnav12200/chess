import '../board/board.dart';
import '../types/piece.dart';
import '../types/piece_color.dart';
import '../types/square.dart';
import '../types/piece_type.dart';

abstract class PieceMovement {
  static List<Square> getPseudoLegalMoves(Board board, Square square, Piece piece) {
    switch (piece.type) {
      case PieceType.pawn:
        return PawnMovement.getPseudoLegalMoves(board, square, piece);
      case PieceType.knight:
        return KnightMovement.getPseudoLegalMoves(board, square, piece);
      case PieceType.bishop:
        return BishopMovement.getPseudoLegalMoves(board, square, piece);
      case PieceType.rook:
        return RookMovement.getPseudoLegalMoves(board, square, piece);
      case PieceType.queen:
        return QueenMovement.getPseudoLegalMoves(board, square, piece);
      case PieceType.king:
        return KingMovement.getPseudoLegalMoves(board, square, piece);
    }
  }
}

class PawnMovement {
  static List<Square> getPseudoLegalMoves(Board board, Square square, Piece piece) {
    final moves = <Square>[];
    final direction = piece.color == PieceColor.white ? 1 : -1;
    final startRank = piece.color == PieceColor.white ? 1 : 6;

    // Forward move
    final forward = Square(square.file, square.rank + direction);
    if (forward.isValid && board.isEmpty(forward)) {
      moves.add(forward);
      
      // Double move from starting position
      if (square.rank == startRank) {
        final doubleForward = Square(square.file, square.rank + 2 * direction);
        if (doubleForward.isValid && board.isEmpty(doubleForward)) {
          moves.add(doubleForward);
        }
      }
    }

    // Captures
    for (final fileOffset in [-1, 1]) {
      final captureSquare = Square(square.file + fileOffset, square.rank + direction);
      if (captureSquare.isValid && board.isOccupiedByOpponent(captureSquare, piece.color)) {
        moves.add(captureSquare);
      }
    }

    return moves;
  }
}

class KnightMovement {
  static const List<Square> offsets = [
    Square(1, 2), Square(1, -2),
    Square(-1, 2), Square(-1, -2),
    Square(2, 1), Square(2, -1),
    Square(-2, 1), Square(-2, -1),
  ];

  static List<Square> getPseudoLegalMoves(Board board, Square square, Piece piece) {
    final moves = <Square>[];
    for (final offset in offsets) {
      final target = square + offset;
      if (target.isValid && !board.isOccupiedBy(target, piece.color)) {
        moves.add(target);
      }
    }
    return moves;
  }
}

class BishopMovement {
  static const List<Square> directions = [
    Square(1, 1), Square(1, -1),
    Square(-1, 1), Square(-1, -1),
  ];

  static List<Square> getPseudoLegalMoves(Board board, Square square, Piece piece) {
    return _getSlidingMoves(board, square, piece, directions);
  }

  static List<Square> _getSlidingMoves(
    Board board,
    Square square,
    Piece piece,
    List<Square> directions,
  ) {
    final moves = <Square>[];
    for (final direction in directions) {
      var current = square + direction;
      while (current.isValid) {
        if (board.isEmpty(current)) {
          moves.add(current);
        } else {
          if (board.isOccupiedByOpponent(current, piece.color)) {
            moves.add(current);
          }
          break;
        }
        current = current + direction;
      }
    }
    return moves;
  }
}

class RookMovement {
  static const List<Square> directions = [
    Square(1, 0), Square(-1, 0),
    Square(0, 1), Square(0, -1),
  ];

  static List<Square> getPseudoLegalMoves(Board board, Square square, Piece piece) {
    return BishopMovement._getSlidingMoves(board, square, piece, directions);
  }
}

class QueenMovement {
  static List<Square> getPseudoLegalMoves(Board board, Square square, Piece piece) {
    return [
      ...BishopMovement.getPseudoLegalMoves(board, square, piece),
      ...RookMovement.getPseudoLegalMoves(board, square, piece),
    ];
  }
}

class KingMovement {
  static const List<Square> offsets = [
    Square(1, 0), Square(-1, 0),
    Square(0, 1), Square(0, -1),
    Square(1, 1), Square(1, -1),
    Square(-1, 1), Square(-1, -1),
  ];

  static List<Square> getPseudoLegalMoves(Board board, Square square, Piece piece) {
    final moves = <Square>[];
    for (final offset in offsets) {
      final target = square + offset;
      if (target.isValid && !board.isOccupiedBy(target, piece.color)) {
        moves.add(target);
      }
    }
    return moves;
  }
}
