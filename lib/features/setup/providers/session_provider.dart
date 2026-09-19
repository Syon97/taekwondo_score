import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/enums/app_mode.dart';
import '../../../core/enums/device_role.dart';
import '../../../core/models/match_event.dart'; // MatchState lives here
import '../../../core/models/judge.dart';
import '../../../core/models/round_config.dart';
import '../../../core/enums/match_status.dart';

class SessionConfig {
  final AppMode mode;
  final String matchId;
  final String chungName;
  final String hongName;
  final String? weightClass;
  final String? category;
  final RoundConfig roundConfig;
  final DeviceRole deviceRole;
  final int judgeSlot;
  final String sessionToken;
  final String? serverIp;

  const SessionConfig({
    required this.mode, required this.matchId, required this.chungName,
    required this.hongName, this.weightClass, this.category,
    required this.roundConfig, required this.deviceRole,
    required this.judgeSlot, required this.sessionToken, this.serverIp,
  });

  SessionConfig copyWith({AppMode? mode, String? chungName, String? hongName,
    String? weightClass, String? category, RoundConfig? roundConfig,
    DeviceRole? deviceRole, int? judgeSlot, String? serverIp}) {
    return SessionConfig(
      mode: mode ?? this.mode, matchId: matchId,
      chungName: chungName ?? this.chungName, hongName: hongName ?? this.hongName,
      weightClass: weightClass ?? this.weightClass, category: category ?? this.category,
      roundConfig: roundConfig ?? this.roundConfig, deviceRole: deviceRole ?? this.deviceRole,
      judgeSlot: judgeSlot ?? this.judgeSlot, sessionToken: sessionToken,
      serverIp: serverIp ?? this.serverIp,
    );
  }

  MatchState toInitialMatchState() {
    return MatchState(
      matchId: matchId, chungName: chungName, hongName: hongName,
      chungScore: 0, hongScore: 0, chungPenalties: 0, hongPenalties: 0,
      currentRound: 1, totalRounds: roundConfig.totalRounds,
      status: MatchStatus.setup,
      timerRemainingMs: roundConfig.roundDurationSeconds * 1000,
      timerRunning: false,
      judges: List.generate(AppConstants.kyorugiJudgeCount,
        (i) => Judge(id: 'slot_${i + 1}', slot: i + 1, isConnected: false)),
    );
  }

  Map<String, dynamic> toQrPayload(String ip) => {
    'ip': ip, 'port': AppConstants.wsPort,
    'sessionToken': sessionToken, 'matchId': matchId,
  };
}

class SessionNotifier extends Notifier<SessionConfig?> {
  @override
  SessionConfig? build() => null;

  void startNew({required AppMode mode}) {
    state = SessionConfig(
      mode: mode, matchId: const Uuid().v4(),
      chungName: '', hongName: '',
      roundConfig: RoundConfig.colourBeltU18,
      deviceRole: DeviceRole.scoreboard,
      judgeSlot: 1,
      sessionToken: _generateToken(),
    );
  }

  void updateMatchDetails({String? chungName, String? hongName,
    String? weightClass, String? category, RoundConfig? roundConfig}) {
    if (state == null) return;
    state = state!.copyWith(chungName: chungName, hongName: hongName,
      weightClass: weightClass, category: category, roundConfig: roundConfig);
  }

  void setRole(DeviceRole role, {int judgeSlot = 1}) {
    if (state == null) return;
    state = state!.copyWith(deviceRole: role, judgeSlot: judgeSlot);
  }

  void setServerIp(String ip) {
    if (state == null) return;
    state = state!.copyWith(serverIp: ip);
  }

  void reset() => state = null;

  String _generateToken() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(AppConstants.sessionTokenLength,
      (_) => chars[rng.nextInt(chars.length)]).join();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionConfig?>(SessionNotifier.new);