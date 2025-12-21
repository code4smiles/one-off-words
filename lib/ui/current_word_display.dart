import 'package:flutter/material.dart';
import 'package:oneoffwords/game_elements/game_mode.dart';
import 'package:oneoffwords/game_elements/puzzle_session.dart';
import 'package:oneoffwords/ui/tile_row.dart';

import '../game_elements/puzzle.dart';
import '../game_logic/game_logic.dart';
import 'game_clock.dart';

class CurrentWordDisplay extends StatelessWidget {
  final GlobalKey<GameClockState> gameClockKey;
  final PuzzleSession puzzleSession;
  final GameMode mode;
  final Puzzle puzzle;
  final void Function(int) onTap;

  const CurrentWordDisplay({
    super.key,
    required this.gameClockKey,
    required this.puzzleSession,
    required this.mode,
    required this.puzzle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),

        // Current editable word
        SizedBox(
          height: 150,
          child: TileRow(
              puzzle: puzzle,
              puzzleSession: puzzleSession,
              onTap: onTap,
              distanceToTarget: GameLogic.distanceToTarget,
              distanceColor: GameLogic.distanceColor),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: const Text(
                'Current Word',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            GameClock(
              key: gameClockKey,
              mode: mode,
              onTimeExpired: () {
                // Future: auto-fail dialog
              },
            ),
          ],
        ),
      ],
    );
  }
}
