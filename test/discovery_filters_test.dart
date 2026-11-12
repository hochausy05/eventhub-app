import 'package:eventhub_app/features/discovery/data/mock/sample_events.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/presentation/utils/discovery_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('featured selection returns at most three featured events by date', () {
    final featured = getFeaturedEvents(sampleEvents);

    expect(featured, hasLength(3));
    expect(featured.every((event) => event.isFeatured), isTrue);
    expect(featured.map((event) => event.id), [
      'evt-saigon-tech-meetup',
      'evt-indie-music-night',
      'evt-da-nang-startup-pitch-day',
    ]);
  });

  test(
    'search matches title, category, city and summary case-insensitively',
    () {
      expect(
        filterEvents(
          events: sampleEvents,
          query: '  AI TRONG ĐỜI SỐNG  ',
        ).map((event) => event.id),
        contains('evt-saigon-tech-meetup'),
      );
      expect(
        filterEvents(
          events: sampleEvents,
          query: 'CÔNG NGHỆ',
        ).map((event) => event.id),
        containsAll([
          'evt-saigon-tech-meetup',
          'evt-da-nang-startup-pitch-day',
        ]),
      );
      expect(
        filterEvents(
          events: sampleEvents,
          query: 'HÀ NỘI',
        ).map((event) => event.id),
        containsAll([
          'evt-design-thinking-workshop',
          'evt-vietnamese-food-festival',
        ]),
      );
    },
  );

  test('search is accent-insensitive for Vietnamese text', () {
    expect(
      filterEvents(
        events: sampleEvents,
        query: 'cong nghe',
      ).map((event) => event.id),
      containsAll(['evt-saigon-tech-meetup', 'evt-da-nang-startup-pitch-day']),
    );
    expect(
      filterEvents(
        events: sampleEvents,
        query: 'da nang',
      ).map((event) => event.id),
      containsAll([
        'evt-da-nang-startup-pitch-day',
        'evt-da-nang-photography-walk',
      ]),
    );
  });

  test('an unknown keyword returns no events', () {
    expect(
      filterEvents(events: sampleEvents, query: 'khong-co-su-kien'),
      isEmpty,
    );
  });

  test('category filter selects only matching events', () {
    final filtered = filterEvents(
      events: sampleEvents,
      category: EventCategory.technology,
    );

    expect(filtered.map((event) => event.id), [
      'evt-saigon-tech-meetup',
      'evt-da-nang-startup-pitch-day',
    ]);
  });

  test('search and category filters work together', () {
    final filtered = filterEvents(
      events: sampleEvents,
      query: 'da nang',
      category: EventCategory.technology,
    );

    expect(filtered.map((event) => event.id), [
      'evt-da-nang-startup-pitch-day',
    ]);
  });

  test(
    'upcoming events are chronological and localized prices are accurate',
    () {
      final upcoming = getUpcomingEvents(
        sampleEvents,
        now: DateTime.utc(2026, 11, 11),
      );

      expect(upcoming, hasLength(8));
      expect(upcoming.first.startsAt.isBefore(upcoming.last.startsAt), isTrue);
      expect(formatVnd(0), 'Miễn phí');
      expect(formatVnd(180000), '180.000 ₫');
      expect(formatVnd(1250000), '1.250.000 ₫');
    },
  );
}
