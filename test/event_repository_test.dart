import 'package:eventhub_app/app/theme/app_theme.dart';
import 'package:eventhub_app/features/discovery/presentation/widgets/event_banner.dart';
import 'package:eventhub_app/features/discovery/data/mock/sample_events.dart';
import 'package:eventhub_app/features/discovery/data/repositories/mock_event_repository.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/domain/entities/ticket_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repository = MockEventRepository();

  test('returns eight published fictional sample events', () async {
    final events = await repository.getPublishedEvents();

    expect(events, hasLength(8));
    expect(
      events.every((event) => event.status == EventStatus.published),
      isTrue,
    );
  });

  test('event IDs and ticket type IDs are globally unique', () {
    final eventIds = sampleEvents.map((event) => event.id).toList();
    final ticketIds = sampleEvents
        .expand((event) => event.ticketTypes)
        .map((ticket) => ticket.id)
        .toList();

    expect(eventIds.toSet(), hasLength(eventIds.length));
    expect(ticketIds.toSet(), hasLength(ticketIds.length));
  });

  test('ticket types belong to their event and have valid quantities', () {
    for (final event in sampleEvents) {
      for (final ticket in event.ticketTypes) {
        expect(ticket.eventId, event.id);
        expect(ticket.priceVnd, greaterThanOrEqualTo(0));
        expect(ticket.capacity, greaterThanOrEqualTo(0));
        expect(ticket.soldQuantity, inInclusiveRange(0, ticket.capacity));
      }
    }
  });

  test('event dates use UTC and every start precedes its end', () {
    for (final event in sampleEvents) {
      expect(event.startsAt.isUtc, isTrue);
      expect(event.endsAt.isUtc, isTrue);
      expect(event.startsAt.isBefore(event.endsAt), isTrue);
    }
  });

  test('sample events include free and paid ticket types', () {
    final tickets = sampleEvents.expand((event) => event.ticketTypes);

    expect(tickets.any((ticket) => ticket.isFree), isTrue);
    expect(tickets.any((ticket) => !ticket.isFree), isTrue);
  });

  test('finds an event and returns null for an unknown ID', () async {
    final firstEvent = sampleEvents.first;

    expect(await repository.getEventById(firstEvent.id), same(firstEvent));
    expect(await repository.getEventById('evt-not-found'), isNull);
  });

  test('public listing excludes unpublished events', () async {
    final published = sampleEvents.first;
    final draft = _testEvent(
      id: 'evt-private-draft',
      status: EventStatus.draft,
    );
    final seededRepository = MockEventRepository(
      seedEvents: [published, draft],
    );

    expect(await seededRepository.getPublishedEvents(), [published]);
    expect(await seededRepository.getEventById(draft.id), same(draft));
  });

  test('entities reject invalid time ranges and ticket amounts', () {
    expect(
      () => _testEvent(
        id: 'evt-invalid-range',
        status: EventStatus.published,
        startsAt: DateTime.utc(2027, 1, 2),
        endsAt: DateTime.utc(2027, 1, 2),
      ),
      throwsArgumentError,
    );
    expect(
      () => TicketType(
        id: 'tkt-negative-price',
        eventId: 'evt-test',
        name: 'Vé lỗi',
        priceVnd: -1,
        capacity: 1,
        soldQuantity: 0,
      ),
      throwsArgumentError,
    );
    expect(
      () => TicketType(
        id: 'tkt-over-capacity',
        eventId: 'evt-test',
        name: 'Vé lỗi',
        priceVnd: 0,
        capacity: 1,
        soldQuantity: 2,
      ),
      throwsArgumentError,
    );
  });

  testWidgets('all eight local event banners load successfully', (
    tester,
  ) async {
    for (final event in sampleEvents) {
      final bannerPath = event.bannerAssetPath;
      expect(bannerPath, isNotNull, reason: event.title);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 280,
              height: 180,
              child: EventBanner(
                assetPath: bannerPath,
                fallbackIcon: Icons.event_outlined,
                semanticLabel: event.title,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: event.title);
      expect(find.byType(EventBanner), findsOneWidget);
    }
  });

  testWidgets('event banner falls back when no asset is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SizedBox(
            width: 280,
            height: 180,
            child: EventBanner(
              assetPath: null,
              fallbackIcon: Icons.event_outlined,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.event_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'mock data can be read repeatedly without a network dependency',
    () async {
      final firstRead = await repository.getPublishedEvents();
      final secondRead = await repository.getPublishedEvents();

      expect(
        secondRead.map((event) => event.id).toList(),
        firstRead.map((event) => event.id).toList(),
      );
    },
  );
}

Event _testEvent({
  required String id,
  required EventStatus status,
  DateTime? startsAt,
  DateTime? endsAt,
}) {
  return Event(
    id: id,
    organizerId: 'org-test',
    title: 'Sự kiện kiểm thử',
    summary: 'Nội dung kiểm thử.',
    description: 'Mô tả kiểm thử.',
    category: EventCategory.community,
    venueName: 'Địa điểm kiểm thử',
    address: 'Địa chỉ kiểm thử',
    city: 'Hà Nội',
    startsAt: startsAt ?? DateTime.utc(2027, 1, 1, 1),
    endsAt: endsAt ?? DateTime.utc(2027, 1, 1, 2),
    bannerAssetPath: null,
    isFeatured: false,
    status: status,
    ticketTypes: const [],
  );
}
