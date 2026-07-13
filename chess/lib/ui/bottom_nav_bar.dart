import 'package:flutter/material.dart';

class ChessBottomNavBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onForward;
  final bool canGoBack;
  final bool canGoForward;

  const ChessBottomNavBar({
    super.key,
    required this.onBack,
    required this.onForward,
    this.canGoBack = false,
    this.canGoForward = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavItem(
            icon: Icons.arrow_back,
            label: 'Undo',
            onTap: canGoBack ? onBack : null,
          ),
          const SizedBox(width: 32),
          _buildNavItem(
            icon: Icons.arrow_forward,
            label: 'Redo',
            onTap: canGoForward ? onForward : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: onTap != null ? Colors.black87 : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: onTap != null ? Colors.black87 : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
