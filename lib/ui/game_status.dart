import 'package:flutter/material.dart';
import 'package:oneoffwords/game_elements/puzzle_session.dart';
import 'package:oneoffwords/ui/move_counter.dart';

import '../game_elements/game_mode.dart';
import '../game_elements/puzzle.dart';
import 'game_clock.dart';
import 'history_section.dart';

class GameStatus extends StatelessWidget {
  final GlobalKey<GameClockState> gameClockKey;
  final GameMode mode;
  final Puzzle puzzle;
  final PuzzleSession puzzleSession;
  final VoidCallback? onTimeExpired;

  const GameStatus({
    super.key,
    required this.gameClockKey,
    required this.mode,
    required this.puzzle,
    required this.puzzleSession,
    required this.onTimeExpired,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ///Game Clock
              GameClock(
                key: gameClockKey,
                mode: mode,
                initialDuration: const Duration(minutes: 2),
                onTimeExpired: onTimeExpired,
              ),

              /// Move counter
              MoveCounter(
                puzzleSession: puzzleSession,
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Subtle divider
          Container(
            height: 1,
            color: Colors.black.withOpacity(0.08),
          ),

          const SizedBox(height: 12),

          /// Recent guesses / history
          HistorySection(
            guesses: puzzleSession.userPath,
            puzzle: puzzle,
          ),
        ],
      ),
    );
  }
}
