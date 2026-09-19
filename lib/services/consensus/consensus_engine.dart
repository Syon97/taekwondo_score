import 'dart:async';
import 'package:taekwondo_score/core/models/consensus_result.dart';
import 'package:taekwondo_score/core/models/vote.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/enums/consensus_outcome.dart';
import '../../core/enums/fighter_side.dart';
import '../../core/enums/technique.dart';
// import '../../core/models/models.dart';

/// Result of evaluating the votes in a window.
class EvaluationResult {
  final ConsensusOutcome outcome;

  /// Null if outcome is not [ConsensusOutcome.awarded]
  final FighterSide? awardedTo;
  final Technique? technique;
  final int pointsAwarded;
  final List<Vote> contributingVotes;

  const EvaluationResult({
    required this.outcome,
    this.awardedTo,
    this.technique,
    required this.pointsAwarded,
    required this.contributingVotes,
  });
}

/// Callback fired when the engine produces a consensus result.
/// The server uses this to update [MatchState] and broadcast to clients.
typedef OnConsensusResult = void Function(
  ConsensusResult result,
  ConsensusWindow closedWindow,
);

/// The ConsensusEngine manages a single active voting window at a time.
///
/// Responsibilities:
/// - Open a window on first vote received
/// - Accept and deduplicate votes (last vote wins per judge)
/// - Close the window early if 3-of-4 agreement already met
/// - Close the window after [AppConstants.consensusWindowMs] elapses
/// - Evaluate votes at close time using conservative tie-breaking rules
/// - Fire [OnConsensusResult] with the outcome
///
/// This class is stateful and should live on the server (scoreboard) only.
class ConsensusEngine {
  ConsensusEngine({
    required this.matchId,
    required this.onResult,
  });

  final String matchId;
  final OnConsensusResult onResult;
  final _uuid = const Uuid();

  ConsensusWindow? _activeWindow;
  Timer? _windowTimer;
  int _currentRound = 1;

  /// Called by the server whenever it receives a [Vote] from a judge.
  ///
  /// If no window is open, opens one.
  /// If a window is open, adds the vote (replacing any prior vote from
  /// the same judge) and checks for early consensus.
  void receiveVote(Vote vote) {
    if (_activeWindow == null) {
      _openWindow(vote);
    } else {
      _activeWindow = _activeWindow!.withVote(vote);
      _checkEarlyConsensus();
    }
  }

  /// Called externally to force-close the current window (chief jury cancel).
  void cancelActiveWindow() {
    if (_activeWindow == null) return;
    final window = _activeWindow!;
    _closeWindow(
      window,
      const EvaluationResult(
        outcome: ConsensusOutcome.cancelled,
        pointsAwarded: 0,
        contributingVotes: [],
      ),
    );
  }

  /// Update the current round so votes are stamped correctly.
  void setRound(int round) {
    _currentRound = round;
  }

  void dispose() {
    _windowTimer?.cancel();
    _activeWindow = null;
  }

  // ─── Private ───────────────────────────────────────────────────────────────

  void _openWindow(Vote firstVote) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _activeWindow = ConsensusWindow(
      windowId: firstVote.windowId,
      openedAtMs: now,
      expiresAtMs: now + AppConstants.consensusWindowMs,
      votes: [firstVote],
    );

    _windowTimer = Timer(
      Duration(milliseconds: AppConstants.consensusWindowMs),
      _onWindowExpired,
    );
  }

  void _checkEarlyConsensus() {
    if (_activeWindow == null) return;
    final result = _evaluate(_activeWindow!.votes);
    if (result.outcome == ConsensusOutcome.awarded) {
      // Cancel the timer — we have a winner already
      _windowTimer?.cancel();
      _closeWindow(_activeWindow!, result);
    }
  }

  void _onWindowExpired() {
    if (_activeWindow == null) return;
    final result = _evaluate(_activeWindow!.votes);
    _closeWindow(_activeWindow!, result);
  }

  void _closeWindow(ConsensusWindow window, EvaluationResult evaluation) {
    _windowTimer?.cancel();
    _activeWindow = null;

    final consensusResult = ConsensusResult(
      windowId: window.windowId,
      outcome: evaluation.outcome,
      awardedTo: evaluation.awardedTo,
      technique: evaluation.technique,
      pointsAwarded: evaluation.pointsAwarded,
      contributingVotes: evaluation.contributingVotes,
      allVotes: window.votes,
      resolvedAt: DateTime.now(),
    );

    onResult(consensusResult, window);
  }

  /// Core evaluation logic.
  ///
  /// Groups votes by (fighter, technique) pair.
  /// Finds the group(s) with the highest vote count.
  /// Awards consensus if the top group has >= [AppConstants.consensusThreshold] votes.
  ///
  /// Tie-breaking (two groups tied at threshold):
  ///   - Same fighter, different technique → award lower-value technique (conservative)
  ///   - Different fighter → no_consensus (cannot determine who was hit)
  EvaluationResult _evaluate(List<Vote> votes) {
    if (votes.isEmpty) {
      return const EvaluationResult(
        outcome: ConsensusOutcome.noConsensus,
        pointsAwarded: 0,
        contributingVotes: [],
      );
    }

    // Group votes by (fighter, technique)
    final Map<String, List<Vote>> groups = {};
    for (final vote in votes) {
      final key = '${vote.targetFighter.name}:${vote.technique.name}';
      groups.putIfAbsent(key, () => []).add(vote);
    }

    // Find max vote count
    final maxCount = groups.values.map((v) => v.length).reduce(
      (a, b) => a > b ? a : b,
    );

    // No group meets threshold
    if (maxCount < AppConstants.consensusThreshold) {
      return const EvaluationResult(
        outcome: ConsensusOutcome.noConsensus,
        pointsAwarded: 0,
        contributingVotes: [],
      );
    }

    // Collect all groups that hit the max count
    final winners = groups.entries
        .where((e) => e.value.length == maxCount)
        .toList();

    if (winners.length == 1) {
      // Clean consensus — one group wins
      final winnerVotes = winners.first.value;
      final technique = winnerVotes.first.technique;
      final fighter = winnerVotes.first.targetFighter;
      return EvaluationResult(
        outcome: ConsensusOutcome.awarded,
        awardedTo: fighter,
        technique: technique,
        pointsAwarded: technique.points,
        contributingVotes: winnerVotes,
      );
    }

    // ── Tie-breaking ──────────────────────────────────────────────────────────
    // Multiple groups tied at the threshold count.

    final tiedVoteGroups = winners.map((e) => e.value).toList();
    final fighters = tiedVoteGroups.map((v) => v.first.targetFighter).toSet();

    if (fighters.length > 1) {
      // Tied across different fighters — cannot safely award anyone
      return EvaluationResult(
        outcome: ConsensusOutcome.noConsensus,
        pointsAwarded: 0,
        contributingVotes: [],
      );
    }

    // Same fighter, multiple techniques tied — award lowest-value technique
    final fighter = fighters.first;
    final techniques = tiedVoteGroups.map((v) => v.first.technique).toList();
    techniques.sort((a, b) => a.points.compareTo(b.points));
    final conservativeTechnique = techniques.first;
    final conservativeVotes = tiedVoteGroups
        .firstWhere((v) => v.first.technique == conservativeTechnique);

    return EvaluationResult(
      outcome: ConsensusOutcome.awarded,
      awardedTo: fighter,
      technique: conservativeTechnique,
      pointsAwarded: conservativeTechnique.points,
      contributingVotes: conservativeVotes,
    );
  }
}