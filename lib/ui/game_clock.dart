import 'dart:async';
import 'package:flutter/material.dart';
import '../game_elements/game_mode.dart';

class GameClock extends StatefulWidget {
  final GameMode mode;
  final Duration initialDuration;
  final VoidCallback? onTimeExpired;

  const GameClock({
    super.key,
    required this.mode,
    this.initialDuration = const Duration(minutes: 2),
    this.onTimeExpired,
  });

  @override
  GameClockState createState() => GameClockState();
}

class GameClockState extends State<GameClock>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  Timer? _timer;

  Duration _elapsed = Duration.zero;
  late Duration _remaining;
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  bool _isRunning = false;
  bool _expired = false;

  bool get _shouldPulse =>
      widget.mode.isCountdown &&
      _remaining.inSeconds > 0 &&
      _remaining.inSeconds <= 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.mode.isCountdown) {
      _remaining = widget.mode.timeLimit!;
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void start() {
    if (_isRunning || !widget.mode.usesClock) return;

    _isRunning = true;
    _expired = false;
    _startTimer();
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
  }

  void reset() {
    stop();
    setState(() {
      _elapsed = Duration.zero;
      _remaining = widget.initialDuration;
      _expired = false;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        widget.mode.isCountdown
            ? _tickCountdown()
            : _elapsed += const Duration(seconds: 1);
      });
    });
  }

  void _tickCountdown() {
    if (_remaining == null) return;

    _remaining = _remaining - const Duration(seconds: 1);

    if (_shouldPulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!_shouldPulse && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }

    if (_remaining.isNegative || _remaining == Duration.zero) {
      _remaining = Duration.zero;
      stop();
      _pulseController.stop();
      _pulseController.reset();
      widget.onTimeExpired?.call();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed && _isRunning) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.mode.usesClock) {
      return const SizedBox.shrink();
    }

    final display = widget.mode.isCountdown ? _remaining : _elapsed;

    final minutes = display.inMinutes.toString().padLeft(2, '0');
    final seconds = (display.inSeconds % 60).toString().padLeft(2, '0');

    final isUrgent = _shouldPulse;

    final color = isUrgent ? Colors.redAccent : Colors.black54;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.mode.isCountdown
                ? Icons.hourglass_bottom
                : Icons.timer_outlined,
            size: 16,
            color: widget.mode.isCountdown &&
                    _remaining <= const Duration(seconds: 10)
                ? Colors.redAccent
                : Colors.black54,
          ),
          const SizedBox(width: 4),
          Text(
            '$minutes:$seconds',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
