import 'package:flutter/material.dart';

import 'package:oneoffwords/screens/puzzle_screen.dart';
import 'constants.dart';

void main() {
  runApp(const OneOffWordsApp());
}

class OneOffWordsApp extends StatelessWidget {
  const OneOffWordsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const PuzzleScreen(),
    );
  }
}
