# Piggy Back - Mobile Application

Ứng dụng Flutter cho nền tảng hoàn tiền Piggy Back.

---

## 🚀 Hướng dẫn Build APK Android & Xuất ra Desktop

### 1. Lệnh nhanh (Build Release & tự động copy ra Desktop)

Chạy lệnh sau tại thư mục `BuyBack-NexoraVN-Mobile`:

```bash
flutter build apk --release && cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/PiggyBack.apk
```

Sau khi build xong, file `PiggyBack.apk` sẽ tự động xuất hiện ngay trên **Desktop** của bạn để dễ dàng kéo thả gửi qua Zalo / Telegram / Drive.

---

### 2. Các tùy chọn build khác

#### A. Build APK tách theo kiến trúc chip (Dung lượng nhẹ hơn ~50%)
```bash
flutter build apk --release --split-per-abi
```
File APK cho từng dòng máy sẽ nằm tại:
- Máy Android đời mới (phổ biến nhất): `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- Copy ra Desktop:
  ```bash
  cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk ~/Desktop/PiggyBack-arm64.apk
  ```

#### B. Build chỉ định Server API tùy ý (không cần sửa code)
Mặc định app đã trỏ tới server mới: `http://14.225.224.82:3001/api/v1`. Nếu muốn đổi endpoint khác:
```bash
flutter build apk --release --dart-define=API_BASE_URL=http://14.225.224.82:3001/api/v1 && cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/PiggyBack.apk
```

---

## 🛠 Khắc phục sự cố khi build

Nếu gặp lỗi cache hoặc thư viện không đồng bộ, hãy chạy:
```bash
flutter clean
flutter pub get
flutter build apk --release && cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/PiggyBack.apk
```
