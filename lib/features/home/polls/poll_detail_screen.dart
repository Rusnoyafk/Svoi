import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_spacing.dart';
import '../../../core/models/poll_model.dart';
import '../../../core/providers/poll_provider.dart';
import '../../../features/auth/domain/auth_state.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import 'widgets/poll_card.dart';

class PollDetailScreen extends ConsumerWidget {
  const PollDetailScreen({super.key, required this.poll});

  final PollModel poll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final uid = authState is AuthStateAuthenticated ? authState.user.uid : null;
    final isOwner = uid == poll.authorUid;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Опитування'),
        actions: [
          if (isOwner)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: () => _confirmDelete(context, ref),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Повторно використовуємо PollCard без onTap (лише контент)
          PollCard(poll: poll),
          const SizedBox(height: AppSpacing.lg),

          // ── Статистика ─────────────────────────────────────────────────────
          _StatRow(
              icon: Icons.how_to_vote_outlined,
              label: 'Всього голосів',
              value: '${poll.totalVotes}'),
          const SizedBox(height: AppSpacing.sm),
          _StatRow(
              icon: Icons.calendar_today_outlined,
              label: 'Завершується',
              value: _formatDate(poll.endsAt)),
          const SizedBox(height: AppSpacing.sm),
          _StatRow(
              icon: Icons.public_outlined,
              label: 'Аудиторія',
              value: poll.geoScope.label),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити опитування?'),
        content: const Text('Воно буде архівоване.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Скасувати')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(pollServiceProvider).deletePoll(poll.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'січня', 'лютого', 'березня', 'квітня', 'травня', 'червня',
      'липня', 'серпня', 'вересня', 'жовтня', 'листопада', 'грудня',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconMd, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            Text(value, style: textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}
