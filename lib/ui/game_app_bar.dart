import 'package:flutter/material.dart';

import '../constants.dart';
import 'game_options.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> userPath;
  final bool canReset;
  final bool ignoreInput;
  final VoidCallback onReset;
  final VoidCallback startNewPuzzle;

  const GameAppBar({
    super.key,
    required this.userPath,
    required this.canReset,
    required this.ignoreInput,
    required this.onReset,
    required this.startNewPuzzle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Game title
          Text(
            appName.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      actions: [
        IgnorePointer(
          ignoring: ignoreInput,
          child: GameActionsButton(
            canReset: canReset,
            onReset: onReset,
            onNewPuzzle: startNewPuzzle,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.black12,
        ),
      ),
    );
  }
}
