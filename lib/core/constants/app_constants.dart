class AppConstants {
  AppConstants._();

  // ─── WebSocket ──────────────────────────────────────────────────────────────
  static const int wsPort = 8080;
  static const String wsPath = '/score';
  static const Duration wsReconnectDelay = Duration(seconds: 2);
  static const Duration wsReconnectMaxDelay = Duration(seconds: 30);
  static const int wsReconnectMaxAttempts = 20;

  // ─── Consensus Engine ───────────────────────────────────────────────────────
  /// How long a voting window stays open after the first vote (milliseconds)
  static const int consensusWindowMs = 1000;

  /// Minimum votes required for a consensus (out of 4 judges)
  static const int consensusThreshold = 3;

  /// Total number of corner judges in Kyorugi mode
  static const int kyorugiJudgeCount = 4;

  // ─── Match Rules ────────────────────────────────────────────────────────────
  static const int maxPenaltiesBeforeForfeit = 10;

  /// Seconds after a point is awarded during which it can be undone
  static const int undoWindowSeconds = 10;

  // ─── Timer ──────────────────────────────────────────────────────────────────
  /// How often the server broadcasts a timer tick to clients (ms)
  static const int timerBroadcastIntervalMs = 100;

  // ─── Clock Sync ─────────────────────────────────────────────────────────────
  /// How often judges send a clock sync ping (minutes)
  static const int clockSyncIntervalMinutes = 5;

  /// Maximum acceptable clock skew before a warning is shown (ms)
  static const int maxClockSkewWarningMs = 500;

  // ─── Session ────────────────────────────────────────────────────────────────
  static const int sessionTokenLength = 8;
}