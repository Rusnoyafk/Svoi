import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../app_spacing.dart';

/// Кореневий віджет застосунку — вирішує який екран показати
/// залежно від стану авторизації
class AppRouter extends ConsumerWidget {
  const AppRouter({super.key, required this.mainShell});

  /// Головна оболонка з навігацією (передається ззовні)
  final Widget mainShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return switch (authState) {
      AuthStateInitial() => const _SplashScreen(),
      AuthStateUnauthenticated() => const AuthScreen(),
      AuthStateError() => const AuthScreen(),
      AuthStateAuthenticated() => mainShell,
    };
  }
}

/// Splash-екран поки перевіряємо сесію Firebase
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: Colors.white,
                size: AppSpacing.iconXl,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Свої',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
