# IPOS POS - Customer QR Ordering App

A modern, responsive Flutter application designed for restaurant customers to order food via QR codes. Built with Flutter, GetX, and Hive for offline-first capabilities.

## 🚀 Key Features

- **QR Code Scanning**: Easily scan restaurant table QR codes to access the menu.
- **Dynamic Menu**: Real-time menu updates with categorization and customization options.
- **Offline Support**: Queue orders when offline and sync them once connectivity is restored.
- **Multi-language Support**: Built-in support for multiple languages.
- **Modern UI**: Smooth animations and responsive design using Flutter Animate and Shimmer.

---

## 🛠 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: `^3.41.9` (Recommended)
- **Dart SDK**: `^3.11.5`
- **CocoaPods** (for iOS development)
- **Android Studio** / **VS Code** with Flutter extensions

---

## ⚙️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/rifqisyarif/ipos-pos.git
cd ipos-pos
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Environment Configuration

The app uses `.env` files for configuration.

1. Copy the example file:
   ```bash
   cp .env.example .env
   ```
2. Open `.env` and configure your `BASE_URL`:
   ```env
   BASE_URL=https://api.yourrestaurant.com
   ```

### 4. Platform Specific Setup

#### **Android**

- Ensure you have the Android SDK installed.
- Minimum SDK Version: `21`
- Target SDK Version: `34`

#### **iOS**

- Navigate to the `ios` directory and install pods:
  ```bash
  cd ios
  pod install
  cd ..
  ```
- Minimum iOS Version: `12.0`

#### **Web**

- Ensure the web platform is enabled in your Flutter installation.
  ```bash
  flutter config --enable-web
  ```

---

## 🏃‍♂️ Running the Project

### Debug Mode

Run the app in debug mode on your connected device or emulator:

```bash
flutter run
```

### Release Builds

#### **Android (APK)**

```bash
flutter build apk --release
```

#### **iOS (IPA)**

```bash
flutter build ipa --release
```

#### **Web**

```bash
flutter build web --release
```

---

## 🧪 Testing

### Run Unit Tests
To run all tests in the `test/` directory:
```bash
flutter test
```

### Run Integration Tests
To run end-to-end integration tests:
```bash
flutter test integration_test
```
or for a specific test file:
```bash
flutter test integration_test/app_test.dart
```

---

## 🏗 Project Structure

- `lib/api/`: API client and network logic.
- `lib/config/`: App configuration and environment variables.
- `lib/local/`: Local storage services (Hive).
- `lib/models/`: Data models and JSON serialization.
- `lib/navigation/`: Route management using GetX.
- `lib/state/`: State management (GetX Controllers).
- `lib/ui/`: UI components and screens.

---

## 📄 License

This project is proprietary and confidential.
