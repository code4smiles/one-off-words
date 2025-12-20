import 'package:flutter/material.dart';

class NextPuzzleButton extends StatelessWidget {
  final VoidCallback startNewPuzzle;

  const NextPuzzleButton({super.key, required this.startNewPuzzle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: Material(
          color: Colors.teal, // Contrasting color to history tiles
          borderRadius: BorderRadius.circular(30),
          elevation: 4,
          child: InkWell(
            onTap: startNewPuzzle,
            borderRadius: BorderRadius.circular(30),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_forward,
                      color: Colors.white), // Could use Icons.arrow_forward too
                  SizedBox(width: 12),
                  Text(
                    "Next Puzzle",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
