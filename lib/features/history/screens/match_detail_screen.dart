import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../database/app_database.dart';
import '../../../services/export/pdf_exporter.dart';
import '../../../services/export/excel_exporter.dart';
import '../providers/history_provider.dart';

class MatchDetailScreen extends ConsumerWidget {
  const MatchDetailScreen({super.key, required this.matchId});
  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchAsync = ref.watch(matchDetailProvider(matchId));
    final eventsAsync = ref.watch(matchEventsProvider(matchId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Match Detail',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: matchAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.chung)),
        error: (e, _) => Center(child: Text('$e',
            style: const TextStyle(color: AppColors.error))),
        data: (match) {
          if (match == null) return const Center(
              child: Text('Match not found',
                  style: TextStyle(color: AppColors.textSecondary)));

          return eventsAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.chung)),
            error: (e, _) => Center(child: Text('$e')),
            data: (events) => _MatchDetailBody(
                match: match, events: events),
          );
        },
      ),
    );
  }
}

class _MatchDetailBody extends StatelessWidget {
  const _MatchDetailBody({required this.match, required this.events});
  final MatchRecord match;
  final List<ConsensusEventRecord> events;

  @override
  Widget build(BuildContext context) {
    final chungWins = match.winner == 'chung';
    final hongWins = match.winner == 'hong';
    final awarded = events.where((e) => e.outcome == 'awarded').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.paddingMd),
      child: Column(children: [
        // ── Score card ─────────────────────────────────────────────────
        TkCard(child: Column(children: [
          if (match.category != null)
            Text(match.category!, style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Column(children: [
              Text(match.chungName, style: TextStyle(
                color: chungWins ? AppColors.chung : AppColors.textPrimary,
                fontSize: 16, fontWeight: FontWeight.w800)),
              Text('${match.chungScore}', style: TextStyle(
                color: chungWins ? AppColors.chung : Colors.white,
                fontSize: 64, fontWeight: FontWeight.w900, height: 1)),
              Text('${match.chungPenalties} gam-jeom',
                  style: const TextStyle(color: AppColors.textDisabled, fontSize: 12)),
              if (chungWins) const Text('WINNER', style: TextStyle(
                  color: AppColors.chung, fontSize: 12, fontWeight: FontWeight.w800)),
            ])),
            Column(children: [
              const Text('VS', style: TextStyle(color: AppColors.textDisabled,
                  fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('R${match.totalRounds}', style: const TextStyle(
                  color: AppColors.textDisabled, fontSize: 12)),
            ]),
            Expanded(child: Column(children: [
              Text(match.hongName, style: TextStyle(
                color: hongWins ? AppColors.hong : AppColors.textPrimary,
                fontSize: 16, fontWeight: FontWeight.w800)),
              Text('${match.hongScore}', style: TextStyle(
                color: hongWins ? AppColors.hong : Colors.white,
                fontSize: 64, fontWeight: FontWeight.w900, height: 1)),
              Text('${match.hongPenalties} gam-jeom',
                  style: const TextStyle(color: AppColors.textDisabled, fontSize: 12)),
              if (hongWins) const Text('WINNER', style: TextStyle(
                  color: AppColors.hong, fontSize: 12, fontWeight: FontWeight.w800)),
            ])),
          ]),
        ])),

        const SizedBox(height: 16),

        // ── Export buttons ─────────────────────────────────────────────
        Row(children: [
          Expanded(child: TkButton(
            label: 'EXPORT PDF',
            icon: Icons.picture_as_pdf,
            color: AppColors.error,
            onTap: () => PdfExporter.exportMatch(
                match: match, events: events),
          )),
          const SizedBox(width: 12),
          Expanded(child: TkButton(
            label: 'EXPORT EXCEL',
            icon: Icons.table_chart,
            color: AppColors.success,
            onTap: () => ExcelExporter.exportMatch(
                match: match, events: events),
          )),
        ]),

        const SizedBox(height: 20),

        // ── Scoring log ────────────────────────────────────────────────
        const TkSectionLabel('Scoring Log'),
        if (awarded.isEmpty)
          const TkCard(child: Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No points awarded',
                style: TextStyle(color: AppColors.textDisabled)),
          )))
        else
          TkCard(child: Column(
            children: awarded.asMap().entries.map((entry) {
              final e = entry.value;
              final isChung = e.awardedTo == 'chung';
              final color = isChung ? AppColors.chung : AppColors.hong;
              final name = isChung ? match.chungName : match.hongName;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Container(width: 3, height: 36,
                      decoration: BoxDecoration(color: color,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 12),
                  Text('R${e.round}', style: const TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: TextStyle(color: color,
                        fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(_techLabel(e.technique), style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                  ])),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.15)),
                    child: Center(child: Text('+${e.pointsAwarded}',
                        style: TextStyle(color: color, fontSize: 13,
                            fontWeight: FontWeight.w900))),
                  ),
                ]),
              );
            }).toList(),
          )),

        const SizedBox(height: 20),

        // ── Stats ──────────────────────────────────────────────────────
        const TkSectionLabel('Match Stats'),
        TkCard(child: Column(children: [
          _StatRow('Total scoring actions', '${awarded.length}'),
          _StatRow('No consensus windows',
              '${events.where((e) => e.outcome == 'noConsensus').length}'),
          _StatRow('Gam-jeom (${match.chungName})',
              '${match.chungPenalties}'),
          _StatRow('Gam-jeom (${match.hongName})',
              '${match.hongPenalties}'),
          _StatRow('Duration',
              match.completedAt != null
                  ? _duration(match.createdAt, match.completedAt!)
                  : '-'),
        ])),

        const SizedBox(height: 24),
      ]),
    );
  }

  String _techLabel(String? tech) {
    switch (tech) {
      case 'headKick': return 'Head Kick (+3)';
      case 'bodyKick': return 'Body Kick (+2)';
      case 'punch': return 'Punch (+1)';
      case 'gamjeom': return 'Gam-jeom';
      default: return tech ?? '-';
    }
  }

  String _duration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    return '${diff.inMinutes}m ${diff.inSeconds % 60}s';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Text(label, style: const TextStyle(
          color: AppColors.textSecondary, fontSize: 14)),
      const Spacer(),
      Text(value, style: const TextStyle(
          color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
    ]),
  );
}