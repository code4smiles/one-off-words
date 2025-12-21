import 'dart:async';
import 'package:flutter/material.dart';

class GameClock extends StatefulWidget {
  const GameClock({super.key});

  @override
  GameClockState createState() => GameClockState();
}

class GameClockState extends State<GameClock> with WidgetsBindingObserver {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;

  Duration get elapsed => _elapsed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    if (_isRunning) return;
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
    });
  }

  // ─────────────────────────────────────────────
  // Internal helpers
  // ─────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
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
    final minutes = _elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, size: 16, color: Colors.black54),
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
