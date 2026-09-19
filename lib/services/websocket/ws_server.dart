import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:taekwondo_score/core/enums/match_status.dart';
import 'package:taekwondo_score/core/models/consensus_result.dart';
import 'package:taekwondo_score/core/models/judge.dart';
import 'package:taekwondo_score/core/models/match_event.dart';
import 'package:taekwondo_score/core/models/vote.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ws_message_types.dart';
import '../../core/enums/device_role.dart';
import '../../core/enums/fighter_side.dart';
import '../../core/enums/technique.dart';
// import '../../core/models/models.dart';
import '../../core/models/ws_message.dart';
import '../consensus/consensus_engine.dart';

typedef OnMatchStateChanged = void Function(MatchState state);

class WsServer {
  WsServer({required this.onMatchStateChanged});

  final OnMatchStateChanged onMatchStateChanged;

  HttpServer? _server;
  final Map<String, WebSocketChannel> _clients = {}; // senderId → channel
  final Map<String, DeviceRole> _clientRoles = {};
  ConsensusEngine? _consensusEngine;
  MatchState? _matchState;
  Timer? _timerTick;
  Timer? _undoTimer;

  final _uuid = const Uuid();
  String? _sessionToken;

  // ─── Server Lifecycle ───────────────────────────────────────────────────────

  Future<String> start(MatchState initialState, String sessionToken) async {
    _matchState = initialState;
    _sessionToken = sessionToken;

    _consensusEngine = ConsensusEngine(
      matchId: initialState.matchId,
      onResult: _onConsensusResult,
    );

    final handler = webSocketHandler(_onClientConnected);
    _server = await shelf_io.serve(handler, '0.0.0.0', AppConstants.wsPort);

    // Get local IP for QR display
    final ip = await _getLocalIp();
    return ip;
  }

  Future<void> stop() async {
    _timerTick?.cancel();
    _undoTimer?.cancel();
    _consensusEngine?.dispose();
    for (final client in _clients.values) {
      await client.sink.close();
    }
    await _server?.close(force: true);
  }

  // ─── Client Connection ──────────────────────────────────────────────────────

  void _onClientConnected(WebSocketChannel channel) {
    channel.stream.listen(
      (data) => _onMessage(data as String, channel),
      onDone: () => _onClientDisconnected(channel),
      onError: (e) => _onClientDisconnected(channel),
    );
  }

  void _onClientDisconnected(WebSocketChannel channel) {
    final senderId = _clients.entries
        .firstWhere(
          (e) => e.value == channel,
          orElse: () => MapEntry('', channel),
        )
        .key;

    if (senderId.isEmpty) return;
    _clients.remove(senderId);
    _clientRoles.remove(senderId);

    // Mark judge as disconnected in match state
    final updatedJudges = _matchState!.judges.map((j) {
      if (j.id == senderId) return j.copyWith(isConnected: false);
      return j;
    }).toList();

    _updateAndBroadcast(_matchState!.copyWith(judges: updatedJudges));
  }

  // ─── Message Routing ────────────────────────────────────────────────────────

  void _onMessage(String raw, WebSocketChannel channel) {
    try {
      final msg = WsMessage.fromJsonString(raw);
      _clients[msg.senderId] = channel;
      _clientRoles[msg.senderId] = msg.senderRole;

      switch (msg.type) {
        case WsMessageTypes.judgeConnect:
          _handleJudgeConnect(msg, channel);
          break;
        case WsMessageTypes.judgeDisconnect:
          _onClientDisconnected(channel);
          break;
        case WsMessageTypes.judgeVote:
          _handleJudgeVote(msg);
          break;
        case WsMessageTypes.ping:
          _handlePing(msg, channel);
          break;
        case WsMessageTypes.timerStart:
          _handleTimerStart();
          break;
        case WsMessageTypes.timerStop:
          _handleTimerStop();
          break;
        case WsMessageTypes.undoLastPoint:
          _handleUndo(msg);
          break;
        case WsMessageTypes.issueGamjeom:
          _handleGamjeomOverride(msg);
          break;
        case WsMessageTypes.endRound:
          _handleEndRound();
          break;
        case WsMessageTypes.endMatch:
          _handleEndMatch(reason: 'manual');
          break;
      }
    } catch (e) {
      // Log parse errors but don't crash
      print('WsServer: Failed to parse message: $e');
    }
  }

  // ─── Handler: Judge Connect ─────────────────────────────────────────────────

