enum ConsensusOutcome {
  awarded,     // 3-of-4 agreement reached — points applied
  noConsensus, // Window expired, insufficient agreement
  cancelled,   // Voided by chief jury override
}