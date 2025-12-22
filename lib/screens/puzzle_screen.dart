import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oneoffwords/game_elements/puzzle.dart';
import 'package:oneoffwords/game_logic/game_logic.dart';
import 'package:oneoffwords/ui/current_word_display.dart';
import 'package:oneoffwords/ui/game_app_bar.dart';
import 'package:oneoffwords/ui/puzzle_controls.dart';
import 'package:oneoffwords/ui/history_section.dart';
import 'package:oneoffwords/ui/next_puzzle_button.dart';

import '../game_elements/game_mode.dart';
import '../game_elements/puzzle_session.dart';
import '../ui/game_clock.dart';
import '../ui/letter_picker.dart';
import '../ui/pre_start_countdown.dart';

class PuzzleScreen extends StatefulWidget {
  final GameMode mode;
  const PuzzleScreen({super.key, required this.mode});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  late Future<Puzzle> _puzzleFuture;
  final _random = Random();
  final _puzzleSession = PuzzleSession();
  final _gameClockKey = GlobalKey<GameClockState>();
  bool _showPreStart = false;

  @override
  void initState() {
    super.initState();
    _puzzleFuture = _loadPuzzle();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Puzzle> _loadPuzzle({bool randomize = false}) async {
    final puzzlesJson =
        await rootBundle.loadString('assets/puzzles_4_easy.json');
    final puzzlesList = jsonDecode(puzzlesJson) as List<dynamic>;

    int index = randomize ? _random.nextInt(puzzlesList.length) : 0;
    final puzzleJson = puzzlesList[index]; // pick first for demo
    final puzzle = Puzzle.fromJson(puzzleJson);

    if (widget.mode.usesPreStartCountdown) {
      _showPreStart = true;
    }

    _puzzleSession.userPath
      ..clear()
      ..add(puzzle.startWord);
    _puzzleSession.selectedTileIndex = null;
    _puzzleSession.shakeTileIndex = null;
    _puzzleSession.errorMessage = null;
    _puzzleSession.hintTileIndex = null;

    return puzzle;
  }

  void _startGameClockIfNeeded() {
    if (!widget.mode.usesClock) return;
    _gameClockKey.currentState?.start();
  }

  void _onCountdownComplete() {
    setState(() {
      _showPreStart = false;
    });
    _startGameClockIfNeeded();
  }

  void _onWin() {
    _gameClockKey.currentState?.stop();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("You got it! 🎉"),
        content: Text("Solved in ${_puzzleSession.userPath.length - 1} moves."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showHint(Puzzle puzzle) {
    final index = GameLogic.findHintTile(puzzle, _puzzleSession.userPath);
    if (index == null) return;

    setState(() {
      _puzzleSession.hintTileIndex = index;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _puzzleSession.hintTileIndex = null;
        });
      }
    });
  }

  void _checkForWin(String guess, Puzzle puzzle) {
    if (guess == puzzle.targetWord) {
      _onWin();
    }
  }

  void _changeLetter(Puzzle puzzle, int index, String newLetter) {
    if (_showPreStart) return;

    final prev = _puzzleSession.userPath.last;
    final chars = prev.split('');

    if (chars[index] == newLetter) return;

    chars[index] = newLetter;
    final guess = chars.join();

    bool alreadyUsed = _puzzleSession.userPath.contains(guess);
    bool invalidWord = !puzzle.distanceMap.containsKey(guess);

    // Invalid dictionary word or previously-used word
    if (invalidWord || alreadyUsed) {
      setState(() {
        _puzzleSession.shakeTileIndex = index;
        _puzzleSession.errorMessage =
            alreadyUsed ? "Word already used" : "That won't work";
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _puzzleSession.shakeTileIndex = null;
            _puzzleSession.errorMessage = null;
          });
        }
      });
      return;
    }

    setState(() {
      _puzzleSession.userPath.add(guess);
      _puzzleSession.shakeTileIndex = null;
      _puzzleSession.errorMessage = null;
    });

    _checkForWin(guess, puzzle);
  }

  void _setTileIndex(int index) {
    setState(() {
      if (_puzzleSession.selectedTileIndex == index) {
        // Toggle off
        _puzzleSession.selectedTileIndex = null;
      } else {
        _puzzleSession.selectedTileIndex = index;
      }
    });
  }

  void _resetPuzzle(Puzzle puzzle) {
    setState(() {
      _puzzleSession.userPath
        ..clear()
        ..add(puzzle.startWord);

      _puzzleSession.selectedTileIndex = null;
      _puzzleSession.shakeTileIndex = null;
      _puzzleSession.errorMessage = null;
      _puzzleSession.hintTileIndex = null;
      _gameClockKey.currentState?.reset();
      _gameClockKey.currentState?.start();
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

  Future<void> _startNewPuzzle() async {
    setState(() {
      _puzzleFuture = _loadPuzzle(randomize: true);
    });
    _gameClockKey.currentState?.reset();
  }

  void _undoMove() {
    if (_puzzleSession.userPath.length <= 1) return;

    setState(() {
      _puzzleSession.userPath.removeLast();
      _puzzleSession.shakeTileIndex = null;
      _puzzleSession.errorMessage = null;
      _puzzleSession.hintTileIndex = null;
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
        final canReset = _puzzleSession.userPath.length > 1;

        return Scaffold(
          appBar: GameAppBar(
            userPath: _puzzleSession.userPath,
            canReset: canReset,
            onReset: () => _resetPuzzle(puzzle),
            startNewPuzzle: _startNewPuzzle,
            ignoreInput: _showPreStart,
          ),
          body: Stack(
            children: [
              IgnorePointer(
                ignoring: _showPreStart,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      /// Current editable word
                      CurrentWordDisplay(
                        gameClockKey: _gameClockKey,
                        puzzleSession: _puzzleSession,
                        onTap: _setTileIndex,
                        puzzle: puzzle,
                        mode: widget.mode,
                      ),

                      const SizedBox(height: 12),

                      ///Undo and hint controls
                      PuzzleControls(
                        userPath: _puzzleSession.userPath,
                        undoMove: _undoMove,
                        showHint: () => _showHint(puzzle),
                      ),

                      const SizedBox(height: 16),

                      /// Letter picker
                      LetterPicker(
                        puzzle: puzzle,
                        puzzleSession: _puzzleSession,
                        changeLetter: _changeLetter,
                      ),

                      /// History ladder
                      HistorySection(
                        guesses: _puzzleSession.userPath,
                        puzzle: puzzle,
                        onReset: () => _confirmReset(puzzle),
                      ),

                      /// Next puzzle button (only shown when puzzle is solved)
                      if (_puzzleSession.userPath.isNotEmpty &&
                          _puzzleSession.userPath.last == puzzle.targetWord)
                        NextPuzzleButton(
                          startNewPuzzle: _startNewPuzzle,
                        ),
                    ],
                  ),
                ),
              ),
              if (_showPreStart)
                PreStartCountdown(
                  onComplete: _onCountdownComplete,
                ),
            ],
          ),
        );
      },
    );
  }
}
