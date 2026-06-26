import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/notifications_repository.dart';
import '../../../user/presentation/providers/user_provider.dart';

/// Провайдер репозиторію сповіщень
final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(
    userRepository: ref.watch(userRepositoryProvider),
  ),
);

/// Нотифікатор FCM — ініціалізація та керування дозволами
class NotificationsNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Ініціалізувати FCM після успішного входу
  Future<void> init(String uid) async {
    final repo = ref.read(notificationsRepositoryProvider);
    final granted = await repo.requestPermission();
    if (granted) {
      await repo.initAndSaveToken(uid);
    }
  }
}

final notificationsProvider = NotifierProvider<NotificationsNotifier, void>(
  NotificationsNotifier.new,
);
