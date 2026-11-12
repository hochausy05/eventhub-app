import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/domain/entities/ticket_type.dart';
import 'package:eventhub_app/features/tickets/domain/entities/booking.dart';
import 'package:eventhub_app/features/tickets/domain/repositories/booking_repository.dart';

class BookingService {
  BookingService(this.repository);

  final BookingRepository repository;

  Future<int> remainingFor(TicketType type) async {
    final tickets = await repository.getMyTickets();
    return (type.availableQuantity -
            tickets.where((ticket) => ticket.ticketTypeId == type.id).length)
        .clamp(0, type.capacity);
  }

  Future<Booking> book({
    required Event event,
    required TicketType ticketType,
    required int quantity,
    DateTime? now,
  }) async {
    if (quantity < 1 || quantity > 4) {
      throw BookingException('Số lượng vé phải từ 1 đến 4.');
    }
    if (event.status != EventStatus.published ||
        !event.startsAt.isAfter(now ?? DateTime.now())) {
      throw BookingException('Sự kiện đã qua hoặc hiện không mở đặt vé.');
    }
    if (ticketType.eventId != event.id ||
        !event.ticketTypes.any((item) => item.id == ticketType.id)) {
      throw BookingException('Loại vé không thuộc sự kiện này.');
    }
    if (quantity > await remainingFor(ticketType)) {
      throw BookingException('Số vé còn lại không đủ.');
    }
    return repository.createBooking(
      eventId: event.id,
      ticketTypeId: ticketType.id,
      quantity: quantity,
      unitPriceVnd: ticketType.priceVnd,
    );
  }
}

class BookingException implements Exception {
  const BookingException(this.message);
  final String message;
  @override
  String toString() => message;
}
