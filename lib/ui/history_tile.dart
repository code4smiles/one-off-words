import 'package:flutter/material.dart';
import '../game_elements/puzzle.dart';

class HistoryTile extends StatelessWidget {
  final String word;
  final Heat heat;
  final int step;
  final String targetWord;
  final bool isDimmed;
  final bool isCurrent;

  const HistoryTile({
    super.key,
    required this.word,
    required this.step,
    required this.targetWord,
    required this.heat,
    this.isDimmed = false,
    this.isCurrent = false,
  });

  static const double _stepWidth = 48; // fixed width for step labels
  static const double _iconWidth = 32; // fixed width for optional check icon

  @override
  Widget build(BuildContext context) {
    final color = heatToColor(heat);
    final isTarget = word == targetWord;

    Widget tileContent = AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(isDimmed ? 0.3 : 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTarget ? Colors.orange : Colors.black12,
          width: isCurrent ? 2 : 1.5,
        ),
        boxShadow: [
          if (isTarget)
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          if (isCurrent && !isTarget)
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          // Fixed width step label
          SizedBox(
            width: _stepWidth,
            child: Text(
              step == 0 ? "Start" : "#$step",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Word (centered in remaining space)
          Expanded(
            child: Center(
              child: Text(
                word.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Fixed width container for target check
          SizedBox(
            width: _iconWidth,
            child: isTarget
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );

    // Wrap in pulsing animation if current and not target
    if (isCurrent) {
      return _PulseAnimation(
        shouldPulse: !isTarget,
        child: tileContent,
      );
    }

    return tileContent;
  }
}

class _PulseAnimation extends StatefulWidget {
  final Widget child;
  final bool shouldPulse;

  const _PulseAnimation({required this.child, this.shouldPulse = true});

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.shouldPulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.shouldPulse && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0; // reset to normal size
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
