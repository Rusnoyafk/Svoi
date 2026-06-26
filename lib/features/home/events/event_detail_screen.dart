import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_spacing.dart';
import '../../../core/models/event_model.dart';
import '../../../core/providers/event_provider.dart';
import '../../../features/auth/domain/auth_state.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../shared/utils/time_formatter.dart';
import 'create_event_screen.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUid = authState is AuthStateAuthenticated
        ? authState.user.uid
        : null;
    final isOwner = currentUid == event.authorUid;
    final isParticipant =
        currentUid != null && event.participantUids.contains(currentUid);
    final cat = event.category;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Івент'),
        actions: [
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateEventScreen(existing: event),
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
          // ── Категорія + Online ────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
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
              if (event.isOnline) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    'Онлайн',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Дата і час ───────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: AppSpacing.iconMd, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TimeFormatter.formatEventDateFull(event.eventDate),
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  if (event.eventEndDate != null)
                    Text(
                      'до ${TimeFormatter.formatEventDateFull(event.eventEndDate!)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Заголовок ────────────────────────────────────────────────────
          Text(event.title, style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),

          // ── Опис ─────────────────────────────────────────────────────────
          Text(event.description, style: textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xxl),

          // ── Локація ───────────────────────────────────────────────────────
          if (!event.isOnline &&
              (event.address != null || event.city != null)) ...[
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Місце',
              value: [
                if (event.address != null) event.address!,
                if (event.city != null) event.city!,
              ].join(', '),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // ── Онлайн посилання (тільки учасникам) ──────────────────────────
          if (event.isOnline &&
              event.onlineLink != null &&
              (isParticipant || isOwner)) ...[
            _InfoRow(
              icon: Icons.link_outlined,
              label: 'Посилання',
              value: event.onlineLink!,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (event.isOnline &&
              event.onlineLink != null &&
              !isParticipant &&
              !isOwner) ...[
            _InfoRow(
              icon: Icons.lock_outline,
              label: 'Посилання',
              value: 'Доступне після реєстрації',
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // ── Контакт ───────────────────────────────────────────────────────
          if (event.contactInfo != null && event.contactInfo!.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.contact_phone_outlined,
              label: 'Контакт',
              value: event.contactInfo!,
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // ── Учасники ──────────────────────────────────────────────────────
          _InfoRow(
            icon: Icons.people_outline,
            label: 'Учасники',
            value: event.maxParticipants != null
                ? '${event.participantCount} з ${event.maxParticipants}'
                : '${event.participantCount} учасників',
          ),
          const SizedBox(height: AppSpacing.xxl),

          const Divider(),
          const SizedBox(height: AppSpacing.lg),

          // ── Автор ─────────────────────────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: event.authorPhotoUrl != null
                    ? NetworkImage(event.authorPhotoUrl!)
                    : null,
                child: event.authorPhotoUrl == null
                    ? Text(
                        event.authorName.isNotEmpty
                            ? event.authorName[0].toUpperCase()
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
                  Text('Організатор', style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
                  Text(event.authorName, style: textTheme.titleSmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Кнопка участі ─────────────────────────────────────────────────
          if (!isOwner && currentUid != null)
            _ParticipateButton(
              event: event,
              uid: currentUid,
              isParticipant: isParticipant,
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити івент?'),
        content: const Text('Він буде архівований.'),
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
      await ref.read(eventServiceProvider).deleteEvent(event.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

// ── Кнопка "Приєднатися / Відписатися" ───────────────────────────────────────

class _ParticipateButton extends ConsumerStatefulWidget {
  const _ParticipateButton({
    required this.event,
    required this.uid,
    required this.isParticipant,
  });

  final EventModel event;
  final String uid;
  final bool isParticipant;

  @override
  ConsumerState<_ParticipateButton> createState() =>
      _ParticipateButtonState();
}

class _ParticipateButtonState extends ConsumerState<_ParticipateButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final isFull = widget.event.isFull && !widget.isParticipant;

    if (isFull) {
      return FilledButton.tonal(
        onPressed: null,
        child: const Text('Місць немає'),
      );
    }

    return widget.isParticipant
        ? OutlinedButton.icon(
            onPressed: _loading ? null : _leave,
            icon: const Icon(Icons.exit_to_app_outlined),
            label: const Text('Відписатися'),
          )
        : FilledButton.icon(
            onPressed: _loading ? null : _join,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.how_to_reg_outlined),
            label: const Text('Приєднатися'),
          );
  }

  Future<void> _join() async {
    setState(() => _loading = true);
    try {
      await ref
          .read(eventServiceProvider)
          .joinEvent(widget.event.id, widget.uid);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _leave() async {
    setState(() => _loading = true);
    try {
      await ref
          .read(eventServiceProvider)
          .leaveEvent(widget.event.id, widget.uid);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ── Рядок інфо ───────────────────────────────────────────────────────────────

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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
              Text(value, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
