import 'dart:convert';
import 'dart:math';

import 'package:eventhub_app/features/tickets/domain/entities/booking.dart';
import 'package:eventhub_app/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub_app/features/tickets/domain/repositories/booking_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalBookingRepository implements BookingRepository {
  LocalBookingRepository(this.preferences);
  static const storageKey = 'eventhub.demo.bookings.v1';
  final SharedPreferencesAsync preferences;
  final Random _random = Random.secure();

  String _token() => base64Url
      .encode(List<int>.generate(24, (_) => _random.nextInt(256)))
      .replaceAll('=', '');

  List<Booking> _readBookings() {
    // Corrupt data is ignored safely; a new successful booking overwrites it.
    try {
      final raw =
          (jsonDecode(_cachedJson ?? '{}') as Map<String, dynamic>)['bookings']
              as List<dynamic>;
      return raw
          .map((item) => _bookingFromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<Ticket> _readTickets() {
    try {
      final raw =
          (jsonDecode(_cachedJson ?? '{}') as Map<String, dynamic>)['tickets']
              as List<dynamic>;
      return raw
          .map((item) => _ticketFromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  String? _cachedJson;
  Future<void> _load() async =>
      _cachedJson = await preferences.getString(storageKey);

  @override
  Future<Booking> createBooking({
    required String eventId,
    required String ticketTypeId,
    required int quantity,
    required int unitPriceVnd,
  }) async {
    if (quantity < 1 || quantity > 4 || unitPriceVnd < 0) {
      throw ArgumentError('Invalid booking values.');
    }
    await _load();
    final now = DateTime.now().toUtc();
    final bookingId = 'bkg_${_token()}';
    final booking = Booking(
      id: bookingId,
      eventId: eventId,
      ticketTypeId: ticketTypeId,
      quantity: quantity,
      unitPriceVnd: unitPriceVnd,
      totalVnd: quantity * unitPriceVnd,
      createdAt: now,
    );
    final tickets = List.generate(
      quantity,
      (_) => Ticket(
        id: 'tkt_${_token()}',
        bookingId: bookingId,
        eventId: eventId,
        ticketTypeId: ticketTypeId,
        qrPayload: 'eventhub-demo:v1:${_token()}',
        createdAt: now,
      ),
    );
    final previous = _readBookings();
    final existingTickets = _readTickets();
    final document = <String, dynamic>{
      'bookings': [...previous.map(_bookingToJson), _bookingToJson(booking)],
      'tickets': [
        ...existingTickets.map(_ticketToJson),
        ...tickets.map(_ticketToJson),
      ],
    };
    // Persist both collections in one preference write.
    await preferences.setString(storageKey, jsonEncode(document));
    _cachedJson = jsonEncode(document);
    return booking;
  }

  List<Booking> _bookingsFromDocument() => _readBookings();

  @override
  Future<List<Booking>> getBookings() async {
    await _load();
    return _bookingsFromDocument()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Ticket>> getTicketsForBooking(String bookingId) async {
    await _load();
    return _readTickets()
        .where((ticket) => ticket.bookingId == bookingId)
        .toList();
  }

  @override
  Future<Ticket?> getTicketById(String id) async {
    await _load();
    for (final ticket in _readTickets()) {
      if (ticket.id == id) return ticket;
    }
    return null;
  }

  @override
  Future<List<Ticket>> getMyTickets() async {
    await _load();
    return _readTickets()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Map<String, dynamic> _bookingToJson(Booking b) => {
    'id': b.id,
    'eventId': b.eventId,
    'ticketTypeId': b.ticketTypeId,
    'quantity': b.quantity,
    'unitPriceVnd': b.unitPriceVnd,
    'totalVnd': b.totalVnd,
    'createdAt': b.createdAt.toIso8601String(),
    'status': b.status.name,
  };
  Booking _bookingFromJson(Map<String, dynamic> j) => Booking(
    id: j['id'] as String,
    eventId: j['eventId'] as String,
    ticketTypeId: j['ticketTypeId'] as String,
    quantity: j['quantity'] as int,
    unitPriceVnd: j['unitPriceVnd'] as int,
    totalVnd: j['totalVnd'] as int,
    createdAt: DateTime.parse(j['createdAt'] as String),
    status: BookingStatus.values.byName(j['status'] as String),
  );
  Map<String, dynamic> _ticketToJson(Ticket t) => {
    'id': t.id,
    'bookingId': t.bookingId,
    'eventId': t.eventId,
    'ticketTypeId': t.ticketTypeId,
    'qrPayload': t.qrPayload,
    'createdAt': t.createdAt.toIso8601String(),
    'status': t.status.name,
  };
  Ticket _ticketFromJson(Map<String, dynamic> j) => Ticket(
    id: j['id'] as String,
    bookingId: j['bookingId'] as String,
    eventId: j['eventId'] as String,
    ticketTypeId: j['ticketTypeId'] as String,
    qrPayload: j['qrPayload'] as String,
    createdAt: DateTime.parse(j['createdAt'] as String),
    status: TicketStatus.values.byName(j['status'] as String),
  );
}
