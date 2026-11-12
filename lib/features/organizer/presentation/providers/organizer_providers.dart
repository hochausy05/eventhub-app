import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/presentation/providers/event_providers.dart';
import 'package:eventhub_app/features/organizer/domain/services/event_management_service.dart';
import 'package:eventhub_app/features/tickets/presentation/providers/booking_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DemoRole { attendee, organizer }

class DemoRoleController extends Notifier<DemoRole> {
  @override
  DemoRole build() => DemoRole.attendee;

  void select(DemoRole role) => state = role;
}

final demoRoleProvider = NotifierProvider<DemoRoleController, DemoRole>(
  DemoRoleController.new,
);

final allEventsProvider = FutureProvider<List<Event>>(
  (ref) => ref.watch(eventRepositoryProvider).getAllEvents(),
);

final organizerEventsProvider = FutureProvider<List<Event>>((ref) async {
  final events = await ref.watch(eventRepositoryProvider).getAllEvents();
  return events.where((event) => event.organizerId == demoOrganizerId).toList()
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
});

final eventManagementServiceProvider = Provider<EventManagementService>(
  (ref) => EventManagementService(
    events: ref.watch(eventRepositoryProvider),
    bookings: ref.watch(bookingRepositoryProvider),
  ),
);
