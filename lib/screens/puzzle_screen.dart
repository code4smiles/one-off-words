import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../constants.dart';
import '../game_elements/puzzle.dart';
import '../ui/tile_row.dart';
import '../ui/letter_picker.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen>
    with SingleTickerProviderStateMixin {
  late Future<Puzzle> _puzzleFuture;
  final List<String> _userPath = [];

  int? _selectedTileIndex;
  int? _shakeTileIndex;
  int? _hintTileIndex;
  String? _errorMessage;

  late AnimationController _winController;

  @override
  void initState() {
    super.initState();
    _puzzleFuture = _loadPuzzle();

    _winController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  Future<Puzzle> _loadPuzzle() async {
    final jsonStr = await rootBundle.loadString('assets/puzzles_4_easy.json');
    final list = jsonDecode(jsonStr) as List<dynamic>;
    final puzzle = Puzzle.fromJson(list.first);
    _userPath.add(puzzle.startWord);
    return puzzle;
  }

  void _changeLetter(Puzzle puzzle, int index, String letter) {
    final prev = _userPath.last;
    final chars = prev.split('');

    if (chars[index] == letter) return;

    chars[index] = letter;
    final guess = chars.join();

    if (!puzzle.distanceMap.containsKey(guess)) {
      setState(() {
        _shakeTileIndex = index;
        _errorMessage = 'Not a valid word';
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
    });

    if (guess == puzzle.targetWord) {
      _winController.forward(from: 0);
      _onWin();
    }
  }

  void _onWin() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('You got it! 🎉'),
        content: Text('Solved in ${_userPath.length - 1} moves.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  int _computeEditDistance(String a, String b) {
    int d = 0;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) d++;
    }
    return d;
  }

  Color _distanceColor(int distance, String target) {
    final t = distance / target.length;
    return Color.lerp(Colors.green, Colors.red, t)!;
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

    setState(() => _hintTileIndex = index);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _hintTileIndex = null);
      }
    });
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

        return Scaffold(
          appBar: AppBar(title: const Text(appName)),
          body: Column(
            children: [
              // Editable word row and letter picker
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_userPath.isNotEmpty)
                      TileRow(
                        puzzle: puzzle,
                        userPath: _userPath,
                        selectedTileIndex: _selectedTileIndex,
                        shakeTileIndex: _shakeTileIndex,
                        hintTileIndex: _hintTileIndex,
                        errorMessage: _errorMessage,
                        onTap: (i) {
                          setState(() {
                            _selectedTileIndex = i;
                          });
                        },
                        distanceToTarget: (w, t) => _computeEditDistance(w, t),
                        distanceColor: _distanceColor,
                      ),
                    const SizedBox(height: 12),
                    if (_selectedTileIndex != null)
                      LetterPicker(
                        selectedTileIndex: _selectedTileIndex,
                        puzzle: puzzle,
                        changeLetter: _changeLetter,
                      ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _showHint(puzzle),
                        icon: const Icon(Icons.lightbulb_outline),
                        label: const Text('Hint'),
                      ),
                    ),
                  ],
                ),
              ),

              // History ladder
              if (_userPath.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _userPath.length,
                    itemBuilder: (context, index) {
                      final word = _userPath[index];
                      Heat heat = Heat.same;
                      if (index > 0) {
                        heat = _computeHeat(puzzle, _userPath[index - 1], word);
                      }
                      return Container(
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
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
