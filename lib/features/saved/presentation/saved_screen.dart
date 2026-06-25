import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Збережене')),
      body: const Center(
        child: Text('Збережене — скоро тут'),
      ),
    );
  }
}
