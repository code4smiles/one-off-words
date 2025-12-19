import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oneoffwords/game_elements/puzzle.dart';
import 'package:oneoffwords/ui/shake_widget.dart';

import 'glow_widget.dart';

class TileRow extends StatelessWidget {
  List<String> userPath = [];
  int? selectedTileIndex;
  int? hintTileIndex;
  int? shakeTileIndex;
  String? errorMessage;
  Puzzle? puzzle;
  void Function()? onTap;
  int Function(String, String)? distanceToTarget;
  Color Function(int, String)? distanceColor;

  TileRow({
    super.key,
    required userPath,
    required selectedTileIndex,
    required hintTileIndex,
    required shakeTileIndex,
    required errorMessage,
    required puzzle,
    required onTap,
    required distanceToTarget,
    required distanceColor,
  });
  @override
  build(BuildContext context) {
    if (userPath.isEmpty) {
      print("GOT HERE");
      return const SizedBox.shrink();
    }
    final word = userPath.last;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── TILE ROW ─────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(word.length, (i) {
            final selected = selectedTileIndex == i;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: onTap,
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
                          glow: hintTileIndex == i,
                          child: ShakeWidget(
                            shake: shakeTileIndex == i,
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
                      if (shakeTileIndex == i && errorMessage != null)
                        Positioned(
                          top: 72,
                          left: 0,
                          right: 0,
                          child: Text(
                            errorMessage!,
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
        Text(
          'Distance: ${distanceToTarget!(word, puzzle!.targetWord)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: distanceColor!(
              distanceToTarget!(word, puzzle!.targetWord),
              puzzle!.targetWord,
            ),
          ),
        ),
      ],
    );
  }
}
