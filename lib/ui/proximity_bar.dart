import 'package:flutter/material.dart';

class ProximityBar extends StatelessWidget {
  final int distance;
  final int maxDistance;
  final bool isFirstMove;

  const ProximityBar({
    super.key,
    required this.distance,
    required this.maxDistance,
    required this.isFirstMove,
  });

  double get _progress {
    if (maxDistance == 0) return 1.0;
    final p = 1 - (distance / maxDistance);
    return p.clamp(0.0, 1.0);
  }

  String get _baseLabel {
    // ✅ Explicit first-move instruction
    if (isFirstMove) return "Change a letter";

    if (_progress < 0.4) return "Keep going";
    if (_progress < 0.7) return "Getting closer";
    if (_progress < 1.0) return "Almost there";
    return "You got it!";
  }

  Color get _barColor => Color.lerp(Colors.red, Colors.green, _progress)!;

  @override
  Widget build(BuildContext context) {
    final isSolved = _progress >= 1.0;
    final labelWithLettersWrong = isSolved
        ? "All letters correct!"
        : "${_baseLabel} (${distance} letter${distance == 1 ? '' : 's'} wrong)";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            labelWithLettersWrong,
            key: ValueKey(labelWithLettersWrong),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.1,
              fontWeight: isSolved ? FontWeight.bold : FontWeight.w600,
              letterSpacing: 0.2,
              color: isSolved ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 6,
            width: 140,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: _progress),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(_barColor),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
