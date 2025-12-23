import 'package:flutter/material.dart';
import 'package:oneoffwords/game_elements/game_mode.dart';
import 'package:oneoffwords/game_elements/puzzle_session.dart';
import 'package:oneoffwords/ui/tile_row.dart';

import '../game_elements/puzzle.dart';
import '../game_logic/game_logic.dart';

class CurrentWordDisplay extends StatelessWidget {
  final PuzzleSession puzzleSession;
  final GameMode mode;
  final Puzzle puzzle;
  final void Function(int) onTap;

  const CurrentWordDisplay({
    super.key,
    required this.puzzleSession,
    required this.mode,
    required this.puzzle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),

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
            ],
          ),
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
        ],
      ),
    );
  }
}
