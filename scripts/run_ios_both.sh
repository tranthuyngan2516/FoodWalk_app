#!/bin/bash

# Script để chạy Customer trên iOS Simulator và Driver trên iPhone thật
# Sử dụng: ./scripts/run_ios_both.sh

echo "🍎 Khởi động cả hai ứng dụng FoodWalk trên iOS..."
echo "📱 Customer sẽ chạy trên iOS Simulator"
echo "🚗 Driver sẽ chạy trên iPhone thật"

# Kiểm tra Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter không được cài đặt"
    exit 1
fi

# Kiểm tra vị trí script
if [ ! -f "melos.yaml" ]; then
    echo "❌ Vui lòng chạy script này từ thư mục gốc của dự án"
    exit 1
fi

# Tạo thư mục logs
mkdir -p logs

echo ""
echo "📱 Khởi động Customer App trên iOS Simulator..."
cd apps/customer

# Chạy Customer trên Simulator (sử dụng device ID cụ thể)
flutter run -d "FD1A44FC-AC43-44B2-9164-9279642ABB74" > ../../logs/customer_ios.log 2>&1 &
CUSTOMER_PID=$!
cd ../..

echo "🚗 Khởi động Driver App trên iPhone thật..."
cd apps/driver

# Chạy Driver trên iPhone thật (sử dụng device ID cụ thể)
flutter run -d "00008101-0006613A1499A01E" > ../../logs/driver_ios.log 2>&1 &
DRIVER_PID=$!
cd ../..

echo ""
echo "✅ Cả hai ứng dụng đã được khởi động!"
echo "📱 Customer App: Đang chạy trên iOS Simulator (iPhone 16 Plus)"
echo "🚗 Driver App: Đang chạy trên iPhone thật"
echo ""
echo "📋 Logs được lưu trong thư mục logs/"
echo "🛑 Để dừng cả hai ứng dụng, nhấn Ctrl+C"

# Hàm cleanup
cleanup() {
    echo ""
    echo "🛑 Đang dừng các ứng dụng..."
    kill $CUSTOMER_PID 2>/dev/null
    kill $DRIVER_PID 2>/dev/null
    echo "✅ Đã dừng tất cả ứng dụng"
    exit 0
}

# Bắt sự kiện Ctrl+C
trap cleanup SIGINT

# Chờ người dùng nhấn Ctrl+C
echo "⏳ Đang chạy... Nhấn Ctrl+C để dừng"
wait
