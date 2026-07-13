import 'package:flutter/material.dart';
import '../types/piece.dart';
import '../types/piece_type.dart';
import '../types/piece_color.dart';

class PieceWidget extends StatelessWidget {
  final Piece piece;
  final double size;

  const PieceWidget({super.key, required this.piece, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PiecePainter(piece),
    );
  }
}

class _PiecePainter extends CustomPainter {
  final Piece piece;
  _PiecePainter(this.piece);

  bool get isWhite => piece.color == PieceColor.white;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = isWhite ? const Color(0xFFF0D9B5) : const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = isWhite ? const Color(0xFF8B6914) : const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04;

    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);

    switch (piece.type) {
      case PieceType.pawn:
        _drawPawn(canvas, fill, outline);
        break;
      case PieceType.rook:
        _drawRook(canvas, fill, outline);
        break;
      case PieceType.knight:
        _drawKnight(canvas, fill, outline);
        break;
      case PieceType.bishop:
        _drawBishop(canvas, fill, outline);
        break;
      case PieceType.queen:
        _drawQueen(canvas, fill, outline);
        break;
      case PieceType.king:
        _drawKing(canvas, fill, outline);
        break;
    }

    canvas.restore();
  }

  void _drawPawn(Canvas canvas, Paint fill, Paint outline) {
    // Base
    final basePath = Path()
      ..moveTo(28, 88)
      ..lineTo(72, 88)
      ..quadraticBezierTo(76, 88, 76, 82)
      ..lineTo(74, 76)
      ..lineTo(26, 76)
      ..lineTo(24, 82)
      ..quadraticBezierTo(24, 88, 28, 88)
      ..close();
    canvas.drawPath(basePath, fill);
    canvas.drawPath(basePath, outline);

    // Stem
    final stemPath = Path()
      ..moveTo(38, 76)
      ..lineTo(36, 62)
      ..lineTo(64, 62)
      ..lineTo(62, 76)
      ..close();
    canvas.drawPath(stemPath, fill);
    canvas.drawPath(stemPath, outline);

    // Head
    canvas.drawCircle(const Offset(50, 46), 18, fill);
    canvas.drawCircle(const Offset(50, 46), 18, outline);
  }

  void _drawRook(Canvas canvas, Paint fill, Paint outline) {
    // Body
    final body = RRect.fromRectAndRadius(
        const Rect.fromLTWH(22, 50, 56, 38), const Radius.circular(4));
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, outline);

    // Battlements
    for (final x in [22.0, 38.0, 54.0]) {
      final merlon = Rect.fromLTWH(x, 30, 14, 22);
      canvas.drawRect(merlon, fill);
      canvas.drawRect(merlon, outline);
    }

    // Base
    final base = RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 84, 64, 8), const Radius.circular(3));
    canvas.drawRRect(base, fill);
    canvas.drawRRect(base, outline);
  }

  void _drawKnight(Canvas canvas, Paint fill, Paint outline) {
    final path = Path()
      ..moveTo(30, 88)
      ..lineTo(70, 88)
      ..lineTo(70, 78)
      ..lineTo(62, 78)
      ..lineTo(72, 58)
      ..quadraticBezierTo(78, 44, 68, 32)
      ..quadraticBezierTo(60, 20, 44, 22)
      ..quadraticBezierTo(30, 24, 26, 36)
      ..quadraticBezierTo(20, 48, 30, 56)
      ..lineTo(28, 78)
      ..lineTo(30, 78)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, outline);

    // Eye
    final eyeFill = Paint()
      ..color = isWhite ? const Color(0xFF8B6914) : const Color(0xFFF0D9B5);
    canvas.drawCircle(const Offset(54, 38), 4, eyeFill);
  }

  void _drawBishop(Canvas canvas, Paint fill, Paint outline) {
    // Base
    final base = RRect.fromRectAndRadius(
        const Rect.fromLTWH(22, 80, 56, 10), const Radius.circular(4));
    canvas.drawRRect(base, fill);
    canvas.drawRRect(base, outline);

    // Body
    final body = Path()
      ..moveTo(34, 80)
      ..quadraticBezierTo(28, 64, 32, 50)
      ..quadraticBezierTo(36, 38, 50, 30)
      ..quadraticBezierTo(64, 38, 68, 50)
      ..quadraticBezierTo(72, 64, 66, 80)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, outline);

    // Head ball
    canvas.drawCircle(const Offset(50, 24), 10, fill);
    canvas.drawCircle(const Offset(50, 24), 10, outline);

    // Cross tip
    final crossV = Paint()
      ..color = outline.color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(50, 14), const Offset(50, 34), crossV);
    canvas.drawLine(const Offset(42, 22), const Offset(58, 22), crossV);
  }

  void _drawQueen(Canvas canvas, Paint fill, Paint outline) {
    // Base
    final base = RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 80, 64, 10), const Radius.circular(4));
    canvas.drawRRect(base, fill);
    canvas.drawRRect(base, outline);

    // Body
    final body = Path()
      ..moveTo(26, 80)
      ..lineTo(22, 52)
      ..lineTo(36, 62)
      ..lineTo(50, 30)
      ..lineTo(64, 62)
      ..lineTo(78, 52)
      ..lineTo(74, 80)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, outline);

    // Crown balls
    for (final pos in [
      const Offset(22, 50),
      const Offset(36, 60),
      const Offset(50, 28),
      const Offset(64, 60),
      const Offset(78, 50),
    ]) {
      canvas.drawCircle(pos, 6, fill);
      canvas.drawCircle(pos, 6, outline);
    }
  }

  void _drawKing(Canvas canvas, Paint fill, Paint outline) {
    // Base
    final base = RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 80, 64, 10), const Radius.circular(4));
    canvas.drawRRect(base, fill);
    canvas.drawRRect(base, outline);

    // Body
    final body = Path()
      ..moveTo(26, 80)
      ..lineTo(24, 52)
      ..lineTo(38, 58)
      ..lineTo(42, 44)
      ..lineTo(58, 44)
      ..lineTo(62, 58)
      ..lineTo(76, 52)
      ..lineTo(74, 80)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, outline);

    // Cross
    final crossPaint = Paint()
      ..color = outline.color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(50, 20), const Offset(50, 44), crossPaint);
    canvas.drawLine(const Offset(40, 30), const Offset(60, 30), crossPaint);
  }

  @override
  bool shouldRepaint(_PiecePainter old) => old.piece != piece;
}
