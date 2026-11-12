# EventHub

EventHub là ứng dụng Flutter khám phá sự kiện và quản lý vé điện tử. **Demo v0.1** khởi tạo nền tảng đa nền tảng.

## Công nghệ

- Flutter / Dart
- Material 3 và localization tiếng Việt
- Riverpod (`flutter_riverpod`)
- Điều hướng (`go_router`)
- Backend dự kiến: Supabase và PostgreSQL (chưa kết nối)

## Yêu cầu môi trường

- Flutter Stable và Dart theo ràng buộc trong `pubspec.yaml`
- Android SDK, Android Studio và Android emulator hoặc thiết bị Android để chạy Android
- Xcode trên macOS để build/chạy iOS

## Cài dependencies và chạy

```bash
flutter pub get
flutter run
```

Chọn thiết bị Android đang kết nối nếu cần:

```bash
flutter devices
flutter run -d <device-id>
```

## Kiểm thử và phân tích

```bash
dart format .
flutter analyze
flutter test
```

## Cấu trúc chính

```text
lib/
├── app/                 # Cấu hình ứng dụng, router, theme
├── core/theme/          # Token màu sắc, khoảng cách và bo góc
├── core/widgets/        # Component và widget dùng chung
├── features/            # Các feature theo hướng feature-first
└── main.dart            # Entry point và ProviderScope
test/                    # Widget tests
docs/                    # Tài liệu phạm vi demo
```

## Chức năng hiện có

- Điều hướng dưới cùng giữa Khám phá, Vé của tôi và Ban tổ chức.
- Material 3, light theme Indigo và locale tiếng Việt.
- Component dùng chung: nút, trường nhập, chip danh mục, tiêu đề mục, thẻ sự kiện và trạng thái trống.
- Trong bản debug, chạm biểu tượng bảng màu trên thanh tiêu đề để mở trang xem trước design system. Lối tắt và trang xem trước không có trong bản release.
- Có 8 sự kiện mẫu hư cấu, được cung cấp qua repository cục bộ.
- Homepage hỗ trợ tìm kiếm (không phân biệt dấu/hoa thường), lọc danh mục, xem sự kiện nổi bật và mở chi tiết.
- Có thể chọn một loại vé, đặt 1–4 vé mô phỏng, xem tổng tiền VND và xác nhận đơn miễn phí hoặc trả phí. Không phát sinh thanh toán thực tế.
- Booking và từng vé được lưu cục bộ bằng `shared_preferences` (API bất đồng bộ); ví hiển thị vé mới trước. QR được tạo offline và giữ nguyên sau khi mở lại app.
- QR chỉ là mã trình diễn, không được máy chủ xác minh và không chứng minh quyền vào sự kiện.

## Chỉnh sửa dữ liệu sự kiện demo

- Dữ liệu mẫu nằm trong `lib/features/discovery/data/mock/sample_events.dart`.
- Model sự kiện, loại vé và hợp đồng repository nằm trong `lib/features/discovery/domain/`.
- Cập nhật sự kiện hoặc giá vé bằng các giá trị VND nguyên; thời gian seed dùng `DateTime.utc` để kết quả ổn định giữa máy và bài kiểm thử.
- `bannerAssetPath` để `null` khi chưa có ảnh được cấp phép. Widget ảnh hiển thị hình minh họa dự phòng cục bộ; repository không tải dữ liệu qua mạng.
- Repository mẫu được cung cấp qua `eventRepositoryProvider` tại `lib/features/discovery/presentation/providers/event_providers.dart`.
- Banner cục bộ và nguồn tạo ảnh được ghi trong [`assets/images/events/README.md`](assets/images/events/README.md). Muốn đổi ảnh, thay file cùng tên hoặc cập nhật đường dẫn `bannerAssetPath` và danh sách assets trong `pubspec.yaml`.

## Thử luồng đặt vé

1. Mở một sự kiện trong tab **Khám phá** và chọn loại vé.
2. Chọn số lượng từ 1 đến 4, xem tổng tiền rồi nhấn **Xác nhận đặt vé**.
3. Xem xác nhận, mở **Vé của tôi** và chạm từng vé để xem QR.
4. Đóng/mở lại ứng dụng; vé vẫn nằm trong ví trên cùng thiết bị.

Để xóa dữ liệu demo theo cách chủ động, mở **Cài đặt Android → Ứng dụng → EventHub → Bộ nhớ → Xóa dữ liệu**. Thao tác này xóa dữ liệu cục bộ của ứng dụng trên thiết bị; ứng dụng không tự đặt lại dữ liệu.

## Chưa triển khai

Bản demo chưa có backend, đăng nhập, thanh toán, đồng bộ tồn vé giữa nhiều thiết bị, xác thực QR/check-in hoặc tư vấn Gemini. Lộ trình demo nằm trong [`docs/demo_scope.md`](docs/demo_scope.md).
