import 'dart:async';

import 'package:eventhub_app/app/app.dart';
import 'package:eventhub_app/app/router/app_router.dart';
import 'package:eventhub_app/features/discovery/data/mock/sample_events.dart';
import 'package:eventhub_app/features/discovery/domain/entities/event.dart';
import 'package:eventhub_app/features/discovery/presentation/providers/event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );
  testWidgets('Discovery displays mock events and featured section', (
    tester,
  ) async {
    appRouter.go('/discovery');
    await tester.pumpWidget(const ProviderScope(child: EventHubApp()));
    await tester.pumpAndSettle();

    expect(find.text('Sự kiện nổi bật'), findsOneWidget);
    expect(find.text('Sự kiện sắp diễn ra'), findsOneWidget);
    expect(find.text('Saigon Tech Meetup: AI trong đời sống'), findsWidgets);
    expect(find.byType(Image), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Search is connected to events and can be cleared', (
    tester,
  ) async {
    appRouter.go('/discovery');
    await tester.pumpWidget(const ProviderScope(child: EventHubApp()));
    await tester.pumpAndSettle();

    final search = find.byKey(const ValueKey('discovery-search-field'));
    await tester.enterText(search, '  khởi nghiệp  ');
    await tester.pumpAndSettle();

    expect(find.text('Ngày hội ý tưởng khởi nghiệp Đà Nẵng'), findsWidgets);
    expect(find.text('Đêm nhạc indie bên hiên'), findsNothing);

    await tester.enterText(search, 'khong co su kien nay');
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy sự kiện'), findsOneWidget);

    final clearButton = find.text('Xóa tìm kiếm và bộ lọc');
    await tester.ensureVisible(clearButton);
    await tester.tap(clearButton);
    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy sự kiện'), findsNothing);
    expect(find.text('Đêm nhạc indie bên hiên'), findsWidgets);
  });

  testWidgets('Category chips filter the visible list', (tester) async {
    appRouter.go('/discovery');
    await tester.pumpWidget(const ProviderScope(child: EventHubApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Âm nhạc').first);
    await tester.pumpAndSettle();

    expect(find.text('Đêm nhạc indie bên hiên'), findsWidgets);
    expect(find.text('Saigon Tech Meetup: AI trong đời sống'), findsNothing);
  });

  testWidgets('event card opens details with the event tickets and organizer', (
    tester,
  ) async {
    appRouter.go('/discovery');
    await tester.pumpWidget(const ProviderScope(child: EventHubApp()));
    await tester.pumpAndSettle();

    final eventTitle = find.text('Đêm nhạc indie bên hiên').first;
    await tester.ensureVisible(eventTitle);
    await tester.tap(eventTitle);
    await tester.pumpAndSettle();

    expect(find.text('Đêm nhạc indie bên hiên'), findsOneWidget);
    expect(find.text('Saigon Sounds'), findsOneWidget);
    expect(find.text('Vé phổ thông'), findsOneWidget);
    expect(find.text('Vé chỗ ngồi'), findsOneWidget);
    expect(find.text('280.000 ₫'), findsOneWidget);
    expect(find.text('420.000 ₫'), findsOneWidget);
    expect(find.text('Chọn vé'), findsWidgets);
    expect(find.textContaining('Đặt vé mô phỏng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android Back returns to discovery with search state intact', (
    tester,
  ) async {
    appRouter.go('/discovery');
    await tester.pumpWidget(const ProviderScope(child: EventHubApp()));
    await tester.pumpAndSettle();

    final search = find.byKey(const ValueKey('discovery-search-field'));
    await tester.enterText(search, 'ha noi');
    await tester.pumpAndSettle();
    expect(find.text('Ngày hội món ngon ba miền'), findsWidgets);

    final eventTitle = find.text('Ngày hội món ngon ba miền').first;
    await tester.ensureVisible(eventTitle);
    await tester.tap(eventTitle);
    await tester.pumpAndSettle();
    expect(find.text('Vé thử món'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('discovery-search-field')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextField>(
            find.descendant(of: search, matching: find.byType(TextField)),
          )
          .controller!
          .text,
      'ha noi',
    );
    expect(find.text('Ngày hội món ngon ba miền'), findsWidgets);
  });

  testWidgets('unknown event IDs show a not-found state', (tester) async {
    appRouter.go('/events/not-a-real-event');
    await tester.pumpWidget(const ProviderScope(child: EventHubApp()));
    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy sự kiện'), findsOneWidget);
    expect(find.text('Về khám phá'), findsOneWidget);
  });

  testWidgets('loading state is visible while events are loading', (
    tester,
  ) async {
    final eventsCompleter = Completer<List<Event>>();
    appRouter.go('/discovery');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          publishedEventsProvider.overrideWith((ref) => eventsCompleter.future),
        ],
        child: const EventHubApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    eventsCompleter.complete(sampleEvents);
    await tester.pumpAndSettle();
    expect(find.text('Sự kiện nổi bật'), findsOneWidget);
  });

  testWidgets(
    'discovery and detail layouts fit narrow screens and large text',
    (tester) async {
      for (final width in [320.0, 360.0, 390.0, 430.0]) {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        appRouter.go('/discovery');

        await tester.pumpWidget(const ProviderScope(child: EventHubApp()));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Discovery width $width',
        );

        final eventTitle = find.text('Xưởng tư duy thiết kế thực hành').first;
        await tester.ensureVisible(eventTitle);
        await tester.tap(eventTitle);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Details width $width');
      }

      tester.view.physicalSize = const Size(320, 900);
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      appRouter.go('/events/evt-indie-music-night');
      await tester.pumpWidget(const ProviderScope(child: EventHubApp()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Details at 1.5x text');

      tester.platformDispatcher.clearTextScaleFactorTestValue();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );
}
