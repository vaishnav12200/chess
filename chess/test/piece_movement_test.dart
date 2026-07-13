import 'package:flutter_test/flutter_test.dart';
import 'package:chess/board/board.dart';
import 'package:chess/pieces/piece_movement.dart';
import 'package:chess/types/piece.dart';
import 'package:chess/types/piece_type.dart';
import 'package:chess/types/piece_color.dart';
import 'package:chess/types/square.dart';

void main() {
  group('Piece Movement Tests', () {
    test('Pawn initial moves', () {
      final board = Board.initial();
      final pawn = board.getPiece(const Square(0, 1))!;
      final moves = PawnMovement.getPseudoLegalMoves(board, const Square(0, 1), pawn);
      
      expect(moves.length, equals(2));
      expect(moves, contains(const Square(0, 2)));
      expect(moves, contains(const Square(0, 3)));
    });

    test('Knight moves', () {
      final board = Board.initial();
      final knight = board.getPiece(const Square(1, 0))!;
      final moves = KnightMovement.getPseudoLegalMoves(board, const Square(1, 0), knight);
      
      expect(moves.length, equals(2));
      expect(moves, contains(const Square(0, 2)));
      expect(moves, contains(const Square(2, 2)));
    });

    test('Rook moves from corner', () {
      final board = Board.initial();
      final rook = board.getPiece(const Square(0, 0))!;
      final moves = RookMovement.getPseudoLegalMoves(board, const Square(0, 0), rook);
      
      // Rook is blocked by pawn
      expect(moves.length, equals(0));
    });

    test('Bishop moves from starting position', () {
      final board = Board.initial();
      final bishop = board.getPiece(const Square(2, 0))!;
      final moves = BishopMovement.getPseudoLegalMoves(board, const Square(2, 0), bishop);
      
      // Bishop is blocked by pawn
      expect(moves.length, equals(0));
    });
  });
}
