import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oneoffwords/game_elements/puzzle.dart';
import 'package:oneoffwords/game_logic/game_logic.dart';
import 'package:oneoffwords/ui/game_app_bar.dart';

import '../game_elements/game_mode.dart';
import '../game_elements/puzzle_session.dart';
import '../ui/game_clock.dart';
import '../ui/game_ui.dart';
import '../ui/win_dialog.dart';

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
  bool _showNextPuzzleButton = false;
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
    _puzzleSession.isCompleted = false;

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

  void _onTimeExpired(Puzzle puzzle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Time's up ⏰"),
        content: const Text("Give it another try?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetPuzzle(puzzle);
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  void _onWin() async {
    _gameClockKey.currentState?.stop();

    setState(() {
      _showNextPuzzleButton = false;
      _puzzleSession.isCompleted = true;
    });

    final result = await showDialog<WinDialogResult>(
      context: context,
      barrierDismissible: true, // important: tap outside = review
      builder: (_) => WinDialog(
        puzzleSession: _puzzleSession,
        gameClockKey: _gameClockKey,
      ),
    );

    // If user did NOT start a new puzzle, show the bottom button
    if (result != WinDialogResult.newPuzzle) {
      setState(() {
        _showNextPuzzleButton = true;
      });
    } else {
      _startNewPuzzle();
    }
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

  bool _checkForWin(String guess, Puzzle puzzle) {
    if (guess == puzzle.targetWord) {
      _onWin();
      return true;
    }
    return false;
  }

  void _onDeadEnd(Puzzle puzzle) {
    _gameClockKey.currentState?.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("No more moves 😕"),
        content: const Text(
          "You've reached a dead end. There are no valid moves left from here.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _undoMove();
              _gameClockKey.currentState?.start();
            },
            child: const Text("Undo"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmReset(puzzle);
            },
            child: const Text("Restart"),
          ),
        ],
      ),
    );
  }

  void _changeLetter(Puzzle puzzle, int index, String newLetter) {
    if (_showPreStart) return;
    if (_puzzleSession.isCompleted) return;

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

    if (_checkForWin(guess, puzzle)) return;

    //Check for dead end.
    if (!GameLogic.hasAnyValidNextMove(
      puzzle,
      _puzzleSession.userPath,
    )) {
      _onDeadEnd(puzzle);
    }
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
            body: GameUI(
              puzzleSession: _puzzleSession,
              puzzle: puzzle,
              mode: widget.mode,
              gameClockKey: _gameClockKey,
              showPreStart: _showPreStart,
              startNewPuzzle: _startNewPuzzle,
              changeLetter: _changeLetter,
              undoMove: _undoMove,
              showHint: _showHint,
              onTimeExpired: _onTimeExpired,
              onCountdownComplete: _onCountdownComplete,
              setTileIndex: _setTileIndex,
              showNextPuzzleButton: _showNextPuzzleButton,
              confirmReset: _confirmReset,
            ));
      },
    );
  }
}
