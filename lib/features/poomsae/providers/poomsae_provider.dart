import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/ws_message_types.dart';
import '../../../core/models/judge.dart';
import '../../../core/models/poomsae_models.dart';
import '../../../services/poomsae/poomsae_server.dart';
import '../../setup/providers/session_provider.dart';

class PoomsaeServerState {
  final bool isStarting;
  final bool isRunning;
  final String? localIp;
  final String? error;
  final PoomsaeSessionState? sessionState;

  const PoomsaeServerState({
    this.isStarting = false,
    this.isRunning = false,
    this.localIp,
    this.error,
    this.sessionState,
  });

  PoomsaeServerState copyWith({
    bool? isStarting, bool? isRunning,
    String? localIp, String? error,
    PoomsaeSessionState? sessionState,
  }) => PoomsaeServerState(
    isStarting: isStarting ?? this.isStarting,
    isRunning: isRunning ?? this.isRunning,
    localIp: localIp ?? this.localIp,
    error: error ?? this.error,
    sessionState: sessionState ?? this.sessionState,
  );

  int get connectedJudges =>
      sessionState?.judges.where((j) => j.isConnected).length ?? 0;
}

class PoomsaeServerNotifier extends Notifier<PoomsaeServerState> {
  PoomsaeServer? _server;
  final _uuid = const Uuid();

  @override
  PoomsaeServerState build() => const PoomsaeServerState();

  Future<void> startServer(List<PoomsaeAthlete> athletes,
      String sessionName) async {
    final session = ref.read(sessionProvider);
    if (session == null) return;

    state = state.copyWith(isStarting: true, error: null);
    try {
      _server = PoomsaeServer(
        onStateChanged: (s) => state = state.copyWith(sessionState: s),
      );

      final initialState = PoomsaeSessionState(
        sessionId: _uuid.v4(),
        sessionName: sessionName,
        athletes: athletes,
        currentAthleteIndex: 0,
        submittedScores: {},
        results: {},
        judges: List.generate(5, (i) =>
            Judge(id: 'slot_${i + 1}', slot: i + 1, isConnected: false)),
        status: PoomsaeSessionStatus.setup,
      );

      final ip = await _server!.start(initialState, session.sessionToken);
      ref.read(sessionProvider.notifier).setServerIp(ip);

      state = state.copyWith(
        isStarting: false, isRunning: true,
        localIp: ip, sessionState: initialState,
      );
    } catch (e) {
      state = state.copyWith(
          isStarting: false, isRunning: false,
          error: 'Failed to start: $e');
    }
  }

  void sendCommand(String type, [Map<String, dynamic> payload = const {}]) {
    _server?.handleLocalCommand(type, payload);
  }

  void startPerformance() =>
      sendCommand(WsMessageTypes.poomsaeStartPerformance);

  void openScoring() =>
      sendCommand(WsMessageTypes.poomsaeOpenScoring);

  void calculateResult() =>
      sendCommand(WsMessageTypes.poomsaeCalculate);

  void nextAthlete() =>
      sendCommand(WsMessageTypes.poomsaeNextAthlete);

  Future<void> stopServer() async {
    await _server?.stop();
    _server = null;
    state = const PoomsaeServerState();
  }
}

final poomsaeServerProvider =
    NotifierProvider<PoomsaeServerNotifier, PoomsaeServerState>(
        PoomsaeServerNotifier.new);