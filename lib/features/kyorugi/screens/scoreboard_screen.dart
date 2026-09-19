import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/enums/match_status.dart';
import '../../../core/enums/fighter_side.dart';
import '../../../core/models/match_event.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/match_state_provider.dart';

class ScoreboardScreen extends ConsumerStatefulWidget {
  const ScoreboardScreen({super.key});
  @override
  ConsumerState<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends ConsumerState<ScoreboardScreen> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Force landscape on scoreboard
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.space) {
      final state = ref.read(matchStateProvider);
      if (state?.timerRunning == true) {
        ref.read(matchCommandProvider.notifier).timerStop();
      } else {
        ref.read(matchCommandProvider.notifier).timerStart();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchStateProvider);
    final timer = ref.watch(timerDisplayProvider);

    if (state == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.chung)),
      );
    }

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (e) => _onKey(_focusNode, e),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(children: [
            // ── Top bar: round + status + judge dots ────────────────────────
            _TopBar(state: state),

            // ── Main scoring area ────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  // Chung (Blue) side
                  Expanded(child: _FighterPanel(
                    name: state.chungName,
                    score: state.chungScore,
                    penalties: state.chungPenalties,
                    color: AppColors.chung,
                    side: FighterSide.chung,
                    isLeft: true,
                  )),

                  // Centre column: timer + controls
                  SizedBox(
                    width: 200,
                    child: _CentreColumn(state: state, timer: timer),
                  ),

                  // Hong (Red) side
                  Expanded(child: _FighterPanel(
                    name: state.hongName,
                    score: state.hongScore,
                    penalties: state.hongPenalties,
                    color: AppColors.hong,
                    side: FighterSide.hong,
                    isLeft: false,
                  )),
                ]),
              ),
            ),

            // ── Bottom bar: undo + last result ──────────────────────────────
            _BottomBar(state: state),
          ]),
        ),
      ),
    );
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.state});
  final MatchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        // Back
        GestureDetector(
          onTap: () => context.go('/'),
          child: const Icon(Icons.home, color: AppColors.textDisabled, size: 20),
        ),
        const SizedBox(width: 16),

        // Round indicator
        _RoundPills(current: state.currentRound, total: state.totalRounds),

        const Spacer(),

        // Status badge
        _StatusBadge(status: state.status),

        const Spacer(),

        // Judge connection dots
        Row(children: List.generate(4, (i) {
          final connected = i < state.judges.length && state.judges[i].isConnected;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ConnectionDot(isConnected: connected, size: 10),
              const SizedBox(height: 2),
              Text('J${i + 1}', style: const TextStyle(
                  color: AppColors.textDisabled, fontSize: 9)),
            ]),
          );
        })),
      ]),
    );
  }
}

class _RoundPills extends StatelessWidget {
  const _RoundPills({required this.current, required this.total});
  final int current, total;
  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(total, (i) {
      final active = i + 1 == current;
      final done = i + 1 < current;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.chung : done ? AppColors.chung.withOpacity(0.3) : AppColors.surface,
            border: Border.all(color: active ? AppColors.chung : AppColors.border, width: 1.5),
          ),
          child: Center(child: Text('${i + 1}',
              style: TextStyle(color: active ? Colors.white : AppColors.textDisabled,
                  fontSize: 12, fontWeight: FontWeight.w700))),
        ),
      );
    }));
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final MatchStatus status;

  String get _label {
    switch (status) {
      case MatchStatus.setup: return 'READY';
      case MatchStatus.active: return 'LIVE';
      case MatchStatus.paused: return 'PAUSED';
      case MatchStatus.roundBreak: return 'BREAK';
      case MatchStatus.goldenRound: return 'GOLDEN';
      case MatchStatus.finished: return 'FINAL';
    }
  }

  Color get _color {
    switch (status) {
      case MatchStatus.active: return AppColors.success;
      case MatchStatus.goldenRound: return AppColors.warning;
      case MatchStatus.finished: return AppColors.textSecondary;
      default: return AppColors.textDisabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(_label, style: TextStyle(color: _color,
          fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2)),
    );
  }
}

// ─── Fighter Panel ────────────────────────────────────────────────────────────

class _FighterPanel extends StatelessWidget {
  const _FighterPanel({required this.name, required this.score,
    required this.penalties, required this.color, required this.side,
    required this.isLeft});
  final String name;
  final int score, penalties;
  final Color color;
  final FighterSide side;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Fighter name
        Text(name.toUpperCase(),
          style: TextStyle(color: color, fontSize: 18,
              fontWeight: FontWeight.w800, letterSpacing: 3),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        // Score — the big number
        Text('$score',
          style: TextStyle(
            color: Colors.white,
            fontSize: 140,
            fontWeight: FontWeight.w900,
            height: 0.9,
            shadows: [Shadow(color: color.withOpacity(0.4), blurRadius: 40)],
          ),
        ),

        const SizedBox(height: 12),

        // Penalties (Gam-jeom)
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('GAM-JEOM', style: TextStyle(color: AppColors.textDisabled,
              fontSize: 11, letterSpacing: 2)),
          const SizedBox(width: 10),
          ...List.generate(10, (i) => Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < penalties ? AppColors.warning : AppColors.surface,
                border: Border.all(
                    color: i < penalties ? AppColors.warning : AppColors.border),
              ),
            ),
          )),
        ]),
      ]),
    );
  }
}

