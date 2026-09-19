import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/ws_client_provider.dart';
import '../../setup/providers/session_provider.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});
  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  final _scanner = MobileScannerController();
  bool _scanned = false;
  bool _connecting = false;
  String? _error;

  @override
  void dispose() { _scanner.dispose(); super.dispose(); }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final ip = data['ip'] as String;
      final port = data['port'] as int;
      final token = data['sessionToken'] as String;

      setState(() { _scanned = true; _connecting = true; _error = null; });
      HapticFeedback.mediumImpact();
      await _scanner.stop();

      final session = ref.read(sessionProvider);
      if (session == null) {
        setState(() { _error = 'Session expired. Restart the app.'; _connecting = false; _scanned = false; });
        return;
      }

      ref.read(sessionProvider.notifier).setServerIp(ip);
      await ref.read(wsClientProvider.notifier).connect(
        ip: ip, port: port, sessionToken: token, judgeSlot: session.judgeSlot,
      );

      if (mounted) context.go('/kyorugi/judge/${session.judgeSlot}');
    } catch (e) {
      setState(() { _scanned = false; _connecting = false; _error = 'Invalid QR. Scan the code on the scoreboard.'; });
      _scanner.start();
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
      backgroundColor: Colors.black,
      body: Stack(children: [
        if (!_connecting) MobileScanner(controller: _scanner, onDetect: _onDetect),

        if (_connecting)
          Container(color: AppColors.background,
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const CircularProgressIndicator(color: AppColors.chung, strokeWidth: 3),
              const SizedBox(height: 24),
              const Text('Connecting…', style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Judge ${session.judgeSlot}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ]))),

        if (!_connecting) SafeArea(child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20)),
              ),
              const SizedBox(width: 16),
              Text('Judge ${session.judgeSlot}  ·  Scan QR',
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            ]),
          ),
          const Spacer(),
          Center(child: Container(width: 240, height: 240,
            decoration: BoxDecoration(border: Border.all(color: AppColors.chung, width: 3),
                borderRadius: BorderRadius.circular(16)))),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(color: const Color.fromRGBO(0, 0, 0, 0.7), borderRadius: BorderRadius.circular(12)),
            child: const Text('Point your camera at the QR code\nshown on the scoreboard laptop',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColors.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withOpacity(0.4))),
              child: Row(children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
              ]),
            ),
          ],
          const SizedBox(height: 48),
        ])),
      ]),
    );
  }
}