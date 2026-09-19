import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/match_event.dart';
import '../../../services/websocket/ws_server.dart';
import '../../setup/providers/session_provider.dart';

class ServerState {
  final bool isStarting;
  final bool isRunning;
  final String? localIp;
  final String? error;
  final MatchState? matchState;

  const ServerState({this.isStarting = false, this.isRunning = false,
    this.localIp, this.error, this.matchState});

  ServerState copyWith({bool? isStarting, bool? isRunning, String? localIp,
    String? error, MatchState? matchState}) {
    return ServerState(
      isStarting: isStarting ?? this.isStarting,
      isRunning: isRunning ?? this.isRunning,
      localIp: localIp ?? this.localIp,
      error: error ?? this.error,
      matchState: matchState ?? this.matchState,
    );
  }

  int get connectedJudges => matchState?.judges.where((j) => j.isConnected).length ?? 0;
  bool get allJudgesReady => connectedJudges >= 4;
}

class ServerNotifier extends Notifier<ServerState> {
  WsServer? _server;

  @override
  ServerState build() => const ServerState();

  Future<void> startServer() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    state = state.copyWith(isStarting: true, error: null);
    try {
      _server = WsServer(onMatchStateChanged: (ms) => state = state.copyWith(matchState: ms));
      final initialState = session.toInitialMatchState();
      final ip = await _server!.start(initialState, session.sessionToken);
      ref.read(sessionProvider.notifier).setServerIp(ip);
      state = state.copyWith(isStarting: false, isRunning: true, localIp: ip, matchState: initialState);
    } catch (e) {
      state = state.copyWith(isStarting: false, isRunning: false, error: 'Failed to start: $e');
    }
  }

  Future<void> stopServer() async {
    await _server?.stop();
    _server = null;
    state = const ServerState();
  }

  void sendCommand(String type, Map<String, dynamic> payload) {
    _server?.handleLocalCommand(type, payload);
  }
}

final serverProvider = NotifierProvider<ServerNotifier, ServerState>(ServerNotifier.new);