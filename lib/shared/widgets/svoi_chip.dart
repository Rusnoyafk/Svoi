import 'package:flutter/material.dart';
import '../../core/app_spacing.dart';

/// Chip з іконкою і кольором категорії.
class SvoiChip extends StatelessWidget {
  const SvoiChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = selected
        ? color.withValues(alpha: 0.15)
        : colorScheme.surfaceContainerLow;
    final borderColor = selected ? color : colorScheme.outlineVariant;
    final labelColor = selected ? color : colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSpacing.iconMd, color: selected ? color : colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: labelColor,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
