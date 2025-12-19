import 'package:flutter/material.dart';

import '../game_elements/puzzle.dart';

class LetterPicker extends StatelessWidget {
  int? selectedTileIndex;
  final Puzzle puzzle;
  final Function changeLetter;

  LetterPicker(
      {super.key,
      required this.selectedTileIndex,
      required this.puzzle,
      required this.changeLetter});

  @override
  Widget build(BuildContext context) {
    if (selectedTileIndex == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(26, (i) {
        final letter = String.fromCharCode(97 + i);

        return GestureDetector(
          onTap: () => changeLetter(puzzle, selectedTileIndex!, letter),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              letter.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLetterPicker(Puzzle puzzle) {
    if (selectedTileIndex == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(26, (i) {
        final letter = String.fromCharCode(97 + i);

        return GestureDetector(
          onTap: () => changeLetter(puzzle, selectedTileIndex!, letter),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              letter.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }
}
