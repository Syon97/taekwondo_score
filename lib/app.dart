import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/setup/screens/mode_select_screen.dart';
import 'features/setup/screens/match_setup_screen.dart';
import 'features/setup/screens/role_select_screen.dart';
import 'features/pairing/screens/qr_display_screen.dart';
import 'features/pairing/screens/qr_scan_screen.dart';
import 'features/kyorugi/screens/scoreboard_screen.dart';
import 'features/kyorugi/screens/judge_panel_screen.dart';
import 'features/kyorugi/screens/chief_jury_screen.dart';
import 'features/history/screens/match_history_screen.dart';
import 'features/poomsae/screens/poomsae_stub_screen.dart';
import 'features/history/screens/match_detail_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const ModeSelectScreen()),
    GoRoute(path: '/setup', builder: (_, __) => const MatchSetupScreen()),
    GoRoute(path: '/role', builder: (_, __) => const RoleSelectScreen()),
    GoRoute(path: '/pairing/display', builder: (_, __) => const QrDisplayScreen()),
    GoRoute(path: '/pairing/scan', builder: (_, __) => const QrScanScreen()),
    GoRoute(path: '/kyorugi/scoreboard', builder: (_, __) => const ScoreboardScreen()),
    GoRoute(
      path: '/kyorugi/judge/:slot',
      builder: (_, state) {
        final slot = int.parse(state.pathParameters['slot'] ?? '1');
        return JudgePanelScreen(judgeSlot: slot);
      },
    ),
    GoRoute(path: '/kyorugi/chief', builder: (_, __) => const ChiefJuryScreen()),
    GoRoute(path: '/poomsae', builder: (_, __) => const PoomsaeStubScreen()),
    GoRoute(path: '/history', builder: (_, __) => const MatchHistoryScreen()),
    GoRoute(
      path: '/history/:matchId',
      builder: (_, state) =>
          MatchDetailScreen(matchId: state.pathParameters['matchId']!),
    ),
  ],
);

class TaekwondoScoreApp extends StatelessWidget {
  const TaekwondoScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TaekwondoScore',
      theme: _buildTheme(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF2979FF),
        secondary: Color(0xFFFF1744),
        surface: Color(0xFF121212),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}