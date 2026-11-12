import 'dart:convert';
import 'dart:math';

import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/domain/entities/ticket_type.dart';
import 'package:eventhub_app/features/discovery/domain/repositories/event_repository.dart';
import 'package:eventhub_app/features/tickets/domain/entities/booking.dart';
import 'package:eventhub_app/features/tickets/domain/repositories/booking_repository.dart';

const demoOrganizerId = 'org-eventhub-demo';
const demoOrganizerName = 'Ban tổ chức Demo';

class EventManagementService {
  EventManagementService({
    required this.events,
    required this.bookings,
    Random? random,
  }) : _random = random ?? Random.secure();

  final EventRepository events;
  final BookingRepository bookings;
  final Random _random;

  String _token() => base64Url
      .encode(List<int>.generate(18, (_) => _random.nextInt(256)))
      .replaceAll('=', '');

  Event createEvent({
    required String title,
    required String summary,
    required String description,
    required EventCategory category,
    required String venueName,
    required String address,
    required String city,
    required DateTime startsAt,
    required DateTime endsAt,
    required String? bannerAssetPath,
    required EventStatus status,
    required String ticketName,
    required int priceVnd,
    required int capacity,
    DateTime? now,
  }) {
    _validateText(
      title,
      summary,
      description,
      venueName,
      address,
      city,
      ticketName,
    );
    _validateDates(
      startsAt,
      endsAt,
      now ?? DateTime.now(),
      requireFuture: status == EventStatus.published,
    );
    if (priceVnd < 0) throw EventManagementException('Giá vé không được âm.');
    if (capacity <= 0) {
      throw EventManagementException('Sức chứa phải lớn hơn 0.');
    }
    if (status == EventStatus.cancelled) {
      throw EventManagementException(
        'Sự kiện mới chỉ có thể ở trạng thái nháp hoặc đã xuất bản.',
      );
    }
    final eventId = 'evt_demo_${_token()}';
    return Event(
      id: eventId,
      organizerId: demoOrganizerId,
      organizerName: demoOrganizerName,
      title: title.trim(),
      summary: summary.trim(),
      description: description.trim(),
      category: category,
      venueName: venueName.trim(),
      address: address.trim(),
      city: city.trim(),
      startsAt: startsAt,
      endsAt: endsAt,
      bannerAssetPath: bannerAssetPath,
      isFeatured: false,
      status: status,
      ticketTypes: [
        TicketType(
          id: 'tkt_demo_${_token()}',
          eventId: eventId,
          name: ticketName.trim(),
          priceVnd: priceVnd,
          capacity: capacity,
          soldQuantity: 0,
        ),
      ],
    );
  }

  Future<void> updateEvent({
    required Event original,
    required Event edited,
    DateTime? now,
  }) async {
    if (original.organizerId != demoOrganizerId ||
        edited.organizerId != original.organizerId ||
        edited.id != original.id) {
      throw EventManagementException(
        'Bạn chỉ có thể chỉnh sửa sự kiện của chế độ demo.',
      );
    }
    _validateText(
      edited.title,
      edited.summary,
      edited.description,
      edited.venueName,
      edited.address,
      edited.city,
      'vé',
    );
    _validateDates(edited.startsAt, edited.endsAt, now ?? DateTime.now());
    await _validateBookedCapacity(edited);
    if (!_sameTicketTypes(original.ticketTypes, edited.ticketTypes)) {
      throw EventManagementException(
        'Loại vé hiện có được giữ nguyên khi chỉnh sửa sự kiện.',
      );
    }
    await events.updateEvent(edited);
  }

  Future<void> _validateBookedCapacity(Event event) async {
    final allBookings = await bookings.getBookings();
    for (final type in event.ticketTypes) {
      final localBooked = allBookings
          .where(
            (booking) =>
                booking.eventId == event.id &&
                booking.ticketTypeId == type.id &&
                booking.status == BookingStatus.confirmed,
          )
          .fold<int>(0, (sum, booking) => sum + booking.quantity);
      if (type.capacity < type.soldQuantity + localBooked) {
        throw EventManagementException(
          'Sức chứa không thể thấp hơn số vé đã bán hoặc đã đặt.',
        );
      }
    }
  }

  bool _sameTicketTypes(List<TicketType> a, List<TicketType> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      final left = a[index];
      final right = b[index];
      if (left.id != right.id ||
          left.eventId != right.eventId ||
          left.name != right.name ||
          left.priceVnd != right.priceVnd ||
          left.capacity != right.capacity ||
          left.soldQuantity != right.soldQuantity) {
        return false;
      }
    }
    return true;
  }

  void _validateText(
    String title,
    String summary,
    String description,
    String venue,
    String address,
    String city,
    String ticketName,
  ) {
    if (title.trim().isEmpty) {
      throw EventManagementException('Vui lòng nhập tên sự kiện.');
    }
    if (summary.trim().isEmpty) {
      throw EventManagementException('Vui lòng nhập mô tả ngắn.');
    }
    if (description.trim().isEmpty) {
      throw EventManagementException('Vui lòng nhập nội dung sự kiện.');
    }
    if (venue.trim().isEmpty) {
      throw EventManagementException('Vui lòng nhập địa điểm.');
    }
    if (address.trim().isEmpty) {
      throw EventManagementException('Vui lòng nhập địa chỉ.');
    }
    if (city.trim().isEmpty) {
      throw EventManagementException('Vui lòng nhập thành phố.');
    }
    if (ticketName.trim().isEmpty) {
      throw EventManagementException('Vui lòng nhập tên loại vé.');
    }
  }

  void _validateDates(
    DateTime startsAt,
    DateTime endsAt,
    DateTime now, {
    bool requireFuture = false,
  }) {
    if (!startsAt.isBefore(endsAt)) {
      throw EventManagementException(
        'Thời gian kết thúc phải sau thời gian bắt đầu.',
      );
    }
    if (requireFuture && !startsAt.isAfter(now)) {
      throw EventManagementException(
        'Sự kiện đã xuất bản cần có ngày bắt đầu trong tương lai.',
      );
    }
  }
}

class EventManagementException implements Exception {
  const EventManagementException(this.message);
  final String message;
  @override
  String toString() => message;
}
