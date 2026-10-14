import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/poomsae_models.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/poomsae_provider.dart';

class PoomsaeResultsScreen extends ConsumerWidget {
  const PoomsaeResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(poomsaeServerProvider).sessionState;

    if (state == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
      return const SizedBox.shrink();
    }

    // Sort by final score descending
    final ranked = state.athletes
        .where((a) => state.results.containsKey(a.id))
        .map((a) => state.results[a.id]!)
        .toList()
      ..sort((a, b) => b.finalScore.compareTo(a.finalScore));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(state.sessionName,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(poomsaeServerProvider.notifier).stopServer();
              context.go('/');
            },
            icon: const Icon(Icons.home, color: AppColors.textSecondary),
            label: const Text('End Session',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingMd),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(children: [
              const TkSectionLabel('Final Rankings'),

              if (ranked.isEmpty)
                const TkCard(child: Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No results yet',
                      style: TextStyle(color: AppColors.textDisabled)),
                )))
              else
                ...ranked.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final result = entry.value;
                  final isFirst = rank == 1;
                  final isSecond = rank == 2;
                  final isThird = rank == 3;

                  Color rankColor = AppColors.textDisabled;
                  if (isFirst) rankColor = const Color(0xFFFFD700);
                  if (isSecond) rankColor = const Color(0xFFC0C0C0);
                  if (isThird) rankColor = const Color(0xFFCD7F32);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TkCard(
                      borderColor: isFirst
                          ? rankColor.withOpacity(0.5) : AppColors.border,
                      color: isFirst
                          ? rankColor.withOpacity(0.05) : AppColors.surface,
                      child: Row(children: [
                        // Rank
                        SizedBox(
                          width: 40,
                          child: Text('$rank',
                              style: TextStyle(color: rankColor,
                                  fontSize: isFirst ? 28 : 22,
                                  fontWeight: FontWeight.w900),
                              textAlign: TextAlign.center),
                        ),
                        const SizedBox(width: 16),

                        // Name
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(result.athleteName,
                                style: TextStyle(
                                  color: isFirst
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimary,
                                  fontSize: isFirst ? 18 : 16,
                                  fontWeight: FontWeight.w700,
                                )),
                            // Individual judge scores
                            Text(
                              result.scores
                                  .map((s) => s.total.toStringAsFixed(1))
                                  .join('  '),
                              style: const TextStyle(
                                  color: AppColors.textDisabled, fontSize: 11),
                            ),
                          ],
                        )),

                        // Final score
                        Column(crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                          Text(result.finalScore.toStringAsFixed(2),
                              style: TextStyle(
                                color: isFirst ? rankColor : AppColors.textPrimary,
                                fontSize: isFirst ? 28 : 22,
                                fontWeight: FontWeight.w900,
                              )),
                          const Text('final', style: TextStyle(
                              color: AppColors.textDisabled, fontSize: 10)),
                        ]),
                      ]),
                    ),
                  );
                }),

              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}