enum MatchStatus {
  setup,        // Not yet started — waiting for judges to connect
  active,       // Timer running, scoring live
  paused,       // Timer paused by chief jury mid-round
  roundBreak,   // Between rounds, rest period
  goldenRound,  // Tie-breaker round
  finished,     // Match concluded
}

enum ConsensusOutcome {
  awarded,      // 3-of-4 agreement — point(s) given
  noConsensus,  // Window expired without 3-of-4
  cancelled,    // Window voided by chief jury override
}