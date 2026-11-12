import 'dart:async';

import 'package:eventhub_app/app/app.dart';
import 'package:eventhub_app/app/router/app_router.dart';
import 'package:eventhub_app/features/tickets/domain/entities/booking.dart';
import 'package:eventhub_app/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub_app/features/tickets/domain/repositories/booking_repository.dart';
import 'package:eventhub_app/features/tickets/presentation/providers/booking_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    appRouter.go('/discovery');
  });

  testWidgets('paid booking reaches confirmation, wallet, and QR ticket', (
    tester,
  ) async {
    final repository = DelayedBookingRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bookingRepositoryProvider.overrideWithValue(repository)],
        child: const EventHubApp(),
      ),
    );
    await tester.pumpAndSettle();
    appRouter.go('/events/evt-saigon-tech-meetup');
    await tester.pumpAndSettle();
    final selectTicket = find.text('Chọn vé').first;
    await tester.ensureVisible(selectTicket);
    await tester.pumpAndSettle();
    await tester.tap(selectTicket);
    await tester.pumpAndSettle();
    expect(find.text('Đặt vé mô phỏng'), findsOneWidget);
    await tester.tap(find.byTooltip('Tăng số lượng'));
    await tester.pumpAndSettle();
    expect(find.text('360.000 ₫'), findsOneWidget);
    final confirmButton = find.byKey(const ValueKey('confirm-booking'));
    for (var i = 0; i < 4 && confirmButton.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -420));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(confirmButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmButton);
    await tester.pump();
    expect(repository.createCount, 1);
    repository.allowCreate.complete();
    await tester.pumpAndSettle();
    expect(find.text('Đã tạo vé mô phỏng'), findsOneWidget);
    await tester.tap(find.text('Xem vé của tôi'));
    await tester.pumpAndSettle();
    expect(find.text('Vé của tôi'), findsWidgets);
    expect(find.text('Saigon Tech Meetup: AI trong đời sống'), findsWidgets);
    expect(find.text('Vé tiêu chuẩn'), findsNWidgets(2));
    final ticketCard = find.byType(Card).first;
    await tester.tap(ticketCard);
    await tester.pumpAndSettle();
    expect(find.text('MÃ QR VÉ MINH HỌA'), findsOneWidget);
    expect(find.byKey(const ValueKey('qr-code')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wallet shows a real empty state with no bookings', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: EventHubApp()));
    await tester.pumpAndSettle();
    appRouter.go('/tickets');
    await tester.pumpAndSettle();
    expect(find.text('Bạn chưa có vé'), findsOneWidget);
  });
}

class DelayedBookingRepository implements BookingRepository {
  final allowCreate = Completer<void>();
  final List<Booking> bookings = [];
  final List<Ticket> tickets = [];
  var createCount = 0;

  @override
  Future<Booking> createBooking({
    required String eventId,
    required String ticketTypeId,
    required int quantity,
    required int unitPriceVnd,
  }) async {
    createCount++;
    await allowCreate.future;
    final id = 'booking-demo';
    final now = DateTime.now();
    final booking = Booking(
      id: id,
      eventId: eventId,
      ticketTypeId: ticketTypeId,
      quantity: quantity,
      unitPriceVnd: unitPriceVnd,
      totalVnd: unitPriceVnd * quantity,
      createdAt: now,
    );
    bookings.add(booking);
    tickets.addAll(
      List.generate(
        quantity,
        (index) => Ticket(
          id: 'ticket-$index',
          bookingId: id,
          eventId: eventId,
          ticketTypeId: ticketTypeId,
          qrPayload: 'eventhub-demo:v1:ticket-$index',
          createdAt: now,
        ),
      ),
    );
    return booking;
  }

  @override
  Future<List<Booking>> getBookings() async => [...bookings];
  @override
  Future<List<Ticket>> getTicketsForBooking(String bookingId) async =>
      tickets.where((ticket) => ticket.bookingId == bookingId).toList();
  @override
  Future<Ticket?> getTicketById(String id) async =>
      tickets.where((ticket) => ticket.id == id).firstOrNull;
  @override
  Future<List<Ticket>> getMyTickets() async => [...tickets];
}
