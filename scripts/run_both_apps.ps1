# Script PowerShell để chạy cả hai ứng dụng FoodWalk (Customer và Driver) cùng lúc
# Sử dụng: .\scripts\run_both_apps.ps1

Write-Host "🚀 Khởi động cả hai ứng dụng FoodWalk..." -ForegroundColor Green

# Kiểm tra xem có Flutter không
try {
    $flutterVersion = flutter --version
    Write-Host "✅ Flutter đã được cài đặt" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter không được cài đặt hoặc không có trong PATH" -ForegroundColor Red
    exit 1
}

# Kiểm tra xem có đang ở thư mục gốc của dự án không
if (-not (Test-Path "melos.yaml")) {
    Write-Host "❌ Vui lòng chạy script này từ thư mục gốc của dự án" -ForegroundColor Red
    exit 1
}

# Tạo thư mục logs nếu chưa có
if (-not (Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs" | Out-Null
}

Write-Host "📱 Khởi động ứng dụng Customer..." -ForegroundColor Yellow
# Chạy ứng dụng customer trong background
Start-Process -FilePath "flutter" -ArgumentList "run", "--web-port=8080" -WorkingDirectory "apps/customer" -WindowStyle Hidden

Write-Host "🚗 Khởi động ứng dụng Driver..." -ForegroundColor Yellow
# Chạy ứng dụng driver trong background
Start-Process -FilePath "flutter" -ArgumentList "run", "--web-port=8081" -WorkingDirectory "apps/driver" -WindowStyle Hidden

Write-Host "✅ Cả hai ứng dụng đã được khởi động!" -ForegroundColor Green
Write-Host "📱 Customer app: http://localhost:8080" -ForegroundColor Cyan
Write-Host "🚗 Driver app: http://localhost:8081" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Để dừng các ứng dụng, hãy đóng terminal hoặc sử dụng Task Manager" -ForegroundColor Yellow
Write-Host "⏳ Các ứng dụng đang chạy trong background..."

# Chờ một chút để ứng dụng khởi động
Start-Sleep -Seconds 5

Write-Host "🎉 Hoàn tất! Bạn có thể mở trình duyệt để test cả hai ứng dụng." -ForegroundColor Green
