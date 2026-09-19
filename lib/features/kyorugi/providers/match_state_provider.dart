import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taekwondo_score/features/pairing/providers/pairing_provider.dart';
import '../../../core/enums/fighter_side.dart';
import '../../../core/enums/technique.dart';
import '../../../core/models/match_event.dart';
import '../../../core/models/ws_message.dart';
import '../../../core/constants/ws_message_types.dart';
import '../../../core/enums/device_role.dart';
import '../../pairing/providers/pairing_provider.dart';

// Re-expose MatchState from the server provider so screens only
// need one import. Scoreboard reads from serverProvider.matchState.
final matchStateProvider = Provider<MatchState?>((ref) {
  return ref.watch(serverProvider).matchState;
});

// Helper provider: formats timer as MM:SS string
final timerDisplayProvider = Provider<String>((ref) {
  final ms = ref.watch(matchStateProvider)?.timerRemainingMs ?? 0;
  final totalSec = (ms / 1000).ceil();
  final m = totalSec ~/ 60;
  final s = totalSec % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
});

// Commands the scoreboard/chief jury sends to the server via WsServer directly.
// Since WsServer lives inside serverProvider, we call it through a notifier method.
// We expose command methods here so screens don't import WsServer directly.
class MatchCommandNotifier extends Notifier<void> {
  @override
  void build() {}

  void _send(String type, Map<String, dynamic> payload) {
    // Commands from the scoreboard go directly into the local WsServer
    // by broadcasting as if sent by chief jury. The server handles them
    // internally via the same message router.
    // We do this by calling WsServer's public command methods directly.
    // Access via serverProvider's internal server ref.
    // For now, commands are wired through a dedicated method on ServerNotifier.
    ref.read(serverProvider.notifier).sendCommand(type, payload);
  }

  void timerStart() => _send(WsMessageTypes.timerStart, {});
  void timerStop() => _send(WsMessageTypes.timerStop, {});
  void undoLastPoint() => _send(WsMessageTypes.undoLastPoint, {});
  void issueGamjeom(FighterSide target) =>
      _send(WsMessageTypes.issueGamjeom, {'targetFighter': target.name});
  void endRound() => _send(WsMessageTypes.endRound, {});
  void endMatch() => _send(WsMessageTypes.endMatch, {});
}

final matchCommandProvider =
    NotifierProvider<MatchCommandNotifier, void>(MatchCommandNotifier.new);