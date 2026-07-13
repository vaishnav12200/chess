import 'piece_color.dart';
import 'piece_type.dart';

class Piece {
  final PieceType type;
  final PieceColor color;
  final bool hasMoved;

  const Piece({
    required this.type,
    required this.color,
    this.hasMoved = false,
  });

  Piece copyWith({PieceType? type, PieceColor? color, bool? hasMoved}) {
    return Piece(
      type: type ?? this.type,
      color: color ?? this.color,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }

  Piece withMoved() {
    return copyWith(hasMoved: true);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Piece &&
        other.type == type &&
        other.color == color &&
        other.hasMoved == hasMoved;
  }

  @override
  int get hashCode => type.hashCode ^ color.hashCode ^ hasMoved.hashCode;

  @override
  String toString() {
    final symbol = _getSymbol();
    return color == PieceColor.white ? symbol.toUpperCase() : symbol.toLowerCase();
  }

  String _getSymbol() {
    switch (type) {
      case PieceType.pawn:
        return 'p';
      case PieceType.knight:
        return 'n';
      case PieceType.bishop:
        return 'b';
      case PieceType.rook:
        return 'r';
      case PieceType.queen:
        return 'q';
      case PieceType.king:
        return 'k';
    }
  }
}
