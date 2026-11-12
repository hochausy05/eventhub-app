import 'package:eventhub_app/features/tickets/data/repositories/local_booking_repository.dart';
import 'package:eventhub_app/features/tickets/domain/entities/booking.dart';
import 'package:eventhub_app/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub_app/features/tickets/domain/repositories/booking_repository.dart';
import 'package:eventhub_app/features/tickets/domain/services/booking_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => LocalBookingRepository(SharedPreferencesAsync()),
);
final bookingServiceProvider = Provider<BookingService>(
  (ref) => BookingService(ref.watch(bookingRepositoryProvider)),
);
final myTicketsProvider = FutureProvider<List<Ticket>>(
  (ref) => ref.watch(bookingRepositoryProvider).getMyTickets(),
);
final bookingsProvider = FutureProvider<List<Booking>>(
  (ref) => ref.watch(bookingRepositoryProvider).getBookings(),
);
final ticketByIdProvider = FutureProvider.family<Ticket?, String>(
  (ref, id) => ref.watch(bookingRepositoryProvider).getTicketById(id),
);
