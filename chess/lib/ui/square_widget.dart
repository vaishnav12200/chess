import 'package:flutter/material.dart';
import '../types/square.dart';
import '../types/piece.dart';
import 'piece_widget.dart';

class SquareWidget extends StatefulWidget {
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
  State<SquareWidget> createState() => _SquareWidgetState();
}

class _SquareWidgetState extends State<SquareWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(SquareWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.piece != widget.piece && widget.piece != null) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = widget.isLight
        ? const Color(0xFFF0D9B5)
        : const Color(0xFFB58863);

    // Highlight selected square
    if (widget.isSelected) {
      backgroundColor = const Color(0xFFBACA44);
    }

    // Highlight last move
    if (widget.isLastMoveFrom || widget.isLastMoveTo) {
      backgroundColor = backgroundColor.withOpacity(0.8);
      if (widget.isLight) {
        backgroundColor = const Color(0xFFF0F0F0);
      } else {
        backgroundColor = const Color(0xFFAAAAAA);
      }
    }

    // Highlight check
    if (widget.isInCheck) {
      backgroundColor = const Color(0xFFFF6B6B);
    }

    return GestureDetector(
      onTap: widget.onTap,
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
            if (widget.piece != null)
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: PieceWidget(piece: widget.piece!),
                ),
              ),
            // Legal move indicator
            if (widget.isLegalMove)
              Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: widget.piece != null
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Coordinate labels (only on edge squares)
            if (widget.square.file == 0)
              Positioned(
                top: 2,
                left: 2,
                child: Text(
                  '${widget.square.rank + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.isLight ? Colors.black54 : Colors.white54,
                  ),
                ),
              ),
            if (widget.square.rank == 0)
              Positioned(
                bottom: 2,
                right: 2,
                child: Text(
                  String.fromCharCode(97 + widget.square.file),
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.isLight ? Colors.black54 : Colors.white54,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
