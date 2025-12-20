import 'package:flutter/material.dart';
import '../game_elements/puzzle.dart';

class HistoryTile extends StatelessWidget {
  final String word;
  final Heat heat;
  final int step;
  final String targetWord;
  final bool isDimmed;

  const HistoryTile({
    super.key,
    required this.word,
    required this.step,
    required this.targetWord,
    required this.heat,
    this.isDimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTarget = word == targetWord;
    final baseColor = heatToColor(heat);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isDimmed ? 0.45 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: baseColor.withOpacity(isTarget ? 0.35 : 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isTarget ? Colors.green.shade600 : Colors.black12,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // ─── FIXED-WIDTH STEP COLUMN ─────────────
            SizedBox(
              width: 48,
              child: Center(
                child: Text(
                  step == 0 ? "Start" : '$step',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
            ),

            // ─── WORD (PERFECTLY CENTERED) ──────────
            Expanded(
              child: Center(
                child: Text(
                  word.toUpperCase(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: isTarget ? FontWeight.w800 : FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // ─── FIXED-WIDTH BADGE COLUMN ───────────
            SizedBox(
              width: 72,
              child: isTarget
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(
                        width: 76, // small safety margin
                        child: isTarget
                            ? FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "SOLVED",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
