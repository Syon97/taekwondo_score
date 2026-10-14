import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ws_message_types.dart';
import '../../core/enums/device_role.dart';
import '../../core/models/judge.dart';
import '../../core/models/ws_message.dart';
import '../../core/models/poomsae_models.dart';

typedef OnPoomsaeStateChanged = void Function(PoomsaeSessionState state);

class PoomsaeServer {
  PoomsaeServer({required this.onStateChanged});

  final OnPoomsaeStateChanged onStateChanged;
  HttpServer? _server;
  final Map<String, WebSocketChannel> _clients = {};
  PoomsaeSessionState? _state;
  String? _sessionToken;
  final _uuid = const Uuid();

  Future<String> start(
      PoomsaeSessionState initialState, String sessionToken) async {
    _state = initialState;
    _sessionToken = sessionToken;
    final handler = webSocketHandler(_onClientConnected);
    _server = await shelf_io.serve(
        handler, InternetAddress.anyIPv4, AppConstants.wsPort);
    return _getLocalIp();
  }

  Future<void> stop() async {
    for (final c in _clients.values) await c.sink.close();
    await _server?.close(force: true);
  }

  void handleLocalCommand(String type, Map<String, dynamic> payload) {
    final msg = WsMessage.create(
      type: type,
      senderId: 'local',
      senderRole: DeviceRole.chiefJury,
      payload: payload,
    );
    _routeMessage(msg);
  }

  // ── Connections ────────────────────────────────────────────────────────────

  void _onClientConnected(WebSocketChannel channel) {
    channel.stream.listen(
      (data) => _onRaw(data as String, channel),
      onDone: () => _onDisconnected(channel),
      onError: (_) => _onDisconnected(channel),
    );
  }

  void _onDisconnected(WebSocketChannel channel) {
    final id = _clients.entries
        .firstWhere((e) => e.value == channel,
            orElse: () => MapEntry('', channel))
        .key;
    if (id.isEmpty) return;
    _clients.remove(id);
    final updated = _state!.judges
        .map((j) => j.id == id ? j.copyWith(isConnected: false) : j)
        .toList();
    _updateAndBroadcast(_state!.copyWith(judges: updated));
  }

  void _onRaw(String raw, WebSocketChannel channel) {
    try {
      final msg = WsMessage.fromJsonString(raw);
      _clients[msg.senderId] = channel;
      if (msg.type == WsMessageTypes.judgeConnect) {
        _handleJudgeConnect(msg, channel);
      } else {
        _routeMessage(msg);
      }
    } catch (_) {}
  }

  void _handleJudgeConnect(WsMessage msg, WebSocketChannel channel) {
    final token = msg.payload['sessionToken'] as String?;
    if (token != _sessionToken) return;
    final slot = msg.payload['judgeSlot'] as int;
    final deviceName = msg.payload['deviceName'] as String?;

    final updatedJudges = _state!.judges.map((j) {
      if (j.slot == slot) {
        return Judge(id: msg.senderId, slot: slot,
            deviceName: deviceName, isConnected: true);
      }
      return j;
    }).toList();

    _state = _state!.copyWith(judges: updatedJudges);

    _send(channel, WsMessage.create(
      type: WsMessageTypes.sessionJoinAck,
      senderId: 'server',
      senderRole: DeviceRole.scoreboard,
      payload: {'judgeSlot': slot, 'poomsaeState': _state!.toJson()},
    ));
    _broadcastState();
  }

  // ── Message routing ────────────────────────────────────────────────────────

  void _routeMessage(WsMessage msg) {
    switch (msg.type) {
      case WsMessageTypes.poomsaeStartPerformance:
        _handleStartPerformance();
        break;
      case WsMessageTypes.poomsaeOpenScoring:
        _handleOpenScoring();
        break;
      case WsMessageTypes.poomsaeSubmitScore:
        _handleSubmitScore(msg);
        break;
      case WsMessageTypes.poomsaeCalculate:
        _handleCalculate();
        break;
      case WsMessageTypes.poomsaeNextAthlete:
        _handleNextAthlete();
        break;
    }
  }

  void _handleStartPerformance() {
    _updateAndBroadcast(
        _state!.copyWith(status: PoomsaeSessionStatus.performing));
  }

