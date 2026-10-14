import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/poomsae_models.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/poomsae_provider.dart';
import '../../setup/providers/session_provider.dart';

class PoomsaeSetupScreen extends ConsumerStatefulWidget {
  const PoomsaeSetupScreen({super.key});
  @override
  ConsumerState<PoomsaeSetupScreen> createState() => _PoomsaeSetupScreenState();
}

class _PoomsaeSetupScreenState extends ConsumerState<PoomsaeSetupScreen> {
  final _sessionNameCtrl = TextEditingController(text: 'Poomsae Individual');
  final _nameCtrl = TextEditingController();
  final _teamCtrl = TextEditingController();
  final _uuid = const Uuid();
  final List<PoomsaeAthlete> _athletes = [];

  @override
  void dispose() {
    _sessionNameCtrl.dispose();
    _nameCtrl.dispose();
    _teamCtrl.dispose();
    super.dispose();
  }

  void _addAthlete() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _athletes.add(PoomsaeAthlete(
        id: _uuid.v4(),
        name: name,
        team: _teamCtrl.text.trim().isEmpty ? null : _teamCtrl.text.trim(),
        order: _athletes.length + 1,
      ));
      _nameCtrl.clear();
      _teamCtrl.clear();
    });
  }

  void _removeAthlete(int index) =>
      setState(() => _athletes.removeAt(index));

  Future<void> _proceed() async {
    if (_athletes.isEmpty) return;
    await ref.read(poomsaeServerProvider.notifier)
        .startServer(_athletes, _sessionNameCtrl.text.trim());
    if (mounted) context.push('/poomsae/display');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Poomsae Setup',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingMd),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Session name
              const TkSectionLabel('Session Name'),
              TkTextField(
                controller: _sessionNameCtrl,
                label: 'SESSION / CATEGORY NAME',
                hint: 'e.g. Women Individual Pattern - Final',
                prefixIcon: Icons.label_outline,
              ),

              const SizedBox(height: 28),

              // Add athlete
              const TkSectionLabel('Athletes'),
              TkCard(child: Column(children: [
                TkTextField(
                  controller: _nameCtrl,
                  label: 'ATHLETE NAME',
                  hint: 'Full name',
                  prefixIcon: Icons.person,
                ),
                const SizedBox(height: 12),
                TkTextField(
                  controller: _teamCtrl,
                  label: 'TEAM / CLUB (Optional)',
                  hint: 'e.g. SKM Johor',
                  prefixIcon: Icons.group,
                ),
                const SizedBox(height: 16),
                TkButton(
                  label: 'ADD ATHLETE',
                  icon: Icons.add,
                  onTap: _addAthlete,
                  enabled: true,
                ),
              ])),

              const SizedBox(height: 16),

              // Athlete list
              if (_athletes.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No athletes added yet',
                        style: TextStyle(color: AppColors.textDisabled,
                            fontSize: 14)),
                  ),
                )
              else
                ...List.generate(_athletes.length, (i) {
                  final a = _athletes[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TkCard(
                      color: AppColors.surfaceElevated,
                      child: Row(children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.chung.withOpacity(0.15),
                          ),
                          child: Center(child: Text('${i + 1}',
                              style: const TextStyle(color: AppColors.chung,
                                  fontWeight: FontWeight.w900))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.name, style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15, fontWeight: FontWeight.w700)),
                            if (a.team != null)
                              Text(a.team!, style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        )),
                        GestureDetector(
                          onTap: () => _removeAthlete(i),
                          child: const Icon(Icons.remove_circle_outline,
                              color: AppColors.textDisabled, size: 20),
                        ),
                      ]),
                    ),
                  );
                }),

              const SizedBox(height: 28),

              // Info
              TkCard(
                color: AppColors.chung.withOpacity(0.05),
                borderColor: AppColors.chung.withOpacity(0.2),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SCORING METHOD', style: TextStyle(
                        color: AppColors.chung, fontSize: 11,
                        fontWeight: FontWeight.w700, letterSpacing: 2)),
                    SizedBox(height: 8),
                    Text('5 judges score each athlete on Accuracy and '
                        'Presentation (0.0 – 10.0 each).\n'
                        'Highest and lowest totals are dropped. '
                        'Final score = average of remaining 3.',
                        style: TextStyle(color: AppColors.textSecondary,
                            fontSize: 13, height: 1.5)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              TkButton(
                label: 'START SESSION',
                icon: Icons.play_arrow,
                onTap: _proceed,
                enabled: _athletes.isNotEmpty,
              ),

              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}