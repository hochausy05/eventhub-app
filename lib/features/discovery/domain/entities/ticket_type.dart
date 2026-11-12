class TicketType {
  TicketType({
    required this.id,
    required this.eventId,
    required this.name,
    required this.priceVnd,
    required this.capacity,
    required this.soldQuantity,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Ticket type ID cannot be empty.');
    }
    if (eventId.trim().isEmpty) {
      throw ArgumentError.value(
        eventId,
        'eventId',
        'Event ID cannot be empty.',
      );
    }
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Ticket name cannot be empty.');
    }
    if (priceVnd < 0) {
      throw ArgumentError.value(
        priceVnd,
        'priceVnd',
        'Ticket price cannot be negative.',
      );
    }
    if (capacity < 0) {
      throw ArgumentError.value(
        capacity,
        'capacity',
        'Ticket capacity cannot be negative.',
      );
    }
    if (soldQuantity < 0 || soldQuantity > capacity) {
      throw ArgumentError.value(
        soldQuantity,
        'soldQuantity',
        'Sold quantity must be between zero and capacity.',
      );
    }
  }

  final String id;
  final String eventId;
  final String name;
  final int priceVnd;
  final int capacity;
  final int soldQuantity;

  int get availableQuantity => capacity - soldQuantity;
  bool get isFree => priceVnd == 0;
}
