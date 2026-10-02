import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ─── Tables ──────────────────────────────────────────────────────────────────

class MatchRecords extends Table {
  TextColumn get id => text()();
  TextColumn get chungName => text()();
  TextColumn get hongName => text()();
  TextColumn get category => text().nullable()();
  IntColumn get chungScore => integer()();
  IntColumn get hongScore => integer()();
  IntColumn get chungPenalties => integer()();
  IntColumn get hongPenalties => integer()();
  IntColumn get totalRounds => integer()();
  IntColumn get roundDurationSeconds => integer()();
  TextColumn get winner => text().nullable()();
  TextColumn get endReason => text().nullable()();
  TextColumn get mode => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ConsensusEventRecords extends Table {
  TextColumn get id => text()();
  TextColumn get matchId => text()();
  TextColumn get windowId => text()();
  TextColumn get outcome => text()(); // awarded | noConsensus | cancelled
  TextColumn get awardedTo => text().nullable()(); // chung | hong
  TextColumn get technique => text().nullable()();
  IntColumn get pointsAwarded => integer()();
  IntColumn get round => integer()();
  IntColumn get resolvedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [MatchRecords, ConsensusEventRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── Match operations ──────────────────────────────────────────────────────

  Future<void> insertMatch(MatchRecordsCompanion match) =>
      into(matchRecords).insert(match, mode: InsertMode.insertOrReplace);

  Future<void> updateMatch(MatchRecordsCompanion match) =>
      (update(matchRecords)..where((t) => t.id.equals(match.id.value)))
          .write(match);

  Future<List<MatchRecord>> getAllMatches() =>
      (select(matchRecords)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<MatchRecord?> getMatch(String id) =>
      (select(matchRecords)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> deleteMatch(String id) =>
      (delete(matchRecords)..where((t) => t.id.equals(id))).go();

  // ── Consensus event operations ────────────────────────────────────────────

  Future<void> insertConsensusEvent(ConsensusEventRecordsCompanion event) =>
      into(consensusEventRecords).insert(event);

  Future<List<ConsensusEventRecord>> getEventsForMatch(String matchId) =>
      (select(consensusEventRecords)
        ..where((t) => t.matchId.equals(matchId))
        ..orderBy([(t) => OrderingTerm.asc(t.resolvedAtMs)]))
          .get();

  Future<void> deleteEventsForMatch(String matchId) =>
      (delete(consensusEventRecords)
        ..where((t) => t.matchId.equals(matchId)))
          .go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'taekwondo_score.db'));
    return NativeDatabase.createInBackground(file);
  });
}