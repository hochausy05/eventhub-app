import 'package:eventhub_app/core/theme/app_colors.dart';
import 'package:eventhub_app/core/theme/app_spacing.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/presentation/utils/discovery_filters.dart';
import 'package:eventhub_app/features/tickets/domain/entities/booking.dart';
import 'package:eventhub_app/features/tickets/presentation/providers/booking_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ConfirmationArgs {
  const ConfirmationArgs({required this.booking, required this.event});
  final Booking booking;
  final Event event;
}

class BookingConfirmationPage extends ConsumerWidget {
  const BookingConfirmationPage({required this.args, super.key});
  final ConfirmationArgs args;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Đặt vé thành công')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 76, color: AppColors.success),
            const SizedBox(height: AppSpacing.x4),
            Text(
              'Đã tạo vé mô phỏng',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(args.event.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.x3),
            Text(
              'Mã đơn: ${args.booking.id.substring(0, 12)}',
              key: const ValueKey('booking-reference'),
            ),
            Text(
              '${args.booking.quantity} vé · ${formatVnd(args.booking.totalVnd)}',
            ),
            const SizedBox(height: AppSpacing.x2),
            const Text(
              'Không phát sinh thanh toán thực tế.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x5),
            FilledButton.icon(
              onPressed: () {
                ref.invalidate(myTicketsProvider);
                context.go('/tickets');
              },
              icon: const Icon(Icons.confirmation_num_outlined),
              label: const Text('Xem vé của tôi'),
            ),
            TextButton(
              onPressed: () => context.go('/discovery'),
              child: const Text('Tiếp tục khám phá'),
            ),
          ],
        ),
      ),
    ),
  );
}
