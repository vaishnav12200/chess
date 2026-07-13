import 'package:flutter/material.dart';

class ChessBottomNavBar extends StatelessWidget {
  final VoidCallback onOptions;
  final VoidCallback onChat;
  final VoidCallback onAnalyze;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final bool canGoBack;
  final bool canGoForward;

  const ChessBottomNavBar({
    super.key,
    required this.onOptions,
    required this.onChat,
    required this.onAnalyze,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.settings,
            label: 'Options',
            onTap: onOptions,
          ),
          _buildNavItem(
            icon: Icons.chat_bubble_outline,
            label: 'Chat',
            onTap: onChat,
          ),
          _buildNavItem(
            icon: Icons.analytics,
            label: 'Analyze',
            onTap: onAnalyze,
          ),
          _buildNavItem(
            icon: Icons.arrow_back,
            label: 'Back',
            onTap: canGoBack ? onBack : null,
          ),
          _buildNavItem(
            icon: Icons.arrow_forward,
            label: 'Forward',
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: onTap != null ? Colors.black87 : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: onTap != null ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
