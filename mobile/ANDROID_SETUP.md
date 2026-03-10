# Android App Setup Instructions

## 1. Firebase Configuration (CRITICAL)
The app requires Firebase to be configured for Google Sign-In and Authentication.

1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Select your project (`finsight-159e0`).
3.  Add an Android App to the project.
    *   **Package Name**: `com.example.finsight_mobile` (Check `android/app/build.gradle` to confirm, usually `applicationId`).
    *   **Debug Signing Certificate SHA-1**: Run `cd mobile/android && ./gradlew signingReport` to get this. Required for Google Sign-In.
4.  Download variables `google-services.json`.
5.  Place the `google-services.json` file in: `mobile/android/app/google-services.json`.

## 2. Enable Authentication
1.  In Firebase Console, go to **Authentication** > **Sign-in method**.
2.  Enable **Google**.
3.  Ensure your support email is set.

## 3. Backend Connection
The app connects to `http://127.0.0.1:8080/finsight/backend/api` by default for Android devices (via `api_service.dart`).
*   **Emulator/Physical Device**: You must run:
    ```bash
    adb reverse tcp:8080 tcp:80
    ```
    This proxies the phone's port 8080 to your computer's port 80 (where XAMPP is).

## 4. Build and Run
```bash
flutter pub get
flutter run
```
