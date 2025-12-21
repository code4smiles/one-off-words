class PuzzleSession {
  final List<String> userPath = [];
  int? selectedTileIndex;
  int? shakeTileIndex;
  int? hintTileIndex;
  String? errorMessage;

  void reset(String startWord) {
    userPath
      ..clear()
      ..add(startWord);
    selectedTileIndex = null;
    shakeTileIndex = null;
    hintTileIndex = null;
    errorMessage = null;
  }
}
