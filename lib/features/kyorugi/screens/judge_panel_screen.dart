import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taekwondo_score/services/websocket/ws_client.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/enums/fighter_side.dart';
import '../../../core/enums/match_status.dart';
import '../../../core/enums/technique.dart';
import '../../../core/models/match_event.dart';
import '../../../core/services/ws_client_provider.dart';

class JudgePanelScreen extends ConsumerStatefulWidget {
  const JudgePanelScreen({super.key, required this.judgeSlot});
  final int judgeSlot;
  @override
  ConsumerState<JudgePanelScreen> createState() => _JudgePanelScreenState();
}

class _JudgePanelScreenState extends ConsumerState<JudgePanelScreen> {
  // Two-tap model state:
  // Step 1 — judge taps fighter zone → _pendingSide is set
  // Step 2 — technique overlay appears → judge taps technique → vote sent
  FighterSide? _pendingSide;

  // Track what this judge submitted in the current window for feedback
  Technique? _submittedTechnique;
  FighterSide? _submittedSide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _onFighterTap(FighterSide side) {
    final clientState = ref.read(wsClientProvider);
    if (clientState.matchState?.status != MatchStatus.active) return;
    HapticFeedback.mediumImpact();
    setState(() { _pendingSide = side; });
  }

  void _onTechniqueTap(Technique technique) {
    if (_pendingSide == null) return;
    HapticFeedback.heavyImpact();
    ref.read(wsClientProvider.notifier).sendVote(
      fighter: _pendingSide!,
      technique: technique,
    );
    setState(() {
      _submittedSide = _pendingSide;
      _submittedTechnique = technique;
      _pendingSide = null;
    });
  }

  void _cancelPending() => setState(() => _pendingSide = null);

  @override
  Widget build(BuildContext context) {
    final clientState = ref.watch(wsClientProvider);
    final matchState = clientState.matchState;
    final connState = clientState.connectionState;

    // Clear submitted vote when window closes
    if (clientState.activeWindowId == null && _submittedTechnique != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() { _submittedTechnique = null; _submittedSide = null; });
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        // ── Main two-zone layout ──────────────────────────────────────────
        Column(children: [
          // CHUNG (Blue) — top half
          Expanded(child: _FighterZone(
            side: FighterSide.chung,
            name: matchState?.chungName ?? 'CHUNG',
            score: matchState?.chungScore ?? 0,
            color: AppColors.chung,
            onTap: () => _onFighterTap(FighterSide.chung),
            isEnabled: matchState?.status == MatchStatus.active,
            isSelected: _pendingSide == FighterSide.chung,
            wasSubmitted: _submittedSide == FighterSide.chung,
            submittedTechnique: _submittedSide == FighterSide.chung ? _submittedTechnique : null,
          )),

          // Divider strip with judge slot info
          _JudgeStrip(slot: widget.judgeSlot, matchState: matchState),

          // HONG (Red) — bottom half
          Expanded(child: _FighterZone(
            side: FighterSide.hong,
            name: matchState?.hongName ?? 'HONG',
            score: matchState?.hongScore ?? 0,
            color: AppColors.hong,
            onTap: () => _onFighterTap(FighterSide.hong),
            isEnabled: matchState?.status == MatchStatus.active,
            isSelected: _pendingSide == FighterSide.hong,
            wasSubmitted: _submittedSide == FighterSide.hong,
            submittedTechnique: _submittedSide == FighterSide.hong ? _submittedTechnique : null,
          )),
        ]),

        // ── Technique overlay (step 2 of two-tap) ────────────────────────
        if (_pendingSide != null)
          _TechniqueOverlay(
            side: _pendingSide!,
            onTechnique: _onTechniqueTap,
            onCancel: _cancelPending,
          ),

        // ── PAUSED overlay ────────────────────────────────────────────────
        if (matchState?.status == MatchStatus.paused ||
            matchState?.status == MatchStatus.roundBreak)
          _StatusOverlay(
            label: matchState?.status == MatchStatus.roundBreak
                ? 'ROUND BREAK' : 'PAUSED',
            color: AppColors.warning,
          ),

        // ── DISCONNECTED overlay ──────────────────────────────────────────
        if (connState == WsConnectionState.disconnected ||
            connState == WsConnectionState.reconnecting)
          _StatusOverlay(
            label: connState == WsConnectionState.reconnecting
                ? 'RECONNECTING…' : 'DISCONNECTED',
            color: AppColors.error,
            subtitle: 'Check WiFi connection',
          ),

        // ── FINISHED overlay ──────────────────────────────────────────────
        if (matchState?.status == MatchStatus.finished)
          _FinishedOverlay(state: matchState!),
      ]),
    );
  }
}

