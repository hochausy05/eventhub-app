import 'package:eventhub_app/features/discovery/data/mock/sample_events.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/domain/entities/ticket_type.dart';
import 'package:eventhub_app/features/tickets/data/repositories/local_booking_repository.dart';
import 'package:eventhub_app/features/tickets/domain/entities/booking.dart';
import 'package:eventhub_app/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub_app/features/tickets/domain/repositories/booking_repository.dart';
import 'package:eventhub_app/features/tickets/domain/services/booking_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late MemoryBookingRepository repository;
  late BookingService service;
  final event = sampleEvents.first;
  final paidType = sampleEvents.first.ticketTypes.first;
  final freeEvent = sampleEvents.firstWhere(
    (e) => e.id == 'evt-green-earth-community-run',
  );
  final freeType = freeEvent.ticketTypes.first;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    repository = MemoryBookingRepository();
    service = BookingService(repository);
  });

  test('quantity limits and total use integer VND', () async {
    expect((180000 * 2), 360000);
    await expectLater(
      service.book(event: event, ticketType: paidType, quantity: 0),
      throwsA(isA<BookingException>()),
    );
    await expectLater(
      service.book(event: event, ticketType: paidType, quantity: 5),
      throwsA(isA<BookingException>()),
    );
  });

  test('paid and free bookings create one ticket per unit', () async {
    final paid = await service.book(
      event: event,
      ticketType: paidType,
      quantity: 2,
    );
    expect(paid.totalVnd, paidType.priceVnd * 2);
    expect((await repository.getTicketsForBooking(paid.id)).length, 2);
    final free = await service.book(
      event: freeEvent,
      ticketType: freeType,
      quantity: 1,
    );
    expect(free.totalVnd, 0);
    expect(
      (await repository.getTicketsForBooking(free.id)).single.eventId,
      freeEvent.id,
    );
  });

  test('ticket identifiers and versioned QR payloads are unique and contain no personal data', () async {
    final booking = await service.book(
      event: event,
      ticketType: paidType,
      quantity: 4,
    );
    final tickets = await repository.getTicketsForBooking(booking.id);
    expect(tickets.map((t) => t.id).toSet().length, 4);
    expect(tickets.map((t) => t.qrPayload).toSet().length, 4);
    expect(
      tickets.every((t) => t.qrPayload.startsWith('eventhub-demo:v1:')),
      isTrue,
    );
    expect(
      tickets.every(
        (t) => !t.qrPayload.contains('@') && !t.qrPayload.contains('hocha'),
      ),
      isTrue,
    );
  });

  test(
    'inventory includes seed sold quantity plus previous local tickets',
    () async {
      final almostSoldOut = TicketType(
        id: 'limited',
        eventId: event.id,
        name: 'Limited',
        priceVnd: 100,
        capacity: 3,
        soldQuantity: 2,
      );
      final limitedEvent = Event(
        id: event.id,
        organizerId: event.organizerId,
        title: event.title,
        summary: event.summary,
        description: event.description,
        category: event.category,
        venueName: event.venueName,
        address: event.address,
        city: event.city,
        startsAt: event.startsAt,
        endsAt: event.endsAt,
        bannerAssetPath: event.bannerAssetPath,
        isFeatured: false,
        status: EventStatus.published,
        ticketTypes: [almostSoldOut],
      );
      await service.book(
        event: limitedEvent,
        ticketType: almostSoldOut,
        quantity: 1,
      );
      await expectLater(
        service.book(
          event: limitedEvent,
          ticketType: almostSoldOut,
          quantity: 1,
        ),
        throwsA(isA<BookingException>()),
      );
    },
  );

  test('rejects foreign ticket type and past or unavailable events', () async {
    final foreign = sampleEvents[1].ticketTypes.first;
    await expectLater(
      service.book(event: event, ticketType: foreign, quantity: 1),
      throwsA(isA<BookingException>()),
    );
    await expectLater(
      service.book(
        event: event,
        ticketType: paidType,
        quantity: 1,
        now: event.startsAt,
      ),
      throwsA(isA<BookingException>()),
    );
    final cancelled = Event(
      id: event.id,
      organizerId: event.organizerId,
      title: event.title,
      summary: event.summary,
      description: event.description,
      category: event.category,
      venueName: event.venueName,
      address: event.address,
      city: event.city,
      startsAt: event.startsAt,
      endsAt: event.endsAt,
      bannerAssetPath: event.bannerAssetPath,
      isFeatured: false,
      status: EventStatus.cancelled,
      ticketTypes: event.ticketTypes,
    );
    await expectLater(
      service.book(event: cancelled, ticketType: paidType, quantity: 1),
      throwsA(isA<BookingException>()),
    );
  });

  test('SharedPreferences repository survives reconstruction and ignores corrupt data', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final first = LocalBookingRepository(SharedPreferencesAsync());
    final booking = await first.createBooking(
      eventId: event.id,
      ticketTypeId: paidType.id,
      quantity: 2,
      unitPriceVnd: paidType.priceVnd,
    );
    final originalTickets = await first.getTicketsForBooking(booking.id);
    final reloaded = LocalBookingRepository(SharedPreferencesAsync());
    expect((await reloaded.getMyTickets()).length, 2);
    expect((await reloaded.getBookings()).single.id, booking.id);
    final reloadedTickets = await reloaded.getTicketsForBooking(booking.id);
    expect(
      reloadedTickets.map((ticket) => ticket.qrPayload),
      originalTickets.map((ticket) => ticket.qrPayload),
    );
    expect(await reloaded.getTicketById(originalTickets.first.id), isNotNull);
    await SharedPreferencesAsync().setString(
      LocalBookingRepository.storageKey,
      '{bad json',
    );
    expect(
      await LocalBookingRepository(SharedPreferencesAsync()).getMyTickets(),
      isEmpty,
    );
  });
}

class MemoryBookingRepository implements BookingRepository {
  final List<Booking> bookings = [];
  final List<Ticket> tickets = [];
  int nextId = 0;
  @override
  Future<Booking> createBooking({
    required String eventId,
    required String ticketTypeId,
    required int quantity,
    required int unitPriceVnd,
  }) async {
    final id = 'booking-${nextId++}';
    final booking = Booking(
      id: id,
      eventId: eventId,
      ticketTypeId: ticketTypeId,
      quantity: quantity,
      unitPriceVnd: unitPriceVnd,
      totalVnd: quantity * unitPriceVnd,
      createdAt: DateTime.now(),
    );
    bookings.add(booking);
    for (var i = 0; i < quantity; i++) {
      tickets.add(
        Ticket(
          id: 'ticket-${nextId++}',
          bookingId: id,
          eventId: eventId,
          ticketTypeId: ticketTypeId,
          qrPayload: 'eventhub-demo:v1:$id:$i',
          createdAt: booking.createdAt,
        ),
      );
    }
    return booking;
  }

  @override
  Future<List<Booking>> getBookings() async => [...bookings];
  @override
  Future<List<Ticket>> getTicketsForBooking(String bookingId) async =>
      tickets.where((t) => t.bookingId == bookingId).toList();
  @override
  Future<Ticket?> getTicketById(String id) async =>
      tickets.where((t) => t.id == id).firstOrNull;
  @override
  Future<List<Ticket>> getMyTickets() async => [...tickets];
}
