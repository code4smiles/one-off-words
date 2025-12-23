import 'package:flutter/material.dart';
import 'package:oneoffwords/game_elements/puzzle_session.dart';
import 'package:oneoffwords/ui/pre_start_countdown.dart';
import 'package:oneoffwords/ui/puzzle_controls.dart';

import '../game_elements/game_mode.dart';
import '../game_elements/puzzle.dart';
import 'current_word_display.dart';
import 'game_clock.dart';
import 'game_status.dart';
import 'letter_picker.dart';
import 'next_puzzle_button.dart';

class GameUI extends StatelessWidget {
  final PuzzleSession puzzleSession;
  final Puzzle puzzle;
  final GameMode mode;
  final GlobalKey<GameClockState> gameClockKey;
  final bool showPreStart;
  final VoidCallback startNewPuzzle;
  final Function(Puzzle, int, String) changeLetter;
  final VoidCallback undoMove;
  final Function(Puzzle) showHint;
  final Function(int) setTileIndex;
  final Function(Puzzle) onTimeExpired;
  final VoidCallback onCountdownComplete;

  const GameUI(
      {super.key,
      required this.puzzleSession,
      required this.puzzle,
      required this.mode,
      required this.gameClockKey,
      required this.showPreStart,
      required this.startNewPuzzle,
      required this.changeLetter,
      required this.undoMove,
      required this.showHint,
      required this.onTimeExpired,
      required this.onCountdownComplete,
      required this.setTileIndex});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: showPreStart,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                        child: Column(
                      children: [
                        /// Current editable word
                        CurrentWordDisplay(
                          puzzleSession: puzzleSession,
                          onTap: setTileIndex,
                          puzzle: puzzle,
                          mode: mode,
                        ),

                        const SizedBox(height: 12),

                        /// Letter picker
                        LetterPicker(
                          puzzle: puzzle,
                          puzzleSession: puzzleSession,
                          changeLetter: changeLetter,
                        ),

                        ///Undo and hint controls
                        PuzzleControls(
                          userPath: puzzleSession.userPath,
                          undoMove: undoMove,
                          showHint: () => showHint(puzzle),
                        ),

                        const SizedBox(height: 16),

                        /// Game status (clock + moves)
                        GameStatus(
                          gameClockKey: gameClockKey,
                          mode: mode,
                          puzzle: puzzle,
                          puzzleSession: puzzleSession,
                          onTimeExpired: () => onTimeExpired(puzzle),
                        ),

                        /// Next puzzle button (only shown when puzzle is solved)
                        if (puzzleSession.userPath.isNotEmpty &&
                            puzzleSession.userPath.last == puzzle.targetWord)
                          NextPuzzleButton(
                            startNewPuzzle: startNewPuzzle,
                          ),
                      ],
                    )),
                  ),
                );
              },
            ),
          ),
        ),
        if (showPreStart)
          PreStartCountdown(
            onComplete: onCountdownComplete,
          ),
      ],
    );
  }
}
