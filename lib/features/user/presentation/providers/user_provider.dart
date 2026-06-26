import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/auth/domain/auth_state.dart';
import '../../data/user_repository.dart';
import '../../domain/user_profile.dart';

/// Провайдер репозиторію користувачів
final userRepositoryProvider = Provider<UserRepository>(
  (_) => UserRepository(),
);

/// Нотифікатор профілю поточного користувача
class UserProfileNotifier extends Notifier<AsyncValue<UserProfile?>> {
  @override
  AsyncValue<UserProfile?> build() => const AsyncValue.loading();

  /// Завантажити профіль за uid
  Future<void> loadProfile(String uid) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(userRepositoryProvider).getProfile(uid),
    );
  }

  /// Оновити поля профілю
  Future<void> updateProfile(String uid, Map<String, dynamic> fields) async {
    await ref.read(userRepositoryProvider).updateProfile(uid, fields);
    await loadProfile(uid);
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>(
  UserProfileNotifier.new,
);

/// Стрімінг профілю в реальному часі (для сторінки профілю)
final userProfileStreamProvider = StreamProvider.family<UserProfile?, String>(
  (ref, uid) => ref.watch(userRepositoryProvider).watchProfile(uid),
);

/// Профіль поточного авторизованого користувача (stream)
final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthStateAuthenticated) {
    return ref.watch(userRepositoryProvider).watchProfile(authState.user.uid);
  }
  return Stream.value(null);
});
