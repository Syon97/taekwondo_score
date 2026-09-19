// ─── MatchState (live, server-side source of truth) ──────────────────────────

import 'package:taekwondo_score/core/enums/match_status.dart';
import 'package:taekwondo_score/core/models/consensus_result.dart';
import 'package:taekwondo_score/core/models/judge.dart';

class MatchState {
  final String matchId;
  final String chungName;
  final String hongName;
  final int chungScore;
  final int hongScore;
  final int chungPenalties;
  final int hongPenalties;
  final int currentRound;
  final int totalRounds;
  final MatchStatus status;
  final int timerRemainingMs;
  final bool timerRunning;
  final List<Judge> judges;
  final ConsensusWindow? activeWindow;
  final ConsensusResult? lastResult;
  final DateTime? undoExpiresAt; // set for 10s after a point is awarded

  const MatchState({
    required this.matchId,
    required this.chungName,
    required this.hongName,
    required this.chungScore,
    required this.hongScore,
    required this.chungPenalties,
    required this.hongPenalties,
    required this.currentRound,
    required this.totalRounds,
    required this.status,
    required this.timerRemainingMs,
    required this.timerRunning,
    required this.judges,
    this.activeWindow,
    this.lastResult,
    this.undoExpiresAt,
  });

  bool get canUndo =>
      lastResult != null &&
      !lastResult!.undone &&
      undoExpiresAt != null &&
      DateTime.now().isBefore(undoExpiresAt!);

  int connectedJudgeCount() => judges.where((j) => j.isConnected).length;

  bool get allJudgesConnected => connectedJudgeCount() == 4;

  MatchState copyWith({
    int? chungScore,
    int? hongScore,
    int? chungPenalties,
    int? hongPenalties,
    int? currentRound,
    MatchStatus? status,
    int? timerRemainingMs,
    bool? timerRunning,
    List<Judge>? judges,
    ConsensusWindow? activeWindow,
    bool clearActiveWindow = false,
    ConsensusResult? lastResult,
    DateTime? undoExpiresAt,
    bool clearUndoExpiry = false,
  }) {
    return MatchState(
      matchId: matchId,
      chungName: chungName,
      hongName: hongName,
      chungScore: chungScore ?? this.chungScore,
      hongScore: hongScore ?? this.hongScore,
      chungPenalties: chungPenalties ?? this.chungPenalties,
      hongPenalties: hongPenalties ?? this.hongPenalties,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds,
      status: status ?? this.status,
      timerRemainingMs: timerRemainingMs ?? this.timerRemainingMs,
      timerRunning: timerRunning ?? this.timerRunning,
      judges: judges ?? this.judges,
      activeWindow: clearActiveWindow ? null : activeWindow ?? this.activeWindow,
      lastResult: lastResult ?? this.lastResult,
      undoExpiresAt: clearUndoExpiry ? null : undoExpiresAt ?? this.undoExpiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'chungName': chungName,
        'hongName': hongName,
        'chungScore': chungScore,
        'hongScore': hongScore,
        'chungPenalties': chungPenalties,
        'hongPenalties': hongPenalties,
        'currentRound': currentRound,
        'totalRounds': totalRounds,
        'status': status.name,
        'timerRemainingMs': timerRemainingMs,
        'timerRunning': timerRunning,
        'judges': judges.map((j) => j.toJson()).toList(),
        'activeWindow': activeWindow?.toJson(),
        'lastResult': lastResult?.toJson(),
        'undoExpiresAt': undoExpiresAt?.toIso8601String(),
      };

  factory MatchState.fromJson(Map<String, dynamic> json) => MatchState(
        matchId: json['matchId'],
        chungName: json['chungName'],
        hongName: json['hongName'],
        chungScore: json['chungScore'],
        hongScore: json['hongScore'],
        chungPenalties: json['chungPenalties'],
        hongPenalties: json['hongPenalties'],
        currentRound: json['currentRound'],
        totalRounds: json['totalRounds'],
        status: MatchStatus.values.byName(json['status']),
        timerRemainingMs: json['timerRemainingMs'],
        timerRunning: json['timerRunning'],
        judges: (json['judges'] as List).map((j) => Judge.fromJson(j)).toList(),
        activeWindow: json['activeWindow'] != null
            ? ConsensusWindow.fromJson(json['activeWindow'])
            : null,
        lastResult: json['lastResult'] != null
            ? ConsensusResult.fromJson(json['lastResult'])
            : null,
        undoExpiresAt: json['undoExpiresAt'] != null
            ? DateTime.parse(json['undoExpiresAt'])
            : null,
      );
}