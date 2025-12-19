import 'package:flutter/material.dart';

class GlowWidget extends StatefulWidget {
  final Widget child;
  final bool glow;

  const GlowWidget({
    super.key,
    required this.child,
    required this.glow,
  });

  @override
  State<GlowWidget> createState() => _GlowWidgetState();
}

class _GlowWidgetState extends State<GlowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant GlowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.glow) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final intensity = widget.glow ? _controller.value : 0.0;
        return Container(
          decoration: BoxDecoration(
            boxShadow: intensity > 0
                ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.6 * intensity),
                      blurRadius: 12 + 12 * intensity,
                      spreadRadius: 2 + 4 * intensity,
                    )
                  ]
                : [],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
