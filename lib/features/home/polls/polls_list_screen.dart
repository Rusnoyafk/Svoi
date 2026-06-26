import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_spacing.dart';
import '../../../core/providers/poll_provider.dart';
import '../../../core/services/poll_service.dart';
import '../../../shared/widgets/svoi_empty_state.dart';
import '../../../shared/widgets/svoi_loading.dart';
import 'create_poll_screen.dart';
import 'poll_detail_screen.dart';
import 'widgets/poll_card.dart';

class PollsListScreen extends ConsumerWidget {
  const PollsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(pollFilterProvider);
    final pollsAsync = ref.watch(pollsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(pollsProvider),
        child: CustomScrollView(
          slivers: [
            // ── Фільтр-чіпи ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: SegmentedButton<PollFilter>(
                  segments: const [
                    ButtonSegment(
                        value: PollFilter.active,
                        label: Text('Активні'),
                        icon: Icon(Icons.play_circle_outline, size: 16)),
                    ButtonSegment(
                        value: PollFilter.ended,
                        label: Text('Завершені'),
                        icon: Icon(Icons.check_circle_outline, size: 16)),
                    ButtonSegment(
                        value: PollFilter.my,
                        label: Text('Мої'),
                        icon: Icon(Icons.person_outline, size: 16)),
                  ],
                  selected: {currentFilter},
                  onSelectionChanged: (s) =>
                      ref.read(pollFilterProvider.notifier).setFilter(s.first),
                ),
              ),
            ),

            // ── Список ─────────────────────────────────────────────────────
            pollsAsync.when(
              loading: () =>
                  const SliverFillRemaining(child: SvoiLoading()),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Помилка: $e')),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return SliverFillRemaining(
                    child: SvoiEmptyState(
                      icon: Icons.poll_outlined,
                      title: _emptyTitle(currentFilter),
                      subtitle: _emptySubtitle(currentFilter),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: i == 0
                          ? const EdgeInsets.only(top: AppSpacing.sm)
                          : EdgeInsets.zero,
                      child: PollCard(
                        poll: list[i],
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) =>
                                PollDetailScreen(poll: list[i]),
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
          MaterialPageRoute(builder: (_) => const CreatePollScreen()),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _emptyTitle(PollFilter filter) => switch (filter) {
        PollFilter.active => 'Активних опитувань немає',
        PollFilter.ended => 'Завершених опитувань немає',
        PollFilter.my => 'Ви ще не створили опитувань',
      };

  String _emptySubtitle(PollFilter filter) => switch (filter) {
        PollFilter.active => 'Будьте першим — створіть опитування',
        PollFilter.ended => 'Тут з\'являться завершені опитування',
        PollFilter.my => 'Натисніть + щоб поставити питання спільноті',
      };
}
