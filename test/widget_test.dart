import 'package:eventhub_app/app/router/app_router.dart';
import 'package:eventhub_app/app/app.dart';
import 'package:eventhub_app/app/theme/app_theme.dart';
import 'package:eventhub_app/core/widgets/app_button.dart';
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
  testWidgets('EventHub shows discovery and switches between destinations', (
    tester,
  ) async {
    appRouter.go('/discovery');
    await tester.pumpWidget(const ProviderScope(child: EventHubApp()));

    expect(find.text('EventHub'), findsOneWidget);
    expect(find.text('Khám phá sự kiện'), findsOneWidget);
    expect(
      find.text('Tìm cảm hứng cho trải nghiệm tiếp theo của bạn.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Vé của tôi'));
    await tester.pumpAndSettle();
    expect(find.text('Bạn chưa có vé'), findsOneWidget);

    await tester.tap(find.text('Ban tổ chức'));
    await tester.pumpAndSettle();
    expect(find.text('Quản lý sự kiện'), findsOneWidget);
    expect(
      find.text('Chế độ mô phỏng · Không phải phân quyền thật'),
      findsOneWidget,
    );
    expect(find.text('Tạo sự kiện'), findsOneWidget);
  });

  testWidgets('Debug showcase previews shared EventHub components', (
    tester,
  ) async {
    appRouter.go('/discovery');
    await tester.pumpWidget(const ProviderScope(child: EventHubApp()));

    await tester.tap(find.byTooltip('Xem bộ giao diện'));
    await tester.pumpAndSettle();

    expect(find.text('Bộ giao diện EventHub'), findsOneWidget);
    expect(find.text('Màu sắc'), findsOneWidget);
    expect(find.text('Nút chính'), findsOneWidget);
    expect(find.text('Trường nhập liệu'), findsOneWidget);
    expect(find.text('Thẻ sự kiện'), findsOneWidget);
    expect(find.text('Trạng thái trống'), findsOneWidget);
  });

  testWidgets(
    'Buttons call enabled actions and disable loading and null actions',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Wrap(
              children: [
                AppButton(label: 'Hoạt động', onPressed: () => taps++),
                const AppButton(label: 'Đã tắt', onPressed: null),
                AppButton(
                  label: 'Đang tải',
                  onPressed: () => taps++,
                  isLoading: true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Hoạt động'));
      await tester.pump();
      expect(taps, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final disabledButton = find.ancestor(
        of: find.text('Đã tắt'),
        matching: find.byType(FilledButton),
      );
      final loadingButton = find.ancestor(
        of: find.text('Đang tải'),
        matching: find.byType(FilledButton),
      );
      expect(tester.widget<FilledButton>(disabledButton).onPressed, isNull);
      expect(tester.widget<FilledButton>(loadingButton).onPressed, isNull);
    },
  );

  testWidgets('Main screens fit narrow and standard phone widths', (
    tester,
  ) async {
    for (final width in [320.0, 360.0, 390.0, 430.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      appRouter.go('/discovery');

      await tester.pumpWidget(const ProviderScope(child: EventHubApp()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Width: $width');

      await tester.tap(find.text('Vé của tôi'));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Tickets at width: $width',
      );

      await tester.tap(find.text('Ban tổ chức'));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Organizer at width: $width',
      );
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Screens and component showcase tolerate larger text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 800);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    appRouter.go('/discovery');

    await tester.pumpWidget(const ProviderScope(child: EventHubApp()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Vé của tôi'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Ban tổ chức'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    appRouter.go('/discovery');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Xem bộ giao diện'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    tester.platformDispatcher.clearTextScaleFactorTestValue();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
