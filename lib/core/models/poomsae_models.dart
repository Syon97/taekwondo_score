import 'package:taekwondo_score/core/models/judge.dart';

// import 'fighter_side.dart'; // reuse for athlete identification if needed
import 'package:taekwondo_score/core/enums/fighter_side.dart';

class PoomsaeScore {
  final String judgeId;
  final int judgeSlot;       // 1–5
  final String athleteId;    // match-scoped ID
  final String athleteName;
  final double accuracy;     // 0.0–10.0
  final double presentation; // 0.0–10.0
  final DateTime submittedAt;

  const PoomsaeScore({
    required this.judgeId,
    required this.judgeSlot,
    required this.athleteId,
    required this.athleteName,
    required this.accuracy,
    required this.presentation,
    required this.submittedAt,
  });

  double get total => double.parse(
      (accuracy + presentation).toStringAsFixed(1));

  Map<String, dynamic> toJson() => {
    'judgeId': judgeId,
    'judgeSlot': judgeSlot,
    'athleteId': athleteId,
    'athleteName': athleteName,
    'accuracy': accuracy,
    'presentation': presentation,
    'submittedAt': submittedAt.toIso8601String(),
  };

  factory PoomsaeScore.fromJson(Map<String, dynamic> j) => PoomsaeScore(
    judgeId: j['judgeId'],
    judgeSlot: j['judgeSlot'],
    athleteId: j['athleteId'],
    athleteName: j['athleteName'],
    accuracy: (j['accuracy'] as num).toDouble(),
    presentation: (j['presentation'] as num).toDouble(),
    submittedAt: DateTime.parse(j['submittedAt']),
  );
}

class PoomsaeResult {
  final String athleteId;
  final String athleteName;
  final List<PoomsaeScore> scores;  // all 5 judges
  final double finalScore;          // after drop high/low
  final int? droppedHighSlot;       // which judge was highest
  final int? droppedLowSlot;        // which judge was lowest

  const PoomsaeResult({
    required this.athleteId,
    required this.athleteName,
    required this.scores,
    required this.finalScore,
    this.droppedHighSlot,
    this.droppedLowSlot,
  });

  // Factory: calculate from 5 submitted scores
  factory PoomsaeResult.calculate({
    required String athleteId,
    required String athleteName,
    required List<PoomsaeScore> scores,
  }) {
    assert(scores.length == 5, 'Poomsae requires exactly 5 judge scores');

    final sorted = [...scores]..sort((a, b) => a.total.compareTo(b.total));
    final dropped = [sorted.first, sorted.last];
    final remaining = scores
        .where((s) => !dropped.contains(s))
        .toList();

    final avg = remaining.map((s) => s.total).reduce((a, b) => a + b) / 3;

    return PoomsaeResult(
      athleteId: athleteId,
      athleteName: athleteName,
      scores: scores,
      finalScore: double.parse(avg.toStringAsFixed(2)),
      droppedHighSlot: sorted.last.judgeSlot,
      droppedLowSlot: sorted.first.judgeSlot,
    );
  }
}

// Live state of a Poomsae session (equivalent to MatchState for Kyorugi)
class PoomsaeSessionState {
  final String sessionId;
  final String sessionName;   // e.g. "Women Individual Pattern – Final"
  final List<PoomsaeAthlete> athletes;
  final int currentAthleteIndex;
  final Map<String, List<PoomsaeScore>> submittedScores; // athleteId → scores
  final Map<String, PoomsaeResult> results;             // athleteId → result
  final List<Judge> judges;  // reuse Judge model from Kyorugi
  final PoomsaeSessionStatus status;

  const PoomsaeSessionState({
    required this.sessionId,
    required this.sessionName,
    required this.athletes,
    required this.currentAthleteIndex,
    required this.submittedScores,
    required this.results,
    required this.judges,
    required this.status,
  });

  PoomsaeAthlete? get currentAthlete =>
      currentAthleteIndex < athletes.length
          ? athletes[currentAthleteIndex]
          : null;

  List<PoomsaeScore> get scoresForCurrent {
    final athlete = currentAthlete;
    if (athlete == null) return [];
    return submittedScores[athlete.id] ?? [];
  }

  int get scoresSubmittedCount => scoresForCurrent.length;
  bool get allScoresSubmitted => scoresSubmittedCount >= 5;

  bool hasJudgeSubmitted(String judgeId) =>
      scoresForCurrent.any((s) => s.judgeId == judgeId);

  int get connectedJudges =>
    judges.where((j) => j.isConnected).length;

  PoomsaeSessionState copyWith({
    int? currentAthleteIndex,
    Map<String, List<PoomsaeScore>>? submittedScores,
    Map<String, PoomsaeResult>? results,
    List<Judge>? judges,
    PoomsaeSessionStatus? status,
  }) {
    return PoomsaeSessionState(
      sessionId: sessionId,
      sessionName: sessionName,
      athletes: athletes,
      currentAthleteIndex: currentAthleteIndex ?? this.currentAthleteIndex,
      submittedScores: submittedScores ?? this.submittedScores,
      results: results ?? this.results,
      judges: judges ?? this.judges,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'sessionName': sessionName,
    'athletes': athletes.map((a) => a.toJson()).toList(),
    'currentAthleteIndex': currentAthleteIndex,
    'submittedScores': submittedScores.map((k, v) =>
        MapEntry(k, v.map((s) => s.toJson()).toList())),
    'results': results.map((k, v) => MapEntry(k, {
      'athleteId': v.athleteId,
      'athleteName': v.athleteName,
      'finalScore': v.finalScore,
      'droppedHighSlot': v.droppedHighSlot,
      'droppedLowSlot': v.droppedLowSlot,
      'scores': v.scores.map((s) => s.toJson()).toList(),
    })),
    'judges': judges.map((j) => j.toJson()).toList(),
    'status': status.name,
  };

  factory PoomsaeSessionState.fromJson(Map<String, dynamic> j) {
    final scoresMap = (j['submittedScores'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k,
          (v as List).map((s) => PoomsaeScore.fromJson(s)).toList()),
    );

    return PoomsaeSessionState(
      sessionId: j['sessionId'],
      sessionName: j['sessionName'],
      athletes: (j['athletes'] as List)
          .map((a) => PoomsaeAthlete.fromJson(a))
          .toList(),
      currentAthleteIndex: j['currentAthleteIndex'],
      submittedScores: scoresMap,
      results: {},  // recalculated on receive, not serialized in full
      judges: (j['judges'] as List)
          .map((jj) => Judge.fromJson(jj))
          .toList(),
      status: PoomsaeSessionStatus.values.byName(j['status']),
    );
  }
}

class PoomsaeAthlete {
  final String id;
  final String name;
  final String? team;
  final int order;  // performance order

  const PoomsaeAthlete({
    required this.id,
    required this.name,
    this.team,
    required this.order,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'team': team, 'order': order,
  };

  factory PoomsaeAthlete.fromJson(Map<String, dynamic> j) => PoomsaeAthlete(
    id: j['id'], name: j['name'], team: j['team'], order: j['order'],
  );
}

enum PoomsaeSessionStatus {
  setup,        // waiting for judges to connect
  performing,   // current athlete performing, judges waiting to score
  scoring,      // performance done, judges entering scores
  calculated,   // scores submitted, result shown, ready for next athlete
  finished,     // all athletes scored
}