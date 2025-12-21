import 'package:flutter/material.dart';
import 'package:oneoffwords/constants.dart';
import 'package:oneoffwords/screens/puzzle_screen.dart';

import '../game_elements/game_mode.dart';
import '../ui/game_mode_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _startGame(BuildContext context, GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleScreen(mode: mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              /// Game title
              const Text(
                appName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Change one letter at a time!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 32),

              /// Game modes grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    GameModeCard(
                      icon: Icons.explore_outlined,
                      iconColor: Colors.blueAccent,
                      title: 'Free Play',
                      description: 'Solve at your own pace with no limits.',
                      onTap: () => _startGame(
                        context,
                        GameMode.freePlay,
                      ),
                    ),
                    GameModeCard(
                      icon: Icons.timer_outlined,
                      iconColor: Colors.orangeAccent,
                      title: 'Time Trial',
                      description: 'Solve as fast as possible.',
                      onTap: () => _startGame(
                        context,
                        GameMode.timeTrial,
                      ),
                    ),
                    GameModeCard(
                      icon: Icons.emoji_objects_outlined,
                      iconColor: Colors.green,
                      title: 'Fewest Moves',
                      description: 'Solve using the fewest moves.',
                      onTap: () => _startGame(
                        context,
                        GameMode.optimalMoves,
                      ),
                    ),
                    GameModeCard(
                      icon: Icons.flag_sharp,
                      iconColor: Colors.purpleAccent,
                      title: 'Puzzle Run',
                      description: 'Solve multiple puzzles in one run.',
                      onTap: () => _startGame(
                        context,
                        GameMode.puzzleRun(count: 10),
                      ),
                    ),
                  ],
                ),
              ),

              /// Footer
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'More modes and leaderboards coming soon',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
