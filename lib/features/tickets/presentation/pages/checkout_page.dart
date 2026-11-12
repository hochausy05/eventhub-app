import 'package:eventhub_app/core/theme/app_colors.dart';
import 'package:eventhub_app/core/theme/app_spacing.dart';
import 'package:eventhub_app/core/widgets/app_button.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/domain/entities/ticket_type.dart';
import 'package:eventhub_app/features/discovery/presentation/utils/discovery_filters.dart';
import 'package:eventhub_app/features/discovery/presentation/widgets/event_banner.dart';
import 'package:eventhub_app/features/tickets/presentation/providers/booking_providers.dart';
import 'package:eventhub_app/features/tickets/presentation/pages/booking_confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CheckoutArgs {
  const CheckoutArgs({required this.event, required this.ticketType});
  final Event event;
  final TicketType ticketType;
}

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({required this.args, super.key});
  final CheckoutArgs args;
  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  int quantity = 1;
  bool submitting = false;
  String? error;

  Future<void> _confirm() async {
    if (submitting) return;
    setState(() {
      submitting = true;
      error = null;
    });
    try {
      final booking = await ref
          .read(bookingServiceProvider)
          .book(
            event: widget.args.event,
            ticketType: widget.args.ticketType,
            quantity: quantity,
          );
      ref.invalidate(myTicketsProvider);
      ref.invalidate(bookingsProvider);
      if (mounted) {
        context.go(
          '/booking-confirmation/${booking.id}',
          extra: ConfirmationArgs(booking: booking, event: widget.args.event),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.args.event;
    final type = widget.args.ticketType;
    final remaining = ref
        .watch(myTicketsProvider)
        .when(
          data: (tickets) =>
              (type.availableQuantity -
                      tickets.where((t) => t.ticketTypeId == type.id).length)
                  .clamp(0, type.capacity)
                  .toInt(),
          loading: () => 0,
          error: (_, _) => 0,
        );
    final maxQuantity = remaining.clamp(0, 4).toInt();
    if (quantity > maxQuantity && maxQuantity > 0) quantity = maxQuantity;
    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đặt vé')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.x5),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 160,
                child: EventBanner(
                  assetPath: event.bannerAssetPath,
                  fallbackIcon: Icons.event_outlined,
                  semanticLabel: event.title,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            Text(
              'Đặt vé mô phỏng',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
            Text(
              '${formatEventDateTime(event.startsAt)}\n${event.venueName}, ${event.city}',
            ),
            const Divider(height: 32),
            _line(context, 'Loại vé', type.name),
            _line(context, 'Đơn giá', formatVnd(type.priceVnd)),
            _line(context, 'Còn lại', '$remaining vé'),
            const SizedBox(height: AppSpacing.x3),
            Row(
              children: [
                const Expanded(child: Text('Số lượng')),
                IconButton(
                  tooltip: 'Giảm số lượng',
                  onPressed: quantity > 1
                      ? () => setState(() => quantity--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$quantity',
                  key: const ValueKey('checkout-quantity'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  tooltip: 'Tăng số lượng',
                  onPressed: quantity < maxQuantity
                      ? () => setState(() => quantity++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            Card(
              color: AppColors.softIndigo,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x4),
                child: _line(
                  context,
                  'Tổng cộng',
                  formatVnd(type.priceVnd * quantity),
                  bold: true,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.x3),
            const Text(
              'Không phát sinh thanh toán thực tế. Đây là đặt vé mô phỏng trên thiết bị này.',
            ),
            if (error != null) ...[
              const SizedBox(height: AppSpacing.x2),
              Text(error!, style: const TextStyle(color: AppColors.error)),
            ],
            if (remaining == 0) ...[
              const SizedBox(height: AppSpacing.x2),
              const Text(
                'Loại vé hiện đã hết.',
                style: TextStyle(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.x4),
            AppButton(
              key: const ValueKey('confirm-booking'),
              label: submitting ? 'Đang lưu...' : 'Xác nhận đặt vé',
              onPressed: submitting || remaining == 0 ? null : _confirm,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _line(
  BuildContext context,
  String label,
  String value, {
  bool bold = false,
}) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(label),
    Text(
      value,
      style: bold
          ? Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: AppColors.primary)
          : null,
    ),
  ],
);
