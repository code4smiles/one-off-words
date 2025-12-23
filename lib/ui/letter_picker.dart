import 'package:flutter/material.dart';
import 'package:oneoffwords/game_elements/puzzle_session.dart';

import '../game_elements/puzzle.dart';

class LetterPicker extends StatelessWidget {
  final Puzzle puzzle;
  final PuzzleSession puzzleSession;
  final Function changeLetter;

  const LetterPicker(
      {super.key,
      required this.puzzle,
      required this.puzzleSession,
      required this.changeLetter});

  @override
  Widget build(BuildContext context) {
    if (puzzleSession.selectedTileIndex == null) return const SizedBox.shrink();

    final String currentWord = puzzleSession.userPath.last;
    final List<String> chars = currentWord.split('');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: List.generate(26, (i) {
          final letter = String.fromCharCode(97 + i);

          chars[puzzleSession.selectedTileIndex!] = letter;
          final candidate = chars.join();

          final isSame =
              currentWord[puzzleSession.selectedTileIndex!] == letter;
          final isUsed = puzzleSession.userPath.contains(candidate);

          Color background;
          Color textColor;

          if (isSame) {
            background = Colors.grey.shade300;
            textColor = Colors.grey;
          } else if (isUsed) {
            background = Colors.grey.shade200;
            textColor = Colors.grey.shade500;
          } else {
            background = Colors.grey.shade200;
            textColor = Colors.black;
          }

          return GestureDetector(
            onTap: () =>
                changeLetter(puzzle, puzzleSession.selectedTileIndex!, letter),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background, //Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                letter.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          );
        }),
      ),
    );
  }
}
