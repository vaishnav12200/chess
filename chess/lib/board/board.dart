import '../types/piece.dart';
import '../types/piece_color.dart';
import '../types/piece_type.dart';
import '../types/square.dart';

class Board {
  final List<List<Piece?>> _squares;

  Board() : _squares = List.generate(8, (_) => List.filled(8, null));

  Board.fromList(List<List<Piece?>> squares) : _squares = squares;

  Board copy() {
    return Board.fromList(
      List.generate(8, (file) => List.generate(8, (rank) => _squares[file][rank])),
    );
  }

  Piece? getPiece(Square square) {
    if (!square.isValid) return null;
    return _squares[square.file][square.rank];
  }

  void setPiece(Square square, Piece? piece) {
    if (!square.isValid) return;
    _squares[square.file][square.rank] = piece;
  }

  void movePiece(Square from, Square to) {
    final piece = getPiece(from);
    setPiece(from, null);
    setPiece(to, piece);
  }

  void clear() {
    for (var file = 0; file < 8; file++) {
      for (var rank = 0; rank < 8; rank++) {
        _squares[file][rank] = null;
      }
    }
  }

  static Board initial() {
    final board = Board();
    
    // Place pawns
    for (var file = 0; file < 8; file++) {
      board.setPiece(Square(file, 1), Piece(type: PieceType.pawn, color: PieceColor.white));
      board.setPiece(Square(file, 6), Piece(type: PieceType.pawn, color: PieceColor.black));
    }
    
    // Place rooks
    board.setPiece(const Square(0, 0), Piece(type: PieceType.rook, color: PieceColor.white));
    board.setPiece(const Square(7, 0), Piece(type: PieceType.rook, color: PieceColor.white));
    board.setPiece(const Square(0, 7), Piece(type: PieceType.rook, color: PieceColor.black));
    board.setPiece(const Square(7, 7), Piece(type: PieceType.rook, color: PieceColor.black));
    
    // Place knights
    board.setPiece(const Square(1, 0), Piece(type: PieceType.knight, color: PieceColor.white));
    board.setPiece(const Square(6, 0), Piece(type: PieceType.knight, color: PieceColor.white));
    board.setPiece(const Square(1, 7), Piece(type: PieceType.knight, color: PieceColor.black));
    board.setPiece(const Square(6, 7), Piece(type: PieceType.knight, color: PieceColor.black));
    
    // Place bishops
    board.setPiece(const Square(2, 0), Piece(type: PieceType.bishop, color: PieceColor.white));
    board.setPiece(const Square(5, 0), Piece(type: PieceType.bishop, color: PieceColor.white));
    board.setPiece(const Square(2, 7), Piece(type: PieceType.bishop, color: PieceColor.black));
    board.setPiece(const Square(5, 7), Piece(type: PieceType.bishop, color: PieceColor.black));
    
    // Place queens
    board.setPiece(const Square(3, 0), Piece(type: PieceType.queen, color: PieceColor.white));
    board.setPiece(const Square(3, 7), Piece(type: PieceType.queen, color: PieceColor.black));
    
    // Place kings
    board.setPiece(const Square(4, 0), Piece(type: PieceType.king, color: PieceColor.white));
    board.setPiece(const Square(4, 7), Piece(type: PieceType.king, color: PieceColor.black));
    
    return board;
  }

  List<Piece> getPieces(PieceColor color) {
    final pieces = <Piece>[];
    for (var file = 0; file < 8; file++) {
      for (var rank = 0; rank < 8; rank++) {
        final piece = _squares[file][rank];
        if (piece != null && piece.color == color) {
          pieces.add(piece);
        }
      }
    }
    return pieces;
  }

  Square? findKing(PieceColor color) {
    for (var file = 0; file < 8; file++) {
      for (var rank = 0; rank < 8; rank++) {
        final piece = _squares[file][rank];
        if (piece != null && piece.type == PieceType.king && piece.color == color) {
          return Square(file, rank);
        }
      }
    }
    return null;
  }

  bool isEmpty(Square square) {
    return getPiece(square) == null;
  }

  bool isOccupied(Square square) {
    return !isEmpty(square);
  }

  bool isOccupiedBy(Square square, PieceColor color) {
    final piece = getPiece(square);
    return piece != null && piece.color == color;
  }

  bool isOccupiedByOpponent(Square square, PieceColor color) {
    final piece = getPiece(square);
    return piece != null && piece.color != color;
  }
}
