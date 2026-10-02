import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../database/app_database.dart';
import '../../../services/persistence/match_repository.dart';
import '../providers/history_provider.dart';

class MatchHistoryScreen extends ConsumerWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(matchHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Match History',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/'),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.chung)),
        error: (e, _) => Center(
          child: Text('Error loading history: $e',
              style: const TextStyle(color: AppColors.error))),
        data: (matches) {
          if (matches.isEmpty) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 64, color: AppColors.textDisabled),
                const SizedBox(height: 16),
                const Text('No matches yet',
                    style: TextStyle(color: AppColors.textSecondary,
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Completed matches will appear here',
                    style: TextStyle(color: AppColors.textDisabled, fontSize: 14)),
                const SizedBox(height: 32),
                TkButton(
                  label: 'START A MATCH',
                  icon: Icons.add,
                  fullWidth: false,
                  onTap: () => context.go('/'),
                ),
              ],
            ));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimens.paddingMd),
            itemCount: matches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _MatchTile(
              match: matches[i],
              onTap: () => context.push('/history/${matches[i].id}'),
              onDelete: () async {
                await ref.read(matchRepositoryProvider).deleteMatch(matches[i].id);
                ref.invalidate(matchHistoryProvider);
              },
            ),
          );
        },
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.match, required this.onTap, required this.onDelete});
  final MatchRecord match;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final chungWins = match.winner == 'chung';
    final hongWins = match.winner == 'hong';

    return GestureDetector(
      onTap: onTap,
      child: TkCard(
        child: Row(children: [
          // Chung score
          Column(children: [
            Text(match.chungName,
                style: TextStyle(
                  color: chungWins ? AppColors.chung : AppColors.textSecondary,
                  fontSize: 13, fontWeight: FontWeight.w700),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${match.chungScore}',
                style: TextStyle(
                  color: chungWins ? AppColors.chung : AppColors.textPrimary,
                  fontSize: 32, fontWeight: FontWeight.w900,
                  shadows: chungWins ? [Shadow(color: AppColors.chung.withOpacity(0.4), blurRadius: 12)] : null,
                )),
          ]),

          const Spacer(),

          // Centre info
          Column(children: [
            if (match.winner != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: (chungWins ? AppColors.chung : AppColors.hong).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chungWins ? '${match.chungName} wins'
                      : hongWins ? '${match.hongName} wins' : 'Draw',
                  style: TextStyle(
                    color: chungWins ? AppColors.chung : AppColors.hong,
                    fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            const SizedBox(height: 4),
            Text(_formatDate(match.createdAt),
                style: const TextStyle(color: AppColors.textDisabled, fontSize: 11)),
            if (match.category != null)
              Text(match.category!,
                  style: const TextStyle(color: AppColors.textDisabled, fontSize: 11)),
          ]),

          const Spacer(),

          // Hong score
          Column(children: [
            Text(match.hongName,
                style: TextStyle(
                  color: hongWins ? AppColors.hong : AppColors.textSecondary,
                  fontSize: 13, fontWeight: FontWeight.w700),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${match.hongScore}',
                style: TextStyle(
                  color: hongWins ? AppColors.hong : AppColors.textPrimary,
                  fontSize: 32, fontWeight: FontWeight.w900,
                  shadows: hongWins ? [Shadow(color: AppColors.hong.withOpacity(0.4), blurRadius: 12)] : null,
                )),
          ]),

          const SizedBox(width: 12),

          // Delete
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: const Icon(Icons.delete_outline,
                color: AppColors.textDisabled, size: 20),
          ),
        ]),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Match?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '${match.chungName} vs ${match.hongName}\n'
          'This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () { Navigator.pop(context); onDelete(); },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  '
      '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
}