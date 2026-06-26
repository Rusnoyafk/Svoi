import 'package:firebase_auth/firebase_auth.dart';

/// Стани авторизації користувача
sealed class AuthState {
  const AuthState();
}

/// Перевіряємо збережену сесію при старті
class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

/// Користувач не авторизований
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// Користувач авторизований
class AuthStateAuthenticated extends AuthState {
  final User user;
  const AuthStateAuthenticated(this.user);
}

/// Помилка авторизації
class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}
