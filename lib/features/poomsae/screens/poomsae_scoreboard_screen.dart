import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/poomsae_models.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../providers/poomsae_provider.dart';

class PoomsaeScoreboardScreen extends ConsumerWidget {
  const PoomsaeScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(poomsaeServerProvider);
    final state = server.sessionState;
    final notifier = ref.read(poomsaeServerProvider.notifier);

    if (state == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.chung)),
      );
    }

    final athlete = state.currentAthlete;
    final scores = state.scoresForCurrent;
    final result = athlete != null ? state.results[athlete.id] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(state.sessionName,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            notifier.stopServer();
            context.go('/');
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(children: [
              Text('${state.connectedJudges}/5 judges',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(width: 8),
              ConnectionDot(isConnected: state.connectedJudges >= 5),
            ]),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingMd),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(children: [

              // Progress bar — which athlete we're on
              _AthleteProgress(state: state),
              const SizedBox(height: 20),

              // Current athlete card
              if (athlete != null) ...[
                TkCard(child: Column(children: [
                  Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.chung.withOpacity(0.15),
                      ),
                      child: Center(child: Text('${athlete.order}',
                          style: const TextStyle(color: AppColors.chung,
                              fontSize: 20, fontWeight: FontWeight.w900))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(athlete.name, style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20, fontWeight: FontWeight.w800)),
                        if (athlete.team != null)
                          Text(athlete.team!, style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    )),
                    _StatusBadge(status: state.status),
                  ]),

                  const SizedBox(height: 20),

                  // Score submissions progress
                  if (state.status == PoomsaeSessionStatus.scoring ||
                      state.status == PoomsaeSessionStatus.calculated) ...[
                    Row(children: List.generate(5, (i) {
                      final slot = i + 1;
                      final submitted = scores.any((s) => s.judgeSlot == slot);
                      final score = scores.firstWhere(
                          (s) => s.judgeSlot == slot,
                          orElse: () => PoomsaeScore(
                            judgeId: '', judgeSlot: slot,
                            athleteId: '', athleteName: '',
                            accuracy: 0, presentation: 0,
                            submittedAt: DateTime.now(),
                          ));

                      final isDropped = result != null &&
                          (result.droppedHighSlot == slot ||
                              result.droppedLowSlot == slot);

                      return Expanded(child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: submitted
                                ? (isDropped
                                    ? AppColors.textDisabled.withOpacity(0.1)
                                    : AppColors.success.withOpacity(0.1))
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: submitted
                                  ? (isDropped
                                      ? AppColors.textDisabled
                                      : AppColors.success)
                                  : AppColors.border,
                            ),
                          ),
                          child: Column(children: [
                            Text('J$slot', style: TextStyle(
                                color: submitted
                                    ? (isDropped
                                        ? AppColors.textDisabled
                                        : AppColors.success)
                                    : AppColors.textDisabled,
                                fontSize: 11, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            if (submitted) ...[
                              Text(score.total.toStringAsFixed(1),
                                style: TextStyle(
                                  color: isDropped
                                      ? AppColors.textDisabled
                                      : AppColors.textPrimary,
                                  fontSize: 18, fontWeight: FontWeight.w900,
                                  decoration: isDropped
                                      ? TextDecoration.lineThrough
                                      : null,
                                )),
                              if (isDropped)
                                Text(
                                  result!.droppedHighSlot == slot
                                      ? 'HIGH' : 'LOW',
                                  style: const TextStyle(
                                    color: AppColors.textDisabled,
                                    fontSize: 9, letterSpacing: 1),
                                ),
                            ] else
                              const Text('--', style: TextStyle(
                                  color: AppColors.textDisabled, fontSize: 18)),
                          ]),
                        ),
                      ));
                    })),

                    const SizedBox(height: 16),

                    // Final score reveal
                    if (result != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.chung.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.chung.withOpacity(0.3)),
                        ),
                        child: Column(children: [
                          const Text('FINAL SCORE', style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12,
                              letterSpacing: 2, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(result.finalScore.toStringAsFixed(2),
                            style: const TextStyle(color: AppColors.chung,
                                fontSize: 56, fontWeight: FontWeight.w900,
                                height: 1)),
                        ]),
                      ),

                    const SizedBox(height: 4),
                    Text('${scores.length}/5 submitted',
                        style: const TextStyle(
                            color: AppColors.textDisabled, fontSize: 12)),
                  ],
                ])),

                const SizedBox(height: 20),

                // Chief Jury controls
                const TkSectionLabel('Controls'),
                TkCard(child: Column(children: [
                  if (state.status == PoomsaeSessionStatus.setup ||
                      state.status == PoomsaeSessionStatus.calculated) ...[
                    TkButton(
                      label: 'ATHLETE PERFORMING',
                      icon: Icons.directions_run,
                      color: AppColors.chung,
                      onTap: notifier.startPerformance,
                    ),
                  ],

                  if (state.status == PoomsaeSessionStatus.performing) ...[
                    TkButton(
                      label: 'OPEN SCORING',
                      icon: Icons.how_to_vote,
                      color: AppColors.success,
                      onTap: notifier.openScoring,
                    ),
                  ],

                  if (state.status == PoomsaeSessionStatus.scoring) ...[
                    TkButton(
                      label: 'CALCULATE RESULT',
                      icon: Icons.calculate,
                      color: AppColors.warning,
                      onTap: notifier.calculateResult,
                      enabled: state.allScoresSubmitted,
                    ),
                    if (!state.allScoresSubmitted) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Waiting for ${5 - scores.length} more judge(s)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textDisabled, fontSize: 12),
                      ),
                    ],
                  ],

                  if (state.status == PoomsaeSessionStatus.calculated &&
                      state.currentAthleteIndex < state.athletes.length - 1) ...[
                    const SizedBox(height: 12),
                    TkButton(
                      label: 'NEXT ATHLETE',
                      icon: Icons.skip_next,
                      outlined: true,
                      onTap: notifier.nextAthlete,
                    ),
                  ],

                  if (state.status == PoomsaeSessionStatus.finished ||
                      (state.status == PoomsaeSessionStatus.calculated &&
                          state.currentAthleteIndex >= state.athletes.length - 1)) ...[
                    const SizedBox(height: 12),
                    TkButton(
                      label: 'VIEW RESULTS',
                      icon: Icons.emoji_events,
                      color: AppColors.warning,
                      onTap: () => context.push('/poomsae/results'),
                    ),
                  ],
                ])),
              ],

              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}

