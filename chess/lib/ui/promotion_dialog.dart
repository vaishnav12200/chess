import 'package:flutter/material.dart';
import '../types/piece_type.dart';
import '../types/piece_color.dart';
import 'piece_widget.dart';

class PromotionDialog extends StatelessWidget {
  const PromotionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Promote Pawn'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Choose a piece:'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: PieceType.values
                .where((type) => type != PieceType.pawn && type != PieceType.king)
                .map((type) => _PromotionOption(
                      pieceType: type,
                      onTap: () => Navigator.of(context).pop(type),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PromotionOption extends StatelessWidget {
  final PieceType pieceType;
  final VoidCallback onTap;

  const _PromotionOption({
    required this.pieceType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: PieceWidget(
          piece: Piece(type: pieceType, color: PieceColor.white),
          size: 48,
        ),
      ),
    );
  }
}
