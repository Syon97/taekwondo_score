import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/enums/app_mode.dart';
import '../providers/session_provider.dart';

class ModeSelectScreen extends ConsumerWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingLg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _AppLogo(),
                  const SizedBox(height: 64),
                  _ModeCard(
                    label: 'KYORUGI',
                    subtitle: 'Sparring',
                    description: '4 corner judges · 3-of-4 consensus · Round timer',
                    color: AppColors.chung,
                    icon: Icons.sports_martial_arts,
                    onTap: () {
                      ref.read(sessionProvider.notifier).startNew(mode: AppMode.kyorugi);
                      context.push('/setup');
                    },
                  ),
                  const SizedBox(height: 16),
                  _ModeCard(
                    label: 'POOMSAE',
                    subtitle: 'Pattern',
                    description: '5 umpires · Individual decimal scoring',
                    color: AppColors.textDisabled,
                    icon: Icons.self_improvement,
                    comingSoon: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: () => context.push('/history'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 18, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Text('Match History',
                            style: TextStyle(color: AppColors.textSecondary,
                                fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppColors.chung, AppColors.hong],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Text('TK', style: TextStyle(color: Colors.white, fontSize: 28,
              fontWeight: FontWeight.w900, letterSpacing: 2)),
        ),
      ),
      const SizedBox(height: 20),
      const Text('TAEKWONDO', style: TextStyle(color: AppColors.textPrimary,
          fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 6)),
      const SizedBox(height: 4),
      const Text('SCORE', style: TextStyle(color: AppColors.textSecondary,
          fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 8)),
    ]);
  }
}

class _ModeCard extends StatefulWidget {
  const _ModeCard({required this.label, required this.subtitle,
    required this.description, required this.color, required this.icon,
    required this.onTap, this.comingSoon = false});
  final String label, subtitle, description;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool comingSoon;
  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.comingSoon ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.comingSoon ? null : (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: widget.comingSoon ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Opacity(
          opacity: widget.comingSoon ? 0.45 : 1.0,
          child: Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: widget.color.withOpacity(0.4), width: 2),
            ),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: widget.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(widget.label, style: TextStyle(color: widget.color,
                      fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  if (widget.comingSoon) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.textDisabled.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('SOON', style: TextStyle(color: AppColors.textDisabled,
                          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(widget.subtitle, style: const TextStyle(color: AppColors.textSecondary,
                    fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text(widget.description, style: const TextStyle(
                    color: AppColors.textDisabled, fontSize: 12)),
              ])),
              if (!widget.comingSoon)
                Icon(Icons.chevron_right, color: widget.color.withOpacity(0.6), size: 24),
            ]),
          ),
        ),
      ),
    );
  }
}