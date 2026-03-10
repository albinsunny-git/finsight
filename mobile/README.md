# FinSight Mobile App

This is the Flutter mobile application for FinSight.

## Getting Started

1. Ensure you have [Flutter installed](https://docs.flutter.dev/get-started/install).
2. Open this folder in your terminal.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` to launch the app on your connected device or emulator.

## Configuration

The API URL is configured in `lib/services/api_service.dart`.
- default: `http://10.0.2.2/finsight/backend/api` (for Android Emulator to localhost)
- If running on a physical device, update this IP to your computer's local IP address (e.g., `192.168.1.5`).

## Dependencies

- http
- google_fonts
- flutter_animate
- shared_preferences
