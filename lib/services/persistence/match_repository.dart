import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/app_mode.dart';
import '../../core/models/match_event.dart';
import '../../core/models/consensus_result.dart';
import '../../database/app_database.dart';

class MatchRepository {
  MatchRepository(this._db);
  final AppDatabase _db;

  /// Called when a match finishes — saves the final state.
  Future<void> saveCompletedMatch(MatchState state, {
    required String matchId,
    required AppMode mode,
    required int roundDurationSeconds,
    required DateTime createdAt,
  }) async {
    final companion = MatchRecordsCompanion(
      id: Value(matchId),
      chungName: Value(state.chungName),
      hongName: Value(state.hongName),
      category: const Value(null),
      chungScore: Value(state.chungScore),
      hongScore: Value(state.hongScore),
      chungPenalties: Value(state.chungPenalties),
      hongPenalties: Value(state.hongPenalties),
      totalRounds: Value(state.totalRounds),
      roundDurationSeconds: Value(roundDurationSeconds),
      winner: Value(_determineWinner(state)),
      endReason: const Value('score'),
      mode: Value(mode.name),
      createdAt: Value(createdAt),
      completedAt: Value(DateTime.now()),
    );
    await _db.insertMatch(companion);
  }

  /// Save a single consensus event (called after every window closes).
  Future<void> saveConsensusEvent({
    required String matchId,
    required ConsensusResult result,
    required int round,
  }) async {
    final companion = ConsensusEventRecordsCompanion(
      id: Value(result.windowId),
      matchId: Value(matchId),
      windowId: Value(result.windowId),
      outcome: Value(result.outcome.name),
      awardedTo: Value(result.awardedTo?.name),
      technique: Value(result.technique?.name),
      pointsAwarded: Value(result.pointsAwarded),
      round: Value(round),
      resolvedAtMs: Value(result.resolvedAt.millisecondsSinceEpoch),
    );
    await _db.insertConsensusEvent(companion);
  }

  Future<List<MatchRecord>> getAllMatches() => _db.getAllMatches();

  Future<MatchRecord?> getMatch(String id) => _db.getMatch(id);

  Future<List<ConsensusEventRecord>> getMatchEvents(String matchId) =>
      _db.getEventsForMatch(matchId);

  Future<void> deleteMatch(String id) async {
    await _db.deleteEventsForMatch(id);
    await _db.deleteMatch(id);
  }

  String? _determineWinner(MatchState state) {
    if (state.chungScore > state.hongScore) return 'chung';
    if (state.hongScore > state.chungScore) return 'hong';
    return 'draw';
  }
}

// ─── Providers ───────────────────────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository(ref.watch(appDatabaseProvider));
});