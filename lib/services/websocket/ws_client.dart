import 'dart:async';
import 'dart:math';

import 'package:taekwondo_score/core/models/consensus_result.dart';
import 'package:taekwondo_score/core/models/match_event.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/ws_message_types.dart';
import '../../core/enums/device_role.dart';
import '../../core/enums/fighter_side.dart';
import '../../core/enums/technique.dart';
// import '../../core/models/models.dart';
import '../../core/models/ws_message.dart';

enum WsConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

typedef OnStateUpdate = void Function(MatchState state);
typedef OnConnectionChange = void Function(WsConnectionState state);
typedef OnConsensusOpen = void Function(String windowId, int expiresAtMs);
typedef OnConsensusResult = void Function(ConsensusResult result);

class WsClient {
  WsClient({
    required this.deviceId,
    required this.judgeSlot,
    required this.sessionToken,
    this.deviceName,
    required this.onStateUpdate,
    required this.onConnectionChange,
    required this.onConsensusOpen,
    required this.onConsensusResult,
  });

  final String deviceId;
  final int judgeSlot;
  final String sessionToken;
  final String? deviceName;
  final OnStateUpdate onStateUpdate;
  final OnConnectionChange onConnectionChange;
  final OnConsensusOpen onConsensusOpen;
  final OnConsensusResult onConsensusResult;

  WebSocketChannel? _channel;
  WsConnectionState _connectionState = WsConnectionState.disconnected;
  String? _serverUrl;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _clockSyncTimer;
  int _clockOffsetMs = 0;

  final _uuid = const Uuid();

  WsConnectionState get connectionState => _connectionState;
  int get clockOffsetMs => _clockOffsetMs;

  // ─── Connect ────────────────────────────────────────────────────────────────

  Future<void> connect(String ip, int port) async {
    _serverUrl = 'ws://$ip:$port${AppConstants.wsPath.isEmpty ? '' : AppConstants.wsPath}';
    _reconnectAttempts = 0;
    await _doConnect();
  }

  Future<void> _doConnect() async {
    _setConnectionState(WsConnectionState.connecting);
    try {
      final uri = Uri.parse(_serverUrl!);
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      _setConnectionState(WsConnectionState.connected);
      _reconnectAttempts = 0;

      _channel!.stream.listen(
        _onMessage,
        onDone: _onDisconnected,
        onError: (_) => _onDisconnected(),
      );

      // Send join message
      _send(WsMessage.create(
        type: WsMessageTypes.judgeConnect,
        senderId: deviceId,
        senderRole: DeviceRole.judge,
        payload: {
          'judgeSlot': judgeSlot,
          'sessionToken': sessionToken,
          'deviceName': deviceName ?? 'Judge $judgeSlot',
        },
      ));

      // Start clock sync
      _syncClock();
      _clockSyncTimer = Timer.periodic(
        Duration(minutes: AppConstants.clockSyncIntervalMinutes),
        (_) => _syncClock(),
      );
    } catch (e) {
      _onDisconnected();
    }
  }

  void _onDisconnected() {
    _clockSyncTimer?.cancel();
    _channel = null;
    _setConnectionState(WsConnectionState.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= AppConstants.wsReconnectMaxAttempts) {
      _setConnectionState(WsConnectionState.disconnected);
      return;
    }

    // Exponential backoff: 2s, 4s, 8s, ... capped at 30s
    final delay = Duration(
      seconds: min(
        AppConstants.wsReconnectDelay.inSeconds * (1 << _reconnectAttempts),
        AppConstants.wsReconnectMaxDelay.inSeconds,
      ),
    );
    _reconnectAttempts++;

    _reconnectTimer = Timer(delay, _doConnect);
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _clockSyncTimer?.cancel();
    _send(WsMessage.create(
      type: WsMessageTypes.judgeDisconnect,
      senderId: deviceId,
      senderRole: DeviceRole.judge,
      payload: {},
    ));
    _channel?.sink.close();
    _channel = null;
    _setConnectionState(WsConnectionState.disconnected);
  }

  // ─── Sending Actions ────────────────────────────────────────────────────────

  void sendVote({
    required FighterSide fighter,
    required Technique technique,
    String? windowId,
  }) {
    if (_connectionState != WsConnectionState.connected) return;

    _send(WsMessage.create(
      type: WsMessageTypes.judgeVote,
      senderId: deviceId,
      senderRole: DeviceRole.judge,
      payload: {
        'fighter': fighter.name,
        'technique': technique.name,
        'clientTs': _adjustedTimestamp(),
        if (windowId != null) 'windowId': windowId,
      },
    ));
  }

  // ─── Message Handling ───────────────────────────────────────────────────────

  void _onMessage(dynamic raw) {
    try {
      final msg = WsMessage.fromJsonString(raw as String);

      switch (msg.type) {
        case WsMessageTypes.matchState:
        case WsMessageTypes.sessionJoinAck:
          final stateJson = msg.type == WsMessageTypes.sessionJoinAck
              ? msg.payload['matchState'] as Map<String, dynamic>
              : msg.payload;
          onStateUpdate(MatchState.fromJson(stateJson));
          break;

        case WsMessageTypes.consensusOpen:
          onConsensusOpen(
            msg.payload['windowId'] as String,
            msg.payload['expiresAt'] as int,
          );
          break;

        case WsMessageTypes.consensusResult:
          onConsensusResult(ConsensusResult.fromJson(msg.payload));
          break;

        case WsMessageTypes.pong:
          _handlePong(msg);
          break;

        case WsMessageTypes.wsError:
          // Handle auth or other errors
          print('WsClient error: ${msg.payload['message']}');
          break;
      }
    } catch (e) {
      print('WsClient: Failed to parse message: $e');
    }
  }

  // ─── Clock Sync ─────────────────────────────────────────────────────────────

  void _syncClock() {
    _send(WsMessage.create(
      type: WsMessageTypes.ping,
      senderId: deviceId,
      senderRole: DeviceRole.judge,
      payload: {'clientTs': DateTime.now().millisecondsSinceEpoch},
    ));
  }

  void _handlePong(WsMessage msg) {
    final t1 = msg.payload['clientTs'] as int;
    final t2 = msg.payload['serverTs'] as int;
    final t3 = DateTime.now().millisecondsSinceEpoch;
    _clockOffsetMs = ((t2 - t1) + (t2 - t3)) ~/ 2;

    if (_clockOffsetMs.abs() > AppConstants.maxClockSkewWarningMs) {
      print('WsClient: WARNING — clock skew is ${_clockOffsetMs}ms');
    }
  }

  int _adjustedTimestamp() =>
      DateTime.now().millisecondsSinceEpoch - _clockOffsetMs;

  // ─── Helpers ────────────────────────────────────────────────────────────────

  void _send(WsMessage msg) {
    try {
      _channel?.sink.add(msg.toJsonString());
    } catch (_) {}
  }

  void _setConnectionState(WsConnectionState state) {
    _connectionState = state;
    onConnectionChange(state);
  }

  void dispose() {
    disconnect();
  }
}