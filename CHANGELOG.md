# Nhật ký thay đổi — EventHub

Ghi kết quả theo từng task, mới nhất ở trên. Chỉ đánh dấu hoàn thành khi có kết quả kiểm thử; nêu rõ phần chưa thực hiện và các giới hạn còn lại.

## [DEMO-06] - 2026-11-11

**Trạng thái:** Hoàn thành.

### Hoàn thành

- Bổ sung dashboard Organizer với số liệu sự kiện, trạng thái xuất bản, booking/vé và tổng giá trị mô phỏng; thêm luồng chuyển vai trò demo, tạo/sửa sự kiện và kho lưu overlay để giữ nguyên 8 seed events và dữ liệu booking.
- Sửa nhãn chế độ mô phỏng trong dashboard để tự xuống dòng ở màn hình hẹp/cỡ chữ lớn. Cập nhật kiểm thử tab Organizer để khớp nội dung dashboard hiện tại.

### Kiểm thử

- `dart format lib test` — thành công; không còn file cần format.
- `flutter analyze` — thành công, không phát hiện vấn đề.
- `flutter test test/organizer_flow_test.dart --reporter expanded` — điều tra cho thấy sau khi chọn vé, giao diện đã ở trang checkout (nội dung và tiêu đề “Đặt vé mô phỏng” xuất hiện; route được mở bằng `push`, nên `routeInformationProvider` vẫn hiển thị `/discovery`). Nút xác nhận nằm dưới phần đang nhìn thấy trong `ListView` checkout; do danh sách con được dựng lười, finder theo key chưa có widget để `ensureVisible` tìm. Khi dùng text finder, phần tử duy nhất đang dựng là tiêu đề app bar, không phải nút. Sửa test để cuộn checkout đến khi nút thật được dựng, rồi xác nhận booking, vé và thống kê dashboard. Bài test luồng đạt.
- `dart format lib test` — thành công, không có file cần format.
- `flutter analyze` — thành công, không phát hiện vấn đề.
- `flutter test` — cả 48 bài đạt. Bao gồm luồng Organizer → tạo/xuất bản → Discovery → booking → dashboard và kiểm tra giao diện ở kích thước hẹp/cỡ chữ lớn.
- `flutter run -d emulator-5554` — build và khởi chạy ứng dụng trên emulator Android 17/API 37 thành công.
- Chủ dự án xác nhận đã tự hoàn thành đủ 8 bước nghiệm thu thủ công trên Android emulator vào ngày 2026-11-11: vào chế độ Organizer, tạo sự kiện kèm loại vé, xuất bản, tìm trên Discovery, đặt vé mô phỏng, kiểm tra vé phát hành, xác nhận số liệu dashboard, đóng hoàn toàn rồi mở lại ứng dụng và xác nhận sự kiện cùng booking vẫn được lưu. Đây là xác nhận của chủ dự án, không phải thao tác do AI thực hiện.
- Tương tác emulator do AI điều khiển không khả dụng vì native pipe lỗi; chủ dự án đã trực tiếp kiểm thử thay thế và xác nhận toàn bộ bước đạt.

### Giới hạn và lưu ý

- Booking/vé và thống kê vẫn chỉ là dữ liệu mô phỏng cục bộ.

## [DEMO-05] - 2026-11-11

**Trạng thái:** Hoàn thành.

### Hoàn thành

- Mở đặt vé từ chi tiết sự kiện: chọn một loại vé, chọn 1–4 vé, xem tồn cục bộ và tổng tiền VND; hỗ trợ vé miễn phí. Kiểm tra sự kiện còn mở, loại vé thuộc sự kiện, số lượng hợp lệ và tồn kho seed cộng vé đã đặt trên thiết bị.
- Thêm `Booking`, `Ticket`, `BookingRepository` và `BookingService`; xác nhận tạo một booking cùng một vé riêng cho từng đơn vị. Ngăn xác nhận lặp trong lúc đang lưu.
- Lưu dữ liệu bằng `SharedPreferencesAsync` trong `LocalBookingRepository`; dữ liệu JSON thiếu/hỏng được xử lý như ví rỗng, không tự xóa khi đọc.
- Thay màn Vé của tôi bằng ví vé sắp xếp mới nhất trước; thêm trang xác nhận và trang chi tiết vé với QR offline qua `qr_flutter`. QR có payload ngẫu nhiên riêng, tiền tố `eventhub-demo:v1:` và không chứa thông tin cá nhân.
- Cập nhật README về cách thử luồng và cách xóa dữ liệu chủ động từ Cài đặt Android; đánh dấu DEMO-05 trong `TASK.md`.