class _AthleteProgress extends StatelessWidget {
  const _AthleteProgress({required this.state});
  final PoomsaeSessionState state;

  @override
  Widget build(BuildContext context) {
    return TkCard(
      color: AppColors.surfaceElevated,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('ATHLETES', style: TextStyle(color: AppColors.textSecondary,
              fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
          Text('${state.currentAthleteIndex + 1} of ${state.athletes.length}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ]),
        const SizedBox(height: 10),
        Row(children: List.generate(state.athletes.length, (i) {
          final done = state.results.containsKey(state.athletes[i].id);
          final current = i == state.currentAthleteIndex;
          return Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: done
                    ? AppColors.success
                    : current
                        ? AppColors.chung
                        : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ));
        })),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final PoomsaeSessionStatus status;

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    switch (status) {
      case PoomsaeSessionStatus.setup:
        label = 'READY'; color = AppColors.textDisabled; break;
      case PoomsaeSessionStatus.performing:
        label = 'PERFORMING'; color = AppColors.chung; break;
      case PoomsaeSessionStatus.scoring:
        label = 'SCORING'; color = AppColors.warning; break;
      case PoomsaeSessionStatus.calculated:
        label = 'DONE'; color = AppColors.success; break;
      case PoomsaeSessionStatus.finished:
        label = 'FINISHED'; color = AppColors.success; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(color: color,
          fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
    );
  }
}