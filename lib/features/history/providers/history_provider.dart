import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/app_database.dart';
import '../../../services/persistence/match_repository.dart';

final matchHistoryProvider = FutureProvider<List<MatchRecord>>((ref) async {
  return ref.watch(matchRepositoryProvider).getAllMatches();
});

final matchDetailProvider =
    FutureProvider.family<MatchRecord?, String>((ref, id) async {
  return ref.watch(matchRepositoryProvider).getMatch(id);
});

final matchEventsProvider =
    FutureProvider.family<List<ConsensusEventRecord>, String>((ref, matchId) async {
  return ref.watch(matchRepositoryProvider).getMatchEvents(matchId);
});