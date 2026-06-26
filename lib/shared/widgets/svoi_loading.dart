import 'package:flutter/material.dart';

/// Індикатор завантаження з кольором primary.
class SvoiLoading extends StatelessWidget {
  const SvoiLoading({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
