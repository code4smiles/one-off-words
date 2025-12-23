import 'package:flutter/material.dart';

class PuzzleControls extends StatelessWidget {
  final List<String> userPath;
  final VoidCallback undoMove;
  final VoidCallback showHint;

  const PuzzleControls(
      {super.key,
      required this.userPath,
      required this.undoMove,
      required this.showHint});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Undo button (left)
        TextButton.icon(
          onPressed: userPath.length > 1 ? undoMove : null,
          icon: const Icon(Icons.undo, size: 16),
          label: const Text("Undo"),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black54,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),

        TextButton.icon(
          onPressed: showHint,
          icon: const Icon(Icons.lightbulb_outline),
          label: const Text("Hint"),
        ),
      ],
    );
  }
}
