import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/round_config.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/session_provider.dart';

class _Preset {
  final String label, description;
  final RoundConfig config;
  const _Preset(this.label, this.description, this.config);
}

final _presets = [
  const _Preset('Colour Belt U18', '1 round × 1m 30s', RoundConfig.colourBeltU18),
  const _Preset('Black Belt U18', '2 rounds × 1m', RoundConfig.blackBeltU18),
  const _Preset('Senior', '3 rounds × 2m', RoundConfig.senior),
  const _Preset('Custom', 'Set your own timing',
      RoundConfig(totalRounds: 2, roundDurationSeconds: 90, restDurationSeconds: 30)),
];

class MatchSetupScreen extends ConsumerStatefulWidget {
  const MatchSetupScreen({super.key});
  @override
  ConsumerState<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends ConsumerState<MatchSetupScreen> {
  final _chungCtrl = TextEditingController();
  final _hongCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  int _selectedPreset = 0;
  bool _isCustom = false;
  int _customRounds = 2, _customRoundMin = 1, _customRoundSec = 30, _customRest = 30;

  @override
  void initState() {
    super.initState();
    final s = ref.read(sessionProvider);
    if (s != null) {
      _chungCtrl.text = s.chungName;
      _hongCtrl.text = s.hongName;
      _categoryCtrl.text = s.category ?? '';
    }
  }

  @override
  void dispose() {
    _chungCtrl.dispose(); _hongCtrl.dispose(); _categoryCtrl.dispose();
    super.dispose();
  }

  bool get _canProceed =>
      _chungCtrl.text.trim().isNotEmpty && _hongCtrl.text.trim().isNotEmpty;

  RoundConfig get _config => _isCustom
      ? RoundConfig(totalRounds: _customRounds,
          roundDurationSeconds: _customRoundMin * 60 + _customRoundSec,
          restDurationSeconds: _customRest)
      : _presets[_selectedPreset].config;

  void _proceed() {
    if (!_canProceed) return;
    ref.read(sessionProvider.notifier).updateMatchDetails(
      chungName: _chungCtrl.text.trim(),
      hongName: _hongCtrl.text.trim(),
      category: _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
      roundConfig: _config,
    );
    context.push('/role');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Match Setup', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingMd),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Fighters ──
              const TkSectionLabel('Fighters'),
              TkCard(child: Column(children: [
                Row(children: [
                  Container(width: 4, height: 52,
                      decoration: BoxDecoration(color: AppColors.chung, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 16),
                  Expanded(child: TkTextField(controller: _chungCtrl, label: 'CHUNG (Blue)',
                      hint: 'Fighter name', prefixIcon: Icons.person, autofocus: true,
                      onChanged: (_) => setState(() {}))),
                ]),
                const SizedBox(height: 20),
                const Row(children: [
                  Expanded(child: TkDivider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('VS', style: TextStyle(color: AppColors.textDisabled,
                          fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2))),
                  Expanded(child: TkDivider()),
                ]),
                const SizedBox(height: 20),
                Row(children: [
                  Container(width: 4, height: 52,
                      decoration: BoxDecoration(color: AppColors.hong, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 16),
                  Expanded(child: TkTextField(controller: _hongCtrl, label: 'HONG (Red)',
                      hint: 'Fighter name', prefixIcon: Icons.person,
                      onChanged: (_) => setState(() {}))),
                ]),
              ])),

              const SizedBox(height: 28),

              // ── Category ──
              const TkSectionLabel('Category (Optional)'),
              TkTextField(controller: _categoryCtrl, label: 'WEIGHT CLASS / CATEGORY',
                  hint: 'e.g. Black Belt U18 -63kg', prefixIcon: Icons.label_outline),

              const SizedBox(height: 28),

              // ── Round config ──
              const TkSectionLabel('Round Configuration'),
              ...List.generate(_presets.length, (i) {
                final isCustomSlot = i == _presets.length - 1;
                final isSelected = isCustomSlot ? _isCustom : (!_isCustom && _selectedPreset == i);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PresetTile(
                    label: _presets[i].label, description: _presets[i].description,
                    isSelected: isSelected,
                    onTap: () => setState(() {
                      if (isCustomSlot) { _isCustom = true; }
                      else { _isCustom = false; _selectedPreset = i; }
                    }),
                  ),
                );
              }),

              if (_isCustom) ...[
                const SizedBox(height: 8),
                TkCard(
                  borderColor: AppColors.chung.withOpacity(0.4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('CUSTOM TIMING', style: TextStyle(color: AppColors.chung,
                        fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2)),
                    const SizedBox(height: 20),
                    _NumberRow(label: 'Rounds', value: _customRounds, min: 1, max: 3,
                        onChanged: (v) => setState(() => _customRounds = v)),
                    const SizedBox(height: 16),
                    const Text('Round Duration', style: TextStyle(color: AppColors.textSecondary,
                        fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: _NumberRow(label: 'Min', value: _customRoundMin,
                          min: 0, max: 5, onChanged: (v) => setState(() => _customRoundMin = v))),
                      const SizedBox(width: 12),
                      Expanded(child: _NumberRow(label: 'Sec', value: _customRoundSec,
                          min: 0, max: 59, step: 15, onChanged: (v) => setState(() => _customRoundSec = v))),
                    ]),
                    const SizedBox(height: 16),
                    _NumberRow(label: 'Rest between rounds (sec)', value: _customRest,
                        min: 15, max: 120, step: 15, onChanged: (v) => setState(() => _customRest = v)),
                  ]),
                ),
              ],

              const SizedBox(height: 36),
              TkButton(label: 'CONTINUE', icon: Icons.arrow_forward,
                  onTap: _proceed, enabled: _canProceed),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({required this.label, required this.description,
    required this.isSelected, required this.onTap});
  final String label, description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chung.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: isSelected ? AppColors.chung : AppColors.border,
              width: isSelected ? 2 : 1.5),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: isSelected ? AppColors.chung : AppColors.textDisabled, width: 2),
              color: isSelected ? AppColors.chung : Colors.transparent,
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(
                color: isSelected ? AppColors.chung : AppColors.textPrimary,
                fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ])),
        ]),
      ),
    );
  }
}

class _NumberRow extends StatelessWidget {
  const _NumberRow({required this.label, required this.value,
    required this.min, required this.max, required this.onChanged, this.step = 1});
  final String label;
  final int value, min, max, step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
      _StepBtn(icon: Icons.remove, onTap: value - step >= min ? () => onChanged(value - step) : null),
      const SizedBox(width: 4),
      Container(
        width: 52, height: 40,
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text('$value', style: const TextStyle(color: AppColors.textPrimary,
            fontSize: 18, fontWeight: FontWeight.w900))),
      ),
      const SizedBox(width: 4),
      _StepBtn(icon: Icons.add, onTap: value + step <= max ? () => onChanged(value + step) : null),
    ]);
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.surfaceElevated : AppColors.surfaceElevated.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18,
            color: onTap != null ? AppColors.textPrimary : AppColors.textDisabled),
      ),
    );
  }
}