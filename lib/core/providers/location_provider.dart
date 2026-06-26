import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';

/// Синглтон сервісу локацій
final locationServiceProvider = Provider<LocationService>(
  (_) => LocationService(),
);

/// Завантажує всі дані локацій один раз
final locationDataProvider = FutureProvider<LocationData>((ref) {
  return ref.read(locationServiceProvider).loadLocations();
});

/// Список областей
final oblastsProvider = FutureProvider<List<String>>((ref) {
  return ref.read(locationServiceProvider).getOblasts();
});

/// Список районів для вибраної області
final raionsProvider = FutureProvider.family<List<String>, String>((ref, oblast) {
  return ref.read(locationServiceProvider).getRaions(oblast);
});

/// Список міст для вибраної області і району
final citiesProvider = FutureProvider.family<List<String>, (String, String)>(
  (ref, params) {
    final (oblast, raion) = params;
    return ref.read(locationServiceProvider).getCities(oblast, raion);
  },
);
