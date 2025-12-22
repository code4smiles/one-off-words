import 'dart:ui';

import 'package:flutter/material.dart';

class GameActionsButton extends StatelessWidget {
  final bool canReset;
  final VoidCallback onReset;
  final VoidCallback onNewPuzzle;

  const GameActionsButton({
    super.key,
    required this.canReset,
    required this.onReset,
    required this.onNewPuzzle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      tooltip: "Game options",
      onPressed: () => _openGameOptions(context),
    );
  }

  void _openGameOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text("Restart current puzzle"),
                enabled: canReset,
                onTap: canReset
                    ? () {
                        Navigator.pop(sheetContext);
                        _confirmReset(context);
                      }
                    : null,
              ),
              ListTile(
                leading: const Icon(Icons.casino),
                title: const Text("New puzzle"),
                subtitle: const Text("Start with a new word"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmNewPuzzle(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Restart puzzle?"),
        content: const Text("Your current progress will be reset."),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Restart"),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              onReset();
            },
          ),
        ],
      ),
    );
  }

  void _confirmNewPuzzle(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("New Puzzle"),
          content: const Text(
            "Start a new puzzle? Your current progress will be lost.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext, rootNavigator: true).pop();
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                onNewPuzzle();
                Navigator.of(dialogContext, rootNavigator: true).pop();
              },
              child: const Text("New Puzzle"),
            ),
          ],
        );
      },
    );
  }
}
