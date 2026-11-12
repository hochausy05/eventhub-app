import 'package:eventhub_app/features/discovery/data/mock/sample_events.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/domain/repositories/event_repository.dart';

class MockEventRepository implements EventRepository {
  MockEventRepository({List<Event>? seedEvents})
    : _events = List.of(seedEvents ?? sampleEvents);

  final List<Event> _events;

  @override
  Future<List<Event>> getAllEvents() async => List.unmodifiable(_events);

  @override
  Future<List<Event>> getPublishedEvents() async => List.unmodifiable(
    _events.where((event) => event.status == EventStatus.published),
  );

  @override
  Future<Event?> getEventById(String id) async {
    for (final event in _events) {
      if (event.id == id) return event;
    }
    return null;
  }

  @override
  Future<void> createEvent(Event event) async {
    if (_events.any((existing) => existing.id == event.id)) {
      throw StateError('Event ID already exists.');
    }
    _events.add(event);
  }

  @override
  Future<void> updateEvent(Event event) async {
    final index = _events.indexWhere((existing) => existing.id == event.id);
    if (index < 0) throw StateError('Event not found.');
    _events[index] = event;
  }
}
