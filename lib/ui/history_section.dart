import 'package:flutter/material.dart';
import '../game_elements/puzzle.dart';
import 'history_tile.dart';

class HistorySection extends StatefulWidget {
  final Puzzle puzzle;
  final List<String> guesses;
  final VoidCallback onReset;

  const HistorySection({
    super.key,
    required this.puzzle,
    required this.guesses,
    required this.onReset,
  });

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<HistorySection> {
  final ScrollController _scrollController = ScrollController();
  int _lastCount = 0;

  @override
  void didUpdateWidget(covariant HistorySection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.guesses.length > _lastCount) {
      _lastCount = widget.guesses.length;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Heat _computeHeat(String prev, String curr) {
    final heatStr = widget.puzzle.heatMap[prev]?[curr] ?? 'same';
    switch (heatStr) {
      case 'muchWarmer':
        return Heat.muchWarmer;
      case 'warmer':
        return Heat.warmer;
      case 'colder':
        return Heat.colder;
      case 'muchColder':
        return Heat.muchColder;
      default:
        return Heat.same;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.guesses.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Your Moves",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Colors.black,
                ),
              ),
              TextButton.icon(
                onPressed: widget.guesses.length <= 1 ? null : widget.onReset,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Restart"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black54,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.guesses.length,
            itemBuilder: (context, index) {
              final word = widget.guesses[index];
              final isLatest = index == widget.guesses.length - 1;
              final isRecent = index >= widget.guesses.length - 2;

              final heat = index == 0
                  ? Heat.same
                  : _computeHeat(
                      widget.guesses[index - 1],
                      word,
                    );

              return _AnimatedHistoryEntry(
                isLatest: isLatest,
                child: HistoryTile(
                  word: word,
                  step: index,
                  targetWord: widget.puzzle.targetWord,
                  heat: heat,
                  isDimmed: !isRecent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AnimatedHistoryEntry extends StatelessWidget {
  final bool isLatest;
  final Widget child;

  const _AnimatedHistoryEntry({
    required this.isLatest,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLatest) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 8),
            child: child,
          ),
        );
      },
    );
  }
}
