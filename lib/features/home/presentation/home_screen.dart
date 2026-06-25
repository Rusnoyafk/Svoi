import 'package:flutter/material.dart';
import 'tabs/announcements_tab.dart';
import 'tabs/events_tab.dart';
import 'tabs/polls_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Три верхні таби: Оголошення, Івенти, Опитування
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Свої'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Оголошення'),
              Tab(text: 'Івенти'),
              Tab(text: 'Опитування'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AnnouncementsTab(),
            EventsTab(),
            PollsTab(),
          ],
        ),
      ),
    );
  }
}
