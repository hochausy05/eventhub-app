import 'package:eventhub_app/core/theme/app_colors.dart';
import 'package:eventhub_app/core/theme/app_spacing.dart';
import 'package:eventhub_app/core/widgets/app_empty_state.dart';
import 'package:eventhub_app/features/discovery/presentation/providers/event_providers.dart';
import 'package:eventhub_app/features/discovery/presentation/utils/discovery_filters.dart';
import 'package:eventhub_app/features/discovery/presentation/widgets/event_banner.dart';
import 'package:eventhub_app/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub_app/features/tickets/presentation/providers/booking_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyTicketsPage extends ConsumerWidget {
  const MyTicketsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(
    child: ref
        .watch(myTicketsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: AppEmptyState(
              icon: Icons.error_outline,
              title: 'Chưa tải được vé',
              description: 'Không đọc được dữ liệu vé trên thiết bị.',
              actionLabel: 'Thử lại',
              onAction: () => ref.invalidate(myTicketsProvider),
            ),
          ),
          data: (tickets) => tickets.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.x5),
                    child: AppEmptyState(
                      icon: Icons.confirmation_num_outlined,
                      title: 'Bạn chưa có vé',
                      description:
                          'Vé mô phỏng bạn xác nhận sẽ xuất hiện tại đây.',
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.x4),
                  children: [
                    Text(
                      'Vé của tôi',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    const Text('Vé mô phỏng đã lưu trên thiết bị này.'),
                    const SizedBox(height: AppSpacing.x3),
                    ...tickets.map((ticket) => _TicketListCard(ticket: ticket)),
                  ],
                ),
        ),
  );
}

class _TicketListCard extends ConsumerWidget {
  const _TicketListCard({required this.ticket});
  final Ticket ticket;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(publishedEventsProvider).value ?? const [];
    final event = events.where((e) => e.id == ticket.eventId).firstOrNull;
    final type = event?.ticketTypes
        .where((t) => t.id == ticket.ticketTypeId)
        .firstOrNull;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/tickets/${ticket.id}'),
        child: Row(
          children: [
            SizedBox(
              width: 108,
              height: 116,
              child: EventBanner(
                assetPath: event?.bannerAssetPath,
                fallbackIcon: Icons.event_outlined,
                semanticLabel: event?.title ?? 'Vé sự kiện',
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event?.title ?? 'Sự kiện không còn trong danh sách',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (event != null)
                      Text(
                        formatEventDateTime(event.startsAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    Text(type?.name ?? 'Loại vé không xác định'),
                    const Text(
                      'Hợp lệ · Vé demo',
                      style: TextStyle(color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(AppSpacing.x2),
              child: Icon(Icons.qr_code_2),
            ),
          ],
        ),
      ),
    );
  }
}
