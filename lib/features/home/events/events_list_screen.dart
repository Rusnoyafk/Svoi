import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_category.dart';
import '../../../core/app_spacing.dart';
import '../../../core/providers/event_provider.dart';
import '../../../shared/widgets/svoi_empty_state.dart';
import '../../../shared/widgets/svoi_loading.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';
import 'widgets/event_card.dart';

class EventsListScreen extends ConsumerWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedEventCategoryProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(eventsProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _CategoryChips(selected: selectedCategory),
            ),
            eventsAsync.when(
              loading: () =>
                  const SliverFillRemaining(child: SvoiLoading()),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Помилка: $e')),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return SliverFillRemaining(
                    child: SvoiEmptyState(
                      icon: Icons.event_outlined,
                      title: 'Івентів поки немає',
                      subtitle: selectedCategory != null
                          ? 'У категорії «${selectedCategory.label}» нічого немає'
                          : 'Будьте першим — створіть івент',
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: i == 0
                          ? const EdgeInsets.only(top: AppSpacing.sm)
                          : EdgeInsets.zero,
                      child: EventCard(
                        event: list[i],
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) =>
                                EventDetailScreen(event: list[i]),
                          ),
                        ),
                      ),
                    ),
                    childCount: list.length,
                  ),
                );
              },
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateEventScreen()),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Горизонтальні chips категорій ─────────────────────────────────────────────

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({required this.selected});

  final EventCategory? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _Chip(
              label: 'Усі',
              icon: Icons.apps,
              color: colorScheme.primary,
              selected: selected == null,
              onTap: () =>
                  ref.read(selectedEventCategoryProvider.notifier).select(null),
            ),
          ),
          ...EventCategory.values.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _Chip(
                label: cat.label,
                icon: cat.icon,
                color: cat.color,
                selected: selected == cat,
                onTap: () => ref
                    .read(selectedEventCategoryProvider.notifier)
                    .select(cat),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : colorScheme.surfaceContainerLow,
          border: Border.all(
            color: selected ? color : colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected ? color : colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? color : colorScheme.onSurface,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
