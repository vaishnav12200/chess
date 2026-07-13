import 'package:flutter/material.dart';
import '../types/piece.dart';
import '../types/piece_type.dart';
import '../types/piece_color.dart';

class PieceWidget extends StatelessWidget {
  final Piece piece;
  final double size;

  const PieceWidget({
    super.key,
    required this.piece,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          _getPieceSymbol(),
          style: TextStyle(
            fontSize: size * 0.8,
            fontFamily: 'Segoe UI Symbol',
            color: piece.color == PieceColor.white ? Colors.white : Colors.black,
            shadows: piece.color == PieceColor.white
                ? [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  String _getPieceSymbol() {
    switch (piece.type) {
      case PieceType.pawn:
        return piece.color == PieceColor.white ? '♙' : '♟';
      case PieceType.knight:
        return piece.color == PieceColor.white ? '♘' : '♞';
      case PieceType.bishop:
        return piece.color == PieceColor.white ? '♗' : '♝';
      case PieceType.rook:
        return piece.color == PieceColor.white ? '♖' : '♜';
      case PieceType.queen:
        return piece.color == PieceColor.white ? '♕' : '♛';
      case PieceType.king:
        return piece.color == PieceColor.white ? '♔' : '♚';
    }
  }
}
