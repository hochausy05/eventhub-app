import 'package:eventhub_app/core/theme/app_colors.dart';
import 'package:eventhub_app/core/theme/app_spacing.dart';
import 'package:eventhub_app/core/widgets/app_empty_state.dart';
import 'package:eventhub_app/features/discovery/presentation/providers/event_providers.dart';
import 'package:eventhub_app/features/discovery/presentation/utils/discovery_filters.dart';
import 'package:eventhub_app/features/discovery/presentation/widgets/event_banner.dart';
import 'package:eventhub_app/features/tickets/presentation/providers/booking_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailsPage extends ConsumerWidget {
  const TicketDetailsPage({required this.ticketId, super.key});
  final String ticketId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(ticketByIdProvider(ticketId))
      .when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, _) => const _UnknownTicket(),
        data: (ticket) {
          if (ticket == null) return const _UnknownTicket();
          final eventAsync = ref.watch(eventByIdProvider(ticket.eventId));
          return eventAsync.when(
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const _UnknownTicket(),
            data: (event) {
              final type = event?.ticketTypes
                  .where((t) => t.id == ticket.ticketTypeId)
                  .firstOrNull;
              final booking = ref
                  .watch(bookingsProvider)
                  .value
                  ?.where((b) => b.id == ticket.bookingId)
                  .firstOrNull;
              return Scaffold(
                appBar: AppBar(title: const Text('Vé điện tử')),
                body: ListView(
                  padding: const EdgeInsets.all(AppSpacing.x4),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 180,
                        child: EventBanner(
                          assetPath: event?.bannerAssetPath,
                          fallbackIcon: Icons.event_outlined,
                          semanticLabel: event?.title ?? 'Sự kiện',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    Text(
                      event?.title ?? 'Sự kiện không còn trong danh sách',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (event != null) ...[
                      Text(formatEventDateTime(event.startsAt)),
                      Text('${event.venueName}, ${event.city}'),
                    ],
                    const SizedBox(height: AppSpacing.x3),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.x3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type?.name ?? 'Loại vé không xác định',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text('Mã vé: ${_shortId(ticket.id)}'),
                            Text('Mã đơn: ${_shortId(ticket.bookingId)}'),
                            if (booking != null)
                              Text(
                                'Đơn mô phỏng · ${formatVnd(booking.totalVnd)}',
                              ),
                            const Text(
                              'Trạng thái: Hợp lệ (demo)',
                              style: TextStyle(color: AppColors.success),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.x4),
                        child: Column(
                          children: [
                            const Text(
                              'MÃ QR VÉ MINH HỌA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.x3),
                            Container(
                              key: const ValueKey('qr-code'),
                              color: Colors.white,
                              padding: const EdgeInsets.all(AppSpacing.x3),
                              child: QrImageView(
                                data: ticket.qrPayload,
                                version: QrVersions.auto,
                                size: 232,
                                backgroundColor: Colors.white,
                                errorCorrectionLevel: QrErrorCorrectLevel.M,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.x2),
                            const Text(
                              'Mã QR chỉ dùng để trình diễn. Không có xác thực vào cổng.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
}

String _shortId(String value) =>
    value.substring(0, value.length < 12 ? value.length : 12);

class _UnknownTicket extends StatelessWidget {
  const _UnknownTicket();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Vé điện tử')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: AppEmptyState(
          icon: Icons.qr_code_2,
          title: 'Không tìm thấy vé',
          description: 'Vé này không nằm trong dữ liệu đã lưu trên thiết bị.',
          actionLabel: 'Về vé của tôi',
          onAction: () => context.go('/tickets'),
        ),
      ),
    ),
  );
}
