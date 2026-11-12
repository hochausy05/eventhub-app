import 'package:eventhub_app/core/theme/app_colors.dart';
import 'package:eventhub_app/core/theme/app_spacing.dart';
import 'package:eventhub_app/core/widgets/app_button.dart';
import 'package:eventhub_app/core/widgets/app_empty_state.dart';
import 'package:eventhub_app/core/widgets/app_section_header.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/domain/entities/ticket_type.dart';
import 'package:eventhub_app/features/discovery/presentation/providers/event_providers.dart';
import 'package:eventhub_app/features/discovery/presentation/utils/discovery_filters.dart';
import 'package:eventhub_app/features/discovery/presentation/widgets/event_banner.dart';
import 'package:eventhub_app/features/tickets/presentation/providers/booking_providers.dart';
import 'package:eventhub_app/features/tickets/presentation/pages/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventDetailsPage extends ConsumerWidget {
  const EventDetailsPage({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));

    return eventAsync.when(
      loading: () => const _DetailsLoadingPage(),
      error: (error, stackTrace) => _DetailsErrorPage(
        onRetry: () => ref.invalidate(eventByIdProvider(eventId)),
      ),
      data: (event) => event == null
          ? const _EventNotFoundPage()
          : _EventDetailsContent(event: event),
    );
  }
}

class _EventDetailsContent extends ConsumerStatefulWidget {
  const _EventDetailsContent({required this.event});

  final Event event;

  @override
  ConsumerState<_EventDetailsContent> createState() =>
      _EventDetailsContentState();
}

class _EventDetailsContentState extends ConsumerState<_EventDetailsContent> {
  final _ticketSectionKey = GlobalKey();

  Future<void> _scrollToTickets() async {
    final targetContext = _ticketSectionKey.currentContext;
    if (targetContext == null) return;
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final textTheme = Theme.of(context).textTheme;
    final savedTickets = ref.watch(myTicketsProvider).value ?? const [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 248,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.x2),
              child: Center(
                child: Material(
                  color: AppColors.surface.withValues(alpha: 0.95),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Quay lại',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: EventBanner(
                assetPath: event.bannerAssetPath,
                fallbackIcon: _categoryIcon(event.category),
                semanticLabel: 'Ảnh sự kiện: ${event.title}',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x5,
                AppSpacing.x5,
                AppSpacing.x5,
                AppSpacing.x8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.x2,
                    runSpacing: AppSpacing.x2,
                    children: [
                      _LabelPill(
                        label: event.category.label,
                        foreground: AppColors.deepIndigo,
                        background: AppColors.softIndigo,
                      ),
                      const _LabelPill(
                        label: 'Sự kiện minh họa',
                        foreground: AppColors.secondaryText,
                        background: AppColors.surface,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  Text(event.title, style: textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.x2),
                  Text(
                    event.summary,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  AppButton(
                    label: 'Xem các loại vé',
                    leadingIcon: Icons.confirmation_num_outlined,
                    onPressed: _scrollToTickets,
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  const AppSectionHeader(title: 'Thời gian'),
                  const SizedBox(height: AppSpacing.x2),
                  _DetailInfoRow(
                    icon: Icons.calendar_today_outlined,
                    title: formatEventDateTime(event.startsAt),
                    subtitle: 'Kết thúc: ${formatEventDateTime(event.endsAt)}',
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  const AppSectionHeader(title: 'Địa điểm'),
                  const SizedBox(height: AppSpacing.x2),
                  _DetailInfoRow(
                    icon: Icons.location_on_outlined,
                    title: event.venueName,
                    subtitle: '${event.address}, ${event.city}',
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  const AppSectionHeader(title: 'Về sự kiện'),
                  const SizedBox(height: AppSpacing.x2),
                  Text(event.description, style: textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.x6),
                  const AppSectionHeader(title: 'Ban tổ chức'),
                  const SizedBox(height: AppSpacing.x2),
                  _DetailInfoRow(
                    icon: Icons.groups_outlined,
                    title: event.organizerName ?? 'Ban tổ chức sự kiện',
                    subtitle: 'Thông tin ban tổ chức trong dữ liệu demo.',
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  Container(
                    key: _ticketSectionKey,
                    child: const AppSectionHeader(
                      title: 'Các loại vé',
                      subtitle: 'Giá và số lượng trong dữ liệu minh họa.',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  ...event.ticketTypes.map(
                    (ticket) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.x2),
                      child: _TicketTypeCard(
                        ticket: ticket,
                        remaining:
                            (ticket.availableQuantity -
                                    savedTickets
                                        .where(
                                          (t) => t.ticketTypeId == ticket.id,
                                        )
                                        .length)
                                .clamp(0, ticket.capacity)
                                .toInt(),
                        enabled:
                            event.status == EventStatus.published &&
                            event.startsAt.isAfter(DateTime.now()),
                        onSelect: () => context.push(
                          '/checkout',
                          extra: CheckoutArgs(event: event, ticketType: ticket),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  const Text(
                    'Đặt vé mô phỏng · Không phát sinh thanh toán thực tế.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelPill extends StatelessWidget {
  const _LabelPill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x2,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: foreground),
        ),
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.softIndigo,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 21, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.x1),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TicketTypeCard extends StatelessWidget {
  const _TicketTypeCard({
    required this.ticket,
    required this.remaining,
    required this.enabled,
    required this.onSelect,
  });

  final TicketType ticket;
  final int remaining;
  final bool enabled;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final availability = remaining == 0
        ? 'Đã hết vé (dữ liệu demo)'
        : 'Còn $remaining vé trên thiết bị này';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket.name, style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    availability,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.x2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatVnd(ticket.priceVnd),
                  textAlign: TextAlign.end,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.x2),
                FilledButton.tonal(
                  onPressed: enabled && remaining > 0 ? onSelect : null,
                  child: const Text('Chọn vé'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EventNotFoundPage extends StatelessWidget {
  const _EventNotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sự kiện')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x5),
          child: AppEmptyState(
            icon: Icons.event_busy_outlined,
            title: 'Không tìm thấy sự kiện',
            description:
                'Sự kiện này không có trong danh sách minh họa hiện tại.',
            actionLabel: 'Về khám phá',
            onAction: () => context.go('/discovery'),
          ),
        ),
      ),
    );
  }
}

class _DetailsLoadingPage extends StatelessWidget {
  const _DetailsLoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _DetailsErrorPage extends StatelessWidget {
  const _DetailsErrorPage({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sự kiện')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x5),
          child: AppEmptyState(
            icon: Icons.error_outline,
            title: 'Chưa tải được sự kiện',
            description: 'Đã có lỗi khi đọc thông tin sự kiện mẫu.',
            actionLabel: 'Thử lại',
            onAction: onRetry,
          ),
        ),
      ),
    );
  }
}

IconData _categoryIcon(EventCategory category) => switch (category) {
  EventCategory.technology => Icons.lightbulb_outline,
  EventCategory.music => Icons.music_note_outlined,
  EventCategory.workshop => Icons.handyman_outlined,
  EventCategory.community => Icons.groups_outlined,
  EventCategory.education => Icons.school_outlined,
  EventCategory.arts => Icons.palette_outlined,
  EventCategory.foodLifestyle => Icons.restaurant_outlined,
  EventCategory.entertainment => Icons.celebration_outlined,
};
