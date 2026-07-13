import 'package:flutter/material.dart';
import '../engine/game_state.dart';
import '../engine/move_executor.dart';
import '../types/move.dart';
import '../utils/move_notation.dart';

class HorizontalMoveHistory extends StatelessWidget {
  final ChessGameState gameState;

  const HorizontalMoveHistory({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    final moves = gameState.moveHistory;

    return Container(
      height: 50,
      color: Colors.grey[50],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: (moves.length + 1) ~/ 2,
        itemBuilder: (context, index) {
          final moveNumber = index + 1;
          final whiteMove = moves[index * 2];
          final blackMove = index * 2 + 1 < moves.length
              ? moves[index * 2 + 1]
              : null;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Text(
                  '$moveNumber.',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  whiteMove != null
                      ? _getMoveNotation(gameState, whiteMove, index * 2)
                      : '',
                  style: const TextStyle(fontSize: 12),
                ),
                if (blackMove != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    _getMoveNotation(gameState, blackMove, index * 2 + 1),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _getMoveNotation(ChessGameState state, Move move, int moveIndex) {
    var reconstructedState = ChessGameState.initial();
    for (var i = 0; i < moveIndex; i++) {
      reconstructedState = MoveExecutor.executeMove(
        reconstructedState,
        state.moveHistory[i],
      );
    }
    return MoveNotation.toNotation(reconstructedState, move);
  }
}
