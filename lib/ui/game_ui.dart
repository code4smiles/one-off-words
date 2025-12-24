import 'package:flutter/material.dart';
import 'package:oneoffwords/game_elements/puzzle_session.dart';
import 'package:oneoffwords/ui/game_navigation.dart';
import 'package:oneoffwords/ui/pre_start_countdown.dart';

import '../game_elements/game_mode.dart';
import '../game_elements/puzzle.dart';
import 'current_word_display.dart';
import 'game_clock.dart';
import 'game_status.dart';
import 'letter_picker.dart';

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
  final Function(Puzzle) confirmReset;
  final bool showNextPuzzleButton;

  const GameUI({
    super.key,
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
    required this.setTileIndex,
    required this.confirmReset,
    required this.showNextPuzzleButton,
  });

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
                        Opacity(
                          opacity: puzzleSession.isCompleted ? 0.6 : 1.0,
                          child: CurrentWordDisplay(
                            puzzleSession: puzzleSession,
                            onTap: setTileIndex,
                            puzzle: puzzle,
                            mode: mode,
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// Letter picker
                        LetterPicker(
                          puzzle: puzzle,
                          puzzleSession: puzzleSession,
                          changeLetter: changeLetter,
                        ),

                        const SizedBox(height: 16),

                        /// Game status (clock + moves)
                        GameStatus(
                          gameClockKey: gameClockKey,
                          mode: mode,
                          puzzle: puzzle,
                          puzzleSession: puzzleSession,
                          onTimeExpired: () => onTimeExpired(puzzle),
                          undoMove: undoMove,
                          showHint: showHint,
                          restartPuzzle: confirmReset,
                        ),
                        const Spacer(),
                        GameNavigation(
                          startNewPuzzle: startNewPuzzle,
                          goToHomeScreenConfirmed: () {
                            Navigator.pop(context); // go back to HomeScreen
                          },
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
