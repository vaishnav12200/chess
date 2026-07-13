import 'package:flutter_test/flutter_test.dart';
import 'package:chess/board/board.dart';
import 'package:chess/types/piece.dart';
import 'package:chess/types/piece_type.dart';
import 'package:chess/types/piece_color.dart';
import 'package:chess/types/square.dart';

void main() {
  group('Board Tests', () {
    test('Initial board setup', () {
      final board = Board.initial();
      
      // Check white pieces
      expect(board.getPiece(const Square(0, 0))?.type, equals(PieceType.rook));
      expect(board.getPiece(const Square(0, 0))?.color, equals(PieceColor.white));
      expect(board.getPiece(const Square(4, 0))?.type, equals(PieceType.king));
      expect(board.getPiece(const Square(4, 0))?.color, equals(PieceColor.white));
      
      // Check black pieces
      expect(board.getPiece(const Square(0, 7))?.type, equals(PieceType.rook));
      expect(board.getPiece(const Square(0, 7))?.color, equals(PieceColor.black));
      expect(board.getPiece(const Square(4, 7))?.type, equals(PieceType.king));
      expect(board.getPiece(const Square(4, 7))?.color, equals(PieceColor.black));
      
      // Check pawns
      expect(board.getPiece(const Square(0, 1))?.type, equals(PieceType.pawn));
      expect(board.getPiece(const Square(0, 1))?.color, equals(PieceColor.white));
      expect(board.getPiece(const Square(0, 6))?.type, equals(PieceType.pawn));
      expect(board.getPiece(const Square(0, 6))?.color, equals(PieceColor.black));
    });

    test('Find king', () {
      final board = Board.initial();
      
      final whiteKing = board.findKing(PieceColor.white);
      final blackKing = board.findKing(PieceColor.black);
      
      expect(whiteKing, equals(const Square(4, 0)));
      expect(blackKing, equals(const Square(4, 7)));
    });

    test('Board copy', () {
      final board = Board.initial();
      final copy = board.copy();
      
      expect(board.getPiece(const Square(0, 0)), equals(copy.getPiece(const Square(0, 0))));
      
      // Modify original
      board.setPiece(const Square(0, 0), null);
      
      // Copy should be unchanged
      expect(copy.getPiece(const Square(0, 0)), isNotNull);
    });
  });
}
