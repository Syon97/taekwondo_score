import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/judge.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../setup/providers/session_provider.dart';
import '../../pairing/providers/pairing_provider.dart';

class QrDisplayScreen extends ConsumerStatefulWidget {
  const QrDisplayScreen({super.key});
  @override
  ConsumerState<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends ConsumerState<QrDisplayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serverProvider.notifier).startServer();
    });
  }

  void _showQrModal(BuildContext context, String? data) {
    if (data == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Scan to Join', style: TextStyle(
              color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 280,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square, color: Color(0xFF0A0A0A)),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0A0A0A)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.black54)),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final server = ref.watch(serverProvider);

    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
      return const SizedBox.shrink();
    }

    final qrData = server.localIp != null
        ? jsonEncode(session.toQrPayload(server.localIp!))
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Connect Judges',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            ref.read(serverProvider.notifier).stopServer();
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingMd),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(children: [
              // Match pill
              TkCard(
                color: AppColors.surfaceElevated,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _FighterPill(name: session.chungName, color: AppColors.chung),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('VS', style: TextStyle(color: AppColors.textDisabled,
                          fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2))),
                  _FighterPill(name: session.hongName, color: AppColors.hong),
                ]),
              ),
              const SizedBox(height: 24),

              // QR + checklist side by side
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // QR panel
                Expanded(flex: 2, child: TkCard(child: Column(children: [
                  const Text('SCAN TO JOIN', style: TextStyle(color: AppColors.textSecondary,
                      fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _showQrModal(context, qrData),
                    child: _QrWidget(data: qrData, isLoading: server.isStarting),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap to enlarge', style: TextStyle(
                    color: AppColors.textDisabled, fontSize: 11)),
                  const SizedBox(height: 16),
                  if (server.localIp != null)
                    GestureDetector(
                      onTap: () => Clipboard.setData(
                          ClipboardData(text: '${server.localIp}:${AppConstants.wsPort}')),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.wifi, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text('${server.localIp}:${AppConstants.wsPort}',
                              style: const TextStyle(color: AppColors.textSecondary,
                                  fontSize: 13)),
                          const SizedBox(width: 8),
                          const Icon(Icons.copy, size: 14, color: AppColors.textDisabled),
                        ]),
                      ),
                    ),
                  if (server.error != null) ...[
                    const SizedBox(height: 12),
                    Text(server.error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                  ],
                ]))),

                const SizedBox(width: 16),

                // Judge checklist
                Expanded(flex: 3, child: TkCard(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('JUDGES', style: TextStyle(color: AppColors.textSecondary,
                      fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  ...List.generate(4, (i) {
                    final slot = i + 1;
                    final judge = server.matchState?.judges.firstWhere(
                          (j) => j.slot == slot,
                          orElse: () => Judge(id: '', slot: slot, isConnected: false),
                        );
                    return _JudgeRow(slot: slot, judge: judge);
                  }),
                  const SizedBox(height: 20),
                  const TkDivider(),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Connected', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    Text('${server.connectedJudges} / 4',
                        style: TextStyle(
                          color: server.allJudgesReady ? AppColors.success : AppColors.textPrimary,
                          fontSize: 20, fontWeight: FontWeight.w900,
                        )),
                  ]),
                  const SizedBox(height: 20),
                  TkButton(
                    label: server.allJudgesReady ? 'START MATCH' : 'WAITING FOR JUDGES…',
                    icon: server.allJudgesReady ? Icons.play_arrow : Icons.hourglass_empty,
                    onTap: () => context.go('/kyorugi/scoreboard'),
                    enabled: server.isRunning,
                  ),
                  if (!server.allJudgesReady) ...[
                    const SizedBox(height: 10),
                    TkButton(label: 'START ANYWAY', onTap: () => context.go('/kyorugi/scoreboard'),
                        outlined: true, small: true, enabled: server.isRunning),
                  ],
                ]))),
              ]),

              const SizedBox(height: 20),

              // Session token row
              if (server.isRunning)
                TkCard(child: Row(children: [
                  const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  const Text('Token: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text(session.sessionToken, style: const TextStyle(color: AppColors.textPrimary,
                      fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 4)),
                  const Spacer(),
                  const Text('Embedded in QR', style: TextStyle(color: AppColors.textDisabled, fontSize: 11)),
                ])),

              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}

class _FighterPill extends StatelessWidget {
  const _FighterPill({required this.name, required this.color});
  final String name; final Color color;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    const SizedBox(width: 8),
    Text(name, style: const TextStyle(color: AppColors.textPrimary,
        fontSize: 16, fontWeight: FontWeight.w700)),
  ]);
}

class _QrWidget extends StatelessWidget {
  const _QrWidget({required this.data, required this.isLoading});
  final String? data; final bool isLoading;
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(width: 200, height: 200,
        decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(color: AppColors.chung, strokeWidth: 2),
          SizedBox(height: 12),
          Text('Starting server…', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ])));
    }
    if (data == null) {
      return Container(width: 200, height: 200,
        decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Icon(Icons.error_outline, color: AppColors.error, size: 40)));
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: QrImageView(data: data!, version: QrVersions.auto, size: 176,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0A0A0A)),
        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0A0A0A)),
      ),
    );
  }
}

class _JudgeRow extends StatelessWidget {
  const _JudgeRow({required this.slot, this.judge});
  final int slot; final Judge? judge;
  @override
  Widget build(BuildContext context) {
    final connected = judge?.isConnected ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        ConnectionDot(isConnected: connected, size: 14),
        const SizedBox(width: 12),
        Text('Judge $slot', style: TextStyle(
            color: connected ? AppColors.textPrimary : AppColors.textDisabled,
            fontSize: 15, fontWeight: FontWeight.w600)),
        if (judge?.deviceName != null) ...[
          const SizedBox(width: 8),
          Text(judge!.deviceName!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: connected ? AppColors.success.withOpacity(0.12) : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(connected ? 'READY' : 'WAITING',
              style: TextStyle(color: connected ? AppColors.success : AppColors.textDisabled,
                  fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
        ),
      ]),
    );
  }
}