enum PieceColor {
  white,
  black;

  PieceColor get opposite => this == white ? black : white;
}