  void _handleJudgeConnect(WsMessage msg, WebSocketChannel channel) {
    final token = msg.payload['sessionToken'] as String?;
    if (token != _sessionToken) {
      _send(channel, WsMessage.create(
        type: WsMessageTypes.wsError,
        senderId: 'server',
        senderRole: DeviceRole.scoreboard,
        payload: {'code': 'invalid_token', 'message': 'Invalid session token'},
      ));
      return;
    }

    final slot = msg.payload['judgeSlot'] as int;
    final deviceName = msg.payload['deviceName'] as String?;

    final updatedJudges = _matchState!.judges.map((j) {
      if (j.slot == slot) {
        return Judge(
          id: msg.senderId,
          slot: slot,
          deviceName: deviceName,
          isConnected: true,
        );
      }
      return j;
    }).toList();

    // If no judge existed for this slot yet, add one
    if (!updatedJudges.any((j) => j.slot == slot)) {
      updatedJudges.add(Judge(
        id: msg.senderId,
        slot: slot,
        deviceName: deviceName,
        isConnected: true,
      ));
    }

    _matchState = _matchState!.copyWith(judges: updatedJudges);

    // Ack to this specific client with full state
    _send(channel, WsMessage.create(
      type: WsMessageTypes.sessionJoinAck,
      senderId: 'server',
      senderRole: DeviceRole.scoreboard,
      payload: {
        'judgeSlot': slot,
        'matchState': _matchState!.toJson(),
      },
    ));

    // Broadcast updated judge list to everyone
    _broadcastState();
  }

  // ─── Handler: Vote ──────────────────────────────────────────────────────────

  void _handleJudgeVote(WsMessage msg) {
    if (_matchState?.status != MatchStatus.active) return;

    final fighter = FighterSide.values.byName(msg.payload['fighter'] as String);
    final technique = Technique.values.byName(msg.payload['technique'] as String);
    final clientTs = msg.payload['clientTs'] as int;
    final judge = _matchState!.judges.firstWhere(
      (j) => j.id == msg.senderId,
      orElse: () => Judge(
        id: msg.senderId,
        slot: 0,
        isConnected: true,
      ),
    );

    // Determine windowId — reuse active window or generate new
    final windowId = _matchState!.activeWindow?.windowId ?? _uuid.v4();

    final vote = Vote(
      id: _uuid.v4(),
      matchId: _matchState!.matchId,
      windowId: windowId,
      judgeId: msg.senderId,
      judgeSlot: judge.slot,
      targetFighter: fighter,
      technique: technique,
      clientTimestampMs: clientTs,
      serverReceivedMs: msg.timestampMs,
      round: _matchState!.currentRound,
    );

    // If this is the first vote, notify clients a window just opened
    if (_matchState!.activeWindow == null) {
      _broadcastMessage(WsMessage.create(
        type: WsMessageTypes.consensusOpen,
        senderId: 'server',
        senderRole: DeviceRole.scoreboard,
        payload: {
          'windowId': windowId,
          'expiresAt': DateTime.now()
                  .millisecondsSinceEpoch +
              AppConstants.consensusWindowMs,
        },
      ));

      final window = ConsensusWindow(
        windowId: windowId,
        openedAtMs: DateTime.now().millisecondsSinceEpoch,
        expiresAtMs: DateTime.now().millisecondsSinceEpoch +
            AppConstants.consensusWindowMs,
        votes: [],
      );
      _matchState = _matchState!.copyWith(activeWindow: window);
    }

    // Update window in state (for broadcasting current vote tally to judges)
    final updatedWindow = _matchState!.activeWindow!.withVote(vote);
    _matchState = _matchState!.copyWith(activeWindow: updatedWindow);
    _broadcastState();

    // Pass to consensus engine
    _consensusEngine!.receiveVote(vote);
  }

  // ─── Handler: Consensus Result ──────────────────────────────────────────────

