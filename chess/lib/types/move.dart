import '../types/square.dart';
import '../types/piece_type.dart';

enum MoveType {
  normal,
  capture,
  enPassant,
  castlingKingside,
  castlingQueenside,
  promotion,
  doublePawn,
}

class Move {
  final Square from;
  final Square to;
  final MoveType type;
  final PieceType? promotionPiece;

  const Move({
    required this.from,
    required this.to,
    this.type = MoveType.normal,
    this.promotionPiece,
  });

  Move copyWith({
    Square? from,
    Square? to,
    MoveType? type,
    PieceType? promotionPiece,
  }) {
    return Move(
      from: from ?? this.from,
      to: to ?? this.to,
      type: type ?? this.type,
      promotionPiece: promotionPiece ?? this.promotionPiece,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Move &&
        other.from == from &&
        other.to == to &&
        other.type == type &&
        other.promotionPiece == promotionPiece;
  }

  @override
  int get hashCode => from.hashCode ^ to.hashCode ^ type.hashCode ^ promotionPiece.hashCode;

  @override
  String toString() => '$from->$to (${type.name})';
}
