enum BookingStatus { confirmed }

class Booking {
  const Booking({
    required this.id,
    required this.eventId,
    required this.ticketTypeId,
    required this.quantity,
    required this.unitPriceVnd,
    required this.totalVnd,
    required this.createdAt,
    this.status = BookingStatus.confirmed,
  });

  final String id;
  final String eventId;
  final String ticketTypeId;
  final int quantity;
  final int unitPriceVnd;
  final int totalVnd;
  final DateTime createdAt;
  final BookingStatus status;
}
