import 'dart:async';
import 'package:flutter/material.dart';

class PreStartCountdown extends StatefulWidget {
  final VoidCallback onComplete;
  final int seconds;

  const PreStartCountdown({
    super.key,
    required this.onComplete,
    this.seconds = 3,
  });

  @override
  State<PreStartCountdown> createState() => _PreStartCountdownState();
}

class _PreStartCountdownState extends State<PreStartCountdown> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining == 1) {
        timer.cancel();
        widget.onComplete();
      } else {
        setState(() {
          _remaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          _remaining.toString(),
          key: ValueKey(_remaining),
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
