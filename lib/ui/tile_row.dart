import 'package:flutter/material.dart';
import 'package:oneoffwords/game_elements/puzzle.dart';
import 'package:oneoffwords/ui/proximity_bar.dart';
import 'package:oneoffwords/ui/shake_widget.dart';

import 'glow_widget.dart';

class TileRow extends StatefulWidget {
  List<String> userPath;
  int? selectedTileIndex;
  int? hintTileIndex;
  int? shakeTileIndex;
  String? errorMessage;
  Puzzle puzzle;
  void Function(int) onTap;
  int Function(String) distanceToTarget;
  Color Function(int) distanceColor;

  TileRow({
    super.key,
    required this.userPath,
    required this.selectedTileIndex,
    required this.hintTileIndex,
    required this.shakeTileIndex,
    required this.errorMessage,
    required this.puzzle,
    required this.onTap,
    required this.distanceToTarget,
    required this.distanceColor,
  });

  @override
  State<TileRow> createState() => TileRowState();
}

class TileRowState extends State<TileRow> {
  int _prevDistance = 0;

  @override
  void didUpdateWidget(TileRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldWord = oldWidget.userPath.last;
    final newWord = widget.userPath.last;

    if (oldWord != newWord) {
      _prevDistance = widget.distanceToTarget(oldWord);
    }
  }

  @override
  build(BuildContext context) {
    final word = widget.userPath.last;
    final currentDistance = widget.distanceToTarget(word);
    final currentColor = widget.distanceColor(currentDistance);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── TILE ROW ─────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(word.length, (i) {
            final selected = widget.selectedTileIndex == i;

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
                          glow: widget.hintTileIndex == i,
                          child: ShakeWidget(
                            shake: widget.shakeTileIndex == i,
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
                      if (widget.shakeTileIndex == i &&
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

        // ─── DISTANCE INDICATOR ────────────────────
        ProximityBar(
          distance: widget.distanceToTarget(word),
          maxDistance: word.length,
          isFirstMove: widget.userPath.length == 1,
        ),
      ],
    );
  }
}