// ─── Fighter Zone ─────────────────────────────────────────────────────────────

class _FighterZone extends StatefulWidget {
  const _FighterZone({required this.side, required this.name, required this.score,
    required this.color, required this.onTap, required this.isEnabled,
    required this.isSelected, required this.wasSubmitted, this.submittedTechnique});
  final FighterSide side;
  final String name;
  final int score;
  final Color color;
  final VoidCallback onTap;
  final bool isEnabled, isSelected, wasSubmitted;
  final Technique? submittedTechnique;
  @override
  State<_FighterZone> createState() => _FighterZoneState();
}

class _FighterZoneState extends State<_FighterZone>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (widget.isSelected) {
      bg = widget.color.withOpacity(0.3);
    } else if (widget.wasSubmitted) {
      bg = widget.color.withOpacity(0.12);
    } else {
      bg = widget.color.withOpacity(0.06);
    }

    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) {
        _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());
        widget.onTap();
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: bg,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Name
            Text(widget.name.toUpperCase(),
              style: TextStyle(color: widget.color, fontSize: 20,
                  fontWeight: FontWeight.w900, letterSpacing: 4),
            ),
            const SizedBox(height: 8),

            // Score
            Text('${widget.score}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 96,
                fontWeight: FontWeight.w900,
                height: 0.9,
                shadows: [Shadow(color: widget.color.withOpacity(0.5), blurRadius: 30)],
              ),
            ),

            const SizedBox(height: 16),

            // Submitted vote feedback
            if (widget.wasSubmitted && widget.submittedTechnique != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withOpacity(0.4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check, color: AppColors.success, size: 16),
                  const SizedBox(width: 6),
                  Text(widget.submittedTechnique!.label.toUpperCase(),
                    style: const TextStyle(color: AppColors.success,
                        fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1)),
                ]),
              )
            else if (widget.isEnabled && !widget.wasSubmitted)
              Text('TAP TO SCORE',
                style: TextStyle(color: widget.color.withOpacity(0.5),
                    fontSize: 12, letterSpacing: 2)),
          ]),
        ),
      ),
    );
  }
}

// ─── Judge Strip ──────────────────────────────────────────────────────────────

class _JudgeStrip extends StatelessWidget {
  const _JudgeStrip({required this.slot, this.matchState});
  final int slot;
  final MatchState? matchState;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: AppColors.surface,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.person, size: 14, color: AppColors.textDisabled),
        const SizedBox(width: 6),
        Text('Judge $slot', style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        if (matchState != null) ...[
          const SizedBox(width: 16),
          Container(width: 1, height: 16, color: AppColors.border),
          const SizedBox(width: 16),
          Text('R${matchState!.currentRound}',
            style: const TextStyle(color: AppColors.textDisabled,
                fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
        ],
      ]),
    );
  }
}

// ─── Technique Overlay ────────────────────────────────────────────────────────

class _TechniqueOverlay extends StatelessWidget {
  const _TechniqueOverlay({required this.side, required this.onTechnique,
    required this.onCancel});
  final FighterSide side;
  final ValueChanged<Technique> onTechnique;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final color = side == FighterSide.chung ? AppColors.chung : AppColors.hong;
    final name = side == FighterSide.chung ? 'CHUNG' : 'HONG';

