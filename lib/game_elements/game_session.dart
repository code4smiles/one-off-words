import 'game_mode.dart';

class GameSession {
  final GameMode mode;
  int puzzlesSolved = 0;
  Duration elapsed = Duration.zero;
  bool failed = false;

  GameSession({required this.mode});
}
