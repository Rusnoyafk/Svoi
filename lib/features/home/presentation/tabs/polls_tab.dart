import 'package:flutter/material.dart';
import '../../../../shared/widgets/svoi_empty_state.dart';

class PollsTab extends StatelessWidget {
  const PollsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SvoiEmptyState(
      icon: Icons.poll_outlined,
      title: 'Опитування — скоро тут',
      subtitle: 'Тут з\'являться опитування від спільноти у вашому місті',
    );
  }
}