### Kiểm thử

- `dart format lib test` — thành công.
- `flutter analyze` — không phát hiện vấn đề.
- `flutter test` — cả 39 bài kiểm thử đạt; gồm đơn miễn phí/trả phí, số lượng/giá, tồn kho, QR riêng và không chứa dữ liệu cá nhân, lưu/tải lại, dữ liệu hỏng, ví rỗng, xác nhận lặp, QR widget và luồng điều hướng.
- `flutter run -d emulator-5554` — build và chạy trên Pixel 7 emulator (Android 17/API 37).
- Kiểm tra thủ công: đặt 2 vé trả phí và 2 vé miễn phí; mở ví và hai trang QR, mã QR khác nhau; đóng/khởi động lại ứng dụng và xác nhận cả 5 vé còn trong ví.

### Giới hạn và lưu ý

- Booking và tồn vé chỉ là mô phỏng cục bộ; không có thanh toán thật, đồng bộ giữa thiết bị hoặc bảo vệ chống bán vượt tồn trên nhiều thiết bị.
- QR chỉ là vé minh họa, không được máy chủ xác minh; không triển khai quét hoặc check-in.
- Xóa dữ liệu ứng dụng Android sẽ xóa booking/vé đã lưu trên thiết bị. Không có hành động xóa tự động trong ứng dụng.

## [DEMO-04] - 2026-11-11

**Trạng thái:** Hoàn thành.

### Hoàn thành

- Thay màn Khám phá tạm bằng luồng khám phá lấy dữ liệu qua Riverpod/repository: tìm kiếm không phân biệt dấu và hoa thường trên tiêu đề, danh mục, thành phố, mô tả; xóa truy vấn; lọc danh mục; sự kiện nổi bật và danh sách sắp tới theo thời gian.
- Thêm route `/events/:eventId` với ảnh banner, thời gian, địa điểm, nội dung, đơn vị tổ chức và các loại vé có giá VND; sự kiện không tồn tại có trạng thái riêng.
- Thêm nút xem vé để cuộn đến danh sách vé. Nút đặt vé được vô hiệu hóa và ghi rõ phần đặt vé thuộc DEMO-05.
- Tạo và đóng gói 8 ảnh minh họa riêng cho sự kiện trong `assets/images/events/`; ghi nguồn, ngày tạo và cách dùng/fallback trong README của thư mục asset. Không dùng ảnh stock bên ngoài.
- Cập nhật README và đánh dấu DEMO-04 trong `TASK.md`.

### Kiểm thử

- `dart format lib test` — thành công.
- `flutter analyze` — không phát hiện vấn đề.
- `flutter test` — cả 31 bài kiểm thử đạt; gồm tìm kiếm/lọc, chi tiết, không tìm thấy, Back, trạng thái tải, ảnh cục bộ và fallback.
- Kiểm tra widget ở chiều rộng 320, 360, 390, 430 px và cỡ chữ 1,5x.
- `flutter run -d emulator-5554` — build và khởi chạy thành công trên Pixel 7 emulator (Android 17/API 37); đã xem trực quan màn Khám phá và chi tiết sự kiện.

### Giới hạn và lưu ý

- Dữ liệu vẫn là mock cục bộ; chưa có backend hoặc đăng ký/đặt vé. Thao tác đặt vé đang tắt có chủ đích cho đến DEMO-05.
- Ngày sự kiện dùng seed data hư cấu và thời gian cố định; danh sách sắp tới loại bỏ sự kiện đã qua.
- Ảnh là hình minh họa được tạo cho dự án, không phải ảnh chụp địa điểm hay poster chính thức.

## [DEMO-03] - 2026-11-11

**Trạng thái:** Hoàn thành.

### Hoàn thành

- Tạo model `Event`, `TicketType`, danh mục và trạng thái; kiểm tra khoảng thời gian, giá vé, sức chứa, số vé đã bán và quan hệ vé-sự kiện.
- Bổ sung hợp đồng `EventRepository`, `MockEventRepository` và provider Riverpod để có thể thay implementation sau này.
- Chuẩn bị 8 sự kiện mẫu hư cấu, 15 loại vé thuộc 7 danh mục; dữ liệu dùng thời gian UTC cố định và có cả vé miễn phí lẫn vé trả phí.
- Không thêm ảnh không rõ giấy phép hoặc phụ thuộc mạng. Để `bannerAssetPath` trống và kiểm tra ảnh minh họa dự phòng cục bộ sẵn có của `AppEventCard`.
- Cập nhật README hướng dẫn chỉnh seed data; đánh dấu DEMO-03 trong `TASK.md`.

### Kiểm thử