  void _handleOpenScoring() {
    _updateAndBroadcast(
        _state!.copyWith(status: PoomsaeSessionStatus.scoring));
    _broadcast(WsMessage.create(
      type: WsMessageTypes.poomsaeScoringOpen,
      senderId: 'server',
      senderRole: DeviceRole.scoreboard,
      payload: {
        'athleteId': _state!.currentAthlete?.id,
        'athleteName': _state!.currentAthlete?.name,
      },
    ));
  }

  void _handleSubmitScore(WsMessage msg) {
    if (_state?.status != PoomsaeSessionStatus.scoring) return;
    final athlete = _state!.currentAthlete;
    if (athlete == null) return;

    // Prevent duplicate submission from same judge
    if (_state!.hasJudgeSubmitted(msg.senderId)) return;

    final judge = _state!.judges.firstWhere(
      (j) => j.id == msg.senderId,
      orElse: () => Judge(id: msg.senderId, slot: 0, isConnected: true),
    );

    final score = PoomsaeScore(
      judgeId: msg.senderId,
      judgeSlot: judge.slot,
      athleteId: athlete.id,
      athleteName: athlete.name,
      accuracy: (msg.payload['accuracy'] as num).toDouble(),
      presentation: (msg.payload['presentation'] as num).toDouble(),
      submittedAt: DateTime.now(),
    );

    final updatedScores = Map<String, List<PoomsaeScore>>.from(
        _state!.submittedScores);
    updatedScores[athlete.id] = [
      ...(updatedScores[athlete.id] ?? []),
      score,
    ];

    _updateAndBroadcast(_state!.copyWith(submittedScores: updatedScores));
  }

  void _handleCalculate() {
    final athlete = _state!.currentAthlete;
    if (athlete == null) return;
    final scores = _state!.submittedScores[athlete.id] ?? [];
    if (scores.length < 5) return; // need all 5

    final result = PoomsaeResult.calculate(
      athleteId: athlete.id,
      athleteName: athlete.name,
      scores: scores,
    );

    final updatedResults = Map<String, PoomsaeResult>.from(_state!.results)
      ..[athlete.id] = result;

    _updateAndBroadcast(_state!.copyWith(
      results: updatedResults,
      status: PoomsaeSessionStatus.calculated,
    ));

    _broadcast(WsMessage.create(
      type: WsMessageTypes.poomsaeResultCalculated,
      senderId: 'server',
      senderRole: DeviceRole.scoreboard,
      payload: {
        'athleteId': result.athleteId,
        'athleteName': result.athleteName,
        'finalScore': result.finalScore,
        'droppedHighSlot': result.droppedHighSlot,
        'droppedLowSlot': result.droppedLowSlot,
        'scores': result.scores.map((s) => s.toJson()).toList(),
      },
    ));
  }

  void _handleNextAthlete() {
    final next = _state!.currentAthleteIndex + 1;
    if (next >= _state!.athletes.length) {
      _updateAndBroadcast(
          _state!.copyWith(status: PoomsaeSessionStatus.finished));
    } else {
      _updateAndBroadcast(_state!.copyWith(
        currentAthleteIndex: next,
        status: PoomsaeSessionStatus.performing,
      ));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _updateAndBroadcast(PoomsaeSessionState state) {
    _state = state;
    onStateChanged(state);
    _broadcastState();
  }

  void _broadcastState() {
    if (_state == null) return;
    _broadcast(WsMessage.create(
      type: WsMessageTypes.poomsaeSessionState,
      senderId: 'server',
      senderRole: DeviceRole.scoreboard,
      payload: _state!.toJson(),
    ));
  }

  void _broadcast(WsMessage msg) {
    final data = msg.toJsonString();
    for (final c in _clients.values) {
      try { c.sink.add(data); } catch (_) {}
    }
  }

  void _send(WebSocketChannel channel, WsMessage msg) {
    try { channel.sink.add(msg.toJsonString()); } catch (_) {}
  }

  Future<String> _getLocalIp() async {
    final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4, includeLoopback: false);
    for (final i in interfaces) {
      for (final a in i.addresses) {
        if (a.address.startsWith('192.168.') ||
            a.address.startsWith('10.')) return a.address;
      }
    }
    for (final i in interfaces) {
      for (final a in i.addresses) {
        if (!a.isLoopback) return a.address;
      }
    }
    return '127.0.0.1';
  }
}