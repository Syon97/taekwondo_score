enum FighterSide {
  chung, // Blue
  hong,  // Red
}

extension FighterSideX on FighterSide {
  String get label => this == FighterSide.chung ? 'Chung' : 'Hong';
  String get koreanLabel => this == FighterSide.chung ? '청' : '홍';

  /// Returns the opponent side
  FighterSide get opponent =>
      this == FighterSide.chung ? FighterSide.hong : FighterSide.chung;
}