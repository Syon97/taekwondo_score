import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taekwondo_score/services/websocket/ws_client.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/poomsae_models.dart';
import '../../../core/services/ws_client_provider.dart';
import '../../../core/constants/ws_message_types.dart';
import '../../../core/enums/device_role.dart';
import '../../../core/models/ws_message.dart';

class PoomsaeJudgeScreen extends ConsumerStatefulWidget {
  const PoomsaeJudgeScreen({super.key, required this.judgeSlot});
  final int judgeSlot;
  @override
  ConsumerState<PoomsaeJudgeScreen> createState() => _PoomsaeJudgeScreenState();
}

class _PoomsaeJudgeScreenState extends ConsumerState<PoomsaeJudgeScreen> {
  double _accuracy = 5.0;
  double _presentation = 5.0;
  bool _submitted = false;
  PoomsaeSessionState? _sessionState;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  // Called when WsClient receives a poomsae_session_state message
  // We parse that in ws_client — for now read from shared state
  void _submitScore() {
    if (_submitted) return;
    final clientState = ref.read(wsClientProvider);
    if (clientState.connectionState != WsConnectionState.connected) return;

    // Send via a raw WsMessage through the client notifier
    // We need to extend WsClientNotifier to support sending arbitrary payloads
    ref.read(wsClientProvider.notifier).sendPoomsaeScore(
      accuracy: _accuracy,
      presentation: _presentation,
    );

    HapticFeedback.heavyImpact();
    setState(() => _submitted = true);
  }

  void _reset() => setState(() {
    _accuracy = 5.0;
    _presentation = 5.0;
    _submitted = false;
  });

  @override
  Widget build(BuildContext context) {
    final clientState = ref.watch(wsClientProvider);
    final isConnected =
        clientState.connectionState == WsConnectionState.connected;
    final isScoringOpen = clientState.poomsaeScoringOpen;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              // Header
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.chung.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.chung.withOpacity(0.3)),
                  ),
                  child: Text('Judge ${widget.judgeSlot}',
                      style: const TextStyle(color: AppColors.chung,
                          fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                const Spacer(),
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isConnected
                        ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(width: 6),
                Text(isConnected ? 'Connected' : 'Disconnected',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ]),

              const Spacer(),

              if (!isScoringOpen && !_submitted)
                const Column(children: [
                  Icon(Icons.hourglass_empty,
                      size: 48, color: AppColors.textDisabled),
                  SizedBox(height: 16),
                  Text('Waiting for athlete to perform',
                      style: TextStyle(color: AppColors.textSecondary,
                          fontSize: 16)),
                ])
              else if (_submitted)
                Column(children: [
                  const Icon(Icons.check_circle,
                      size: 64, color: AppColors.success),
                  const SizedBox(height: 16),
                  const Text('Score submitted',
                      style: TextStyle(color: AppColors.success,
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'Accuracy: ${_accuracy.toStringAsFixed(1)}  '
                    'Presentation: ${_presentation.toStringAsFixed(1)}',
                    style: const TextStyle(color: AppColors.textSecondary,
                        fontSize: 14),
                  ),
                  Text('Total: ${(_accuracy + _presentation).toStringAsFixed(1)}',
                      style: const TextStyle(color: AppColors.textPrimary,
                          fontSize: 24, fontWeight: FontWeight.w900)),
                ])
              else
                Column(children: [
                  const Text('ENTER YOUR SCORES',
                    style: TextStyle(color: AppColors.textSecondary,
                        fontSize: 12, letterSpacing: 2,
                        fontWeight: FontWeight.w700)),
                  const SizedBox(height: 32),

                  _ScoreSlider(
                    label: 'ACCURACY',
                    value: _accuracy,
                    color: AppColors.chung,
                    onChanged: (v) => setState(() => _accuracy = v),
                  ),
                  const SizedBox(height: 28),
                  _ScoreSlider(
                    label: 'PRESENTATION',
                    value: _presentation,
                    color: AppColors.hong,
                    onChanged: (v) => setState(() => _presentation = v),
                  ),
                  const SizedBox(height: 32),

                  // Total
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(children: [
                      const Text('TOTAL',
                          style: TextStyle(color: AppColors.textDisabled,
                              fontSize: 11, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text(
                        (_accuracy + _presentation).toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white,
                            fontSize: 48, fontWeight: FontWeight.w900,
                            height: 1),
                      ),
                      const Text('out of 20.0',
                          style: TextStyle(color: AppColors.textDisabled,
                              fontSize: 12)),
                    ]),
                  ),

                  const SizedBox(height: 28),

                  GestureDetector(
                    onTap: _submitScore,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: Text('SUBMIT SCORE',
                          style: TextStyle(color: Colors.white,
                              fontSize: 18, fontWeight: FontWeight.w900,
                              letterSpacing: 2))),
                    ),
                  ),
                ]),

              const Spacer(),
            ]),
          ),

          // Disconnected overlay
          if (!isConnected)
            Container(
              color: Colors.black.withOpacity(0.88),
              child: const Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: AppColors.error, size: 48),
                  SizedBox(height: 16),
                  Text('DISCONNECTED',
                      style: TextStyle(color: AppColors.error,
                          fontSize: 24, fontWeight: FontWeight.w900,
                          letterSpacing: 3)),
                  SizedBox(height: 8),
                  Text('Reconnecting…',
                      style: TextStyle(color: AppColors.textSecondary,
                          fontSize: 14)),
                ],
              )),
            ),
        ]),
      ),
    );
  }
}

class _ScoreSlider extends StatelessWidget {
  const _ScoreSlider({required this.label, required this.value,
    required this.color, required this.onChanged});
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: color,
            fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2)),
        Text(value.toStringAsFixed(1),
            style: TextStyle(color: color, fontSize: 28,
                fontWeight: FontWeight.w900)),
      ]),
      const SizedBox(height: 8),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: color,
          inactiveTrackColor: color.withOpacity(0.2),
          thumbColor: color,
          overlayColor: color.withOpacity(0.15),
          trackHeight: 6,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
        ),
        child: Slider(
          value: value,
          min: 0.0,
          max: 10.0,
          divisions: 100, // 0.1 increments
          onChanged: onChanged,
        ),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('0.0', style: TextStyle(color: AppColors.textDisabled,
            fontSize: 11)),
        const Text('10.0', style: TextStyle(color: AppColors.textDisabled,
            fontSize: 11)),
      ]),
    ]);
  }
}