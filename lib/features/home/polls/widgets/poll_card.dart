import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_spacing.dart';
import '../../../../core/models/poll_model.dart';
import '../../../../core/providers/poll_provider.dart';
import '../../../../features/auth/domain/auth_state.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/svoi_card.dart';

class PollCard extends ConsumerWidget {
  const PollCard({
    super.key,
    required this.poll,
    this.onTap,
  });

  final PollModel poll;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final votedOption = ref.watch(votedOptionProvider(poll.id)).value;
    final authState = ref.watch(authProvider);
    final uid = authState is AuthStateAuthenticated ? authState.user.uid : null;
    final hasVoted = votedOption != null;
    final showResults = hasVoted || poll.isEnded;

    return SvoiCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Питання ────────────────────────────────────────────────────────
          Text(poll.question,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),

          // ── Варіанти або результати ────────────────────────────────────────
          if (showResults)
            _ResultsView(poll: poll, votedOptionId: votedOption)
          else
            _VoteView(poll: poll, uid: uid),

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),

          // ── Мета-рядок ────────────────────────────────────────────────────
          Row(
            children: [
              _GeoChip(poll: poll),
              const SizedBox(width: AppSpacing.sm),
              _TimeChip(poll: poll),
              const Spacer(),
              CircleAvatar(
                radius: 10,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: poll.authorPhotoUrl != null
                    ? NetworkImage(poll.authorPhotoUrl!)
                    : null,
                child: poll.authorPhotoUrl == null
                    ? Text(
                        poll.authorName.isNotEmpty
                            ? poll.authorName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            fontSize: 9,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                      )
                    : null,
              ),
              const SizedBox(width: 4),
              Text(
                poll.authorName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Блок голосування ──────────────────────────────────────────────────────────

class _VoteView extends ConsumerStatefulWidget {
  const _VoteView({required this.poll, required this.uid});

  final PollModel poll;
  final String? uid;

  @override
  ConsumerState<_VoteView> createState() => _VoteViewState();
}

class _VoteViewState extends ConsumerState<_VoteView> {
  String? _voting;

  Future<void> _vote(String optionId) async {
    if (widget.uid == null) return;
    setState(() => _voting = optionId);
    try {
      await ref.read(pollServiceProvider).vote(
            pollId: widget.poll.id,
            optionId: optionId,
            userId: widget.uid!,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _voting = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: widget.poll.options.map((opt) {
        final isVoting = _voting == opt.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: InkWell(
            onTap: widget.uid == null || _voting != null
                ? null
                : () => _vote(opt.id),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(opt.text,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  if (isVoting)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: colorScheme.primary),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Блок результатів з анімацією ──────────────────────────────────────────────

class _ResultsView extends StatefulWidget {
  const _ResultsView({required this.poll, required this.votedOptionId});

  final PollModel poll;
  final String? votedOptionId;

  @override
  State<_ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<_ResultsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.poll.totalVotes;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Column(
          children: widget.poll.options.map((opt) {
            final pct = total > 0 ? opt.votes / total : 0.0;
            final isChosen = opt.id == widget.votedOptionId;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isChosen) ...[
                        Icon(Icons.check_circle,
                            size: 14, color: colorScheme.primary),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          opt.text,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: isChosen
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isChosen
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${(pct * 100 * _animation.value).round()}%',
                        style: textTheme.labelMedium?.copyWith(
                          color: isChosen
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: isChosen
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct * _animation.value,
                      minHeight: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: isChosen
                          ? colorScheme.primary
                          : colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${opt.votes} голос${_voteSuffix(opt.votes)}',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _voteSuffix(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod100 >= 11 && mod100 <= 14) return 'ів';
    if (mod10 == 1) return '';
    if (mod10 >= 2 && mod10 <= 4) return 'и';
    return 'ів';
  }
}

// ── Гео-чіп ──────────────────────────────────────────────────────────────────

class _GeoChip extends StatelessWidget {
  const _GeoChip({required this.poll});

  final PollModel poll;

  String get _label {
    return switch (poll.geoScope) {
      GeoScope.city => poll.city ?? poll.geoScope.label,
      GeoScope.country => poll.country,
      GeoScope.all => 'Усі',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        _label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
      ),
    );
  }
}

// ── Часовий чіп ──────────────────────────────────────────────────────────────

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.poll});

  final PollModel poll;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    String label;
    Color color;
    if (poll.isEnded) {
      label = 'Завершено';
      color = colorScheme.onSurfaceVariant;
    } else {
      final diff = poll.endsAt.difference(now);
      final days = diff.inDays;
      final hours = diff.inHours;
      if (days >= 1) {
        label = 'Залишилось $days ${_daySuffix(days)}';
      } else if (hours >= 1) {
        label = 'Залишилось $hours год.';
      } else {
        label = 'Закінчується скоро';
      }
      color = days < 1 ? colorScheme.error : colorScheme.onSurfaceVariant;
    }

    return Text(label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color));
  }

  String _daySuffix(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod100 >= 11 && mod100 <= 14) return 'днів';
    if (mod10 == 1) return 'день';
    if (mod10 >= 2 && mod10 <= 4) return 'дні';
    return 'днів';
  }
}
