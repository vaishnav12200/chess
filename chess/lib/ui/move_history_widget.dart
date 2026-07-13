import 'package:flutter/material.dart';
import '../engine/game_state.dart';
import '../engine/move_executor.dart';
import '../types/move.dart';
import '../utils/move_notation.dart';

class MoveHistoryWidget extends StatelessWidget {
  final ChessGameState gameState;

  const MoveHistoryWidget({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    final moves = gameState.moveHistory;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Move History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (moves.isEmpty)
            const Text(
              'No moves yet',
              style: TextStyle(color: Colors.grey),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: (moves.length + 1) ~/ 2,
                itemBuilder: (context, index) {
                  final moveNumber = index + 1;
                  final whiteMove = moves[index * 2];
                  final blackMove = index * 2 + 1 < moves.length
                      ? moves[index * 2 + 1]
                      : null;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            '$moveNumber.',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            whiteMove != null
                                ? _getMoveNotation(gameState, whiteMove, index * 2)
                                : '',
                          ),
                        ),
                        Expanded(
                          child: Text(
                            blackMove != null
                                ? _getMoveNotation(gameState, blackMove, index * 2 + 1)
                                : '',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _getMoveNotation(ChessGameState state, Move move, int moveIndex) {
    // Reconstruct state before this move
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
