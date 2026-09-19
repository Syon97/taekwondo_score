class RoundConfig {
  final int totalRounds;
  final int roundDurationSeconds;
  final int restDurationSeconds;
  final bool hasGoldenRound;
  final int goldenRoundDurationSeconds;

  const RoundConfig({
    required this.totalRounds,
    required this.roundDurationSeconds,
    required this.restDurationSeconds,
    this.hasGoldenRound = true,
    this.goldenRoundDurationSeconds = 60,
  });

  /// Preset: Colour Belt U18 — 1 round × 1m 30s
  static const colourBeltU18 = RoundConfig(
    totalRounds: 1,
    roundDurationSeconds: 90,
    restDurationSeconds: 30,
  );

  /// Preset: Black Belt U18 — 2 rounds × 1m
  static const blackBeltU18 = RoundConfig(
    totalRounds: 2,
    roundDurationSeconds: 60,
    restDurationSeconds: 30,
  );

  /// Preset: Senior — 3 rounds × 2m (WT standard)
  static const senior = RoundConfig(
    totalRounds: 3,
    roundDurationSeconds: 120,
    restDurationSeconds: 60,
  );

  Map<String, dynamic> toJson() => {
        'totalRounds': totalRounds,
        'roundDurationSeconds': roundDurationSeconds,
        'restDurationSeconds': restDurationSeconds,
        'hasGoldenRound': hasGoldenRound,
        'goldenRoundDurationSeconds': goldenRoundDurationSeconds,
      };

  factory RoundConfig.fromJson(Map<String, dynamic> json) => RoundConfig(
        totalRounds: json['totalRounds'],
        roundDurationSeconds: json['roundDurationSeconds'],
        restDurationSeconds: json['restDurationSeconds'],
        hasGoldenRound: json['hasGoldenRound'] ?? true,
        goldenRoundDurationSeconds: json['goldenRoundDurationSeconds'] ?? 60,
      );
}