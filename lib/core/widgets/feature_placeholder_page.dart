import 'package:eventhub_app/core/theme/app_spacing.dart';
import 'package:eventhub_app/core/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({
    required this.title,
    required this.message,
    required this.icon,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AppEmptyState(
                icon: icon,
                title: title,
                description: message,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
