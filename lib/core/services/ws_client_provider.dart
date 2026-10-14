import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taekwondo_score/core/constants/ws_message_types.dart';
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
  final bool poomsaeScoringOpen;

  const WsClientState({this.connectionState = WsConnectionState.disconnected,
    this.matchState, this.activeWindowId, this.activeWindowExpiresAt,
    this.lastResult, this.poomsaeScoringOpen = false,});

  bool get isConnected => connectionState == WsConnectionState.connected;

  WsClientState copyWith({WsConnectionState? connectionState, MatchState? matchState,
    String? activeWindowId, int? activeWindowExpiresAt,
    bool clearWindow = false, ConsensusResult? lastResult,
    bool? poomsaeScoringOpen }) {
    return WsClientState(
      connectionState: connectionState ?? this.connectionState,
      matchState: matchState ?? this.matchState,
      activeWindowId: clearWindow ? null : activeWindowId ?? this.activeWindowId,
      activeWindowExpiresAt: clearWindow ? null : activeWindowExpiresAt ?? this.activeWindowExpiresAt,
      lastResult: lastResult ?? this.lastResult,
      poomsaeScoringOpen: poomsaeScoringOpen ?? this.poomsaeScoringOpen,
    );
  }
}

class WsClientNotifier extends Notifier<WsClientState> {
  WsClient? _client;
  bool poomsaeScoringOpen = false;
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
      onPoomsaeScoringOpen: (isOpen) {
        state = state.copyWith(poomsaeScoringOpen: isOpen);
      },
    );
    await _client!.connect(ip, port);
  }

  void sendPoomsaeScore({
    required double accuracy,
    required double presentation,
  }) {
    if (_client == null) return;
    // Reuse the raw send mechanism
    _client!.sendRawPayload(
      type: WsMessageTypes.poomsaeSubmitScore,
      payload: {
        'accuracy': accuracy,
        'presentation': presentation,
        'clientTs': DateTime.now().millisecondsSinceEpoch,
      },
    );
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