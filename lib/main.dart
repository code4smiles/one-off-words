import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oneoffwords/ui/glow_widget.dart';
import 'package:oneoffwords/ui/letter_picker.dart';
import 'package:oneoffwords/ui/shake_widget.dart';
// import 'package:oneoffwords/screens/puzzle_screen.dart';
import 'constants.dart';
import 'game_elements/puzzle.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  late Future<Puzzle> _puzzleFuture;
  final List<String> _userPath = [];
  String? _puzzleTargetWord;
  String _currentInput = '';
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
    final normalized = distance / maxDistance; // 0 = correct, 1 = farthest
    return Color.lerp(Colors.green, Colors.red, normalized)!;
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
    if (_puzzleFuture == null) return 0; // safety
    final target = _puzzleTargetWord; // store target once Future resolves
    return _computeEditDistance(word, target!);
  }

  Widget _buildTileRow(Puzzle puzzle) {
    final word = _userPath.last;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── TILE ROW ─────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(word.length, (i) {
            final selected = _selectedTileIndex == i;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTileIndex = i;
                  });
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
                          glow: _hintTileIndex == i,
                          child: ShakeWidget(
                            shake: _shakeTileIndex == i,
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
                      if (_shakeTileIndex == i && _errorMessage != null)
                        Positioned(
                          top: 72,
                          left: 0,
                          right: 0,
                          child: Text(
                            _errorMessage!,
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
          'Distance: ${_distanceToTarget(word)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _distanceColor(_distanceToTarget(word)),
          ),
        ),
      ],
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Almost a Word')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Current editable word
                _buildTileRow(puzzle),

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
                Expanded(
                  child: ListView(
                    children: tiles,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void main() {
  runApp(const OneOffWordsApp());
}

class OneOffWordsApp extends StatelessWidget {
  const OneOffWordsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const PuzzleScreen(),
    );
  }
}
