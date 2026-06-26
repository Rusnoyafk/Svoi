import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../features/user/data/user_repository.dart';

/// Репозиторій для роботи з Firebase Cloud Messaging
class NotificationsRepository {
  final FirebaseMessaging _messaging;
  final UserRepository _userRepository;

  NotificationsRepository({
    FirebaseMessaging? messaging,
    required this._userRepository,
  }) : _messaging = messaging ?? FirebaseMessaging.instance;

  /// Запитати дозвіл на сповіщення (обов'язково для iOS)
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Отримати поточний FCM токен і зберегти у профіль
  Future<void> initAndSaveToken(String uid) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _userRepository.saveFcmToken(uid, token);
    }

    // Оновлюємо токен при кожному його оновленні
    _messaging.onTokenRefresh.listen((newToken) {
      _userRepository.saveFcmToken(uid, newToken);
    });
  }
}
