import 'package:flutter/material.dart';

import '../game_elements/puzzle.dart';

class PuzzleActionBar extends StatelessWidget {
  final List<String> userPath;
  final Puzzle puzzle;
  final VoidCallback undoMove;
  final VoidCallback showHint;
  final Function(Puzzle) restartPuzzle;

  const PuzzleActionBar({
    super.key,
    required this.userPath,
    required this.puzzle,
    required this.undoMove,
    required this.showHint,
    required this.restartPuzzle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          ActionIcon(
            icon: Icons.restart_alt,
            label: "Restart",
            onTap: () => restartPuzzle(puzzle),
          ),
          TextButton.icon(
            onPressed: userPath.length > 1 ? undoMove : null,
            icon: const Icon(Icons.undo, size: 16),
            label: const Text("Undo"),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black54,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          TextButton.icon(
            onPressed: showHint,
            icon: const Icon(Icons.lightbulb_outline, size: 16),
            label: const Text("Hint"),
          ),
        ],
      ),
    );
  }
}

class ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const ActionIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.black54 : Colors.black26;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}
