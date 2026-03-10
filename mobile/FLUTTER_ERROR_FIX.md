# Flutter Setup & Troubleshooting Guide

It appears that the **Flutter SDK** is not recognized in your current terminal. This prevents the app from running or being fully created.

## 1. Install Flutter
If you haven't installed Flutter yet:
1.  Download the Flutter SDK for Windows: [https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
2.  Extract the zip file (e.g., to `C:\src\flutter`).
3.  **Critical Step:** Add `flutter\bin` to your **Environmental Variables Path**.
    *   Search for "Edit the system environment variables" in Windows Search.
    *   Click "Environment Variables".
    *   Under "User variables", select **Path** and click **Edit**.
    *   Click **New** and add the path to `flutter\bin` (e.g., `C:\src\flutter\bin`).
    *   Click OK on all windows.
4.  **Restart your Terminal/VS Code** for changes to take effect.

## 2. Initialize the Project Structure
Since the `flutter` tools were unavailable, I could only create the Dart source code (`lib/` folder) and the configuration (`pubspec.yaml`). The native Android and iOS project files (like `build.gradle`, `AndroidManifest.xml`) are missing.

**Once Flutter is working, run this command in the `mobile` folder:**

```bash
flutter create .
```

This will generate all the missing native files without overwriting the Dart code I wrote for you.

## 3. Run the App
After running `flutter create .`, you can run the app:

```bash
flutter pub get
flutter run
```

## 4. Run Doctor
To verify everything is correct:
```bash
flutter doctor
```
