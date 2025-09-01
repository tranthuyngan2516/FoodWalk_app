# FoodWalk Monorepo Starter (v1.0)

> Flutter/Dart monorepo cho 2 ứng dụng: **Customer** & **Driver**, kèm packages dùng chung.
> Tối ưu cho **macOS** + VS Code. Phù hợp để học theo sách *FoodWalk* và phát triển nhánh theo cách của bạn.

## Cấu trúc
```
foodwalk/
  apps/
    customer/
    driver/
  packages/
    core/
    design_system/
    features_auth/
    features_orders/
    features_maps/
  docs/
    FoodWalk_Book_v1.0.docx
  .vscode/
  analysis_options.yaml
  melos.yaml (tùy chọn)
  scripts/setup.sh
```

## Yêu cầu
- macOS + Xcode (đã mở ít nhất 1 lần), Android Studio (có AVD)
- Flutter SDK (khuyên dùng FVM), Dart 3+
- VS Code + extensions: Dart, Flutter

## Bắt đầu nhanh (không dùng Melos)
```bash
# 1) Mỗi app cần platform folders (ios/, android/). Tạo bằng:
cd apps/customer && flutter create . && flutter pub get
cd ../driver && flutter create . && flutter pub get

# 2) Chạy thử
cd ../customer && flutter run -d ios   # simulator iOS
# hoặc
flutter run -d android                 # emulator Android
```

## Bắt đầu nhanh (có Melos - **khuyến nghị**)
```bash
# Cài melos (một lần)
dart pub global activate melos

# Bootstrap toàn bộ monorepo
melos bootstrap

# Tạo platform folders cho 2 app (mỗi app chạy 1 lần)
melos exec --scope="customer" -- flutter create .
melos exec --scope="driver"   -- flutter create .

# Chạy app khách
cd apps/customer && flutter run -d ios
```

## Biến môi trường & API keys
- Tạo file `.env` (hoặc dùng flavors) cho API keys (Firebase, Google Maps).
- **Không commit** khóa bí mật.

## Lỗi thường gặp (tóm tắt)
- **iOS bản đồ xám**: sai/thiếu Google Maps API key hoặc chưa bật Maps SDK.
- **CocoaPods base configuration**: mở `ios/Runner.xcworkspace` → Product > Clean Build Folder → `pod install`.
- **Push iOS không tới**: thiếu APNs key .p8 trong Firebase, chưa xin quyền.
- Xem thêm `docs/TROUBLESHOOTING.md` hoặc chương “Lỗi phổ biến” trong sách.

---
© Bạn sở hữu dự án này. Hãy chỉnh sửa theo ý bạn.
