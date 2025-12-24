class PuzzleSession {
  final List<String> userPath = [];
  int? selectedTileIndex;
  int? shakeTileIndex;
  int? hintTileIndex;
  String? errorMessage;
  bool isCompleted = false;

  void reset(String startWord) {
    userPath
      ..clear()
      ..add(startWord);
    selectedTileIndex = null;
    shakeTileIndex = null;
    hintTileIndex = null;
    errorMessage = null;
    isCompleted = false;
  }
}
