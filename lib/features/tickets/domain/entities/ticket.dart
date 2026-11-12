enum TicketStatus { valid }

class Ticket {
  const Ticket({
    required this.id,
    required this.bookingId,
    required this.eventId,
    required this.ticketTypeId,
    required this.qrPayload,
    required this.createdAt,
    this.status = TicketStatus.valid,
  });

  final String id;
  final String bookingId;
  final String eventId;
  final String ticketTypeId;
  final String qrPayload;
  final DateTime createdAt;
  final TicketStatus status;
}
