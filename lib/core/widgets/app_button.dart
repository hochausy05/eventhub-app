import 'package:eventhub_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leadingIcon,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? leadingIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final foreground = variant == AppButtonVariant.primary
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.primary;
    final content = _ButtonContent(
      label: label,
      foreground: foreground,
      leadingIcon: leadingIcon,
      isLoading: isLoading,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: variant == AppButtonVariant.primary
          ? FilledButton(onPressed: enabled ? onPressed : null, child: content)
          : OutlinedButton(
              onPressed: enabled ? onPressed : null,
              child: content,
            ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.foreground,
    required this.leadingIcon,
    required this.isLoading,
  });

  final String label;
  final Color foreground;
  final IconData? leadingIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final leading = isLoading
        ? SizedBox.square(
            dimension: AppSpacing.x4,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : leadingIcon == null
        ? null
        : Icon(leadingIcon, size: 18);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading, const SizedBox(width: AppSpacing.x2)],
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
