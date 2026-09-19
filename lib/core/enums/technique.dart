enum Technique {
  punch,     // 1 point
  bodyKick,  // 2 points
  headKick,  // 3 points
  gamjeom,   // Penalty — 0 points for target, +1 to opponent
}

extension TechniqueX on Technique {
  int get points {
    switch (this) {
      case Technique.punch:
        return 1;
      case Technique.bodyKick:
        return 2;
      case Technique.headKick:
        return 3;
      case Technique.gamjeom:
        return 0; // points applied to opponent separately
    }
  }

  String get label {
    switch (this) {
      case Technique.punch:
        return 'Punch';
      case Technique.bodyKick:
        return 'Body Kick';
      case Technique.headKick:
        return 'Head Kick';
      case Technique.gamjeom:
        return 'Gam-jeom';
    }
  }

  String get shortLabel {
    switch (this) {
      case Technique.punch:
        return 'P';
      case Technique.bodyKick:
        return 'BK';
      case Technique.headKick:
        return 'HK';
      case Technique.gamjeom:
        return 'GJ';
    }
  }

  bool get isScoringTechnique => this != Technique.gamjeom;
}