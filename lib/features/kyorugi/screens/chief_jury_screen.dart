import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taekwondo_score/core/enums/technique.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/enums/fighter_side.dart';
import '../../../core/enums/match_status.dart';
import '../../../core/models/match_event.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/match_state_provider.dart';

class ChiefJuryScreen extends ConsumerStatefulWidget {
  const ChiefJuryScreen({super.key});
  @override
  ConsumerState<ChiefJuryScreen> createState() => _ChiefJuryScreenState();
}

class _ChiefJuryScreenState extends ConsumerState<ChiefJuryScreen> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() { _focusNode.dispose(); super.dispose(); }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
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
    final cmd = ref.read(matchCommandProvider.notifier);

    if (state == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.chung)),
      );
    }

    final isActive = state.status == MatchStatus.active;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (e) => _onKey(_focusNode, e),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Chief Jury',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.go('/kyorugi/scoreboard'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.paddingMd),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(children: [
                // ── Score summary ────────────────────────────────────────
                TkCard(
                  color: AppColors.surfaceElevated,
                  child: Row(children: [
                    _ScorePill(name: state.chungName, score: state.chungScore,
                        penalties: state.chungPenalties, color: AppColors.chung),
                    const Spacer(),
                    Text('R${state.currentRound}/${state.totalRounds}',
                        style: const TextStyle(color: AppColors.textDisabled,
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    _ScorePill(name: state.hongName, score: state.hongScore,
                        penalties: state.hongPenalties, color: AppColors.hong),
                  ]),
                ),

                const SizedBox(height: 24),

                // ── Timer control ────────────────────────────────────────
                const TkSectionLabel('Timer'),
                TkCard(child: Column(children: [
                  // Big timer display
                  Text(timer, style: TextStyle(
                    color: _timerColor(state),
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'RobotoMono',
                    letterSpacing: 4,
                  )),
                  const SizedBox(height: 6),
                  Text('SPACEBAR to toggle · Round ${state.currentRound}',
                      style: const TextStyle(color: AppColors.textDisabled,
                          fontSize: 11, letterSpacing: 1)),
                  const SizedBox(height: 20),
                  TkButton(
                    label: isActive ? 'PAUSE TIMER' : 'START TIMER',
                    icon: isActive ? Icons.pause : Icons.play_arrow,
                    color: isActive ? AppColors.warning : AppColors.success,
                    onTap: isActive ? cmd.timerStop : cmd.timerStart,
                  ),
                ])),

                const SizedBox(height: 20),

                // ── Undo last point ──────────────────────────────────────
                if (state.canUndo) ...[
                  const TkSectionLabel('Undo'),
                  TkCard(
                    borderColor: AppColors.error.withOpacity(0.4),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.undo, color: AppColors.error, size: 18),
                        SizedBox(width: 8),
                        Text('Undo Last Point', style: TextStyle(color: AppColors.error,
                            fontSize: 15, fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 6),
                      if (state.lastResult != null)
                        Text(
                          '${state.lastResult!.awardedTo?.name.toUpperCase() ?? ''} · '
                          '${state.lastResult!.technique?.label ?? ''} · '
                          '+${state.lastResult!.pointsAwarded} pt',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      const SizedBox(height: 16),
                      TkButton(label: 'UNDO POINT', icon: Icons.undo,
                          color: AppColors.error, onTap: cmd.undoLastPoint),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Manual Gam-jeom ──────────────────────────────────────
                const TkSectionLabel('Issue Gam-Jeom'),
                TkCard(child: Column(children: [
                  const Text('Issue a penalty manually (override). Opponent receives +1 point.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: _GamjeomButton(
                      label: state.chungName,
                      color: AppColors.chung,
                      penalties: state.chungPenalties,
                      onConfirm: () => cmd.issueGamjeom(FighterSide.chung),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _GamjeomButton(
                      label: state.hongName,
                      color: AppColors.hong,
                      penalties: state.hongPenalties,
                      onConfirm: () => cmd.issueGamjeom(FighterSide.hong),
                    )),
                  ]),
                ])),

                const SizedBox(height: 20),

                // ── Round / Match controls ───────────────────────────────
                const TkSectionLabel('Match Control'),
                TkCard(child: Column(children: [
                  if (state.status != MatchStatus.finished)
                    TkButton(label: 'END CURRENT ROUND', icon: Icons.skip_next,
                        color: AppColors.warning, onTap: cmd.endRound,
                        outlined: true),
                  const SizedBox(height: 12),
                  TkButton(label: 'END MATCH', icon: Icons.stop,
                      color: AppColors.error, onTap: cmd.endMatch,
                      outlined: true),
                ])),

                const SizedBox(height: 20),

                // ── Judge connection status ──────────────────────────────
                const TkSectionLabel('Judge Connections'),
                TkCard(child: Column(
                  children: List.generate(4, (i) {
                    final j = i < state.judges.length ? state.judges[i] : null;
                    final connected = j?.isConnected ?? false;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        ConnectionDot(isConnected: connected),
                        const SizedBox(width: 12),
                        Text('Judge ${i + 1}',
                            style: TextStyle(
                              color: connected ? AppColors.textPrimary : AppColors.textDisabled,
                              fontSize: 14, fontWeight: FontWeight.w600,
                            )),
                        if (j?.deviceName != null) ...[
                          const SizedBox(width: 8),
                          Text(j!.deviceName!, style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                        ],
                        const Spacer(),
                        Text(connected ? 'READY' : 'OFFLINE',
                            style: TextStyle(
                              color: connected ? AppColors.success : AppColors.textDisabled,
                              fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1,
                            )),
                      ]),
                    );
                  }),
                )),

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Color _timerColor(MatchState state) {
    if (!state.timerRunning) return AppColors.textSecondary;
    final secs = state.timerRemainingMs / 1000;
    if (secs <= 10) return AppColors.error;
    if (secs <= 30) return AppColors.warning;
    return Colors.white;
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.name, required this.score,
    required this.penalties, required this.color});
  final String name;
  final int score, penalties;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(name, style: TextStyle(color: color, fontSize: 13,
          fontWeight: FontWeight.w700)),
      Text('$score', style: TextStyle(color: Colors.white,
          fontSize: 36, fontWeight: FontWeight.w900)),
      Text('${penalties}gj', style: const TextStyle(
          color: AppColors.textDisabled, fontSize: 11)),
    ]);
  }
}

class _GamjeomButton extends StatefulWidget {
  const _GamjeomButton({required this.label, required this.color,
    required this.penalties, required this.onConfirm});
  final String label;
  final Color color;
  final int penalties;
  final VoidCallback onConfirm;
  @override
  State<_GamjeomButton> createState() => _GamjeomButtonState();
}

class _GamjeomButtonState extends State<_GamjeomButton> {
  bool _holding = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => setState(() => _holding = true),
      onLongPressEnd: (_) {
        setState(() => _holding = false);
        HapticFeedback.heavyImpact();
        widget.onConfirm();
      },
      onLongPressCancel: () => setState(() => _holding = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _holding ? widget.color.withOpacity(0.25) : widget.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.color.withOpacity(0.4), width: 2),
        ),
        child: Column(children: [
          Text(widget.label, style: TextStyle(color: widget.color,
              fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('${widget.penalties} penalties',
              style: const TextStyle(color: AppColors.textDisabled, fontSize: 11)),
          const SizedBox(height: 8),
          const Text('HOLD TO ISSUE', style: TextStyle(color: AppColors.warning,
              fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
        ]),
      ),
    );
  }
}