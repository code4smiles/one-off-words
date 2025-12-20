import 'package:flutter/material.dart';

import '../constants.dart';
import 'game_options.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> userPath;
  final bool canReset;
  final VoidCallback onReset;
  final VoidCallback startNewPuzzle;

  const GameAppBar({
    super.key,
    required this.userPath,
    required this.canReset,
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

          // Vertical divider
          Container(
            width: 1,
            height: 24,
            color: Colors.black26,
          ),
          const SizedBox(width: 12),

          // Animated move counter with fixed width
          SizedBox(
            width: 80, // fixed width enough for "999 moves"
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
              child: Text(
                '${userPath.length - 1} move${userPath.length - 1 == 1 ? '' : 's'}',
                key: ValueKey<int>(userPath.length - 1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      actions: [
        GameActionsButton(
          canReset: canReset,
          onReset: onReset,
          onNewPuzzle: startNewPuzzle,
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
