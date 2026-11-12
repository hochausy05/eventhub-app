import 'package:eventhub_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppCategoryChip extends StatelessWidget {
  const AppCategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: icon == null
          ? null
          : Icon(
              icon,
              size: 18,
              color: selected ? AppColors.deepIndigo : AppColors.secondaryText,
            ),
      showCheckmark: false,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: selected ? AppColors.deepIndigo : AppColors.secondaryText,
      ),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
    );
  }
}
