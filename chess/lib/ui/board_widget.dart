import 'package:flutter/material.dart';
import '../engine/game_state.dart';
import '../rules/move_validator.dart';
import '../types/square.dart';
import '../types/move.dart';
import 'square_widget.dart';

class BoardWidget extends StatelessWidget {
  final ChessGameState gameState;
  final Square? selectedSquare;
  final List<Square> legalMoves;
  final Move? lastMove;
  final Function(Square) onSquareTap;
  final bool showDirectionHints;

  const BoardWidget({
    super.key,
    required this.gameState,
    required this.selectedSquare,
    required this.legalMoves,
    required this.lastMove,
    required this.onSquareTap,
    this.showDirectionHints = true,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemCount: 64,
          itemBuilder: (context, index) {
            final file = index % 8;
            final rank = 7 - (index ~/ 8);
            final square = Square(file, rank);
            final piece = gameState.board.getPiece(square);
            final isLight = (file + rank) % 2 == 0;
            final isSelected = selectedSquare == square;
            final isLegalMove = showDirectionHints ? legalMoves.contains(square) : false;
            final isLastMoveFrom = lastMove?.from == square;
            final isLastMoveTo = lastMove?.to == square;
            
            // Check if this square has the king in check
            final kingSquare = gameState.board.findKing(gameState.currentTurn);
            final isInCheck = kingSquare == square && 
                MoveValidator.isInCheck(gameState, gameState.currentTurn);

            return SquareWidget(
              square: square,
              piece: piece,
              isLight: isLight,
              isSelected: isSelected,
              isLegalMove: isLegalMove,
              isLastMoveFrom: isLastMoveFrom,
              isLastMoveTo: isLastMoveTo,
              isInCheck: isInCheck,
              onTap: () => onSquareTap(square),
            );
          },
        ),
      ),
    );
  }
}
