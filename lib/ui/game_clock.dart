import 'dart:async';
import 'package:flutter/material.dart';
import '../game_elements/game_mode.dart';

class GameClock extends StatefulWidget {
  final GameMode mode;
  final VoidCallback? onTimeExpired;

  const GameClock({
    super.key,
    required this.mode,
    this.onTimeExpired,
  });

  @override
  GameClockState createState() => GameClockState();
}

class GameClockState extends State<GameClock> with WidgetsBindingObserver {
  Timer? _timer;

  Duration _elapsed = Duration.zero;
  Duration? _remaining;

  bool _isRunning = false;

  // ─────────────────────────────────────────────
  // Public getters
  // ─────────────────────────────────────────────

  Duration get elapsed => _elapsed;
  Duration? get remaining => _remaining;

  // ─────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.mode.isCountdown) {
      _remaining = widget.mode.timeLimit;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // App lifecycle handling
  // ─────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pause();
    } else if (state == AppLifecycleState.resumed) {
      _resume();
    }
  }

  // ─────────────────────────────────────────────
  // Public controls
  // ─────────────────────────────────────────────

  void start() {
    if (_isRunning || !widget.mode.usesClock) return;
    _isRunning = true;
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
      _remaining = widget.mode.isCountdown ? widget.mode.timeLimit : null;
    });
  }

  // ─────────────────────────────────────────────
  // Internal helpers
  // ─────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (widget.mode.isCountdown) {
          _tickCountdown();
        } else {
          _elapsed += const Duration(seconds: 1);
        }
      });
    });
  }

  void _tickCountdown() {
    if (_remaining == null) return;

    _remaining = _remaining! - const Duration(seconds: 1);

    if (_remaining!.isNegative || _remaining == Duration.zero) {
      _remaining = Duration.zero;
      stop();
      widget.onTimeExpired?.call();
    }
  }

  void _pause() {
    _timer?.cancel();
  }

  void _resume() {
    if (_isRunning) {
      _startTimer();
    }
  }

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!widget.mode.usesClock) {
      return const SizedBox.shrink();
    }

    final display =
        widget.mode.isCountdown ? _remaining ?? Duration.zero : _elapsed;

    final minutes = display.inMinutes.toString().padLeft(2, '0');
    final seconds = (display.inSeconds % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          widget.mode.isCountdown
              ? Icons.hourglass_bottom
              : Icons.timer_outlined,
          size: 16,
          color: Colors.black54,
        ),
        const SizedBox(width: 4),
        Text(
          '$minutes:$seconds',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
