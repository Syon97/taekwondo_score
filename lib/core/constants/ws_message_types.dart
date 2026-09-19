/// All WebSocket message type identifiers.
/// Used as the [type] field in every WsMessage envelope.
class WsMessageTypes {
  WsMessageTypes._();

  // ─── Judge → Server ─────────────────────────────────────────────────────────
  static const String judgeVote = 'judge_vote';
  static const String judgeConnect = 'judge_connect';
  static const String judgeDisconnect = 'judge_disconnect';
  static const String ping = 'ping';

  // ─── Chief Jury → Server ────────────────────────────────────────────────────
  static const String timerStart = 'timer_start';
  static const String timerStop = 'timer_stop';
  static const String undoLastPoint = 'undo_last_point';
  static const String issueGamjeom = 'issue_gamjeom';
  static const String endRound = 'end_round';
  static const String endMatch = 'end_match';

  // ─── Server → All Clients ───────────────────────────────────────────────────
  static const String matchState = 'match_state';
  static const String consensusOpen = 'consensus_open';
  static const String consensusResult = 'consensus_result';
  static const String pong = 'pong';
  static const String roundTransition = 'round_transition';
  static const String matchEnd = 'match_end';

  // ─── Server → Specific Client ───────────────────────────────────────────────
  static const String sessionJoinAck = 'session_join_ack';
  static const String wsError = 'error';
}