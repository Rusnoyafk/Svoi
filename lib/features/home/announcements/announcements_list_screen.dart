import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_category.dart';
import '../../../core/app_spacing.dart';
import '../../../core/providers/announcement_provider.dart';
import '../../../shared/widgets/svoi_empty_state.dart';
import '../../../shared/widgets/svoi_loading.dart';
import 'announcement_detail_screen.dart';
import 'create_announcement_screen.dart';
import 'widgets/announcement_card.dart';

class AnnouncementsListScreen extends ConsumerWidget {
  const AnnouncementsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final announcementsAsync = ref.watch(announcementsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(announcementsProvider),
        child: CustomScrollView(
          slivers: [
            // ── Горизонтальний скрол категорій ───────────────────────────
            SliverToBoxAdapter(
              child: _CategoryChips(selected: selectedCategory),
            ),

            // ── Список оголошень ──────────────────────────────────────────
            announcementsAsync.when(
              loading: () => const SliverFillRemaining(
                child: SvoiLoading(),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Помилка: $e')),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return SliverFillRemaining(
                    child: SvoiEmptyState(
                      icon: Icons.campaign_outlined,
                      title: 'Оголошень поки немає',
                      subtitle: selectedCategory != null
                          ? 'У категорії «${selectedCategory.label}» нічого немає'
                          : 'Будьте першим — додайте оголошення',
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: AnnouncementCard(
                            announcement: list[i],
                            onTap: () => _openDetail(ctx, ref, list[i].id),
                          ),
                        );
                      }
                      return AnnouncementCard(
                        announcement: list[i],
                        onTap: () => _openDetail(ctx, ref, list[i].id),
                      );
                    },
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
          MaterialPageRoute(
            builder: (_) => const CreateAnnouncementScreen(),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openDetail(BuildContext context, WidgetRef ref, String id) {
    final list = ref.read(announcementsProvider).value ?? [];
    final ann = list.where((a) => a.id == id).firstOrNull;
    if (ann == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnnouncementDetailScreen(announcement: ann),
      ),
    );
  }
}

// ── Горизонтальні chips категорій ─────────────────────────────────────────────

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({required this.selected});

  final AnnouncementCategory? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        children: [
          // "Усі"
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _Chip(
              label: 'Усі',
              icon: Icons.apps,
              color: colorScheme.primary,
              selected: selected == null,
              onTap: () =>
                  ref.read(selectedCategoryProvider.notifier).select(null),
            ),
          ),
          ...AnnouncementCategory.values.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _Chip(
                label: cat.label,
                icon: cat.icon,
                color: cat.color,
                selected: selected == cat,
                onTap: () =>
                    ref.read(selectedCategoryProvider.notifier).select(cat),
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
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : colorScheme.surfaceContainerLow,
          border: Border.all(
            color: selected ? color : colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? color : colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? color : colorScheme.onSurface,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
