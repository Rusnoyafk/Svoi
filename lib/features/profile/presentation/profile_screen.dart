import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Профіль — скоро тут'),
            const SizedBox(height: 40),

            // ── ТИМЧАСОВО: перемикач теми ─────────────────────────────────
            // TODO: перенести в повноцінний екран налаштувань
            Text(
              'Тема',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
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
              onSelectionChanged: (modes) {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(modes.first);
              },
            ),
            // ── кінець тимчасового блоку ──────────────────────────────────
          ],
        ),
      ),
    );
  }
}
