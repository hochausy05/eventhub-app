import 'package:eventhub_app/features/discovery/data/repositories/local_event_repository.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/domain/repositories/event_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => LocalEventRepository(SharedPreferencesAsync()),
);

final publishedEventsProvider = FutureProvider<List<Event>>(
  (ref) => ref.watch(eventRepositoryProvider).getPublishedEvents(),
);

final eventByIdProvider = FutureProvider.family<Event?, String>(
  (ref, id) => ref.watch(eventRepositoryProvider).getEventById(id),
);
