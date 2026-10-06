import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';

class PoomsaeStubScreen extends StatelessWidget {
  const PoomsaeStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Poomsae'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.self_improvement, size: 64, color: AppColors.textDisabled),
            SizedBox(height: 16),
            Text('Poomsae Module', style: TextStyle(
              color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('Coming soon', style: TextStyle(
              color: AppColors.textDisabled, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}