- `dart format lib test` — thành công.
- `flutter analyze` — không phát hiện vấn đề.
- `flutter test` — cả 15 bài kiểm thử đạt, gồm kiểm tra repository, dữ liệu, validation, ảnh dự phòng, điều hướng và giao diện.
- `flutter run -d emulator-5554` — ứng dụng build và khởi chạy thành công trên Pixel 7 emulator (Android 17/API 37).

### Giới hạn và lưu ý

- Dữ liệu hoàn toàn cục bộ, không gọi backend hoặc mạng; cả 8 sự kiện mẫu hiện ở trạng thái đã xuất bản.
- Chưa có banner ảnh thật; thẻ dùng fallback hình minh họa. Có thể bổ sung ảnh được cấp phép sau này bằng `bannerAssetPath`.
- Không triển khai màn Khám phá, tìm kiếm, bộ lọc hoặc chi tiết sự kiện; các phần đó thuộc DEMO-04.

## [DEMO-02] - 2026-11-11

**Trạng thái:** Hoàn thành.

### Hoàn thành

- Áp dụng hướng thiết kế Indigo — Modern Event với màu chính `#4F46E5`, màu nhấn `#7C3AED`, nền sáng và chữ có độ tương phản rõ.
- Tập trung token màu sắc, kiểu chữ, khoảng cách và bo góc; cấu hình theme Material 3 cho màn hình sáng.
- Tạo các thành phần dùng chung: nút, trường nhập, chip danh mục, tiêu đề mục, thẻ sự kiện có ảnh dự phòng và trạng thái trống.
- Làm mới ba màn hình Khám phá, Vé của tôi, Ban tổ chức và thanh điều hướng dưới.
- Thêm trang xem trước thành phần chỉ trong bản debug; không thêm thư viện phụ thuộc.
- Ghi nhận lựa chọn giao diện trong `PLAN.md`, cập nhật `TASK.md` và hướng dẫn xem trước trong `README.md`.

### Kiểm thử

- `dart format lib test` — thành công.
- `flutter analyze` — không phát hiện vấn đề.
- `flutter test` — cả 5 bài kiểm thử đạt; gồm điều hướng, showcase, trạng thái nút, bốn chiều rộng màn hình và cỡ chữ 1,5x.
- `flutter run -d emulator-5554` — khởi chạy thành công trên Pixel 7 emulator (Android 17/API 37).
- Kiểm tra trực quan màn hình Khám phá, Vé của tôi, Ban tổ chức và showcase; thao tác Back từ showcase trở về đúng tab Ban tổ chức.

### Giới hạn và lưu ý

- Chỉ hỗ trợ light theme; dark theme được để dành cho task sau.
- Nội dung ba tab vẫn là trạng thái trống, chưa có dữ liệu sự kiện hay nghiệp vụ.
- Trang showcase chỉ xuất hiện trong bản debug qua biểu tượng bảng màu trên thanh tiêu đề.
- Một số Android SDK license vẫn còn cảnh báo trong `flutter doctor`; emulator vẫn build và chạy ứng dụng được.

## [DEMO-01] - 2026-11-11

**Trạng thái:** Hoàn thành theo báo cáo triển khai; chưa kiểm tra độc lập mã nguồn.

### Hoàn thành

- Khởi tạo dự án Flutter `eventhub_app`, Git nhánh `main`, cấu trúc Android và iOS.
- Thiết lập Material 3, giao diện tiếng Việt, Riverpod 3.5.0 và go_router 18.1.4.
- Tạo ba màn hình tạm: Khám phá, Vé của tôi, Ban tổ chức; thanh điều hướng dưới hoạt động.
- Bổ sung widget test, `README.md` và `docs/demo_scope.md`.

### Kiểm thử

- `flutter pub get` — thành công.
- `dart format .` — thành công.
- `flutter analyze` — không phát hiện vấn đề.
- `flutter test` — toàn bộ bài kiểm thử đạt.
- `flutter build apk --debug --target-platform android-x64` — thành công.
- `flutter run -d emulator-5554` — chạy được trên Pixel 7 emulator, hiển thị màn hình Khám phá.

### Giới hạn và lưu ý

- Các màn hình còn là giao diện tạm; chưa có dữ liệu sự kiện, đăng nhập, đặt vé, QR/check-in, Supabase hoặc Gemini.
- APK debug được tạo cho Android x64, phù hợp emulator hiện tại.
- Một số giấy phép Android SDK chưa được chấp nhận; iOS chưa được chạy thử.
- Kết quả trên được ghi lại từ báo cáo người triển khai, chưa phải kết quả kiểm thử độc lập.


