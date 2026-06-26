import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/poll_model.dart';
import '../services/poll_service.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final pollServiceProvider = Provider<PollService>((_) => PollService());

/// Нотифікатор активного фільтру опитувань
class PollFilterNotifier extends Notifier<PollFilter> {
  @override
  PollFilter build() => PollFilter.active;

  void setFilter(PollFilter filter) => state = filter;
}

final pollFilterProvider =
    NotifierProvider<PollFilterNotifier, PollFilter>(PollFilterNotifier.new);

/// Stream опитувань з урахуванням фільтру
final pollsProvider = StreamProvider<List<PollModel>>((ref) {
  final filter = ref.watch(pollFilterProvider);
  final authState = ref.watch(authProvider);
  final uid = authState is AuthStateAuthenticated ? authState.user.uid : null;

  return ref.watch(pollServiceProvider).watchPolls(filter: filter, uid: uid);
});

/// Голос поточного юзера по конкретному опитуванню
final votedOptionProvider =
    StreamProvider.family<String?, String>((ref, pollId) {
  final authState = ref.watch(authProvider);
  if (authState is! AuthStateAuthenticated) return Stream.value(null);

  return ref
      .watch(pollServiceProvider)
      .watchVotedOptionId(pollId, authState.user.uid);
});
