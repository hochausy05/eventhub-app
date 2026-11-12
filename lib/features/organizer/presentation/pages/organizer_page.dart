import 'package:eventhub_app/core/theme/app_colors.dart';
import 'package:eventhub_app/core/theme/app_spacing.dart';
import 'package:eventhub_app/core/widgets/app_empty_state.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/presentation/utils/discovery_filters.dart';
import 'package:eventhub_app/features/discovery/presentation/widgets/event_banner.dart';
import 'package:eventhub_app/features/organizer/domain/services/event_management_service.dart';
import 'package:eventhub_app/features/organizer/presentation/providers/organizer_providers.dart';
import 'package:eventhub_app/features/tickets/domain/entities/booking.dart';
import 'package:eventhub_app/features/tickets/presentation/providers/booking_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrganizerPage extends ConsumerWidget {
  const OrganizerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(organizerEventsProvider);
    final bookingsAsync = ref.watch(bookingsProvider);
    return SafeArea(
      child: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            _LoadError(onRetry: () => ref.invalidate(organizerEventsProvider)),
        data: (events) => bookingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              _LoadError(onRetry: () => ref.invalidate(bookingsProvider)),
          data: (bookings) =>
              _DashboardContent(events: events, bookings: bookings),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.events, required this.bookings});
  final List<Event> events;
  final List<Booking> bookings;

  @override
  Widget build(BuildContext context) {
    final ids = events.map((event) => event.id).toSet();
    final ownBookings = bookings
        .where(
          (booking) =>
              ids.contains(booking.eventId) &&
              booking.status == BookingStatus.confirmed,
        )
        .toList();
    final confirmedTickets = ownBookings.fold<int>(
      0,
      (sum, booking) => sum + booking.quantity,
    );
    final simulatedRevenue = ownBookings.fold<int>(
      0,
      (sum, booking) => sum + booking.totalVnd,
    );
    final publishedCount = events
        .where((event) => event.status == EventStatus.published)
        .length;
    final draftCount = events
        .where((event) => event.status == EventStatus.draft)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x4,
        AppSpacing.x3,
        AppSpacing.x4,
        AppSpacing.x8,
      ),
      children: [
        Text(
          'Quản lý sự kiện',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.x1),
        Text(demoOrganizerName, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.x2),
        const _DemoModeLabel(),
        const SizedBox(height: AppSpacing.x5),
        Text('Tổng quan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.x2),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 640 ? 4 : 2;
            final width =
                (constraints.maxWidth - AppSpacing.x2 * (columns - 1)) /
                columns;
            return Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x2,
              children: [
                SizedBox(
                  width: width,
                  child: _MetricCard(
                    key: const ValueKey('metric-events'),
                    title: 'Sự kiện',
                    value: '${events.length}',
                    icon: Icons.event_note_outlined,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _MetricCard(
                    key: const ValueKey('metric-published'),
                    title: 'Đã xuất bản',
                    value: '$publishedCount',
                    icon: Icons.public_outlined,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _MetricCard(
                    key: const ValueKey('metric-drafts'),
                    title: 'Bản nháp',
                    value: '$draftCount',
                    icon: Icons.edit_note_outlined,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _MetricCard(
                    key: const ValueKey('metric-tickets'),
                    title: 'Vé đã đặt',
                    value: '$confirmedTickets',
                    icon: Icons.confirmation_num_outlined,
                  ),
                ),
                SizedBox(
                  width: width * columns + AppSpacing.x2 * (columns - 1),
                  child: _MetricCard(
                    key: const ValueKey('metric-revenue'),
                    title: 'Doanh thu mô phỏng',
                    value: formatVnd(simulatedRevenue),
                    icon: Icons.payments_outlined,
                    emphasized: true,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.x1),
        const Text(
          'Chỉ là tổng giá trị booking demo; không phải khoản tiền đã thu.',
        ),
        const SizedBox(height: AppSpacing.x6),
        Row(
          children: [
            Expanded(
              child: Text(
                'Sự kiện của tôi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.icon(
              onPressed: () => context.push('/organizer/events/new'),
              icon: const Icon(Icons.add),
              label: const Text('Tạo sự kiện'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x2),
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.x8),
            child: AppEmptyState(
              icon: Icons.event_available_outlined,
              title: 'Chưa có sự kiện của bạn',
              description:
                  'Sự kiện bạn tạo ở chế độ demo sẽ xuất hiện tại đây.',
            ),
          )
        else
          ...events.map((event) => _OrganizerEventCard(event: event)),
      ],
    );
  }
}

class _DemoModeLabel extends StatelessWidget {
  const _DemoModeLabel();
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.softIndigo,
      borderRadius: BorderRadius.circular(100),
    ),
    child: const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.swap_horiz, size: 18, color: AppColors.primary),
          SizedBox(width: AppSpacing.x1),
          Flexible(
            child: Text(
              'Chế độ mô phỏng · Không phải phân quyền thật',
              style: TextStyle(color: AppColors.deepIndigo),
            ),
          ),
        ],
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.emphasized = false,
  });
  final String title;
  final String value;
  final IconData icon;
  final bool emphasized;
  @override
  Widget build(BuildContext context) => Card(
    key: key,
    color: emphasized ? AppColors.softIndigo : null,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppSpacing.x2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: emphasized ? AppColors.primary : null,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    ),
  );
}

class _OrganizerEventCard extends StatelessWidget {
  const _OrganizerEventCard({required this.event});
  final Event event;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.x3),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.card),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: EventBanner(
                    assetPath: event.bannerAssetPath,
                    fallbackIcon: Icons.event_outlined,
                    semanticLabel: event.title,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    Text(
                      formatEventDateTime(event.startsAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${event.venueName}, ${event.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    _StatusPill(status: event.status),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.x5),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${event.ticketTypes.length} loại vé · ${event.ticketTypes.fold<int>(0, (sum, type) => sum + type.capacity)} chỗ',
                ),
              ),
              TextButton.icon(
                onPressed: () => context.push('/events/${event.id}'),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Xem'),
              ),
              TextButton.icon(
                onPressed: () =>
                    context.push('/organizer/events/${event.id}/edit'),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Sửa'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final EventStatus status;
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      EventStatus.draft => ('Bản nháp', AppColors.warning),
      EventStatus.published => ('Đã xuất bản', AppColors.success),
      EventStatus.cancelled => ('Đã hủy', AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: AppSpacing.x1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.x5),
      child: AppEmptyState(
        icon: Icons.error_outline,
        title: 'Chưa tải được bảng điều khiển',
        description:
            'Không đọc được dữ liệu sự kiện hoặc booking trên thiết bị.',
        actionLabel: 'Thử lại',
        onAction: onRetry,
      ),
    ),
  );
}
