import 'package:flutter/material.dart';
import 'package:oneoffwords/game_elements/puzzle.dart';
import 'package:oneoffwords/ui/proximity_bar.dart';
import 'package:oneoffwords/ui/shake_widget.dart';

import '../game_elements/puzzle_session.dart';
import 'glow_widget.dart';

class TileRow extends StatefulWidget {
  final PuzzleSession puzzleSession;
  String? errorMessage;
  Puzzle puzzle;
  void Function(int) onTap;
  int Function(Puzzle, String) distanceToTarget;
  Color Function(Puzzle, int) distanceColor;

  TileRow({
    super.key,
    required this.puzzle,
    required this.puzzleSession,
    required this.onTap,
    required this.distanceToTarget,
    required this.distanceColor,
  });

  @override
  State<TileRow> createState() => TileRowState();
}

class TileRowState extends State<TileRow> {
  @override
  build(BuildContext context) {
    final word = widget.puzzleSession.userPath.last;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(word.length, (i) {
            final selected = widget.puzzleSession.selectedTileIndex == i;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () {
                  widget.onTap(i);
                },
                child: SizedBox(
                  width: 64,
                  height: 108,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 0,
                        child: GlowWidget(
                          glow: widget.puzzleSession.hintTileIndex == i,
                          child: ShakeWidget(
                            shake: widget.puzzleSession.shakeTileIndex == i,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.orange.shade200
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      selected ? Colors.orange : Colors.black26,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  word[i].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.puzzleSession.shakeTileIndex == i &&
                          widget.errorMessage != null)
                        Positioned(
                          top: 72,
                          left: 0,
                          right: 0,
                          child: Text(
                            widget.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        ProximityBar(
          distance: widget.distanceToTarget(widget.puzzle, word),
          maxDistance: word.length,
          isFirstMove: widget.puzzleSession.userPath.length == 1,
        ),
      ],
    );
  }
}
