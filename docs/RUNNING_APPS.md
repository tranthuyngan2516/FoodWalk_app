# 🚀 Hướng dẫn chạy cả hai ứng dụng FoodWalk cùng lúc

## 📋 Tổng quan

Dự án FoodWalk bao gồm hai ứng dụng Flutter chính:

- **Customer App** (`apps/customer`): Ứng dụng dành cho khách hàng
- **Driver App** (`apps/driver`): Ứng dụng dành cho tài xế

## 🎯 Cách chạy cả hai ứng dụng cùng lúc

### Phương pháp 1: Sử dụng Melos (Khuyến nghị)

```bash
# Cài đặt dependencies
melos bootstrap

# Chạy cả hai ứng dụng cùng lúc
melos run run:both

# Hoặc chạy từng ứng dụng riêng biệt
melos run run:customer  # Chạy Customer app
melos run run:driver    # Chạy Driver app
```

### Phương pháp 2: Sử dụng Script tự động

#### Trên macOS/Linux:

```bash
# Làm cho script có thể thực thi
chmod +x scripts/run_both_apps.sh

# Chạy script
./scripts/run_both_apps.sh
```

#### Trên Windows:

```powershell
# Chạy script PowerShell
.\scripts\run_both_apps.ps1
```

### Phương pháp 3: Chạy thủ công

#### Terminal 1 - Customer App:

```bash
cd apps/customer
flutter run --web-port=8080
```

#### Terminal 2 - Driver App:

```bash
cd apps/driver
flutter run --web-port=8081
```

## 🌐 Truy cập ứng dụng

Sau khi chạy thành công:

- **Customer App**: http://localhost:8080
- **Driver App**: http://localhost:8081

## 🔧 Troubleshooting

### Lỗi thường gặp:

1. **Port đã được sử dụng**:

   ```bash
   # Kiểm tra port nào đang được sử dụng
   lsof -i :8080
   lsof -i :8081

   # Hoặc sử dụng port khác
   flutter run --web-port=8082
   ```

2. **Dependencies chưa được cài đặt**:

   ```bash
   melos bootstrap
   cd apps/customer && flutter pub get
   cd ../driver && flutter pub get
   ```

3. **Flutter không được cài đặt**:
   ```bash
   # Cài đặt Flutter
   # Xem hướng dẫn tại: https://flutter.dev/docs/get-started/install
   ```

### Kiểm tra trạng thái ứng dụng:

```bash
# Kiểm tra các process Flutter đang chạy
ps aux | grep flutter

# Kiểm tra logs
tail -f logs/customer.log
tail -f logs/driver.log
```

## 📱 Test trên thiết bị thật

### Android:

```bash
# Customer app
cd apps/customer
flutter run -d android

# Driver app (terminal khác)
cd apps/driver
flutter run -d android
```

### iOS:

```bash
# Customer app
cd apps/customer
flutter run -d ios

# Driver app (terminal khác)
cd apps/driver
flutter run -d ios
```

## 🎉 Tips và Tricks

1. **Sử dụng VS Code**: Mở hai terminal riêng biệt để chạy từng ứng dụng
2. **Hot Reload**: Cả hai ứng dụng đều hỗ trợ hot reload khi bạn sửa code
3. **Debug**: Bạn có thể debug cả hai ứng dụng cùng lúc
4. **State Management**: Cả hai ứng dụng đều sử dụng Riverpod để quản lý state

## 📚 Tài liệu tham khảo

- [Flutter Documentation](https://flutter.dev/docs)
- [Melos Documentation](https://melos.invertase.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
