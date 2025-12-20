import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:oneoffwords/game_elements/puzzle.dart';
import 'package:oneoffwords/ui/game_app_bar.dart';
import 'package:oneoffwords/ui/game_tools.dart';
import 'package:oneoffwords/ui/history_section.dart';
import 'package:oneoffwords/ui/next_puzzle_button.dart';

import '../constants.dart';
import '../ui/game_options.dart';
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
  final _random = Random();
  int? _selectedTileIndex;
  int? _shakeTileIndex;
  String? _errorMessage;
  int? _hintTileIndex;
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _puzzleFuture = _loadPuzzle();
    _startTimer();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _startTimer() {
    _startTime = DateTime.now();
    _ticker = Ticker((_) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    })
      ..start();
  }

  void _resetTimer() {
    _startTime = DateTime.now();
    _elapsed = Duration.zero;
  }

  Future<Puzzle> _loadPuzzle({bool randomize = false}) async {
    final puzzlesJson =
        await rootBundle.loadString('assets/puzzles_4_easy.json');
    final puzzlesList = jsonDecode(puzzlesJson) as List<dynamic>;

    int index = randomize ? _random.nextInt(puzzlesList.length) : 0;
    final puzzleJson = puzzlesList[index]; // pick first for demo
    final puzzle = Puzzle.fromJson(puzzleJson);

    _userPath
      ..clear()
      ..add(puzzle.startWord);
    _selectedTileIndex = null;
    _shakeTileIndex = null;
    _errorMessage = null;
    _hintTileIndex = null;

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
    _ticker.stop();
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

  Color _distanceColor(Puzzle puzzle, int distance) {
    final maxDistance = puzzle.targetWord.length;
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

  int _distanceToTarget(Puzzle puzzle, String word) {
    final target = puzzle.targetWord;
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

    _resetTimer();
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

  Future<void> _startNewPuzzle() async {
    setState(() {
      _puzzleFuture = _loadPuzzle(randomize: true);
      _resetTimer();
    });
  }

  void _undoMove() {
    if (_userPath.length <= 1) return;

    setState(() {
      _userPath.removeLast();
      _selectedTileIndex = null;
      _shakeTileIndex = null;
      _errorMessage = null;
      _hintTileIndex = null;
    });
  }

  Widget _buildTimer() {
    final minutes = _elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, size: 16, color: Colors.black54),
        const SizedBox(width: 4),
        Text(
          '$minutes:$seconds',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            letterSpacing: 0.5,
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
          appBar: GameAppBar(
            userPath: _userPath,
            canReset: canReset,
            onReset: () => _resetPuzzle(puzzle),
            startNewPuzzle: _startNewPuzzle,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Label above the current word
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      child: const Text(
                        'Current Word',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    _buildTimer(),
                  ],
                ),

                const SizedBox(height: 4),

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

                GameTools(
                  userPath: _userPath,
                  undoMove: _undoMove,
                  showHint: () => _showHint(puzzle),
                ),

                const SizedBox(height: 16),

                // Letter picker (only visible when tile selected)
                LetterPicker(
                  puzzle: puzzle,
                  selectedTileIndex: _selectedTileIndex,
                  changeLetter: _changeLetter,
                ),

                // History ladder
                HistorySection(
                  guesses: _userPath,
                  puzzle: puzzle,
                  onReset: () => _confirmReset(puzzle),
                ),

                // Next puzzle button (only shown when puzzle is solved)
                if (_userPath.isNotEmpty && _userPath.last == puzzle.targetWord)
                  NextPuzzleButton(
                    startNewPuzzle: _startNewPuzzle,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
