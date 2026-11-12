import 'package:eventhub_app/features/discovery/domain/entities/event.dart';

abstract interface class EventRepository {
  Future<List<Event>> getAllEvents();

  Future<List<Event>> getPublishedEvents();

  Future<Event?> getEventById(String id);

  Future<void> createEvent(Event event);

  Future<void> updateEvent(Event event);
}
