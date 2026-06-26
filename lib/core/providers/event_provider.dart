import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_category.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Синглтон сервісу івентів
final eventServiceProvider = Provider<EventService>(
  (_) => EventService(),
);

/// Нотифікатор вибраної категорії івентів (null = усі)
class SelectedEventCategoryNotifier extends Notifier<EventCategory?> {
  @override
  EventCategory? build() => null;

  void select(EventCategory? cat) => state = cat;
}

final selectedEventCategoryProvider =
    NotifierProvider<SelectedEventCategoryNotifier, EventCategory?>(
  SelectedEventCategoryNotifier.new,
);

/// Stream івентів з урахуванням вибраної категорії
final eventsProvider = StreamProvider<List<EventModel>>((ref) {
  final category = ref.watch(selectedEventCategoryProvider);
  return ref.watch(eventServiceProvider).watchEvents(category: category);
});

/// Мої івенти (створені мною)
final myEventsProvider = StreamProvider<List<EventModel>>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is! AuthStateAuthenticated) return Stream.value([]);
  return ref
      .watch(eventServiceProvider)
      .watchMyEvents(authState.user.uid);
});
