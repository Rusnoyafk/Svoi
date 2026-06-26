import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_spacing.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/user/domain/user_profile.dart';
import '../../../features/user/presentation/providers/user_provider.dart';
import '../../../shared/widgets/svoi_card.dart';
import '../../../shared/widgets/svoi_loading.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const SvoiLoading(),
        error: (e, _) => Center(child: Text('Помилка: $e')),
        data: (profile) => profile == null
            ? const Center(child: Text('Профіль не знайдено'))
            : _ProfileBody(profile: profile),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentMode = ref.watch(themeModeProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // ── Аватар та ім'я ────────────────────────────────────────────────
        Center(
          child: Column(
            children: [
              _Avatar(profile: profile),
              const SizedBox(height: AppSpacing.md),
              Text(
                profile.displayName.isNotEmpty ? profile.displayName : 'Без імені',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                profile.email,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Про мене ──────────────────────────────────────────────────────
        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
          _SectionCard(
            title: 'Про мене',
            icon: Icons.person_outline,
            child: Text(profile.bio!, style: textTheme.bodyMedium),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ── Де я зараз ────────────────────────────────────────────────────
        if (profile.country != null || profile.city != null) ...[
          _SectionCard(
            title: 'Де я зараз',
            icon: Icons.location_on_outlined,
            child: Text(
              [
                if (profile.city != null) profile.city!,
                if (profile.country != null) profile.country!,
              ].join(', '),
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ── Звідки я ──────────────────────────────────────────────────────
        if (profile.originOblast != null ||
            profile.originRaion != null ||
            profile.originCity != null) ...[
          _SectionCard(
            title: 'Звідки я',
            icon: Icons.home_outlined,
            child: Text(
              [
                if (profile.originOblast != null) '${profile.originOblast!} обл.',
                if (profile.originRaion != null) '${profile.originRaion!} р-н',
                if (profile.originCity != null) profile.originCity!,
              ].join(', '),
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ── Підказка якщо профіль порожній ────────────────────────────────
        if ((profile.bio == null || profile.bio!.isEmpty) &&
            profile.country == null &&
            profile.city == null &&
            profile.originOblast == null &&
            profile.originRaion == null) ...[
          SvoiCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: colorScheme.primary, size: AppSpacing.iconLg),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Розкажіть про себе — заповніть профіль',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ── Тема ──────────────────────────────────────────────────────────
        _SectionCard(
          title: 'Тема',
          icon: Icons.brightness_6_outlined,
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined),
                label: Text('Світла'),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_outlined),
                label: Text('Системна'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('Темна'),
              ),
            ],
            selected: {currentMode},
            onSelectionChanged: (modes) =>
                ref.read(themeModeProvider.notifier).setThemeMode(modes.first),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Вийти ─────────────────────────────────────────────────────────
        OutlinedButton.icon(
          onPressed: () => _confirmSignOut(context, ref),
          icon: const Icon(Icons.logout),
          label: const Text('Вийти'),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Вийти?'),
        content: const Text('Ви впевнені, що хочете вийти з акаунту?'),
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
            child: const Text('Вийти'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }
}

// ── Аватар ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: 40,
      backgroundColor: colorScheme.primaryContainer,
      backgroundImage:
          profile.photoUrl != null ? NetworkImage(profile.photoUrl!) : null,
      child: profile.photoUrl == null
          ? Text(
              _initials(profile.displayName),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ── Секція-картка ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SvoiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSpacing.iconMd, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
