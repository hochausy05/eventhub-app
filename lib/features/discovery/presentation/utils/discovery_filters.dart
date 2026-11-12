import 'package:eventhub_app/features/discovery/domain/entities/event.dart';

const _accentGroups = <String, String>{
  'a': 'àáạảãâầấậẩẫăằắặẳẵ',
  'e': 'èéẹẻẽêềếệểễ',
  'i': 'ìíịỉĩ',
  'o': 'òóọỏõôồốộổỗơờớợởỡ',
  'u': 'ùúụủũưừứựửữ',
  'y': 'ỳýỵỷỹ',
  'd': 'đ',
};

final _accentMap = <String, String>{
  for (final entry in _accentGroups.entries)
    for (final character in entry.value.split('')) character: entry.key,
};

String normalizeEventSearchText(String value) {
  final lowerCase = value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  return lowerCase
      .split('')
      .map((character) => _accentMap[character] ?? character)
      .join();
}

List<Event> filterEvents({
  required Iterable<Event> events,
  String query = '',
  EventCategory? category,
}) {
  final normalizedQuery = normalizeEventSearchText(query);
  final queryWords = normalizedQuery
      .split(' ')
      .where((word) => word.isNotEmpty)
      .toList();

  return events.where((event) {
    if (category != null && event.category != category) return false;
    if (queryWords.isEmpty) return true;

    final searchableText = normalizeEventSearchText(
      '${event.title} ${event.category.label} ${event.city} ${event.summary}',
    );
    return queryWords.every(searchableText.contains);
  }).toList();
}

List<Event> getFeaturedEvents(Iterable<Event> events, {int limit = 3}) {
  final featured = events.where((event) => event.isFeatured).toList()
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  return featured.take(limit).toList();
}

List<Event> getUpcomingEvents(Iterable<Event> events, {DateTime? now}) {
  final referenceTime = (now ?? DateTime.now()).toUtc();
  final upcoming =
      events
          .where((event) => event.startsAt.toUtc().isAfter(referenceTime))
          .toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  return upcoming;
}

String formatEventDateTime(DateTime value) {
  final date = value.toLocal();
  const weekdays = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ nhật',
  ];
  final weekday = weekdays[date.weekday - 1];
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$weekday, $day/$month/${date.year} · $hour:$minute';
}

String formatVnd(int amount) {
  if (amount < 0) throw ArgumentError.value(amount, 'amount');
  final digits = amount.toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return amount == 0 ? 'Miễn phí' : '$grouped ₫';
}
