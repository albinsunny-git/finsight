# Setup & Installation Guide - FinSight

This guide provides step-by-step instructions to set up the FinSight project on your local environment.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- **XAMPP / WAMP / MAMP** (Apache & MySQL)
- **PHP 8.0 or higher**
- **Flutter SDK** (for the mobile app)
- **Web Browser** (Chrome or Edge recommended)
- **Code Editor** (VS Code recommended)

---

## 📂 1. Backend Setup (XAMPP)

1.  **Move Files:**
    Copy the entire `finsight` directory into your `C:\xampp\htdocs\` folder.

2.  **Start Services:**
    Open the XAMPP Control Panel and start **Apache** and **MySQL**.

3.  **Create Database:**
    -   Open [phpMyAdmin](http://localhost/phpmyadmin/).
    -   Create a new database named `finsight_db`.
    -   Click on the `Import` tab and select the SQL file from `database/finsight_db.sql`.
    -   Alternatively, run the `database/finsight_tables_summary.sql` to create basic tables.

4.  **Configuration:**
    Open `backend/config/config.php` and update the database credentials if necessary:
    ```php
    define('DB_HOST', '127.0.0.1');
    define('DB_USER', 'root');
    define('DB_PASS', '');
    define('DB_NAME', 'finsight_db');
    ```

5.  **Verify Backend:**
    Navigate to `http://localhost/finsight/backend/api/get_version.php` in your browser. You should see a JSON response.

---

## 📱 2. Mobile App Setup (Flutter)

1.  **Open Folder:**
    Open the `mobile` directory in your IDE or terminal.

2.  **Install Dependencies:**
    Run the following command to download necessary Flutter packages:
    ```bash
    flutter pub get
    ```

3.  **Configure API URL:**
    Open `lib/services/api_service.dart` and update the `baseUrl` based on your environment:
    -   **Android Emulator:** `http://10.0.2.2/finsight/backend/api`
    -   **iOS Simulator:** `http://localhost/finsight/backend/api`
    -   **Physical Device:** Use your computer's local IP (e.g., `http://192.168.1.5/finsight/backend/api`)

4.  **Run the App:**
    ```bash
    flutter run
    ```

---

## 🌐 3. Web Frontend Setup

1.  **Browser Access:**
    The web frontend is served by Apache. You can access it directly at:
    `http://localhost/finsight/`

2.  **Login:**
    Use the default admin credentials if they were seeded in the database, or sign up for a new account.

---

## 📧 4. Email & Google Auth (Optional)

To enable Password Resets and Google Sign-In, update the following constants in `backend/config/config.php`:

-   `MAIL_USER` and `MAIL_PASS`: SMTP credentials.
-   `GOOGLE_CLIENT_ID`: Your Google Cloud Console Client ID.
-   `FIREBASE_*`: Your Firebase project configuration.
