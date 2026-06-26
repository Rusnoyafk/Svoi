import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_category.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Синглтон сервісу оголошень
final announcementServiceProvider = Provider<AnnouncementService>(
  (_) => AnnouncementService(),
);

/// Нотифікатор вибраної категорії фільтру (null = усі)
class SelectedCategoryNotifier extends Notifier<AnnouncementCategory?> {
  @override
  AnnouncementCategory? build() => null;

  void select(AnnouncementCategory? cat) => state = cat;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, AnnouncementCategory?>(
  SelectedCategoryNotifier.new,
);

/// Stream оголошень з урахуванням вибраної категорії
final announcementsProvider =
    StreamProvider<List<AnnouncementModel>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  return ref
      .watch(announcementServiceProvider)
      .watchAnnouncements(category: category);
});

/// Мої оголошення
final myAnnouncementsProvider =
    StreamProvider<List<AnnouncementModel>>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is! AuthStateAuthenticated) return Stream.value([]);
  return ref
      .watch(announcementServiceProvider)
      .watchMyAnnouncements(authState.user.uid);
});
