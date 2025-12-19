import 'package:flutter/material.dart';

class Puzzle {
  final String startWord;
  final String targetWord;
  final Map<String, int> distanceMap;
  final Map<String, Map<String, String>> heatMap;

  Puzzle({
    required this.startWord,
    required this.targetWord,
    required this.distanceMap,
    required this.heatMap,
  });

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      startWord: json['startWord'],
      targetWord: json['targetWord'],
      distanceMap: Map<String, int>.from(json['distanceMap']),
      heatMap: (json['heatMap'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, Map<String, String>.from(v as Map))),
    );
  }
}

enum Heat { muchWarmer, warmer, same, colder, muchColder }

Color heatToColor(Heat heat) {
  switch (heat) {
    case Heat.muchWarmer:
      return Colors.redAccent;
    case Heat.warmer:
      return Colors.orange;
    case Heat.same:
      return Colors.grey;
    case Heat.colder:
      return Colors.lightBlue;
    case Heat.muchColder:
      return Colors.blueAccent;
  }
}
