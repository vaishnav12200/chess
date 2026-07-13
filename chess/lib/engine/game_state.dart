import '../board/board.dart';
import '../types/piece.dart';
import '../types/piece_color.dart';
import '../types/square.dart';
import '../types/move.dart';
import '../types/game_state.dart';

class CastlingRights {
  final bool whiteKingside;
  final bool whiteQueenside;
  final bool blackKingside;
  final bool blackQueenside;

  const CastlingRights({
    this.whiteKingside = true,
    this.whiteQueenside = true,
    this.blackKingside = true,
    this.blackQueenside = true,
  });

  CastlingRights copyWith({
    bool? whiteKingside,
    bool? whiteQueenside,
    bool? blackKingside,
    bool? blackQueenside,
  }) {
    return CastlingRights(
      whiteKingside: whiteKingside ?? this.whiteKingside,
      whiteQueenside: whiteQueenside ?? this.whiteQueenside,
      blackKingside: blackKingside ?? this.blackKingside,
      blackQueenside: blackQueenside ?? this.blackQueenside,
    );
  }

  bool canCastleKingside(PieceColor color) {
    return color == PieceColor.white ? whiteKingside : blackKingside;
  }

  bool canCastleQueenside(PieceColor color) {
    return color == PieceColor.white ? whiteQueenside : blackQueenside;
  }
}

class ChessGameState {
  final Board board;
  final PieceColor currentTurn;
  final CastlingRights castlingRights;
  final Square? enPassantSquare;
  final int halfMoveClock;
  final int fullMoveNumber;
  final List<Move> moveHistory;
  final List<Piece> capturedPieces;
  final GameState gameStatus;

  const ChessGameState({
    required this.board,
    required this.currentTurn,
    required this.castlingRights,
    this.enPassantSquare,
    this.halfMoveClock = 0,
    this.fullMoveNumber = 1,
    this.moveHistory = const [],
    this.capturedPieces = const [],
    this.gameStatus = const GameState(status: GameStatus.inProgress),
  });

  ChessGameState.initial()
      : board = Board.initial(),
        currentTurn = PieceColor.white,
        castlingRights = const CastlingRights(),
        enPassantSquare = null,
        halfMoveClock = 0,
        fullMoveNumber = 1,
        moveHistory = const [],
        capturedPieces = const [],
        gameStatus = const GameState(status: GameStatus.inProgress);

  ChessGameState copyWith({
    Board? board,
    PieceColor? currentTurn,
    CastlingRights? castlingRights,
    Square? enPassantSquare,
    int? halfMoveClock,
    int? fullMoveNumber,
    List<Move>? moveHistory,
    List<Piece>? capturedPieces,
    GameState? gameStatus,
  }) {
    return ChessGameState(
      board: board ?? this.board,
      currentTurn: currentTurn ?? this.currentTurn,
      castlingRights: castlingRights ?? this.castlingRights,
      enPassantSquare: enPassantSquare ?? this.enPassantSquare,
      halfMoveClock: halfMoveClock ?? this.halfMoveClock,
      fullMoveNumber: fullMoveNumber ?? this.fullMoveNumber,
      moveHistory: moveHistory ?? this.moveHistory,
      capturedPieces: capturedPieces ?? this.capturedPieces,
      gameStatus: gameStatus ?? this.gameStatus,
    );
  }

  PieceColor get opponent => currentTurn.opposite;
}
