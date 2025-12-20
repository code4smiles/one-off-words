import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oneoffwords/game_elements/puzzle.dart';
import 'package:oneoffwords/ui/history_section.dart';

import '../constants.dart';
import '../ui/history_tile.dart';
import '../ui/letter_picker.dart';
import '../ui/tile_row.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  late Future<Puzzle> _puzzleFuture;
  final List<String> _userPath = [];
  String? _puzzleTargetWord;
  int? _selectedTileIndex;
  int? _shakeTileIndex;
  String? _errorMessage;
  int? _hintTileIndex;

  @override
  void initState() {
    super.initState();
    _puzzleFuture = _loadPuzzle();
    _puzzleFuture.then((p) {
      _puzzleTargetWord = p.targetWord;
    });
  }

  Future<Puzzle> _loadPuzzle() async {
    final puzzlesJson =
        await rootBundle.loadString('assets/puzzles_4_easy.json');
    final puzzlesList = jsonDecode(puzzlesJson) as List<dynamic>;
    final puzzleJson = puzzlesList[0]; // pick first for demo
    final puzzle = Puzzle.fromJson(puzzleJson);
    _userPath.add(puzzle.startWord);
    return puzzle;
  }

  bool isOneLetterDifferent(String a, String b) {
    if (a.length != b.length) return false;
    int diff = 0;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) diff++;
      if (diff > 1) return false;
    }
    return diff == 1;
  }

  void _onWin() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("You got it! 🎉"),
        content: Text("Solved in ${_userPath.length - 1} moves."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  int? _findHintTile(Puzzle puzzle) {
    final word = _userPath.last;
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
            !_userPath.contains(candidate)) {
          chars[i] = original;
          return i;
        }
      }

      chars[i] = original;
    }

    return null;
  }

  void _showHint(Puzzle puzzle) {
    final index = _findHintTile(puzzle);
    if (index == null) return;

    setState(() {
      _hintTileIndex = index;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _hintTileIndex = null;
        });
      }
    });
  }

  void _changeLetter(Puzzle puzzle, int index, String newLetter) {
    final prev = _userPath.last;
    final chars = prev.split('');

    if (chars[index] == newLetter) return;

    chars[index] = newLetter;
    final guess = chars.join();

    // Invalid dictionary word
    if (!puzzle.distanceMap.containsKey(guess)) {
      setState(() {
        _shakeTileIndex = index;
        _errorMessage = "Not a valid word";
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _shakeTileIndex = null;
            _errorMessage = null;
          });
        }
      });
      return;
    }

    if (_userPath.contains(guess)) return;

    setState(() {
      _userPath.add(guess);
      _selectedTileIndex = null;
      _shakeTileIndex = null;
      _errorMessage = null;
    });

    if (guess == puzzle.targetWord) {
      _onWin();
    }
  }

  Heat _computeHeat(Puzzle puzzle, String prev, String curr) {
    final heatStr = puzzle.heatMap[prev]?[curr] ?? 'same';
    switch (heatStr) {
      case 'muchWarmer':
        return Heat.muchWarmer;
      case 'warmer':
        return Heat.warmer;
      case 'colder':
        return Heat.colder;
      case 'muchColder':
        return Heat.muchColder;
      default:
        return Heat.same;
    }
  }

  Color _distanceColor(int distance) {
    if (_puzzleTargetWord == null) return Colors.grey;
    final maxDistance = _puzzleTargetWord!.length;
    final t = (distance / maxDistance).clamp(0.0, 1.0);
    return Color.lerp(Colors.green, Colors.red, t)!;
  }

  int _computeEditDistance(String word1, String word2) {
    assert(word1.length == word2.length,
        'Hamming distance requires equal-length words');

    int distance = 0;
    for (int i = 0; i < word1.length; i++) {
      if (word1[i] != word2[i]) distance++;
    }
    return distance;
  }

  int _distanceToTarget(String word) {
    final target = _puzzleTargetWord;
    if (target == null) return 0;
    return _computeEditDistance(word, target);
  }

  void _setTileIndex(int index) {
    setState(() {
      _selectedTileIndex = index;
    });
  }

  void _resetPuzzle(Puzzle puzzle) {
    setState(() {
      _userPath
        ..clear()
        ..add(puzzle.startWord);

      _selectedTileIndex = null;
      _shakeTileIndex = null;
      _errorMessage = null;
      _hintTileIndex = null;
    });
  }

  void _confirmReset(Puzzle puzzle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset puzzle?"),
        content: const Text(
          "Your current progress will be lost.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetPuzzle(puzzle);
            },
            child: const Text(
              "Reset",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Puzzle>(
      future: _puzzleFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final puzzle = snapshot.data!;
        final tiles = <Widget>[];

        // Build history ladder
        for (int i = 0; i < _userPath.length; i++) {
          final word = _userPath[i];
          Heat heat = Heat.same;

          if (i > 0) {
            final prev = _userPath[i - 1];
            heat = _computeHeat(puzzle, prev, word);
          }

          tiles.add(
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: heatToColor(heat).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Center(
                child: Text(
                  word.toUpperCase(),
                  style: const TextStyle(
                    height: 1.0,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }

        final canReset = _userPath.length > 1;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game title
                Text(
                  appName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),

                // Vertical divider
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.black26,
                ),
                const SizedBox(width: 12),

                // Animated move counter with fixed width
                SizedBox(
                  width: 80, // fixed width enough for "999 moves"
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Text(
                      '${_userPath.length - 1} move${_userPath.length - 1 == 1 ? '' : 's'}',
                      key: ValueKey<int>(_userPath.length - 1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: canReset
                    ? "Restart puzzle"
                    : "You can restart the puzzle after making a move",
                icon: const Icon(Icons.refresh),
                onPressed: canReset ? () => _confirmReset(puzzle) : null,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: Colors.black12,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Current editable word
                SizedBox(
                  height: 150,
                  child: TileRow(
                      userPath: _userPath,
                      selectedTileIndex: _selectedTileIndex,
                      hintTileIndex: _hintTileIndex,
                      shakeTileIndex: _shakeTileIndex,
                      errorMessage: _errorMessage,
                      puzzle: puzzle,
                      onTap: _setTileIndex,
                      distanceToTarget: _distanceToTarget,
                      distanceColor: _distanceColor),
                ),

                const SizedBox(height: 12),

                // Letter picker (only visible when tile selected)
                LetterPicker(
                  puzzle: puzzle,
                  selectedTileIndex: _selectedTileIndex,
                  changeLetter: _changeLetter,
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showHint(puzzle),
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text("Hint"),
                    ),
                  ],
                ),

                // History ladder
                HistorySection(
                  guesses: _userPath,
                  puzzle: puzzle,
                  onReset: () => _confirmReset(puzzle),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
