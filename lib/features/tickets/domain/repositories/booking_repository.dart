import 'package:eventhub_app/features/tickets/domain/entities/booking.dart';
import 'package:eventhub_app/features/tickets/domain/entities/ticket.dart';

abstract interface class BookingRepository {
  Future<Booking> createBooking({
    required String eventId,
    required String ticketTypeId,
    required int quantity,
    required int unitPriceVnd,
  });

  Future<List<Booking>> getBookings();
  Future<List<Ticket>> getTicketsForBooking(String bookingId);
  Future<Ticket?> getTicketById(String id);
  Future<List<Ticket>> getMyTickets();
}
