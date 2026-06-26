import 'package:flutter/material.dart';
import '../../../../core/app_spacing.dart';
import '../../../../core/models/announcement_model.dart';
import '../../../../shared/utils/time_formatter.dart';
import '../../../../shared/widgets/svoi_card.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onTap,
  });

  final AnnouncementModel announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final cat = announcement.category;

    return SvoiCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Категорія + час ──────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 13, color: cat.color),
                    const SizedBox(width: 4),
                    Text(
                      cat.label,
                      style: textTheme.labelSmall?.copyWith(
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
          const SizedBox(height: AppSpacing.sm),

          // ── Заголовок ────────────────────────────────────────────────────
          Text(
            announcement.title,
            style: textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Опис ─────────────────────────────────────────────────────────
          Text(
            announcement.description,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Автор + місто ─────────────────────────────────────────────────
          Row(
            children: [
              _AuthorAvatar(
                name: announcement.authorName,
                photoUrl: announcement.authorPhotoUrl,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  announcement.authorName,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (announcement.city != null) ...[
                Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 2),
                Text(
                  announcement.city!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({required this.name, this.photoUrl});

  final String name;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: 12,
      backgroundColor: colorScheme.primaryContainer,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Text(
              initial,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );
  }
}
