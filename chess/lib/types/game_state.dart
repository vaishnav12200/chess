enum GameStatus {
  inProgress,
  checkmate,
  stalemate,
  drawByInsufficientMaterial,
  drawByFiftyMoveRule,
  drawByThreefoldRepetition,
}

class GameState {
  final GameStatus status;
  final String? winner;

  const GameState({
    required this.status,
    this.winner,
  });

  bool get isGameOver => status != GameStatus.inProgress;
  bool get isDraw => status == GameStatus.stalemate ||
      status == GameStatus.drawByInsufficientMaterial ||
      status == GameStatus.drawByFiftyMoveRule ||
      status == GameStatus.drawByThreefoldRepetition;
}
