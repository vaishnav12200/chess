import 'package:flutter/material.dart';
import 'chess_game_screen.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int selectedTime = 10; // Default 10 minutes
  bool showPieceDirection = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Game Setup'),
        backgroundColor: Colors.brown[700],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Time selection
            const Text(
              'Select Time Control',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTimeButton(2, '2 min'),
                const SizedBox(width: 12),
                _buildTimeButton(5, '5 min'),
                const SizedBox(width: 12),
                _buildTimeButton(10, '10 min'),
              ],
            ),
            const SizedBox(height: 32),
            // Piece direction toggle
            const Text(
              'Piece Movement Direction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Show Direction Hints'),
              subtitle: const Text('Display legal move indicators'),
              value: showPieceDirection,
              onChanged: (value) {
                setState(() {
                  showPieceDirection = value;
                });
              },
              activeColor: Colors.brown[700],
            ),
            const Spacer(),
            // Play button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChessGameScreen(
                      timeControl: selectedTime,
                      showDirectionHints: showPieceDirection,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Play'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(int minutes, String label) {
    final isSelected = selectedTime == minutes;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedTime = minutes;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.brown[700] : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? Colors.brown[700]! : Colors.grey[300]!,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
