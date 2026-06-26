import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_state.dart';
import '../../../user/presentation/providers/user_provider.dart';

/// Провайдер репозиторію авторизації
final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository(),
);

/// Слухає authStateChanges Firebase — дає поточний User або null
final authStateChangesProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);

/// Нотифікатор авторизації — керує станами входу/виходу
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Слухаємо зміни сесії та автоматично оновлюємо стан
    ref.listen(authStateChangesProvider, (_, next) {
      next.when(
        data: (user) {
          if (user != null) {
            state = AuthStateAuthenticated(user);
          } else {
            state = const AuthStateUnauthenticated();
          }
        },
        loading: () => state = const AuthStateInitial(),
        error: (e, _) => state = AuthStateError(e.toString()),
      );
    });

    return const AuthStateInitial();
  }

  /// Вхід через Google + автоматичне створення профілю у Firestore
  Future<void> signInWithGoogle() async {
    state = const AuthStateInitial();
    try {
      final credential =
          await ref.read(authRepositoryProvider).signInWithGoogle();
      final user = credential.user;
      if (user == null) return;

      // Створюємо або оновлюємо профіль у Firestore
      await ref
          .read(userRepositoryProvider)
          .createOrUpdateOnSignIn(user, credential.additionalUserInfo?.isNewUser ?? false);

      state = AuthStateAuthenticated(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'sign-in-cancelled') {
        state = const AuthStateUnauthenticated();
      } else {
        state = AuthStateError(e.message ?? 'Помилка авторизації');
      }
    } catch (e) {
      state = AuthStateError(e.toString());
    }
  }

  /// Вихід із застосунку
  Future<void> signOut() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AuthStateUnauthenticated();
    } catch (e) {
      state = AuthStateError(e.toString());
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
