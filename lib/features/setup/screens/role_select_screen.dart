import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/enums/device_role.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/session_provider.dart';

class RoleSelectScreen extends ConsumerStatefulWidget {
  const RoleSelectScreen({super.key});
  @override
  ConsumerState<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends ConsumerState<RoleSelectScreen> {
  DeviceRole? _role;
  int _slot = 1;

  void _proceed() {
    if (_role == null) return;
    ref.read(sessionProvider.notifier).setRole(_role!, judgeSlot: _slot);
    if (_role == DeviceRole.judge) {
      context.push('/pairing/scan');
    } else {
      context.push('/pairing/display');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Role', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingMd),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Match summary
              TkCard(
                color: AppColors.surfaceElevated,
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${session.chungName} vs ${session.hongName}',
                        style: const TextStyle(color: AppColors.textPrimary,
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    if (session.category != null) ...[
                      const SizedBox(height: 2),
                      Text(session.category!, style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.chung.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      '${session.roundConfig.totalRounds}R · '
                      '${session.roundConfig.roundDurationSeconds ~/ 60}m'
                      '${session.roundConfig.roundDurationSeconds % 60 > 0 ? ' ${session.roundConfig.roundDurationSeconds % 60}s' : ''}',
                      style: const TextStyle(color: AppColors.chung,
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 28),
              const TkSectionLabel('This Device Is…'),

              _RoleTile(
                label: 'Scoreboard / Chief Jury',
                description: 'Laptop or main tablet. Hosts the server, displays the score, controls the timer.',
                icon: Icons.monitor,
                isSelected: _role == DeviceRole.scoreboard,
                onTap: () => setState(() => _role = DeviceRole.scoreboard),
              ),
              const SizedBox(height: 12),
              _RoleTile(
                label: 'Corner Judge',
                description: 'Mobile phone. Connects to the scoreboard via QR code to submit scoring actions.',
                icon: Icons.sports_handball,
                isSelected: _role == DeviceRole.judge,
                onTap: () => setState(() => _role = DeviceRole.judge),
              ),

              // Judge slot picker
              if (_role == DeviceRole.judge) ...[
                const SizedBox(height: 16),
                TkCard(
                  borderColor: AppColors.chung.withOpacity(0.3),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('JUDGE POSITION', style: TextStyle(color: AppColors.chung,
                        fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (i) {
                        final slot = i + 1;
                        final sel = _slot == slot;
                        return GestureDetector(
                          onTap: () => setState(() => _slot = slot),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: sel ? AppColors.chung : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: sel ? AppColors.chung : AppColors.border,
                                  width: sel ? 2 : 1),
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('$slot', style: TextStyle(
                                  color: sel ? Colors.white : AppColors.textSecondary,
                                  fontSize: 22, fontWeight: FontWeight.w900)),
                              Text('J$slot', style: TextStyle(
                                  color: sel ? Colors.white70 : AppColors.textDisabled,
                                  fontSize: 10, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    const Center(child: Text('Each judge phone must select a different position',
                        style: TextStyle(color: AppColors.textDisabled, fontSize: 12))),
                  ]),
                ),
              ],

              const SizedBox(height: 36),
              TkButton(
                label: _role == DeviceRole.judge ? 'SCAN QR CODE' : 'START SESSION',
                icon: _role == DeviceRole.judge ? Icons.qr_code_scanner : Icons.play_arrow,
                onTap: _proceed,
                enabled: _role != null,
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({required this.label, required this.description,
    required this.icon, required this.isSelected, required this.onTap});
  final String label, description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chung.withOpacity(0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: isSelected ? AppColors.chung : AppColors.border,
              width: isSelected ? 2 : 1.5),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.chung.withOpacity(0.15) : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: isSelected ? AppColors.chung : AppColors.textSecondary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(
                color: isSelected ? AppColors.chung : AppColors.textPrimary,
                fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
          ])),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: isSelected ? AppColors.chung : AppColors.textDisabled, width: 2),
              color: isSelected ? AppColors.chung : Colors.transparent,
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
        ]),
      ),
    );
  }
}