  void _onConsensusResult(ConsensusResult result, ConsensusWindow window) {
    var state = _matchState!.copyWith(clearActiveWindow: true);

    if (result.outcome == ConsensusOutcome.awarded) {
      final fighter = result.awardedTo!;
      final technique = result.technique!;

      if (technique == Technique.gamjeom) {
        // Penalty awarded — +1 to opponent, +1 penalty to target
        state = _applyGamjeom(state, fighter);
      } else {
        // Points awarded
        if (fighter == FighterSide.chung) {
          state = state.copyWith(chungScore: state.chungScore + result.pointsAwarded);
        } else {
          state = state.copyWith(hongScore: state.hongScore + result.pointsAwarded);
        }
      }

      // Start undo window
      state = state.copyWith(
        lastResult: result,
        undoExpiresAt: DateTime.now()
            .add(Duration(seconds: AppConstants.undoWindowSeconds)),
      );

      _undoTimer = Timer(
        Duration(seconds: AppConstants.undoWindowSeconds),
        () => _matchState = _matchState!.copyWith(clearUndoExpiry: true),
      );

      // Check penalty forfeit
      if (state.chungPenalties >= AppConstants.maxPenaltiesBeforeForfeit) {
        _handleEndMatch(reason: 'penalty_forfeit', winner: FighterSide.hong);
        return;
      }
      if (state.hongPenalties >= AppConstants.maxPenaltiesBeforeForfeit) {
        _handleEndMatch(reason: 'penalty_forfeit', winner: FighterSide.chung);
        return;
      }
    }

    _updateAndBroadcast(state);

    _broadcastMessage(WsMessage.create(
      type: WsMessageTypes.consensusResult,
      senderId: 'server',
      senderRole: DeviceRole.scoreboard,
      payload: result.toJson(),
    ));
  }

  // ─── Handler: Timer ─────────────────────────────────────────────────────────

  void _handleTimerStart() {
    if (_matchState?.status != MatchStatus.paused &&
        _matchState?.status != MatchStatus.setup) return;

    _matchState = _matchState!.copyWith(
      status: MatchStatus.active,
      timerRunning: true,
    );

    _timerTick = Timer.periodic(
      Duration(milliseconds: AppConstants.timerBroadcastIntervalMs),
      (_) => _onTimerTick(),
    );

    _broadcastState();
  }

  void _handleTimerStop() {
    _timerTick?.cancel();
    _matchState = _matchState!.copyWith(
      status: MatchStatus.paused,
      timerRunning: false,
    );
    _broadcastState();
  }

  void _onTimerTick() {
    if (_matchState == null) return;
    final remaining = _matchState!.timerRemainingMs -
        AppConstants.timerBroadcastIntervalMs;

    if (remaining <= 0) {
      _timerTick?.cancel();
      _matchState = _matchState!.copyWith(timerRemainingMs: 0, timerRunning: false);
      _broadcastState();
      _handleEndRound();
    } else {
      _matchState = _matchState!.copyWith(timerRemainingMs: remaining);
      _broadcastState();
    }
  }

  // ─── Handler: Round / Match End ─────────────────────────────────────────────

  void _handleEndRound() {
    _timerTick?.cancel();
    _consensusEngine?.cancelActiveWindow();

    final state = _matchState!;
    final isLastRound = state.currentRound >= state.totalRounds;

    if (isLastRound) {
      // Check for tie → Golden Round
      if (state.chungScore == state.hongScore) {
        _startGoldenRound();
      } else {
        _handleEndMatch(reason: 'score');
      }
    } else {
      // Transition to next round
      final nextRound = state.currentRound + 1;
      _matchState = state.copyWith(
        status: MatchStatus.roundBreak,
        currentRound: nextRound,
        timerRunning: false,
      );
      _consensusEngine?.setRound(nextRound);

      _broadcastMessage(WsMessage.create(
        type: WsMessageTypes.roundTransition,
        senderId: 'server',
        senderRole: DeviceRole.scoreboard,
        payload: {
          'fromRound': state.currentRound,
          'toRound': nextRound,
        },
      ));
      _broadcastState();
    }
  }

  void _startGoldenRound() {
    _matchState = _matchState!.copyWith(
      status: MatchStatus.goldenRound,
      timerRunning: false,
    );
    _broadcastState();
  }

  void _handleEndMatch({
    required String reason,
    FighterSide? winner,
  }) {
    _timerTick?.cancel();
    _consensusEngine?.cancelActiveWindow();

    String? winnerStr;
    if (winner != null) {
      winnerStr = winner.name;
    } else {
      final s = _matchState!;
      if (s.chungScore > s.hongScore) {
        winnerStr = FighterSide.chung.name;
      } else if (s.hongScore > s.chungScore) {
        winnerStr = FighterSide.hong.name;
      }
      // draw stays null
    }

    _matchState = _matchState!.copyWith(
      status: MatchStatus.finished,
      timerRunning: false,
    );

    _broadcastMessage(WsMessage.create(
      type: WsMessageTypes.matchEnd,
      senderId: 'server',
      senderRole: DeviceRole.scoreboard,
      payload: {'winner': winnerStr, 'reason': reason},
    ));
    _broadcastState();
    onMatchStateChanged(_matchState!);
  }

