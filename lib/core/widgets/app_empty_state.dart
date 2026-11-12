import 'package:eventhub_app/core/theme/app_colors.dart';
import 'package:eventhub_app/core/theme/app_spacing.dart';
import 'package:eventhub_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final showAction = actionLabel != null && onAction != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.softIndigo,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 38, color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.x5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.x2),
        Text(
          description,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
        ),
        if (showAction) ...[
          const SizedBox(height: AppSpacing.x5),
          AppButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    );
  }
}
