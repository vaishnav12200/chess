class Square {
  final int file;
  final int rank;

  const Square(this.file, this.rank);

  static const int boardSize = 8;

  bool get isValid => file >= 0 && file < boardSize && rank >= 0 && rank < boardSize;

  String get notation {
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    return '${files[file]}${rank + 1}';
  }

  static Square? fromNotation(String notation) {
    if (notation.length != 2) return null;
    
    final files = {'a': 0, 'b': 1, 'c': 2, 'd': 3, 'e': 4, 'f': 5, 'g': 6, 'h': 7};
    final fileChar = notation[0].toLowerCase();
    final rankChar = notation[1];
    
    if (!files.containsKey(fileChar)) return null;
    final rank = int.tryParse(rankChar);
    if (rank == null || rank < 1 || rank > 8) return null;
    
    return Square(files[fileChar]!, rank - 1);
  }

  Square operator +(Square other) {
    return Square(file + other.file, rank + other.rank);
  }

  Square operator -(Square other) {
    return Square(file - other.file, rank - other.rank);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Square && other.file == file && other.rank == rank;
  }

  @override
  int get hashCode => file * 8 + rank;

  @override
  String toString() => notation;
}
