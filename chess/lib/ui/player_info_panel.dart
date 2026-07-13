import 'package:flutter/material.dart';
import '../types/piece.dart';
import 'piece_widget.dart';

class PlayerInfoPanel extends StatelessWidget {
  final String name;
  final int rating;
  final String countryCode;
  final List<Piece> capturedPieces;
  final String timeRemaining;
  final bool isTop;

  const PlayerInfoPanel({
    super.key,
    required this.name,
    required this.rating,
    required this.countryCode,
    required this.capturedPieces,
    required this.timeRemaining,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '($rating)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Captured pieces
                Row(
                  children: [
                    ...capturedPieces.map((piece) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: PieceWidget(piece: piece, size: 20),
                          ),
                        )),
                    if (capturedPieces.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '+${capturedPieces.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              timeRemaining,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
