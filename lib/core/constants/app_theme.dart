import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const background = Color(0xFF0A0A0A);
  static const surface = Color(0xFF161616);
  static const surfaceElevated = Color(0xFF1E1E1E);
  static const border = Color(0xFF2A2A2A);
  static const chung = Color(0xFF2979FF);
  static const chungDark = Color(0xFF1565C0);
  static const chungGlow = Color(0x332979FF);
  static const hong = Color(0xFFFF1744);
  static const hongDark = Color(0xFFB71C1C);
  static const hongGlow = Color(0x33FF1744);
  static const success = Color(0xFF00E676);
  static const warning = Color(0xFFFFAB00);
  static const error = Color(0xFFFF5252);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9E9E9E);
  static const textDisabled = Color(0xFF424242);
}

class AppTextStyles {
  AppTextStyles._();
  static const scoreHuge = TextStyle(fontFamily: 'RobotoMono', fontSize: 120, fontWeight: FontWeight.w900, letterSpacing: -4, height: 1);
  static const scoreLarge = TextStyle(fontFamily: 'RobotoMono', fontSize: 72, fontWeight: FontWeight.w900, letterSpacing: -2, height: 1);
  static const scoreMedium = TextStyle(fontFamily: 'RobotoMono', fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1, height: 1);
  static const labelLarge = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppColors.textSecondary);
  static const labelMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: AppColors.textSecondary);
  static const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const headline = TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.textPrimary);
}

class AppDimens {
  AppDimens._();
  static const radiusSm = 6.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  static const paddingSm = 12.0;
  static const paddingMd = 20.0;
  static const paddingLg = 32.0;
}