    return GestureDetector(
      onTap: onCancel,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('$name — SELECT TECHNIQUE',
            style: TextStyle(color: color, fontSize: 14,
                fontWeight: FontWeight.w800, letterSpacing: 2)),
          const SizedBox(height: 32),

          // Three big technique buttons
          _TechBtn(
            label: 'HEAD KICK',
            points: 3,
            color: color,
            icon: Icons.keyboard_arrow_up,
            onTap: () => onTechnique(Technique.headKick),
          ),
          const SizedBox(height: 16),
          _TechBtn(
            label: 'BODY KICK',
            points: 2,
            color: color,
            icon: Icons.remove,
            onTap: () => onTechnique(Technique.bodyKick),
          ),
          const SizedBox(height: 16),
          _TechBtn(
            label: 'PUNCH',
            points: 1,
            color: color,
            icon: Icons.keyboard_arrow_down,
            onTap: () => onTechnique(Technique.punch),
          ),
          const SizedBox(height: 32),

          // Gam-jeom — separated, needs long press
          _GamjeomBtn(color: color, onConfirm: () => onTechnique(Technique.gamjeom)),

          const SizedBox(height: 24),
          GestureDetector(
            onTap: onCancel,
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textDisabled,
                fontSize: 13, letterSpacing: 2)),
          ),
        ]),
      ),
    );
  }
}

class _TechBtn extends StatelessWidget {
  const _TechBtn({required this.label, required this.points, required this.color,
    required this.icon, required this.onTap});
  final String label;
  final int points;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: TextStyle(color: Colors.white,
              fontSize: 20, fontWeight: FontWeight.w800))),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Center(child: Text('+$points',
                style: const TextStyle(color: Colors.white,
                    fontSize: 16, fontWeight: FontWeight.w900))),
          ),
        ]),
      ),
    );
  }
}

class _GamjeomBtn extends StatefulWidget {
  const _GamjeomBtn({required this.color, required this.onConfirm});
  final Color color;
  final VoidCallback onConfirm;
  @override
  State<_GamjeomBtn> createState() => _GamjeomBtnState();
}

class _GamjeomBtnState extends State<_GamjeomBtn> {
  bool _holding = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => setState(() => _holding = true),
      onLongPressEnd: (_) {
        setState(() => _holding = false);
        widget.onConfirm();
        HapticFeedback.heavyImpact();
      },
      onLongPressCancel: () => setState(() => _holding = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(_holding ? 0.3 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.warning.withOpacity(0.5), width: 2),
        ),
        child: const Row(children: [
          Icon(Icons.warning_amber, color: AppColors.warning, size: 22),
          SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('GAM-JEOM', style: TextStyle(color: AppColors.warning,
                fontSize: 18, fontWeight: FontWeight.w800)),
            Text('Hold to issue penalty', style: TextStyle(
                color: AppColors.textDisabled, fontSize: 11)),
          ])),
        ]),
      ),
    );
  }
}

// ─── Status Overlays ──────────────────────────────────────────────────────────

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({required this.label, required this.color, this.subtitle});
  final String label;
  final Color color;
  final String? subtitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.88),
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Column(children: [
            Text(label, style: TextStyle(color: color, fontSize: 28,
                fontWeight: FontWeight.w900, letterSpacing: 4)),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ],
          ]),
        ),
      ])),
    );
  }
}

class _FinishedOverlay extends StatelessWidget {
  const _FinishedOverlay({required this.state});
  final MatchState state;
  @override
  Widget build(BuildContext context) {
    final chungWins = state.chungScore >= state.hongScore;
    final winnerName = chungWins ? state.chungName : state.hongName;
    final color = chungWins ? AppColors.chung : AppColors.hong;
    return Container(
      color: Colors.black.withOpacity(0.92),
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('MATCH OVER', style: TextStyle(color: AppColors.textSecondary,
            fontSize: 14, letterSpacing: 4)),
        const SizedBox(height: 16),
        Text(winnerName.toUpperCase(), style: TextStyle(color: color, fontSize: 36,
            fontWeight: FontWeight.w900, letterSpacing: 3)),
        const SizedBox(height: 8),
        const Text('WINS', style: TextStyle(color: Colors.white, fontSize: 20,
            fontWeight: FontWeight.w700, letterSpacing: 4)),
        const SizedBox(height: 32),
        Text('${state.chungScore}  —  ${state.hongScore}',
          style: const TextStyle(color: AppColors.textSecondary,
              fontSize: 32, fontWeight: FontWeight.w900)),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () => context.go('/'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textDisabled),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('BACK TO HOME', style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13, letterSpacing: 2)),
          ),
        ),
      ])),
    );
  }
}