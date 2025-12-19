import 'package:flutter/material.dart';

import '../game_elements/puzzle.dart';

class HistoryTile extends StatelessWidget {
  final String word;
  final Heat heat;
  final int step;
  final String targetWord;

  const HistoryTile({
    super.key,
    required this.word,
    required this.step,
    required this.targetWord,
    this.heat = Heat.same,
  });

  @override
  Widget build(BuildContext context) {
    final color = heatToColor(heat);
    final isTarget = word == targetWord;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(isTarget ? 0.6 : 0.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (isTarget)
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
        border: Border.all(
          color: isTarget ? Colors.orange : Colors.black12,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Step number
          Text(
            '#$step',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),

          // Word
          Expanded(
            child: Center(
              child: Text(
                word.toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // Star if this is the target word
          if (isTarget)
            const Icon(
              Icons.star,
              color: Colors.orange,
            ),
        ],
      ),
    );
  }
}
