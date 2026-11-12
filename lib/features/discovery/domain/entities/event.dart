import 'package:eventhub_app/features/discovery/domain/entities/ticket_type.dart';

enum EventCategory {
  technology('Công nghệ'),
  music('Âm nhạc'),
  workshop('Workshop'),
  community('Cộng đồng'),
  education('Giáo dục'),
  arts('Nghệ thuật'),
  foodLifestyle('Ẩm thực & đời sống'),
  entertainment('Giải trí');

  const EventCategory(this.label);

  final String label;
}

enum EventStatus { draft, published, cancelled }

class Event {
  Event({
    required this.id,
    required this.organizerId,
    this.organizerName,
    required this.title,
    required this.summary,
    required this.description,
    required this.category,
    required this.venueName,
    required this.address,
    required this.city,
    required this.startsAt,
    required this.endsAt,
    required this.bannerAssetPath,
    required this.isFeatured,
    required this.status,
    required List<TicketType> ticketTypes,
  }) : ticketTypes = List.unmodifiable(ticketTypes) {
    if (id.trim().isEmpty || organizerId.trim().isEmpty) {
      throw ArgumentError('Event and organizer IDs cannot be empty.');
    }
    if (title.trim().isEmpty || summary.trim().isEmpty) {
      throw ArgumentError('Event title and summary cannot be empty.');
    }
    if (!startsAt.isBefore(endsAt)) {
      throw ArgumentError('Event start must be earlier than event end.');
    }

    final ticketIds = this.ticketTypes.map((ticket) => ticket.id).toSet();
    if (ticketIds.length != this.ticketTypes.length) {
      throw ArgumentError('Ticket type IDs must be unique within an event.');
    }
    if (this.ticketTypes.any((ticket) => ticket.eventId != id)) {
      throw ArgumentError('Each ticket type must belong to this event.');
    }
  }

  final String id;
  final String organizerId;
  final String? organizerName;
  final String title;
  final String summary;
  final String description;
  final EventCategory category;
  final String venueName;
  final String address;
  final String city;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? bannerAssetPath;
  final bool isFeatured;
  final EventStatus status;
  final List<TicketType> ticketTypes;
}
