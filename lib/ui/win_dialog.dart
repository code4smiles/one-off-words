import 'package:flutter/material.dart';
import 'package:oneoffwords/game_elements/puzzle_session.dart';
import 'package:oneoffwords/ui/win_action_button.dart';

enum WinDialogResult {
  review,
  newPuzzle,
}

class WinDialog extends StatelessWidget {
  final PuzzleSession puzzleSession;

  const WinDialog({
    super.key,
    required this.puzzleSession,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        "You got it! 🎉",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          Text(
            "${puzzleSession.userPath.length - 1}",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "moves",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "What would you like to do next?",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            WinActionButton(
              icon: Icons.history,
              label: "Review",
              color: Colors.blueGrey.shade600,
              onTap: () {
                Navigator.pop(context, WinDialogResult.review);
              },
            ),
            WinActionButton(
              icon: Icons.casino,
              label: "New Puzzle",
              color: Colors.teal,
              onTap: () {
                Navigator.pop(context, WinDialogResult.newPuzzle);
              },
            ),
          ],
        ),
      ],
    );
  }
}
