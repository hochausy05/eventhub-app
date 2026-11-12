import 'package:eventhub_app/features/discovery/data/mock/sample_events.dart';
import 'package:eventhub_app/features/discovery/data/repositories/local_event_repository.dart';
import 'package:eventhub_app/features/discovery/data/repositories/mock_event_repository.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/domain/entities/ticket_type.dart';
import 'package:eventhub_app/features/discovery/presentation/providers/event_providers.dart';
import 'package:eventhub_app/features/organizer/domain/services/event_management_service.dart';
import 'package:eventhub_app/features/organizer/presentation/providers/organizer_providers.dart';
import 'package:eventhub_app/features/tickets/domain/entities/booking.dart';
import 'package:eventhub_app/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub_app/features/tickets/domain/repositories/booking_repository.dart';
import 'package:eventhub_app/features/tickets/domain/services/booking_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  test(
    'organizer provider filters strictly by selected demo organizer ID',
    () async {
      final owned = _event(organizerId: demoOrganizerId, id: 'mine');
      final other = _event(organizerId: 'someone-else', id: 'other');
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWithValue(
            MockEventRepository(seedEvents: [owned, other]),
          ),
        ],
      );
      addTearDown(container.dispose);
      final events = await container.read(organizerEventsProvider.future);
      expect(events.map((event) => event.id), ['mine']);
    },
  );

  test('creates valid draft and published event with one ticket', () async {
    final service = EventManagementService(
      events: MockEventRepository(),
      bookings: _TestBookingRepository(),
    );
    final draft = _create(service, EventStatus.draft);
    expect(draft.status, EventStatus.draft);
    expect(draft.organizerId, demoOrganizerId);
    expect(draft.ticketTypes.single.capacity, 80);
    final published = _create(service, EventStatus.published);
    expect(published.status, EventStatus.published);
    expect(published.ticketTypes.single.priceVnd, 25000);
  });

  test('rejects invalid event content, dates, price, capacity, and past published events', () {
    final service = EventManagementService(
      events: MockEventRepository(),
      bookings: _TestBookingRepository(),
    );
    expect(
      () => _create(service, EventStatus.published, title: ' '),
      throwsA(isA<EventManagementException>()),
    );
    expect(
      () =>
          _create(service, EventStatus.published, endsAt: DateTime(2030, 2, 1)),
      throwsA(isA<EventManagementException>()),
    );
    expect(
      () => _create(service, EventStatus.published, price: -1),
      throwsA(isA<EventManagementException>()),
    );
    expect(
      () => _create(service, EventStatus.published, capacity: 0),
      throwsA(isA<EventManagementException>()),
    );
    expect(
      () => _create(
        service,
        EventStatus.published,
        startsAt: DateTime(2020),
        now: DateTime(2025),
      ),
      throwsA(isA<EventManagementException>()),
    );
  });

  test(
    'local event repository persists overlays and retains all seed events',
    () async {
      final repository = LocalEventRepository(SharedPreferencesAsync());
      final created = _create(
        EventManagementService(
          events: repository,
          bookings: _TestBookingRepository(),
        ),
        EventStatus.published,
      );
      await repository.createEvent(created);
      final reloaded = LocalEventRepository(SharedPreferencesAsync());
      expect((await reloaded.getAllEvents()).length, sampleEvents.length + 1);
      expect((await reloaded.getEventById(created.id))?.title, created.title);
      expect(
        (await reloaded.getPublishedEvents()).any(
          (event) => event.id == created.id,
        ),
        isTrue,
      );
      final draft = _create(
        EventManagementService(
          events: reloaded,
          bookings: _TestBookingRepository(),
        ),
        EventStatus.draft,
      );
      await reloaded.createEvent(draft);
      expect(
        (await reloaded.getPublishedEvents()).any(
          (event) => event.id == draft.id,
        ),
        isFalse,
      );
    },
  );

  test('edit preserves event and organizer IDs, ticket configuration, and bookings', () async {
    final repository = MockEventRepository();
    final old = _create(
      EventManagementService(
        events: repository,
        bookings: _TestBookingRepository(),
      ),
      EventStatus.published,
    );
    await repository.createEvent(old);
    final bookings = _TestBookingRepository()..items.add(_booking(old, 2));
    final edited = _copy(old, title: 'Updated demo title');
    await EventManagementService(
      events: repository,
      bookings: bookings,
    ).updateEvent(original: old, edited: edited);
    final stored = await repository.getEventById(old.id);
    expect(stored?.title, 'Updated demo title');
    expect(stored?.id, old.id);
    expect(stored?.organizerId, old.organizerId);
    expect(stored?.ticketTypes.single.id, old.ticketTypes.single.id);
    expect((await bookings.getBookings()).single.quantity, 2);
  });

  test('rejects lowering capacity below locally confirmed bookings', () async {
    final repository = MockEventRepository();
    final old = _create(
      EventManagementService(
        events: repository,
        bookings: _TestBookingRepository(),
      ),
      EventStatus.published,
      capacity: 10,
    );
    await repository.createEvent(old);
    final bookings = _TestBookingRepository()..items.add(_booking(old, 2));
    final smallerTicket = TicketType(
      id: old.ticketTypes.single.id,
      eventId: old.id,
      name: old.ticketTypes.single.name,
      priceVnd: old.ticketTypes.single.priceVnd,
      capacity: 1,
      soldQuantity: 0,
    );
    final reduced = _copy(old, tickets: [smallerTicket]);
    await expectLater(
      EventManagementService(
        events: repository,
        bookings: bookings,
      ).updateEvent(original: old, edited: reduced),
      throwsA(isA<EventManagementException>()),
    );
  });

  test('unknown event IDs return null and cannot be updated', () async {
    final repository = LocalEventRepository(SharedPreferencesAsync());
    expect(await repository.getEventById('unknown'), isNull);
    await expectLater(
      repository.updateEvent(
        _event(id: 'unknown', organizerId: demoOrganizerId),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'a newly created published event can be booked by the attendee flow',
    () async {
      final eventRepository = LocalEventRepository(SharedPreferencesAsync());
      final event = _create(
        EventManagementService(
          events: eventRepository,
          bookings: _TestBookingRepository(),
        ),
        EventStatus.published,
      );
      await eventRepository.createEvent(event);
      final bookingRepository = _TestBookingRepository();
      final booking = await BookingService(bookingRepository).book(
        event: event,
        ticketType: event.ticketTypes.single,
        quantity: 1,
        now: DateTime(2025),
      );
      expect(booking.eventId, event.id);
      expect(booking.totalVnd, 25000);
    },
  );
}

Event _create(
  EventManagementService service,
  EventStatus status, {
  String title = 'Demo event',
  int price = 25000,
  int capacity = 80,
  DateTime? startsAt,
  DateTime? endsAt,
  DateTime? now,
}) => service.createEvent(
  title: title,
  summary: 'A short event summary',
  description: 'A longer demo description.',
  category: EventCategory.technology,
  venueName: 'Demo Hall',
  address: '1 Demo Street',
  city: 'Hà Nội',
  startsAt: startsAt ?? DateTime(2030, 4, 1, 9),
  endsAt: endsAt ?? DateTime(2030, 4, 1, 12),
  bannerAssetPath: sampleEvents.first.bannerAssetPath,
  status: status,
  ticketName: 'Vé tham dự',
  priceVnd: price,
  capacity: capacity,
  now: now ?? DateTime(2029),
);

Event _event({required String id, required String organizerId}) => Event(
  id: id,
  organizerId: organizerId,
  title: id,
  summary: 'Summary',
  description: 'Description',
  category: EventCategory.music,
  venueName: 'Hall',
  address: 'Address',
  city: 'Hanoi',
  startsAt: DateTime(2030),
  endsAt: DateTime(2030, 1, 2),
  bannerAssetPath: null,
  isFeatured: false,
  status: EventStatus.published,
  ticketTypes: [
    TicketType(
      id: 'type-$id',
      eventId: id,
      name: 'Ticket',
      priceVnd: 100,
      capacity: 10,
      soldQuantity: 0,
    ),
  ],
);

Event _copy(Event event, {String? title, List<TicketType>? tickets}) => Event(
  id: event.id,
  organizerId: event.organizerId,
  organizerName: event.organizerName,
  title: title ?? event.title,
  summary: event.summary,
  description: event.description,
  category: event.category,
  venueName: event.venueName,
  address: event.address,
  city: event.city,
  startsAt: event.startsAt,
  endsAt: event.endsAt,
  bannerAssetPath: event.bannerAssetPath,
  isFeatured: event.isFeatured,
  status: event.status,
  ticketTypes: tickets ?? event.ticketTypes,
);

Booking _booking(Event event, int quantity) => Booking(
  id: 'booking-${event.id}',
  eventId: event.id,
  ticketTypeId: event.ticketTypes.first.id,
  quantity: quantity,
  unitPriceVnd: event.ticketTypes.first.priceVnd,
  totalVnd: quantity * event.ticketTypes.first.priceVnd,
  createdAt: DateTime.now(),
);

class _TestBookingRepository implements BookingRepository {
  final List<Booking> items = [];
  @override
  Future<Booking> createBooking({
    required String eventId,
    required String ticketTypeId,
    required int quantity,
    required int unitPriceVnd,
  }) async {
    final item = Booking(
      id: 'booking-${items.length}',
      eventId: eventId,
      ticketTypeId: ticketTypeId,
      quantity: quantity,
      unitPriceVnd: unitPriceVnd,
      totalVnd: quantity * unitPriceVnd,
      createdAt: DateTime.now(),
    );
    items.add(item);
    return item;
  }

  @override
  Future<List<Booking>> getBookings() async => [...items];
  @override
  Future<List<Ticket>> getMyTickets() async => [];
  @override
  Future<List<Ticket>> getTicketsForBooking(String bookingId) async => [];
  @override
  Future<Ticket?> getTicketById(String id) async => null;
}
