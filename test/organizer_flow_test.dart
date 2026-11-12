import 'package:eventhub_app/app/app.dart';
import 'package:eventhub_app/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    appRouter.go('/discovery');
  });

  testWidgets(
    'Organizer publishes an event, attendee books it, dashboard stats update',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: EventHubApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Chế độ mô phỏng: Người tham dự'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ban tổ chức · Demo'));
      await tester.pumpAndSettle();
      expect(
        find.text('Chế độ mô phỏng · Không phải phân quyền thật'),
        findsOneWidget,
      );

      final createAction = find.text('Tạo sự kiện');
      await tester.ensureVisible(createAction);
      await tester.pumpAndSettle();
      await tester.tap(createAction);
      await tester.pumpAndSettle();
      await _enter(tester, 'field-title', 'Sự kiện kiểm thử cộng đồng');
      await _enter(tester, 'field-summary', 'Gặp gỡ cộng đồng tại Hà Nội');
      await _enter(
        tester,
        'field-description',
        'Một chương trình minh họa cho bài kiểm thử tích hợp.',
      );
      await _enter(tester, 'field-venue', 'Nhà văn hóa Demo');
      await _enter(tester, 'field-address', '12 Phố Demo');
      await _enter(tester, 'field-city', 'Hà Nội');
      await _enter(tester, 'field-ticketName', 'Vé tiêu chuẩn');
      await _enter(tester, 'field-price', '120000');
      await _enter(tester, 'field-capacity', '20');

      final statusDropdown = find.byKey(const ValueKey('event-status'));
      await tester.ensureVisible(statusDropdown);
      await tester.tap(statusDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Đã xuất bản').last);
      await tester.pumpAndSettle();
      final saveButton = find.byKey(const ValueKey('save-event'));
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Khám phá sự kiện'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Chế độ mô phỏng: Ban tổ chức'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Người tham dự · Demo'));
      await tester.pumpAndSettle();
      final search = find.byKey(const ValueKey('discovery-search-field'));
      await tester.ensureVisible(search);
      await tester.enterText(search, 'Sự kiện kiểm thử cộng đồng');
      await tester.pumpAndSettle();
      final eventTitle = find.text('Sự kiện kiểm thử cộng đồng');
      expect(eventTitle, findsWidgets);
      await tester.tap(eventTitle.last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Chọn vé'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chọn vé'));
      await tester.pumpAndSettle();
      final confirm = find.byKey(const ValueKey('confirm-booking'));
      for (var i = 0; i < 5 && confirm.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(confirm);
      await tester.pumpAndSettle();
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(find.text('Đã tạo vé mô phỏng'), findsOneWidget);
      await tester.tap(find.text('Xem vé của tôi'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Chế độ mô phỏng: Người tham dự'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ban tổ chức · Demo'));
      await tester.pumpAndSettle();

      final ownedEvent = find.text('Sự kiện kiểm thử cộng đồng');
      for (var i = 0; i < 4 && ownedEvent.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      expect(ownedEvent, findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('metric-tickets')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('metric-revenue')),
          matching: find.text('120.000 ₫'),
        ),
        findsOneWidget,
      );
    },
  );
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  final field = find.byKey(ValueKey(key));
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}
