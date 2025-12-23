import 'package:flutter/material.dart';
import 'package:oneoffwords/game_elements/puzzle_session.dart';

class MoveCounter extends StatelessWidget {
  final PuzzleSession puzzleSession;

  const MoveCounter({super.key, required this.puzzleSession});

  @override
  Widget build(BuildContext context) {
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