  // ─── Handler: Undo ──────────────────────────────────────────────────────────

  void _handleUndo(WsMessage msg) {
    final state = _matchState!;
    if (!state.canUndo) return;

    final result = state.lastResult!;
    final fighter = result.awardedTo!;
    final technique = result.technique!;

    MatchState updated;
    if (technique == Technique.gamjeom) {
      // Reverse gamjeom: remove opponent point, remove penalty from target
      final opponent = fighter.opponent;
      if (opponent == FighterSide.chung) {
        updated = state.copyWith(
          chungScore: (state.chungScore - 1).clamp(0, 999),
          hongPenalties: (state.hongPenalties - 1).clamp(0, 999),
        );
      } else {
        updated = state.copyWith(
          hongScore: (state.hongScore - 1).clamp(0, 999),
          chungPenalties: (state.chungPenalties - 1).clamp(0, 999),
        );
      }
    } else {
      if (fighter == FighterSide.chung) {
        updated = state.copyWith(
          chungScore: (state.chungScore - result.pointsAwarded).clamp(0, 999),
        );
      } else {
        updated = state.copyWith(
          hongScore: (state.hongScore - result.pointsAwarded).clamp(0, 999),
        );
      }
    }

    updated = updated.copyWith(
      lastResult: result.markUndone(),
      clearUndoExpiry: true,
    );

    _undoTimer?.cancel();
    _updateAndBroadcast(updated);
  }

  // ─── Handler: Gamjeom Override ──────────────────────────────────────────────

  void _handleGamjeomOverride(WsMessage msg) {
    final fighter = FighterSide.values.byName(
      msg.payload['targetFighter'] as String,
    );
    final updated = _applyGamjeom(_matchState!, fighter);
    _updateAndBroadcast(updated);
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  MatchState _applyGamjeom(MatchState state, FighterSide penalisedFighter) {
    if (penalisedFighter == FighterSide.chung) {
      return state.copyWith(
        chungPenalties: state.chungPenalties + 1,
        hongScore: state.hongScore + 1,
      );
    } else {
      return state.copyWith(
        hongPenalties: state.hongPenalties + 1,
        chungScore: state.chungScore + 1,
      );
    }
  }

  void _updateAndBroadcast(MatchState state) {
    _matchState = state;
    onMatchStateChanged(state);
    _broadcastState();
  }

  void _broadcastState() {
    if (_matchState == null) return;
    _broadcastMessage(WsMessage.create(
      type: WsMessageTypes.matchState,
      senderId: 'server',
      senderRole: DeviceRole.scoreboard,
      payload: _matchState!.toJson(),
    ));
  }

  void _broadcastMessage(WsMessage msg) {
    final data = msg.toJsonString();
    for (final client in _clients.values) {
      try {
        client.sink.add(data);
      } catch (_) {}
    }
  }

  void _send(WebSocketChannel channel, WsMessage msg) {
    try {
      channel.sink.add(msg.toJsonString());
    } catch (_) {}
  }

  void _handlePing(WsMessage msg, WebSocketChannel channel) {
    _send(channel, WsMessage.create(
      type: WsMessageTypes.pong,
      senderId: 'server',
      senderRole: DeviceRole.scoreboard,
      payload: {
        'clientTs': msg.payload['clientTs'],
        'serverTs': DateTime.now().millisecondsSinceEpoch,
      },
    ));
  }

  /// Called by the scoreboard UI directly (no WebSocket round-trip needed).
  void handleLocalCommand(String type, Map<String, dynamic> payload) {
    switch (type) {
      case WsMessageTypes.timerStart:
        _handleTimerStart();
        break;
      case WsMessageTypes.timerStop:
        _handleTimerStop();
        break;
      case WsMessageTypes.undoLastPoint:
        // Build a minimal WsMessage-like call
        if (_matchState != null) _handleUndo(_fakeMsg(type, payload));
        break;
      case WsMessageTypes.issueGamjeom:
        _handleGamjeomOverride(_fakeMsg(type, payload));
        break;
      case WsMessageTypes.endRound:
        _handleEndRound();
        break;
      case WsMessageTypes.endMatch:
        _handleEndMatch(reason: 'manual');
        break;
    }
  }

  WsMessage _fakeMsg(String type, Map<String, dynamic> payload) {
    return WsMessage.create(
      type: type,
      senderId: 'local',
      senderRole: DeviceRole.chiefJury,
      payload: payload,
    );
  }

  Future<String> _getLocalIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
    return '127.0.0.1';
  }
}