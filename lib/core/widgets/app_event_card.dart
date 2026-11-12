import 'package:eventhub_app/core/theme/app_colors.dart';
import 'package:eventhub_app/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AppEventCard extends StatelessWidget {
  const AppEventCard({
    required this.title,
    required this.dateTimeLabel,
    required this.locationLabel,
    required this.priceLabel,
    this.image,
    this.categoryLabel,
    this.onTap,
    super.key,
  });

  final String title;
  final String dateTimeLabel;
  final String locationLabel;
  final String priceLabel;
  final ImageProvider<Object>? image;
  final String? categoryLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderRadius = BorderRadius.circular(AppRadii.featuredCard);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EventArtwork(image: image),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categoryLabel case final category?) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x2,
                          vertical: AppSpacing.x1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softIndigo,
                          borderRadius: BorderRadius.circular(AppRadii.button),
                        ),
                        child: Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.deepIndigo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x2),
                    ],
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    _EventMeta(
                      icon: Icons.calendar_today_outlined,
                      label: dateTimeLabel,
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    _EventMeta(
                      icon: Icons.location_on_outlined,
                      label: locationLabel,
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    Text(
                      priceLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventArtwork extends StatelessWidget {
  const _EventArtwork({required this.image});

  final ImageProvider<Object>? image;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 92,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.softIndigo,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.event_outlined,
        size: 30,
        color: AppColors.primary,
      ),
    );

    if (image == null) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Image(
        image: image!,
        width: 92,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}

class _EventMeta extends StatelessWidget {
  const _EventMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.secondaryText),
        const SizedBox(width: AppSpacing.x1),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
