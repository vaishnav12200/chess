import 'package:flutter/material.dart';
import '../types/square.dart';
import '../types/piece.dart';
import 'piece_widget.dart';

class SquareWidget extends StatelessWidget {
  final Square square;
  final Piece? piece;
  final bool isLight;
  final bool isSelected;
  final bool isLegalMove;
  final bool isLastMoveFrom;
  final bool isLastMoveTo;
  final bool isInCheck;
  final VoidCallback? onTap;

  const SquareWidget({
    super.key,
    required this.square,
    required this.piece,
    required this.isLight,
    this.isSelected = false,
    this.isLegalMove = false,
    this.isLastMoveFrom = false,
    this.isLastMoveTo = false,
    this.isInCheck = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = isLight
        ? const Color(0xFFF0D9B5)
        : const Color(0xFFB58863);

    // Highlight selected square
    if (isSelected) {
      backgroundColor = const Color(0xFFBACA44);
    }

    // Highlight last move
    if (isLastMoveFrom || isLastMoveTo) {
      backgroundColor = backgroundColor.withOpacity(0.8);
      if (isLight) {
        backgroundColor = const Color(0xFFF0F0F0);
      } else {
        backgroundColor = const Color(0xFFAAAAAA);
      }
    }

    // Highlight check
    if (isInCheck) {
      backgroundColor = const Color(0xFFFF6B6B);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            // Piece
            if (piece != null)
              Center(
                child: PieceWidget(piece: piece!),
              ),
            // Legal move indicator
            if (isLegalMove)
              Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: piece != null
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Coordinate labels (only on edge squares)
            if (square.file == 0)
              Positioned(
                top: 2,
                left: 2,
                child: Text(
                  '${square.rank + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isLight ? Colors.black54 : Colors.white54,
                  ),
                ),
              ),
            if (square.rank == 0)
              Positioned(
                bottom: 2,
                right: 2,
                child: Text(
                  String.fromCharCode(97 + square.file),
                  style: TextStyle(
                    fontSize: 10,
                    color: isLight ? Colors.black54 : Colors.white54,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
