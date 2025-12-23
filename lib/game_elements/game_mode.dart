enum GameModeType {
  freePlay,
  timeTrial,
  optimalMoves,
  puzzleRun,
}

class GameMode {
  final GameModeType type;

  /// Clock-related
  final Duration? timeLimit;

  /// Gameplay constraints
  final int? maxMoves;
  final bool trackBestTime;
  final bool requireOptimal;

  const GameMode._({
    required this.type,
    this.timeLimit,
    this.maxMoves,
    this.trackBestTime = false,
    this.requireOptimal = false,
  });

  // ----------------------------
  // Preset modes
  // ----------------------------

  static const freePlay = GameMode._(
    type: GameModeType.freePlay,
  );

  static const timeTrial = GameMode._(
    type: GameModeType.timeTrial,
    trackBestTime: true,
    timeLimit: Duration(minutes: 2),
    // no timeLimit → count UP
  );

  static const optimalMoves = GameMode._(
    type: GameModeType.optimalMoves,
    requireOptimal: true,
  );

  static GameMode puzzleRun({
    required int count,
    Duration? timeLimit,
  }) =>
      GameMode._(
        type: GameModeType.puzzleRun,
        timeLimit: timeLimit,
        trackBestTime: true,
      );

  // ----------------------------
  // Clock helpers (used by GameClock)
  // ----------------------------

  /// Should a clock be shown at all?
  bool get usesClock =>
      type == GameModeType.timeTrial || type == GameModeType.puzzleRun;

  /// Is this a countdown clock?
  bool get isCountdown => timeLimit != null;

  /// Does the clock count up?
  bool get isStopwatch => usesClock && timeLimit == null;
}

extension GameModeClocking on GameMode {
  bool get usesClock =>
      type == GameModeType.timeTrial || type == GameModeType.puzzleRun;

  bool get usesPreStartCountdown => type == GameModeType.timeTrial;
}
