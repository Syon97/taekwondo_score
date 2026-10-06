// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MatchRecordsTable extends MatchRecords
    with TableInfo<$MatchRecordsTable, MatchRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chungNameMeta =
      const VerificationMeta('chungName');
  @override
  late final GeneratedColumn<String> chungName = GeneratedColumn<String>(
      'chung_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hongNameMeta =
      const VerificationMeta('hongName');
  @override
  late final GeneratedColumn<String> hongName = GeneratedColumn<String>(
      'hong_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chungScoreMeta =
      const VerificationMeta('chungScore');
  @override
  late final GeneratedColumn<int> chungScore = GeneratedColumn<int>(
      'chung_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hongScoreMeta =
      const VerificationMeta('hongScore');
  @override
  late final GeneratedColumn<int> hongScore = GeneratedColumn<int>(
      'hong_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _chungPenaltiesMeta =
      const VerificationMeta('chungPenalties');
  @override
  late final GeneratedColumn<int> chungPenalties = GeneratedColumn<int>(
      'chung_penalties', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hongPenaltiesMeta =
      const VerificationMeta('hongPenalties');
  @override
  late final GeneratedColumn<int> hongPenalties = GeneratedColumn<int>(
      'hong_penalties', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalRoundsMeta =
      const VerificationMeta('totalRounds');
  @override
  late final GeneratedColumn<int> totalRounds = GeneratedColumn<int>(
      'total_rounds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _roundDurationSecondsMeta =
      const VerificationMeta('roundDurationSeconds');
  @override
  late final GeneratedColumn<int> roundDurationSeconds = GeneratedColumn<int>(
      'round_duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _winnerMeta = const VerificationMeta('winner');
  @override
  late final GeneratedColumn<String> winner = GeneratedColumn<String>(
      'winner', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _endReasonMeta =
      const VerificationMeta('endReason');
  @override
  late final GeneratedColumn<String> endReason = GeneratedColumn<String>(
      'end_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
      'mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chungName,
        hongName,
        category,
        chungScore,
        hongScore,
        chungPenalties,
        hongPenalties,
        totalRounds,
        roundDurationSeconds,
        winner,
        endReason,
        mode,
        createdAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'match_records';
  @override
  VerificationContext validateIntegrity(Insertable<MatchRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chung_name')) {
      context.handle(_chungNameMeta,
          chungName.isAcceptableOrUnknown(data['chung_name']!, _chungNameMeta));
    } else if (isInserting) {
      context.missing(_chungNameMeta);
    }
    if (data.containsKey('hong_name')) {
      context.handle(_hongNameMeta,
          hongName.isAcceptableOrUnknown(data['hong_name']!, _hongNameMeta));
    } else if (isInserting) {
      context.missing(_hongNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('chung_score')) {
      context.handle(
          _chungScoreMeta,
          chungScore.isAcceptableOrUnknown(
              data['chung_score']!, _chungScoreMeta));
    } else if (isInserting) {
      context.missing(_chungScoreMeta);
    }
    if (data.containsKey('hong_score')) {
      context.handle(_hongScoreMeta,
          hongScore.isAcceptableOrUnknown(data['hong_score']!, _hongScoreMeta));
    } else if (isInserting) {
      context.missing(_hongScoreMeta);
    }
    if (data.containsKey('chung_penalties')) {
      context.handle(
          _chungPenaltiesMeta,
          chungPenalties.isAcceptableOrUnknown(
              data['chung_penalties']!, _chungPenaltiesMeta));
    } else if (isInserting) {
      context.missing(_chungPenaltiesMeta);
    }
    if (data.containsKey('hong_penalties')) {
      context.handle(
          _hongPenaltiesMeta,
          hongPenalties.isAcceptableOrUnknown(
              data['hong_penalties']!, _hongPenaltiesMeta));
    } else if (isInserting) {
      context.missing(_hongPenaltiesMeta);
    }
    if (data.containsKey('total_rounds')) {
      context.handle(
          _totalRoundsMeta,
          totalRounds.isAcceptableOrUnknown(
              data['total_rounds']!, _totalRoundsMeta));
    } else if (isInserting) {
      context.missing(_totalRoundsMeta);
    }
    if (data.containsKey('round_duration_seconds')) {
      context.handle(
          _roundDurationSecondsMeta,
          roundDurationSeconds.isAcceptableOrUnknown(
              data['round_duration_seconds']!, _roundDurationSecondsMeta));
    } else if (isInserting) {
      context.missing(_roundDurationSecondsMeta);
    }
    if (data.containsKey('winner')) {
      context.handle(_winnerMeta,
          winner.isAcceptableOrUnknown(data['winner']!, _winnerMeta));
    }
    if (data.containsKey('end_reason')) {
      context.handle(_endReasonMeta,
          endReason.isAcceptableOrUnknown(data['end_reason']!, _endReasonMeta));
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatchRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chungName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chung_name'])!,
      hongName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hong_name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      chungScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chung_score'])!,
      hongScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hong_score'])!,
      chungPenalties: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chung_penalties'])!,
      hongPenalties: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hong_penalties'])!,
      totalRounds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_rounds'])!,
      roundDurationSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}round_duration_seconds'])!,
      winner: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}winner']),
      endReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_reason']),
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $MatchRecordsTable createAlias(String alias) {
    return $MatchRecordsTable(attachedDatabase, alias);
  }
}

class MatchRecord extends DataClass implements Insertable<MatchRecord> {
  final String id;
  final String chungName;
  final String hongName;
  final String? category;
  final int chungScore;
  final int hongScore;
  final int chungPenalties;
  final int hongPenalties;
  final int totalRounds;
  final int roundDurationSeconds;
  final String? winner;
  final String? endReason;
  final String mode;
  final DateTime createdAt;
  final DateTime? completedAt;
  const MatchRecord(
      {required this.id,
      required this.chungName,
      required this.hongName,
      this.category,
      required this.chungScore,
      required this.hongScore,
      required this.chungPenalties,
      required this.hongPenalties,
      required this.totalRounds,
      required this.roundDurationSeconds,
      this.winner,
      this.endReason,
      required this.mode,
      required this.createdAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chung_name'] = Variable<String>(chungName);
    map['hong_name'] = Variable<String>(hongName);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['chung_score'] = Variable<int>(chungScore);
    map['hong_score'] = Variable<int>(hongScore);
    map['chung_penalties'] = Variable<int>(chungPenalties);
    map['hong_penalties'] = Variable<int>(hongPenalties);
    map['total_rounds'] = Variable<int>(totalRounds);
    map['round_duration_seconds'] = Variable<int>(roundDurationSeconds);
    if (!nullToAbsent || winner != null) {
      map['winner'] = Variable<String>(winner);
    }
    if (!nullToAbsent || endReason != null) {
      map['end_reason'] = Variable<String>(endReason);
    }
    map['mode'] = Variable<String>(mode);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  MatchRecordsCompanion toCompanion(bool nullToAbsent) {
    return MatchRecordsCompanion(
      id: Value(id),
      chungName: Value(chungName),
      hongName: Value(hongName),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      chungScore: Value(chungScore),
      hongScore: Value(hongScore),
      chungPenalties: Value(chungPenalties),
      hongPenalties: Value(hongPenalties),
      totalRounds: Value(totalRounds),
      roundDurationSeconds: Value(roundDurationSeconds),
      winner:
          winner == null && nullToAbsent ? const Value.absent() : Value(winner),
      endReason: endReason == null && nullToAbsent
          ? const Value.absent()
          : Value(endReason),
      mode: Value(mode),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory MatchRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchRecord(
      id: serializer.fromJson<String>(json['id']),
      chungName: serializer.fromJson<String>(json['chungName']),
      hongName: serializer.fromJson<String>(json['hongName']),
      category: serializer.fromJson<String?>(json['category']),
      chungScore: serializer.fromJson<int>(json['chungScore']),
      hongScore: serializer.fromJson<int>(json['hongScore']),
      chungPenalties: serializer.fromJson<int>(json['chungPenalties']),
      hongPenalties: serializer.fromJson<int>(json['hongPenalties']),
      totalRounds: serializer.fromJson<int>(json['totalRounds']),
      roundDurationSeconds:
          serializer.fromJson<int>(json['roundDurationSeconds']),
      winner: serializer.fromJson<String?>(json['winner']),
      endReason: serializer.fromJson<String?>(json['endReason']),
      mode: serializer.fromJson<String>(json['mode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chungName': serializer.toJson<String>(chungName),
      'hongName': serializer.toJson<String>(hongName),
      'category': serializer.toJson<String?>(category),
      'chungScore': serializer.toJson<int>(chungScore),
      'hongScore': serializer.toJson<int>(hongScore),
      'chungPenalties': serializer.toJson<int>(chungPenalties),
      'hongPenalties': serializer.toJson<int>(hongPenalties),
      'totalRounds': serializer.toJson<int>(totalRounds),
      'roundDurationSeconds': serializer.toJson<int>(roundDurationSeconds),
      'winner': serializer.toJson<String?>(winner),
      'endReason': serializer.toJson<String?>(endReason),
      'mode': serializer.toJson<String>(mode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  MatchRecord copyWith(
          {String? id,
          String? chungName,
          String? hongName,
          Value<String?> category = const Value.absent(),
          int? chungScore,
          int? hongScore,
          int? chungPenalties,
          int? hongPenalties,
          int? totalRounds,
          int? roundDurationSeconds,
          Value<String?> winner = const Value.absent(),
          Value<String?> endReason = const Value.absent(),
          String? mode,
          DateTime? createdAt,
          Value<DateTime?> completedAt = const Value.absent()}) =>
      MatchRecord(
        id: id ?? this.id,
        chungName: chungName ?? this.chungName,
        hongName: hongName ?? this.hongName,
        category: category.present ? category.value : this.category,
        chungScore: chungScore ?? this.chungScore,
        hongScore: hongScore ?? this.hongScore,
        chungPenalties: chungPenalties ?? this.chungPenalties,
        hongPenalties: hongPenalties ?? this.hongPenalties,
        totalRounds: totalRounds ?? this.totalRounds,
        roundDurationSeconds: roundDurationSeconds ?? this.roundDurationSeconds,
        winner: winner.present ? winner.value : this.winner,
        endReason: endReason.present ? endReason.value : this.endReason,
        mode: mode ?? this.mode,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  MatchRecord copyWithCompanion(MatchRecordsCompanion data) {
    return MatchRecord(
      id: data.id.present ? data.id.value : this.id,
      chungName: data.chungName.present ? data.chungName.value : this.chungName,
      hongName: data.hongName.present ? data.hongName.value : this.hongName,
      category: data.category.present ? data.category.value : this.category,
      chungScore:
          data.chungScore.present ? data.chungScore.value : this.chungScore,
      hongScore: data.hongScore.present ? data.hongScore.value : this.hongScore,
      chungPenalties: data.chungPenalties.present
          ? data.chungPenalties.value
          : this.chungPenalties,
      hongPenalties: data.hongPenalties.present
          ? data.hongPenalties.value
          : this.hongPenalties,
      totalRounds:
          data.totalRounds.present ? data.totalRounds.value : this.totalRounds,
      roundDurationSeconds: data.roundDurationSeconds.present
          ? data.roundDurationSeconds.value
          : this.roundDurationSeconds,
      winner: data.winner.present ? data.winner.value : this.winner,
      endReason: data.endReason.present ? data.endReason.value : this.endReason,
      mode: data.mode.present ? data.mode.value : this.mode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchRecord(')
          ..write('id: $id, ')
          ..write('chungName: $chungName, ')
          ..write('hongName: $hongName, ')
          ..write('category: $category, ')
          ..write('chungScore: $chungScore, ')
          ..write('hongScore: $hongScore, ')
          ..write('chungPenalties: $chungPenalties, ')
          ..write('hongPenalties: $hongPenalties, ')
          ..write('totalRounds: $totalRounds, ')
          ..write('roundDurationSeconds: $roundDurationSeconds, ')
          ..write('winner: $winner, ')
          ..write('endReason: $endReason, ')
          ..write('mode: $mode, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      chungName,
      hongName,
      category,
      chungScore,
      hongScore,
      chungPenalties,
      hongPenalties,
      totalRounds,
      roundDurationSeconds,
      winner,
      endReason,
      mode,
      createdAt,
      completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchRecord &&
          other.id == this.id &&
          other.chungName == this.chungName &&
          other.hongName == this.hongName &&
          other.category == this.category &&
          other.chungScore == this.chungScore &&
          other.hongScore == this.hongScore &&
          other.chungPenalties == this.chungPenalties &&
          other.hongPenalties == this.hongPenalties &&
          other.totalRounds == this.totalRounds &&
          other.roundDurationSeconds == this.roundDurationSeconds &&
          other.winner == this.winner &&
          other.endReason == this.endReason &&
          other.mode == this.mode &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class MatchRecordsCompanion extends UpdateCompanion<MatchRecord> {
  final Value<String> id;
  final Value<String> chungName;
  final Value<String> hongName;
  final Value<String?> category;
  final Value<int> chungScore;
  final Value<int> hongScore;
  final Value<int> chungPenalties;
  final Value<int> hongPenalties;
  final Value<int> totalRounds;
  final Value<int> roundDurationSeconds;
  final Value<String?> winner;
  final Value<String?> endReason;
  final Value<String> mode;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const MatchRecordsCompanion({
    this.id = const Value.absent(),
    this.chungName = const Value.absent(),
    this.hongName = const Value.absent(),
    this.category = const Value.absent(),
    this.chungScore = const Value.absent(),
    this.hongScore = const Value.absent(),
    this.chungPenalties = const Value.absent(),
    this.hongPenalties = const Value.absent(),
    this.totalRounds = const Value.absent(),
    this.roundDurationSeconds = const Value.absent(),
    this.winner = const Value.absent(),
    this.endReason = const Value.absent(),
    this.mode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchRecordsCompanion.insert({
    required String id,
    required String chungName,
    required String hongName,
    this.category = const Value.absent(),
    required int chungScore,
    required int hongScore,
    required int chungPenalties,
    required int hongPenalties,
    required int totalRounds,
    required int roundDurationSeconds,
    this.winner = const Value.absent(),
    this.endReason = const Value.absent(),
    required String mode,
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chungName = Value(chungName),
        hongName = Value(hongName),
        chungScore = Value(chungScore),
        hongScore = Value(hongScore),
        chungPenalties = Value(chungPenalties),
        hongPenalties = Value(hongPenalties),
        totalRounds = Value(totalRounds),
        roundDurationSeconds = Value(roundDurationSeconds),
        mode = Value(mode),
        createdAt = Value(createdAt);
  static Insertable<MatchRecord> custom({
    Expression<String>? id,
    Expression<String>? chungName,
    Expression<String>? hongName,
    Expression<String>? category,
    Expression<int>? chungScore,
    Expression<int>? hongScore,
    Expression<int>? chungPenalties,
    Expression<int>? hongPenalties,
    Expression<int>? totalRounds,
    Expression<int>? roundDurationSeconds,
    Expression<String>? winner,
    Expression<String>? endReason,
    Expression<String>? mode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chungName != null) 'chung_name': chungName,
      if (hongName != null) 'hong_name': hongName,
      if (category != null) 'category': category,
      if (chungScore != null) 'chung_score': chungScore,
      if (hongScore != null) 'hong_score': hongScore,
      if (chungPenalties != null) 'chung_penalties': chungPenalties,
      if (hongPenalties != null) 'hong_penalties': hongPenalties,
      if (totalRounds != null) 'total_rounds': totalRounds,
      if (roundDurationSeconds != null)
        'round_duration_seconds': roundDurationSeconds,
      if (winner != null) 'winner': winner,
      if (endReason != null) 'end_reason': endReason,
      if (mode != null) 'mode': mode,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? chungName,
      Value<String>? hongName,
      Value<String?>? category,
      Value<int>? chungScore,
      Value<int>? hongScore,
      Value<int>? chungPenalties,
      Value<int>? hongPenalties,
      Value<int>? totalRounds,
      Value<int>? roundDurationSeconds,
      Value<String?>? winner,
      Value<String?>? endReason,
      Value<String>? mode,
      Value<DateTime>? createdAt,
      Value<DateTime?>? completedAt,
      Value<int>? rowid}) {
    return MatchRecordsCompanion(
      id: id ?? this.id,
      chungName: chungName ?? this.chungName,
      hongName: hongName ?? this.hongName,
      category: category ?? this.category,
      chungScore: chungScore ?? this.chungScore,
      hongScore: hongScore ?? this.hongScore,
      chungPenalties: chungPenalties ?? this.chungPenalties,
      hongPenalties: hongPenalties ?? this.hongPenalties,
      totalRounds: totalRounds ?? this.totalRounds,
      roundDurationSeconds: roundDurationSeconds ?? this.roundDurationSeconds,
      winner: winner ?? this.winner,
      endReason: endReason ?? this.endReason,
      mode: mode ?? this.mode,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chungName.present) {
      map['chung_name'] = Variable<String>(chungName.value);
    }
    if (hongName.present) {
      map['hong_name'] = Variable<String>(hongName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (chungScore.present) {
      map['chung_score'] = Variable<int>(chungScore.value);
    }
    if (hongScore.present) {
      map['hong_score'] = Variable<int>(hongScore.value);
    }
    if (chungPenalties.present) {
      map['chung_penalties'] = Variable<int>(chungPenalties.value);
    }
    if (hongPenalties.present) {
      map['hong_penalties'] = Variable<int>(hongPenalties.value);
    }
    if (totalRounds.present) {
      map['total_rounds'] = Variable<int>(totalRounds.value);
    }
    if (roundDurationSeconds.present) {
      map['round_duration_seconds'] = Variable<int>(roundDurationSeconds.value);
    }
    if (winner.present) {
      map['winner'] = Variable<String>(winner.value);
    }
    if (endReason.present) {
      map['end_reason'] = Variable<String>(endReason.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchRecordsCompanion(')
          ..write('id: $id, ')
          ..write('chungName: $chungName, ')
          ..write('hongName: $hongName, ')
          ..write('category: $category, ')
          ..write('chungScore: $chungScore, ')
          ..write('hongScore: $hongScore, ')
          ..write('chungPenalties: $chungPenalties, ')
          ..write('hongPenalties: $hongPenalties, ')
          ..write('totalRounds: $totalRounds, ')
          ..write('roundDurationSeconds: $roundDurationSeconds, ')
          ..write('winner: $winner, ')
          ..write('endReason: $endReason, ')
          ..write('mode: $mode, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConsensusEventRecordsTable extends ConsensusEventRecords
    with TableInfo<$ConsensusEventRecordsTable, ConsensusEventRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsensusEventRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _matchIdMeta =
      const VerificationMeta('matchId');
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
      'match_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _windowIdMeta =
      const VerificationMeta('windowId');
  @override
  late final GeneratedColumn<String> windowId = GeneratedColumn<String>(
      'window_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _outcomeMeta =
      const VerificationMeta('outcome');
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
      'outcome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _awardedToMeta =
      const VerificationMeta('awardedTo');
  @override
  late final GeneratedColumn<String> awardedTo = GeneratedColumn<String>(
      'awarded_to', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _techniqueMeta =
      const VerificationMeta('technique');
  @override
  late final GeneratedColumn<String> technique = GeneratedColumn<String>(
      'technique', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pointsAwardedMeta =
      const VerificationMeta('pointsAwarded');
  @override
  late final GeneratedColumn<int> pointsAwarded = GeneratedColumn<int>(
      'points_awarded', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _roundMeta = const VerificationMeta('round');
  @override
  late final GeneratedColumn<int> round = GeneratedColumn<int>(
      'round', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _resolvedAtMsMeta =
      const VerificationMeta('resolvedAtMs');
  @override
  late final GeneratedColumn<int> resolvedAtMs = GeneratedColumn<int>(
      'resolved_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        matchId,
        windowId,
        outcome,
        awardedTo,
        technique,
        pointsAwarded,
        round,
        resolvedAtMs
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consensus_event_records';
  @override
  VerificationContext validateIntegrity(
      Insertable<ConsensusEventRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(_matchIdMeta,
          matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta));
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('window_id')) {
      context.handle(_windowIdMeta,
          windowId.isAcceptableOrUnknown(data['window_id']!, _windowIdMeta));
    } else if (isInserting) {
      context.missing(_windowIdMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(_outcomeMeta,
          outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta));
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('awarded_to')) {
      context.handle(_awardedToMeta,
          awardedTo.isAcceptableOrUnknown(data['awarded_to']!, _awardedToMeta));
    }
    if (data.containsKey('technique')) {
      context.handle(_techniqueMeta,
          technique.isAcceptableOrUnknown(data['technique']!, _techniqueMeta));
    }
    if (data.containsKey('points_awarded')) {
      context.handle(
          _pointsAwardedMeta,
          pointsAwarded.isAcceptableOrUnknown(
              data['points_awarded']!, _pointsAwardedMeta));
    } else if (isInserting) {
      context.missing(_pointsAwardedMeta);
    }
    if (data.containsKey('round')) {
      context.handle(
          _roundMeta, round.isAcceptableOrUnknown(data['round']!, _roundMeta));
    } else if (isInserting) {
      context.missing(_roundMeta);
    }
    if (data.containsKey('resolved_at_ms')) {
      context.handle(
          _resolvedAtMsMeta,
          resolvedAtMs.isAcceptableOrUnknown(
              data['resolved_at_ms']!, _resolvedAtMsMeta));
    } else if (isInserting) {
      context.missing(_resolvedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConsensusEventRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConsensusEventRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      matchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}match_id'])!,
      windowId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}window_id'])!,
      outcome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}outcome'])!,
      awardedTo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}awarded_to']),
      technique: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}technique']),
      pointsAwarded: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}points_awarded'])!,
      round: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}round'])!,
      resolvedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}resolved_at_ms'])!,
    );
  }

  @override
  $ConsensusEventRecordsTable createAlias(String alias) {
    return $ConsensusEventRecordsTable(attachedDatabase, alias);
  }
}

class ConsensusEventRecord extends DataClass
    implements Insertable<ConsensusEventRecord> {
  final String id;
  final String matchId;
  final String windowId;
  final String outcome;
  final String? awardedTo;
  final String? technique;
  final int pointsAwarded;
  final int round;
  final int resolvedAtMs;
  const ConsensusEventRecord(
      {required this.id,
      required this.matchId,
      required this.windowId,
      required this.outcome,
      this.awardedTo,
      this.technique,
      required this.pointsAwarded,
      required this.round,
      required this.resolvedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['match_id'] = Variable<String>(matchId);
    map['window_id'] = Variable<String>(windowId);
    map['outcome'] = Variable<String>(outcome);
    if (!nullToAbsent || awardedTo != null) {
      map['awarded_to'] = Variable<String>(awardedTo);
    }
    if (!nullToAbsent || technique != null) {
      map['technique'] = Variable<String>(technique);
    }
    map['points_awarded'] = Variable<int>(pointsAwarded);
    map['round'] = Variable<int>(round);
    map['resolved_at_ms'] = Variable<int>(resolvedAtMs);
    return map;
  }

  ConsensusEventRecordsCompanion toCompanion(bool nullToAbsent) {
    return ConsensusEventRecordsCompanion(
      id: Value(id),
      matchId: Value(matchId),
      windowId: Value(windowId),
      outcome: Value(outcome),
      awardedTo: awardedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(awardedTo),
      technique: technique == null && nullToAbsent
          ? const Value.absent()
          : Value(technique),
      pointsAwarded: Value(pointsAwarded),
      round: Value(round),
      resolvedAtMs: Value(resolvedAtMs),
    );
  }

  factory ConsensusEventRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConsensusEventRecord(
      id: serializer.fromJson<String>(json['id']),
      matchId: serializer.fromJson<String>(json['matchId']),
      windowId: serializer.fromJson<String>(json['windowId']),
      outcome: serializer.fromJson<String>(json['outcome']),
      awardedTo: serializer.fromJson<String?>(json['awardedTo']),
      technique: serializer.fromJson<String?>(json['technique']),
      pointsAwarded: serializer.fromJson<int>(json['pointsAwarded']),
      round: serializer.fromJson<int>(json['round']),
      resolvedAtMs: serializer.fromJson<int>(json['resolvedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'matchId': serializer.toJson<String>(matchId),
      'windowId': serializer.toJson<String>(windowId),
      'outcome': serializer.toJson<String>(outcome),
      'awardedTo': serializer.toJson<String?>(awardedTo),
      'technique': serializer.toJson<String?>(technique),
      'pointsAwarded': serializer.toJson<int>(pointsAwarded),
      'round': serializer.toJson<int>(round),
      'resolvedAtMs': serializer.toJson<int>(resolvedAtMs),
    };
  }

  ConsensusEventRecord copyWith(
          {String? id,
          String? matchId,
          String? windowId,
          String? outcome,
          Value<String?> awardedTo = const Value.absent(),
          Value<String?> technique = const Value.absent(),
          int? pointsAwarded,
          int? round,
          int? resolvedAtMs}) =>
      ConsensusEventRecord(
        id: id ?? this.id,
        matchId: matchId ?? this.matchId,
        windowId: windowId ?? this.windowId,
        outcome: outcome ?? this.outcome,
        awardedTo: awardedTo.present ? awardedTo.value : this.awardedTo,
        technique: technique.present ? technique.value : this.technique,
        pointsAwarded: pointsAwarded ?? this.pointsAwarded,
        round: round ?? this.round,
        resolvedAtMs: resolvedAtMs ?? this.resolvedAtMs,
      );
  ConsensusEventRecord copyWithCompanion(ConsensusEventRecordsCompanion data) {
    return ConsensusEventRecord(
      id: data.id.present ? data.id.value : this.id,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      windowId: data.windowId.present ? data.windowId.value : this.windowId,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      awardedTo: data.awardedTo.present ? data.awardedTo.value : this.awardedTo,
      technique: data.technique.present ? data.technique.value : this.technique,
      pointsAwarded: data.pointsAwarded.present
          ? data.pointsAwarded.value
          : this.pointsAwarded,
      round: data.round.present ? data.round.value : this.round,
      resolvedAtMs: data.resolvedAtMs.present
          ? data.resolvedAtMs.value
          : this.resolvedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConsensusEventRecord(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('windowId: $windowId, ')
          ..write('outcome: $outcome, ')
          ..write('awardedTo: $awardedTo, ')
          ..write('technique: $technique, ')
          ..write('pointsAwarded: $pointsAwarded, ')
          ..write('round: $round, ')
          ..write('resolvedAtMs: $resolvedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, matchId, windowId, outcome, awardedTo,
      technique, pointsAwarded, round, resolvedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsensusEventRecord &&
          other.id == this.id &&
          other.matchId == this.matchId &&
          other.windowId == this.windowId &&
          other.outcome == this.outcome &&
          other.awardedTo == this.awardedTo &&
          other.technique == this.technique &&
          other.pointsAwarded == this.pointsAwarded &&
          other.round == this.round &&
          other.resolvedAtMs == this.resolvedAtMs);
}

class ConsensusEventRecordsCompanion
    extends UpdateCompanion<ConsensusEventRecord> {
  final Value<String> id;
  final Value<String> matchId;
  final Value<String> windowId;
  final Value<String> outcome;
  final Value<String?> awardedTo;
  final Value<String?> technique;
  final Value<int> pointsAwarded;
  final Value<int> round;
  final Value<int> resolvedAtMs;
  final Value<int> rowid;
  const ConsensusEventRecordsCompanion({
    this.id = const Value.absent(),
    this.matchId = const Value.absent(),
    this.windowId = const Value.absent(),
    this.outcome = const Value.absent(),
    this.awardedTo = const Value.absent(),
    this.technique = const Value.absent(),
    this.pointsAwarded = const Value.absent(),
    this.round = const Value.absent(),
    this.resolvedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConsensusEventRecordsCompanion.insert({
    required String id,
    required String matchId,
    required String windowId,
    required String outcome,
    this.awardedTo = const Value.absent(),
    this.technique = const Value.absent(),
    required int pointsAwarded,
    required int round,
    required int resolvedAtMs,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        matchId = Value(matchId),
        windowId = Value(windowId),
        outcome = Value(outcome),
        pointsAwarded = Value(pointsAwarded),
        round = Value(round),
        resolvedAtMs = Value(resolvedAtMs);
  static Insertable<ConsensusEventRecord> custom({
    Expression<String>? id,
    Expression<String>? matchId,
    Expression<String>? windowId,
    Expression<String>? outcome,
    Expression<String>? awardedTo,
    Expression<String>? technique,
    Expression<int>? pointsAwarded,
    Expression<int>? round,
    Expression<int>? resolvedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      if (windowId != null) 'window_id': windowId,
      if (outcome != null) 'outcome': outcome,
      if (awardedTo != null) 'awarded_to': awardedTo,
      if (technique != null) 'technique': technique,
      if (pointsAwarded != null) 'points_awarded': pointsAwarded,
      if (round != null) 'round': round,
      if (resolvedAtMs != null) 'resolved_at_ms': resolvedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConsensusEventRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? matchId,
      Value<String>? windowId,
      Value<String>? outcome,
      Value<String?>? awardedTo,
      Value<String?>? technique,
      Value<int>? pointsAwarded,
      Value<int>? round,
      Value<int>? resolvedAtMs,
      Value<int>? rowid}) {
    return ConsensusEventRecordsCompanion(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      windowId: windowId ?? this.windowId,
      outcome: outcome ?? this.outcome,
      awardedTo: awardedTo ?? this.awardedTo,
      technique: technique ?? this.technique,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      round: round ?? this.round,
      resolvedAtMs: resolvedAtMs ?? this.resolvedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (windowId.present) {
      map['window_id'] = Variable<String>(windowId.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (awardedTo.present) {
      map['awarded_to'] = Variable<String>(awardedTo.value);
    }
    if (technique.present) {
      map['technique'] = Variable<String>(technique.value);
    }
    if (pointsAwarded.present) {
      map['points_awarded'] = Variable<int>(pointsAwarded.value);
    }
    if (round.present) {
      map['round'] = Variable<int>(round.value);
    }
    if (resolvedAtMs.present) {
      map['resolved_at_ms'] = Variable<int>(resolvedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsensusEventRecordsCompanion(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('windowId: $windowId, ')
          ..write('outcome: $outcome, ')
          ..write('awardedTo: $awardedTo, ')
          ..write('technique: $technique, ')
          ..write('pointsAwarded: $pointsAwarded, ')
          ..write('round: $round, ')
          ..write('resolvedAtMs: $resolvedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MatchRecordsTable matchRecords = $MatchRecordsTable(this);
  late final $ConsensusEventRecordsTable consensusEventRecords =
      $ConsensusEventRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [matchRecords, consensusEventRecords];
}

typedef $$MatchRecordsTableCreateCompanionBuilder = MatchRecordsCompanion
    Function({
  required String id,
  required String chungName,
  required String hongName,
  Value<String?> category,
  required int chungScore,
  required int hongScore,
  required int chungPenalties,
  required int hongPenalties,
  required int totalRounds,
  required int roundDurationSeconds,
  Value<String?> winner,
  Value<String?> endReason,
  required String mode,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$MatchRecordsTableUpdateCompanionBuilder = MatchRecordsCompanion
    Function({
  Value<String> id,
  Value<String> chungName,
  Value<String> hongName,
  Value<String?> category,
  Value<int> chungScore,
  Value<int> hongScore,
  Value<int> chungPenalties,
  Value<int> hongPenalties,
  Value<int> totalRounds,
  Value<int> roundDurationSeconds,
  Value<String?> winner,
  Value<String?> endReason,
  Value<String> mode,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$MatchRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MatchRecordsTable> {
  $$MatchRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chungName => $composableBuilder(
      column: $table.chungName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hongName => $composableBuilder(
      column: $table.hongName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chungScore => $composableBuilder(
      column: $table.chungScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hongScore => $composableBuilder(
      column: $table.hongScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chungPenalties => $composableBuilder(
      column: $table.chungPenalties,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hongPenalties => $composableBuilder(
      column: $table.hongPenalties, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalRounds => $composableBuilder(
      column: $table.totalRounds, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get roundDurationSeconds => $composableBuilder(
      column: $table.roundDurationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get winner => $composableBuilder(
      column: $table.winner, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endReason => $composableBuilder(
      column: $table.endReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$MatchRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchRecordsTable> {
  $$MatchRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chungName => $composableBuilder(
      column: $table.chungName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hongName => $composableBuilder(
      column: $table.hongName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chungScore => $composableBuilder(
      column: $table.chungScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hongScore => $composableBuilder(
      column: $table.hongScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chungPenalties => $composableBuilder(
      column: $table.chungPenalties,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hongPenalties => $composableBuilder(
      column: $table.hongPenalties,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalRounds => $composableBuilder(
      column: $table.totalRounds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get roundDurationSeconds => $composableBuilder(
      column: $table.roundDurationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get winner => $composableBuilder(
      column: $table.winner, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endReason => $composableBuilder(
      column: $table.endReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$MatchRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchRecordsTable> {
  $$MatchRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chungName =>
      $composableBuilder(column: $table.chungName, builder: (column) => column);

  GeneratedColumn<String> get hongName =>
      $composableBuilder(column: $table.hongName, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get chungScore => $composableBuilder(
      column: $table.chungScore, builder: (column) => column);

  GeneratedColumn<int> get hongScore =>
      $composableBuilder(column: $table.hongScore, builder: (column) => column);

  GeneratedColumn<int> get chungPenalties => $composableBuilder(
      column: $table.chungPenalties, builder: (column) => column);

  GeneratedColumn<int> get hongPenalties => $composableBuilder(
      column: $table.hongPenalties, builder: (column) => column);

  GeneratedColumn<int> get totalRounds => $composableBuilder(
      column: $table.totalRounds, builder: (column) => column);

  GeneratedColumn<int> get roundDurationSeconds => $composableBuilder(
      column: $table.roundDurationSeconds, builder: (column) => column);

  GeneratedColumn<String> get winner =>
      $composableBuilder(column: $table.winner, builder: (column) => column);

  GeneratedColumn<String> get endReason =>
      $composableBuilder(column: $table.endReason, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$MatchRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MatchRecordsTable,
    MatchRecord,
    $$MatchRecordsTableFilterComposer,
    $$MatchRecordsTableOrderingComposer,
    $$MatchRecordsTableAnnotationComposer,
    $$MatchRecordsTableCreateCompanionBuilder,
    $$MatchRecordsTableUpdateCompanionBuilder,
    (
      MatchRecord,
      BaseReferences<_$AppDatabase, $MatchRecordsTable, MatchRecord>
    ),
    MatchRecord,
    PrefetchHooks Function()> {
  $$MatchRecordsTableTableManager(_$AppDatabase db, $MatchRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chungName = const Value.absent(),
            Value<String> hongName = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<int> chungScore = const Value.absent(),
            Value<int> hongScore = const Value.absent(),
            Value<int> chungPenalties = const Value.absent(),
            Value<int> hongPenalties = const Value.absent(),
            Value<int> totalRounds = const Value.absent(),
            Value<int> roundDurationSeconds = const Value.absent(),
            Value<String?> winner = const Value.absent(),
            Value<String?> endReason = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchRecordsCompanion(
            id: id,
            chungName: chungName,
            hongName: hongName,
            category: category,
            chungScore: chungScore,
            hongScore: hongScore,
            chungPenalties: chungPenalties,
            hongPenalties: hongPenalties,
            totalRounds: totalRounds,
            roundDurationSeconds: roundDurationSeconds,
            winner: winner,
            endReason: endReason,
            mode: mode,
            createdAt: createdAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chungName,
            required String hongName,
            Value<String?> category = const Value.absent(),
            required int chungScore,
            required int hongScore,
            required int chungPenalties,
            required int hongPenalties,
            required int totalRounds,
            required int roundDurationSeconds,
            Value<String?> winner = const Value.absent(),
            Value<String?> endReason = const Value.absent(),
            required String mode,
            required DateTime createdAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchRecordsCompanion.insert(
            id: id,
            chungName: chungName,
            hongName: hongName,
            category: category,
            chungScore: chungScore,
            hongScore: hongScore,
            chungPenalties: chungPenalties,
            hongPenalties: hongPenalties,
            totalRounds: totalRounds,
            roundDurationSeconds: roundDurationSeconds,
            winner: winner,
            endReason: endReason,
            mode: mode,
            createdAt: createdAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MatchRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MatchRecordsTable,
    MatchRecord,
    $$MatchRecordsTableFilterComposer,
    $$MatchRecordsTableOrderingComposer,
    $$MatchRecordsTableAnnotationComposer,
    $$MatchRecordsTableCreateCompanionBuilder,
    $$MatchRecordsTableUpdateCompanionBuilder,
    (
      MatchRecord,
      BaseReferences<_$AppDatabase, $MatchRecordsTable, MatchRecord>
    ),
    MatchRecord,
    PrefetchHooks Function()>;
typedef $$ConsensusEventRecordsTableCreateCompanionBuilder
    = ConsensusEventRecordsCompanion Function({
  required String id,
  required String matchId,
  required String windowId,
  required String outcome,
  Value<String?> awardedTo,
  Value<String?> technique,
  required int pointsAwarded,
  required int round,
  required int resolvedAtMs,
  Value<int> rowid,
});
typedef $$ConsensusEventRecordsTableUpdateCompanionBuilder
    = ConsensusEventRecordsCompanion Function({
  Value<String> id,
  Value<String> matchId,
  Value<String> windowId,
  Value<String> outcome,
  Value<String?> awardedTo,
  Value<String?> technique,
  Value<int> pointsAwarded,
  Value<int> round,
  Value<int> resolvedAtMs,
  Value<int> rowid,
});

class $$ConsensusEventRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ConsensusEventRecordsTable> {
  $$ConsensusEventRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get windowId => $composableBuilder(
      column: $table.windowId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get awardedTo => $composableBuilder(
      column: $table.awardedTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get technique => $composableBuilder(
      column: $table.technique, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pointsAwarded => $composableBuilder(
      column: $table.pointsAwarded, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get round => $composableBuilder(
      column: $table.round, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get resolvedAtMs => $composableBuilder(
      column: $table.resolvedAtMs, builder: (column) => ColumnFilters(column));
}

class $$ConsensusEventRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConsensusEventRecordsTable> {
  $$ConsensusEventRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get windowId => $composableBuilder(
      column: $table.windowId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get awardedTo => $composableBuilder(
      column: $table.awardedTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get technique => $composableBuilder(
      column: $table.technique, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pointsAwarded => $composableBuilder(
      column: $table.pointsAwarded,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get round => $composableBuilder(
      column: $table.round, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get resolvedAtMs => $composableBuilder(
      column: $table.resolvedAtMs,
      builder: (column) => ColumnOrderings(column));
}

class $$ConsensusEventRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConsensusEventRecordsTable> {
  $$ConsensusEventRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<String> get windowId =>
      $composableBuilder(column: $table.windowId, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get awardedTo =>
      $composableBuilder(column: $table.awardedTo, builder: (column) => column);

  GeneratedColumn<String> get technique =>
      $composableBuilder(column: $table.technique, builder: (column) => column);

  GeneratedColumn<int> get pointsAwarded => $composableBuilder(
      column: $table.pointsAwarded, builder: (column) => column);

  GeneratedColumn<int> get round =>
      $composableBuilder(column: $table.round, builder: (column) => column);

  GeneratedColumn<int> get resolvedAtMs => $composableBuilder(
      column: $table.resolvedAtMs, builder: (column) => column);
}

class $$ConsensusEventRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConsensusEventRecordsTable,
    ConsensusEventRecord,
    $$ConsensusEventRecordsTableFilterComposer,
    $$ConsensusEventRecordsTableOrderingComposer,
    $$ConsensusEventRecordsTableAnnotationComposer,
    $$ConsensusEventRecordsTableCreateCompanionBuilder,
    $$ConsensusEventRecordsTableUpdateCompanionBuilder,
    (
      ConsensusEventRecord,
      BaseReferences<_$AppDatabase, $ConsensusEventRecordsTable,
          ConsensusEventRecord>
    ),
    ConsensusEventRecord,
    PrefetchHooks Function()> {
  $$ConsensusEventRecordsTableTableManager(
      _$AppDatabase db, $ConsensusEventRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsensusEventRecordsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsensusEventRecordsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConsensusEventRecordsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> matchId = const Value.absent(),
            Value<String> windowId = const Value.absent(),
            Value<String> outcome = const Value.absent(),
            Value<String?> awardedTo = const Value.absent(),
            Value<String?> technique = const Value.absent(),
            Value<int> pointsAwarded = const Value.absent(),
            Value<int> round = const Value.absent(),
            Value<int> resolvedAtMs = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConsensusEventRecordsCompanion(
            id: id,
            matchId: matchId,
            windowId: windowId,
            outcome: outcome,
            awardedTo: awardedTo,
            technique: technique,
            pointsAwarded: pointsAwarded,
            round: round,
            resolvedAtMs: resolvedAtMs,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String matchId,
            required String windowId,
            required String outcome,
            Value<String?> awardedTo = const Value.absent(),
            Value<String?> technique = const Value.absent(),
            required int pointsAwarded,
            required int round,
            required int resolvedAtMs,
            Value<int> rowid = const Value.absent(),
          }) =>
              ConsensusEventRecordsCompanion.insert(
            id: id,
            matchId: matchId,
            windowId: windowId,
            outcome: outcome,
            awardedTo: awardedTo,
            technique: technique,
            pointsAwarded: pointsAwarded,
            round: round,
            resolvedAtMs: resolvedAtMs,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConsensusEventRecordsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ConsensusEventRecordsTable,
        ConsensusEventRecord,
        $$ConsensusEventRecordsTableFilterComposer,
        $$ConsensusEventRecordsTableOrderingComposer,
        $$ConsensusEventRecordsTableAnnotationComposer,
        $$ConsensusEventRecordsTableCreateCompanionBuilder,
        $$ConsensusEventRecordsTableUpdateCompanionBuilder,
        (
          ConsensusEventRecord,
          BaseReferences<_$AppDatabase, $ConsensusEventRecordsTable,
              ConsensusEventRecord>
        ),
        ConsensusEventRecord,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MatchRecordsTableTableManager get matchRecords =>
      $$MatchRecordsTableTableManager(_db, _db.matchRecords);
  $$ConsensusEventRecordsTableTableManager get consensusEventRecords =>
      $$ConsensusEventRecordsTableTableManager(_db, _db.consensusEventRecords);
}
