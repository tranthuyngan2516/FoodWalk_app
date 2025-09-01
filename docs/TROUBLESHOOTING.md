# FoodWalk — Lỗi phổ biến & cách khắc phục (dành cho người mới)

## iOS
- **Bản đồ xám / không hiển thị**: Sai/thiếu Google Maps API key; chưa bật Maps SDK iOS; thiếu cấu hình trong `Info.plist`.
- **Không nhận Push**: Thiếu APNs key .p8 trong Firebase; chưa xin quyền thông báo; app ở foreground cần hiển thị local notifications.

## Android
- **GPS nền bị tắt**: Chưa dùng Foreground Service; hệ thống tối ưu pin. Tạo notification cố định khi gửi GPS.
- **Build release lỗi minify**: Thiếu proguard rules cho Google Play Services/Maps.

## CocoaPods/Xcode
- **did not set the base configuration**: Mở `ios/Runner.xcworkspace` → Product > Clean Build Folder → `pod install` lại.
- **Không generate được ios/**: Chưa chạy `flutter create .` trong thư mục app.

## Firebase
- **Auth/Firestore bị chặn**: Rules đang quá chặt; kiểm tra user đã login chưa.
- **Messaging không tới**: Kiểm tra token đăng ký; thử gửi test message từ Firebase Console.

Xem thêm: chương 20 trong sách FoodWalk.
