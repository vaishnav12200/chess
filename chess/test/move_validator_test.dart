import 'package:flutter_test/flutter_test.dart';
import 'package:chess/engine/game_state.dart';
import 'package:chess/rules/move_validator.dart';
import 'package:chess/types/piece_color.dart';

void main() {
  group('Move Validator Tests', () {
    test('Initial position has legal moves', () {
      final state = ChessGameState.initial();
      final moves = MoveValidator.getLegalMoves(state);
      
      expect(moves.length, greaterThan(0));
    });

    test('White to move initially', () {
      final state = ChessGameState.initial();
      expect(state.currentTurn, equals(PieceColor.white));
    });

    test('Cannot move opponent pieces', () {
      final state = ChessGameState.initial();
      final moves = MoveValidator.getLegalMoves(state);
      
      // All moves should be for white pieces
      for (final move in moves) {
        final piece = state.board.getPiece(move.from);
        expect(piece?.color, equals(PieceColor.white));
      }
    });

    test('Check detection', () {
      final state = ChessGameState.initial();
      expect(MoveValidator.isInCheck(state, PieceColor.white), isFalse);
      expect(MoveValidator.isInCheck(state, PieceColor.black), isFalse);
    });
  });
}
