import 'package:eventhub_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class EventBanner extends StatelessWidget {
  const EventBanner({
    required this.assetPath,
    required this.fallbackIcon,
    this.semanticLabel,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String? assetPath;
  final IconData fallbackIcon;
  final String? semanticLabel;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (assetPath == null || assetPath!.isEmpty) return _fallback(context);

    return Image.asset(
      assetPath!,
      fit: fit,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) => _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) {
    return ColoredBox(
      color: AppColors.softIndigo,
      child: Center(
        child: Icon(
          fallbackIcon,
          size: 52,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
