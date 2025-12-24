import 'package:flutter/material.dart';
import '../game_elements/puzzle.dart';

class HistorySection extends StatelessWidget {
  final Puzzle puzzle;
  final List<String> guesses;

  const HistorySection({
    super.key,
    required this.puzzle,
    required this.guesses,
  });

  Icon _heatIcon(Heat heat) {
    switch (heat) {
      case Heat.muchWarmer:
        return const Icon(Icons.local_fire_department,
            color: Colors.red, size: 18);
      case Heat.warmer:
        return const Icon(Icons.arrow_upward, color: Colors.orange, size: 18);
      case Heat.same:
        return const Icon(Icons.horizontal_rule, color: Colors.grey, size: 18);
      case Heat.colder:
        return const Icon(Icons.arrow_downward,
            color: Colors.lightBlue, size: 18);
      case Heat.muchColder:
        return const Icon(Icons.ac_unit, color: Colors.blue, size: 18);
    }
  }

  Heat _computeHeat(String prev, String curr) {
    final heatStr = puzzle.heatMap[prev]?[curr] ?? 'same';
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
    final recentGuesses = guesses.isEmpty
        ? <String>[]
        : guesses.length <= 3
            ? guesses
            : guesses.sublist(guesses.length - 3);

    return Container(
      width: double.infinity, // full width
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // center inner content
        children: [
          // Header
          const Text(
            "Your Moves",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Column titles
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100, // Word column
                child: Text(
                  "Word",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 80, // Distance column (wider)
                child: Text(
                  "Moves away",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 70, // Trend column (wider)
                child: Text(
                  "Progress",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Recent guesses
          if (recentGuesses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "No moves made yet",
                style: TextStyle(color: Colors.black38),
              ),
            )
          else
            ...List.generate(recentGuesses.length, (i) {
              final index = guesses.length - recentGuesses.length + i;
              final word = guesses[index];
              final heat = index == 0
                  ? Heat.same
                  : _computeHeat(guesses[index - 1], word);
              final distance = puzzle.distanceMap[word] ?? 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(word.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        distance.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 70, child: _heatIcon(heat)),
                  ],
                ),
              );
            }),

          // Optional button to see full history
          if (guesses.length > 3)
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) =>
                      _FullHistoryDialog(puzzle: puzzle, guesses: guesses),
                );
              },
              child: const Text("Show full history"),
            ),
        ],
      ),
    );
  }
}

class _FullHistoryDialog extends StatelessWidget {
  final Puzzle puzzle;
  final List<String> guesses;

  const _FullHistoryDialog({required this.puzzle, required this.guesses});

  Heat _computeHeat(String prev, String curr) {
    final heatStr = puzzle.heatMap[prev]?[curr] ?? 'same';
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

  Icon _heatIcon(Heat heat) {
    switch (heat) {
      case Heat.muchWarmer:
        return const Icon(Icons.local_fire_department, color: Colors.red);
      case Heat.warmer:
        return const Icon(Icons.arrow_upward, color: Colors.orange);
      case Heat.same:
        return const Icon(Icons.horizontal_rule, color: Colors.grey);
      case Heat.colder:
        return const Icon(Icons.arrow_downward, color: Colors.lightBlue);
      case Heat.muchColder:
        return const Icon(Icons.ac_unit, color: Colors.blue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Full History",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...List.generate(guesses.length, (i) {
              final word = guesses[i];
              final distance = puzzle.distanceMap[word] ?? 0;
              final heat =
                  i == 0 ? Heat.same : _computeHeat(guesses[i - 1], word);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 100,
                        child: Text(word.toUpperCase(),
                            style: const TextStyle(fontFamily: 'monospace'))),
                    SizedBox(width: 50, child: Text(distance.toString())),
                    SizedBox(width: 40, child: _heatIcon(heat)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
