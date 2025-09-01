#!/bin/bash

# Script để chạy cả hai ứng dụng FoodWalk (Customer và Driver) cùng lúc
# Sử dụng: ./scripts/run_both_apps.sh

echo "🚀 Khởi động cả hai ứng dụng FoodWalk..."

# Kiểm tra xem có Flutter không
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter không được cài đặt hoặc không có trong PATH"
    exit 1
fi

# Kiểm tra xem có đang ở thư mục gốc của dự án không
if [ ! -f "melos.yaml" ]; then
    echo "❌ Vui lòng chạy script này từ thư mục gốc của dự án"
    exit 1
fi

# Tạo thư mục logs nếu chưa có
mkdir -p logs

echo "📱 Khởi động ứng dụng Customer..."
# Chạy ứng dụng customer trong background
cd apps/customer
flutter run --web-port=8080 > ../../logs/customer.log 2>&1 &
CUSTOMER_PID=$!
cd ../..

echo "🚗 Khởi động ứng dụng Driver..."
# Chạy ứng dụng driver trong background
cd apps/driver
flutter run --web-port=8081 > ../../logs/driver.log 2>&1 &
DRIVER_PID=$!
cd ../..

echo "✅ Cả hai ứng dụng đã được khởi động!"
echo "📱 Customer app: http://localhost:8080"
echo "🚗 Driver app: http://localhost:8081"
echo ""
echo "📋 Logs được lưu trong thư mục logs/"
echo "🛑 Để dừng cả hai ứng dụng, nhấn Ctrl+C"

# Hàm cleanup khi script bị dừng
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
