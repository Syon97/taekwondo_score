import '../enums/app_mode.dart';
import '../enums/match_status.dart';
import 'round_config.dart';

class Match {
  final String id;
  final String chungName;
  final String hongName;
  final String? weightClass;
  final String? category;
  final RoundConfig roundConfig;
  final AppMode mode;
  final MatchStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? winner; // 'chung' | 'hong' | 'draw'
  final String? endReason; // 'score' | 'penalty_forfeit' | 'manual'

  const Match({
    required this.id,
    required this.chungName,
    required this.hongName,
    this.weightClass,
    this.category,
    required this.roundConfig,
    required this.mode,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.winner,
    this.endReason,
  });

  Match copyWith({
    MatchStatus? status,
    DateTime? completedAt,
    String? winner,
    String? endReason,
  }) {
    return Match(
      id: id,
      chungName: chungName,
      hongName: hongName,
      weightClass: weightClass,
      category: category,
      roundConfig: roundConfig,
      mode: mode,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      winner: winner ?? this.winner,
      endReason: endReason ?? this.endReason,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chungName': chungName,
        'hongName': hongName,
        'weightClass': weightClass,
        'category': category,
        'roundConfig': roundConfig.toJson(),
        'mode': mode.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'winner': winner,
        'endReason': endReason,
      };

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json['id'],
        chungName: json['chungName'],
        hongName: json['hongName'],
        weightClass: json['weightClass'],
        category: json['category'],
        roundConfig: RoundConfig.fromJson(json['roundConfig']),
        mode: AppMode.values.byName(json['mode']),
        status: MatchStatus.values.byName(json['status']),
        createdAt: DateTime.parse(json['createdAt']),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        winner: json['winner'],
        endReason: json['endReason'],
      );
}