import 'package:flutter/material.dart';

class GameNavigation extends StatelessWidget {
  final VoidCallback startNewPuzzle;
  final VoidCallback goToHomeScreenConfirmed;

  const GameNavigation({
    super.key,
    required this.startNewPuzzle,
    required this.goToHomeScreenConfirmed,
  });

  Future<void> _confirmGoHome(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Leave puzzle?",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          "Your current progress will be lost.",
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _DialogActionButton(
                icon: Icons.close,
                label: "Cancel",
                color: Colors.grey.shade400,
                onTap: () => Navigator.pop(context, false),
              ),
              _DialogActionButton(
                icon: Icons.home_outlined,
                label: "Leave",
                color: Colors.teal,
                onTap: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm == true) {
      goToHomeScreenConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ActionIcon(
          icon: Icons.home_outlined,
          label: "Home",
          onTap: () => _confirmGoHome(context), // use its own context
        ),
        const SizedBox(width: 30),
        ActionIcon(
          icon: Icons.casino,
          label: "New Puzzle",
          onTap: startNewPuzzle,
        ),
      ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DialogActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16), // less rounded, more rectangular
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
