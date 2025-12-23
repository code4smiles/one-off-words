import 'dart:ui';

import 'package:flutter/material.dart';

import '../game_elements/puzzle.dart';

class GameLogic {
  static int? findHintTile(Puzzle puzzle, List<String> userPath) {
    final word = userPath.last;
    final chars = word.split('');
    final currentDist = puzzle.distanceMap[word]!;

    for (int i = 0; i < chars.length; i++) {
      final original = chars[i];

      for (int c = 0; c < 26; c++) {
        final letter = String.fromCharCode(97 + c);
        if (letter == original) continue;

        chars[i] = letter;
        final candidate = chars.join();

        if (puzzle.distanceMap.containsKey(candidate) &&
            puzzle.distanceMap[candidate]! < currentDist &&
            !userPath.contains(candidate)) {
          chars[i] = original;
          return i;
        }
      }

      chars[i] = original;
    }
    return null;
  }

  static Color distanceColor(Puzzle puzzle, int distance) {
    final maxDistance = puzzle.targetWord.length;
    final t = (distance / maxDistance).clamp(0.0, 1.0);
    return Color.lerp(Colors.green, Colors.red, t)!;
  }

  static int computeEditDistance(String word1, String word2) {
    assert(word1.length == word2.length,
        'Hamming distance requires equal-length words');

    int distance = 0;
    for (int i = 0; i < word1.length; i++) {
      if (word1[i] != word2[i]) distance++;
    }
    return distance;
  }

  static int distanceToTarget(Puzzle puzzle, String word) {
    final target = puzzle.targetWord;
    return computeEditDistance(word, target);
  }

  static bool hasAnyValidNextMove(
    Puzzle puzzle,
    List<String> userPath,
  ) {
    final current = userPath.last;
    final chars = current.split('');

    for (int i = 0; i < chars.length; i++) {
      final original = chars[i];

      for (int c = 0; c < 26; c++) {
        final letter = String.fromCharCode(97 + c);
        if (letter == original) continue;

        chars[i] = letter;
        final guess = chars.join();

        if (puzzle.distanceMap.containsKey(guess) &&
            !userPath.contains(guess)) {
          return true;
        }
      }

      chars[i] = original;
    }

    return false;
  }
}
