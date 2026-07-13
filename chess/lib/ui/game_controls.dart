import 'package:flutter/material.dart';

class GameControls extends StatelessWidget {
  final VoidCallback onNewGame;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onFlipBoard;
  final bool canUndo;
  final bool canRedo;

  const GameControls({
    super.key,
    required this.onNewGame,
    required this.onUndo,
    required this.onRedo,
    required this.onFlipBoard,
    this.canUndo = false,
    this.canRedo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton(
          icon: Icons.refresh,
          label: 'New Game',
          onPressed: onNewGame,
        ),
        _buildButton(
          icon: Icons.undo,
          label: 'Undo',
          onPressed: canUndo ? onUndo : null,
        ),
        _buildButton(
          icon: Icons.redo,
          label: 'Redo',
          onPressed: canRedo ? onRedo : null,
        ),
        _buildButton(
          icon: Icons.flip,
          label: 'Flip',
          onPressed: onFlipBoard,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: onPressed != null
                ? Colors.blue.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