// ─── Centre Column ────────────────────────────────────────────────────────────

class _CentreColumn extends ConsumerWidget {
  const _CentreColumn({required this.state, required this.timer});
  final MatchState state;
  final String timer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cmd = ref.read(matchCommandProvider.notifier);
    final isActive = state.status == MatchStatus.active;
    final canStart = state.status == MatchStatus.paused ||
        state.status == MatchStatus.setup ||
        state.status == MatchStatus.roundBreak ||
        state.status == MatchStatus.goldenRound;

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Active window flash
      if (state.activeWindow != null)
        _ConsensusFlash(windowId: state.activeWindow!.windowId),

      const SizedBox(height: 8),

      // Timer
      GestureDetector(
        onTap: () => isActive ? cmd.timerStop() : cmd.timerStart(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.success.withOpacity(0.4) : AppColors.border,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(children: [
            Text(timer,
              style: TextStyle(
                color: _timerColor(state),
                fontSize: 48,
                fontWeight: FontWeight.w900,
                fontFamily: 'RobotoMono',
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(isActive ? 'TAP OR SPACE TO PAUSE' : 'TAP OR SPACE TO START',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textDisabled,
                  fontSize: 9, letterSpacing: 1)),
          ]),
        ),
      ),

      const SizedBox(height: 16),

      // Round label
      if (state.status == MatchStatus.goldenRound)
        const Text('GOLDEN ROUND', style: TextStyle(color: AppColors.warning,
            fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2))
      else
        Text('ROUND ${state.currentRound} OF ${state.totalRounds}',
          style: const TextStyle(color: AppColors.textDisabled,
              fontSize: 10, letterSpacing: 1.5)),

      const SizedBox(height: 20),

      // End round button
      if (state.status != MatchStatus.finished)
        _ControlBtn(
          label: 'END ROUND',
          icon: Icons.skip_next,
          onTap: cmd.endRound,
          color: AppColors.warning,
        ),

      const SizedBox(height: 8),

      _ControlBtn(
        label: 'END MATCH',
        icon: Icons.stop,
        onTap: cmd.endMatch,
        color: AppColors.error,
      ),
    ]);
  }

  Color _timerColor(MatchState state) {
    if (!state.timerRunning) return AppColors.textSecondary;
    final secs = state.timerRemainingMs / 1000;
    if (secs <= 10) return AppColors.error;
    if (secs <= 30) return AppColors.warning;
    return Colors.white;
  }
}

class _ConsensusFlash extends StatefulWidget {
  const _ConsensusFlash({required this.windowId});
  final String windowId;
  @override
  State<_ConsensusFlash> createState() => _ConsensusFlashState();
}

class _ConsensusFlashState extends State<_ConsensusFlash>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1 + _ctrl.value * 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.warning.withOpacity(0.6)),
        ),
        child: const Text('VOTING…', style: TextStyle(color: AppColors.warning,
            fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  const _ControlBtn({required this.label, required this.icon,
    required this.onTap, required this.color});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11,
              fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        ]),
      ),
    );
  }
}

// ─── Bottom Bar (undo + last result) ─────────────────────────────────────────

class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.state});
  final MatchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUndo = state.canUndo;
    final last = state.lastResult;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        // Last result description
        if (last != null && !last.undone)
          Expanded(child: Text(
            _resultLabel(last, state),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ))
        else
          const Expanded(child: SizedBox()),

        // Undo button — visible for 10s after point awarded
        if (canUndo)
          GestureDetector(
            onTap: () => ref.read(matchCommandProvider.notifier).undoLastPoint(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.4)),
              ),
              child: const Row(children: [
                Icon(Icons.undo, color: AppColors.error, size: 16),
                SizedBox(width: 6),
                Text('UNDO', style: TextStyle(color: AppColors.error,
                    fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ]),
            ),
          ),

        // Finished state — winner banner
        if (state.status == MatchStatus.finished) ...[
          const Spacer(),
          _WinnerBanner(state: state),
        ],
      ]),
    );
  }

  String _resultLabel(dynamic result, MatchState state) {
    if (result.outcome.name == 'noConsensus') return 'No consensus';
    if (result.awardedTo == null) return '';
    final name = result.awardedTo == FighterSide.chung ? state.chungName : state.hongName;
    return '+${result.pointsAwarded}  $name · ${result.technique?.name ?? ''}';
  }
}

class _WinnerBanner extends StatelessWidget {
  const _WinnerBanner({required this.state});
  final MatchState state;
  @override
  Widget build(BuildContext context) {
    final winner = state.chungScore > state.hongScore
        ? state.chungName : state.hongName;
    final color = state.chungScore > state.hongScore
        ? AppColors.chung : AppColors.hong;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text('${winner.toUpperCase()} WINS',
        style: TextStyle(color: color, fontSize: 14,
            fontWeight: FontWeight.w900, letterSpacing: 2)),
    );
  }
}