import 'package:taekwondo_score/core/enums/consensus_outcome.dart';
import 'package:taekwondo_score/core/enums/fighter_side.dart';
import 'package:taekwondo_score/core/enums/technique.dart';
import 'package:taekwondo_score/core/models/vote.dart';

// ─── ConsensusWindow ─────────────────────────────────────────────────────────
class ConsensusWindow {
  final String windowId;
  final int openedAtMs;
  final int expiresAtMs;
  final List<Vote> votes; // up to 1 per judge (last vote wins per judge)

  const ConsensusWindow({
    required this.windowId,
    required this.openedAtMs,
    required this.expiresAtMs,
    required this.votes,
  });

  ConsensusWindow withVote(Vote newVote) {
    // Replace existing vote from same judge, or add new
    final updated = votes.where((v) => v.judgeId != newVote.judgeId).toList()
      ..add(newVote);
    return ConsensusWindow(
      windowId: windowId,
      openedAtMs: openedAtMs,
      expiresAtMs: expiresAtMs,
      votes: updated,
    );
  }

  Map<String, dynamic> toJson() => {
        'windowId': windowId,
        'openedAtMs': openedAtMs,
        'expiresAtMs': expiresAtMs,
        'votes': votes.map((v) => v.toJson()).toList(),
      };

  factory ConsensusWindow.fromJson(Map<String, dynamic> json) =>
      ConsensusWindow(
        windowId: json['windowId'],
        openedAtMs: json['openedAtMs'],
        expiresAtMs: json['expiresAtMs'],
        votes: (json['votes'] as List).map((v) => Vote.fromJson(v)).toList(),
      );
}

// ─── ConsensusResult ─────────────────────────────────────────────────────────

class ConsensusResult {
  final String windowId;
  final ConsensusOutcome outcome;
  final FighterSide? awardedTo;
  final Technique? technique;
  final int pointsAwarded;
  final List<Vote> contributingVotes;
  final List<Vote> allVotes;
  final DateTime resolvedAt;
  final bool undone;

  const ConsensusResult({
    required this.windowId,
    required this.outcome,
    this.awardedTo,
    this.technique,
    required this.pointsAwarded,
    required this.contributingVotes,
    required this.allVotes,
    required this.resolvedAt,
    this.undone = false,
  });

  ConsensusResult markUndone() => ConsensusResult(
        windowId: windowId,
        outcome: outcome,
        awardedTo: awardedTo,
        technique: technique,
        pointsAwarded: pointsAwarded,
        contributingVotes: contributingVotes,
        allVotes: allVotes,
        resolvedAt: resolvedAt,
        undone: true,
      );

  Map<String, dynamic> toJson() => {
        'windowId': windowId,
        'outcome': outcome.name,
        'awardedTo': awardedTo?.name,
        'technique': technique?.name,
        'pointsAwarded': pointsAwarded,
        'contributingVotes': contributingVotes.map((v) => v.toJson()).toList(),
        'allVotes': allVotes.map((v) => v.toJson()).toList(),
        'resolvedAt': resolvedAt.toIso8601String(),
        'undone': undone,
      };

  factory ConsensusResult.fromJson(Map<String, dynamic> json) =>
      ConsensusResult(
        windowId: json['windowId'],
        outcome: ConsensusOutcome.values.byName(json['outcome']),
        awardedTo: json['awardedTo'] != null
            ? FighterSide.values.byName(json['awardedTo'])
            : null,
        technique: json['technique'] != null
            ? Technique.values.byName(json['technique'])
            : null,
        pointsAwarded: json['pointsAwarded'],
        contributingVotes: (json['contributingVotes'] as List)
            .map((v) => Vote.fromJson(v))
            .toList(),
        allVotes:
            (json['allVotes'] as List).map((v) => Vote.fromJson(v)).toList(),
        resolvedAt: DateTime.parse(json['resolvedAt']),
        undone: json['undone'] ?? false,
      );
}
