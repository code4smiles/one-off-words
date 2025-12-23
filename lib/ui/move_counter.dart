import 'package:flutter/material.dart';
import 'package:oneoffwords/game_elements/puzzle_session.dart';

import '../game_elements/game_mode.dart';

class MoveCounter extends StatelessWidget {
  final PuzzleSession puzzleSession;
  final GameMode gameMode;

  const MoveCounter(
      {super.key, required this.puzzleSession, required this.gameMode});

  @override
  Widget build(BuildContext context) {
    //Don't show the clock and the moves counter together.
    if (gameMode.usesClock) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: 80, // fixed width enough for "999 moves"
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
        child: Text(
          '${puzzleSession.userPath.length - 1} move${puzzleSession.userPath.length - 1 == 1 ? '' : 's'}',
          key: ValueKey<int>(puzzleSession.userPath.length - 1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.orange,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
