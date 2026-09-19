import '../enums/fighter_side.dart';
import '../enums/technique.dart';
// import '../enums/match_status.dart';
// import '../enums/consensus_outcome.dart';

// ─── Vote ────────────────────────────────────────────────────────────────────

class Vote {
  final String id;
  final String matchId;
  final String windowId;
  final String judgeId;
  final int judgeSlot; // 1–4
  final FighterSide targetFighter;
  final Technique technique;
  final int clientTimestampMs;
  final int serverReceivedMs;
  final int round;

  const Vote({
    required this.id,
    required this.matchId,
    required this.windowId,
    required this.judgeId,
    required this.judgeSlot,
    required this.targetFighter,
    required this.technique,
    required this.clientTimestampMs,
    required this.serverReceivedMs,
    required this.round,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'windowId': windowId,
        'judgeId': judgeId,
        'judgeSlot': judgeSlot,
        'targetFighter': targetFighter.name,
        'technique': technique.name,
        'clientTimestampMs': clientTimestampMs,
        'serverReceivedMs': serverReceivedMs,
        'round': round,
      };

  factory Vote.fromJson(Map<String, dynamic> json) => Vote(
        id: json['id'],
        matchId: json['matchId'],
        windowId: json['windowId'],
        judgeId: json['judgeId'],
        judgeSlot: json['judgeSlot'],
        targetFighter: FighterSide.values.byName(json['targetFighter']),
        technique: Technique.values.byName(json['technique']),
        clientTimestampMs: json['clientTimestampMs'],
        serverReceivedMs: json['serverReceivedMs'],
        round: json['round'],
      );
}
// ─── MatchEvent (Audit Log) ───────────────────────────────────────────────────

class MatchEvent {
  final String id;
  final String matchId;
  final String eventType; // see WsMessageTypes / event type strings
  final Map<String, dynamic> payload;
  final int timestampMs;
  final int round;

  const MatchEvent({
    required this.id,
    required this.matchId,
    required this.eventType,
    required this.payload,
    required this.timestampMs,
    required this.round,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'eventType': eventType,
        'payload': payload,
        'timestampMs': timestampMs,
        'round': round,
      };
}