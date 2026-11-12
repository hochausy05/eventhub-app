import 'dart:convert';
import 'dart:math';

import 'package:eventhub_app/features/discovery/data/mock/sample_events.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/domain/entities/ticket_type.dart';
import 'package:eventhub_app/features/discovery/domain/repositories/event_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalEventRepository implements EventRepository {
  LocalEventRepository(this.preferences, {List<Event>? seedEvents})
    : _seedEvents = List.unmodifiable(seedEvents ?? sampleEvents);

  static const storageKey = 'eventhub.demo.events.v1';
  final SharedPreferencesAsync preferences;
  final List<Event> _seedEvents;
  final Random _random = Random.secure();

  String newEventId() => 'evt_demo_${_randomToken()}';

  String _randomToken() => base64Url
      .encode(List<int>.generate(18, (_) => _random.nextInt(256)))
      .replaceAll('=', '');

  Future<List<Event>> _readEvents() async {
    final raw = await preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => _eventFromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // A malformed local overlay must not hide the immutable seed events.
      return [];
    }
  }

  Future<void> _writeEvents(List<Event> events) => preferences.setString(
    storageKey,
    jsonEncode(events.map(_eventToJson).toList()),
  );

  Future<List<Event>> _effectiveEvents() async {
    final overrides = await _readEvents();
    final byId = {for (final event in overrides) event.id: event};
    final merged = _seedEvents
        .map((event) => byId.remove(event.id) ?? event)
        .toList();
    merged.addAll(byId.values);
    return merged;
  }

  @override
  Future<List<Event>> getAllEvents() async =>
      List.unmodifiable(await _effectiveEvents());

  @override
  Future<List<Event>> getPublishedEvents() async => List.unmodifiable(
    (await _effectiveEvents()).where(
      (event) => event.status == EventStatus.published,
    ),
  );

  @override
  Future<Event?> getEventById(String id) async {
    for (final event in await _effectiveEvents()) {
      if (event.id == id) return event;
    }
    return null;
  }

  @override
  Future<void> createEvent(Event event) async {
    final effective = await _effectiveEvents();
    if (effective.any((item) => item.id == event.id)) {
      throw StateError('Event ID already exists.');
    }
    final overrides = await _readEvents()
      ..add(event);
    await _writeEvents(overrides);
  }

  @override
  Future<void> updateEvent(Event event) async {
    final effective = await _effectiveEvents();
    if (!effective.any((item) => item.id == event.id)) {
      throw StateError('Event not found.');
    }
    final overrides = await _readEvents();
    final index = overrides.indexWhere((item) => item.id == event.id);
    if (index < 0) {
      overrides.add(event);
    } else {
      overrides[index] = event;
    }
    await _writeEvents(overrides);
  }

  Map<String, dynamic> _eventToJson(Event event) => {
    'id': event.id,
    'organizerId': event.organizerId,
    'organizerName': event.organizerName,
    'title': event.title,
    'summary': event.summary,
    'description': event.description,
    'category': event.category.name,
    'venueName': event.venueName,
    'address': event.address,
    'city': event.city,
    'startsAt': event.startsAt.toIso8601String(),
    'endsAt': event.endsAt.toIso8601String(),
    'bannerAssetPath': event.bannerAssetPath,
    'isFeatured': event.isFeatured,
    'status': event.status.name,
    'ticketTypes': event.ticketTypes.map(_ticketToJson).toList(),
  };

  Event _eventFromJson(Map<String, dynamic> json) => Event(
    id: json['id'] as String,
    organizerId: json['organizerId'] as String,
    organizerName: json['organizerName'] as String?,
    title: json['title'] as String,
    summary: json['summary'] as String,
    description: json['description'] as String,
    category: EventCategory.values.byName(json['category'] as String),
    venueName: json['venueName'] as String,
    address: json['address'] as String,
    city: json['city'] as String,
    startsAt: DateTime.parse(json['startsAt'] as String),
    endsAt: DateTime.parse(json['endsAt'] as String),
    bannerAssetPath: json['bannerAssetPath'] as String?,
    isFeatured: json['isFeatured'] as bool,
    status: EventStatus.values.byName(json['status'] as String),
    ticketTypes: (json['ticketTypes'] as List<dynamic>)
        .map((item) => _ticketFromJson(item as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> _ticketToJson(TicketType ticket) => {
    'id': ticket.id,
    'eventId': ticket.eventId,
    'name': ticket.name,
    'priceVnd': ticket.priceVnd,
    'capacity': ticket.capacity,
    'soldQuantity': ticket.soldQuantity,
  };

  TicketType _ticketFromJson(Map<String, dynamic> json) => TicketType(
    id: json['id'] as String,
    eventId: json['eventId'] as String,
    name: json['name'] as String,
    priceVnd: json['priceVnd'] as int,
    capacity: json['capacity'] as int,
    soldQuantity: json['soldQuantity'] as int,
  );
}
