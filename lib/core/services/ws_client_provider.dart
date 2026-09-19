import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../enums/fighter_side.dart';
import '../enums/technique.dart';
import '../models/match_event.dart';
import '../models/consensus_result.dart';
import '../../services/websocket/ws_client.dart';

class WsClientState {
  final WsConnectionState connectionState;
  final MatchState? matchState;
  final String? activeWindowId;
  final int? activeWindowExpiresAt;
  final ConsensusResult? lastResult;

  const WsClientState({this.connectionState = WsConnectionState.disconnected,
    this.matchState, this.activeWindowId, this.activeWindowExpiresAt, this.lastResult});

  bool get isConnected => connectionState == WsConnectionState.connected;

  WsClientState copyWith({WsConnectionState? connectionState, MatchState? matchState,
    String? activeWindowId, int? activeWindowExpiresAt,
    bool clearWindow = false, ConsensusResult? lastResult}) {
    return WsClientState(
      connectionState: connectionState ?? this.connectionState,
      matchState: matchState ?? this.matchState,
      activeWindowId: clearWindow ? null : activeWindowId ?? this.activeWindowId,
      activeWindowExpiresAt: clearWindow ? null : activeWindowExpiresAt ?? this.activeWindowExpiresAt,
      lastResult: lastResult ?? this.lastResult,
    );
  }
}

class WsClientNotifier extends Notifier<WsClientState> {
  WsClient? _client;
  final _deviceId = const Uuid().v4();

  @override
  WsClientState build() => const WsClientState();

  Future<void> connect({required String ip, required int port,
    required String sessionToken, required int judgeSlot}) async {
    _client?.dispose();
    _client = WsClient(
      deviceId: _deviceId, judgeSlot: judgeSlot,
      sessionToken: sessionToken, deviceName: 'Judge $judgeSlot',
      onStateUpdate: (ms) => state = state.copyWith(matchState: ms),
      onConnectionChange: (cs) => state = state.copyWith(connectionState: cs),
      onConsensusOpen: (wId, exp) => state = state.copyWith(activeWindowId: wId, activeWindowExpiresAt: exp),
      onConsensusResult: (r) => state = state.copyWith(lastResult: r, clearWindow: true),
    );
    await _client!.connect(ip, port);
  }

  void sendVote({required FighterSide fighter, required Technique technique}) {
    _client?.sendVote(fighter: fighter, technique: technique, windowId: state.activeWindowId);
  }

  void disconnect() {
    _client?.disconnect();
    state = const WsClientState();
  }

  @override
  void dispose() { _client?.dispose(); }
}

final wsClientProvider = NotifierProvider<WsClientNotifier, WsClientState>(WsClientNotifier.new);