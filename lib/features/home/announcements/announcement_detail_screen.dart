import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_spacing.dart';
import '../../../core/models/announcement_model.dart';
import '../../../core/providers/announcement_provider.dart';
import '../../../features/auth/domain/auth_state.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../shared/utils/time_formatter.dart';
import 'create_announcement_screen.dart';

class AnnouncementDetailScreen extends ConsumerWidget {
  const AnnouncementDetailScreen({super.key, required this.announcement});

  final AnnouncementModel announcement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isOwner = authState is AuthStateAuthenticated &&
        authState.user.uid == announcement.authorUid;
    final cat = announcement.category;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Оголошення'),
        actions: [
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateAnnouncementScreen(
                    existing: announcement,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // ── Категорія ────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: AppSpacing.iconMd, color: cat.color),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      cat.label,
                      style: textTheme.labelLarge?.copyWith(
                        color: cat.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                TimeFormatter.format(announcement.createdAt),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Заголовок ────────────────────────────────────────────────────
          Text(announcement.title, style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),

          // ── Опис ─────────────────────────────────────────────────────────
          Text(announcement.description, style: textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xxl),

          // ── Контакт ───────────────────────────────────────────────────────
          if (announcement.contactInfo != null &&
              announcement.contactInfo!.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.contact_phone_outlined,
              label: 'Контакт',
              value: announcement.contactInfo!,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Місто ─────────────────────────────────────────────────────────
          if (announcement.city != null) ...[
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Місто',
              value: announcement.city!,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          const Divider(),
          const SizedBox(height: AppSpacing.lg),

          // ── Автор ─────────────────────────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: announcement.authorPhotoUrl != null
                    ? NetworkImage(announcement.authorPhotoUrl!)
                    : null,
                child: announcement.authorPhotoUrl == null
                    ? Text(
                        announcement.authorName.isNotEmpty
                            ? announcement.authorName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.authorName,
                    style: textTheme.titleSmall,
                  ),
                  if (announcement.city != null)
                    Text(
                      announcement.city!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити оголошення?'),
        content: const Text('Це оголошення буде архівовано.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref
          .read(announcementServiceProvider)
          .deleteAnnouncement(announcement.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSpacing.iconMd, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(value, style: textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}
