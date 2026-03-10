# FinSight - Professional Accounting Software

FinSight is a comprehensive accounting and financial management platform designed for professionals to manage financial records with ease, accuracy, and security.

![FinSight Banner](https://img.shields.io/badge/FinSight-Accounting-blue?style=for-the-badge)

## 🚀 Overview

FinSight provides a robust suite of tools for financial tracking, reporting, and analysis. It consists of a web-based frontend, a PHP-powered REST API, and a cross-platform Flutter mobile application.

### Key Features

-   📊 **Financial Reporting:** Real-time Balance Sheets and Profit & Loss (P&L) statements.
-   🎫 **Voucher Management:** Streamlined processing of financial vouchers.
-   🔐 **Security:** Role-based Access Control (RBAC) and comprehensive Audit Trails.
-   📈 **Analytics:** Dashboards for real-time financial insights.
-   📱 **Multi-platform:** Accessible via Web and Mobile (Android/iOS).

---

## 🛠 Tech Stack

| Component     | Technology                                      |
| ------------- | ----------------------------------------------- |
| **Backend**   | PHP (REST API), MySQL                           |
| **Frontend**  | HTML5, CSS3, Vanilla JavaScript                 |
| **Mobile**    | Flutter (Dart)                                  |
| **Auth**      | JWT / Token-based, Google Sign-In               |
| **Server**    | XAMPP / Apache                                  |

---

## 📁 Project Structure

```text
finsight/
├── backend/          # PHP REST API project
│   ├── api/          # API endpoints (auth, vouchers, reports, etc.)
│   ├── config/       # Database and system configurations
│   └── uploads/      # User-uploaded files (profile pictures, etc.)
├── frontend/         # Web-based frontend application
│   ├── css/          # Stylesheets
│   ├── js/           # Application logic
│   └── pages/        # HTML templates for different views
├── mobile/           # Flutter mobile application
│   ├── lib/          # Dart source code
│   └── assets/       # App assets (images, fonts)
├── database/         # Database schema and migration scripts
└── README.md         # Project documentation
```

---

## 🛠 Setup & Installation

Detailed setup instructions can be found in the [Setup Guide](./docs/setup_guide.md).

### Quick Start (Backend)
1. Move the `finsight` folder to your XAMPP `htdocs` directory.
2. Import the database schema from `/database/`.
3. Configure database credentials in `backend/config/db.php`.

### Quick Start (Mobile)
1. Navigate to the `mobile` directory.
2. Run `flutter pub get`.
3. Configure the API URL in `lib/services/api_service.dart`.
4. Run `flutter run`.

---

## 📖 Documentation

-   [Architecture Overview](./docs/architecture.md)
-   [API Documentation](./docs/api_documentation.md)
-   [Setup & Installation Guide](./docs/setup_guide.md)
-   [Feature Breakdown](./docs/features.md)

---

## 📄 License

This project is proprietary and confidential.
