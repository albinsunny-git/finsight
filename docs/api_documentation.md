# API Documentation - FinSight

The FinSight API is a RESTful interface built with PHP. All requests and responses use the `application/json` content type.

## 🔗 Base URL
`http://localhost/finsight/backend/api`

---

## 🔐 Authentication (`auth.php`)

| Endpoint           | Method | Action (`?action=`) | Description                                |
| ------------------ | ------ | ------------------- | ------------------------------------------ |
| `/auth.php`        | POST   | `login`             | Authenticate user and start session.       |
| `/auth.php`        | POST   | `register`          | Register a new accountant account.         |
| `/auth.php`        | GET    | `logout`            | End the current session.                   |
| `/auth.php`        | POST   | `forgot-password`   | Request a password reset link.             |
| `/auth.php`        | POST   | `reset-password`    | Reset password using a valid token.        |
| `/auth.php`        | POST   | `change-password`   | Update password for the logged-in user.    |
| `/auth.php`        | POST   | `google-callback`   | Authenticate using Google ID Token.        |

### Login Response Example:
```json
{
    "success": true,
    "data": {
        "id": 1,
        "email": "admin@example.com",
        "username": "admin",
        "role": "admin",
        "first_name": "Admin",
        "last_name": "User"
    },
    "message": "Login successful"
}
```

---

## 🎫 Voucher Management (`vouchers.php`)

| Endpoint           | Method | Action (`?action=`) | Description                                |
| ------------------ | ------ | ------------------- | ------------------------------------------ |
| `/vouchers.php`    | GET    | `list`              | Retrieve a list of vouchers.               |
| `/vouchers.php`    | GET    | `view`              | Get details of a specific voucher (`&id=`).|
| `/vouchers.php`    | POST   | `create`            | Create a new voucher (Draft/Posted).       |
| `/vouchers.php`    | POST   | `update`            | Update an existing Draft voucher.          |
| `/vouchers.php`    | POST   | `delete`            | Delete a Draft voucher.                    |
| `/vouchers.php`    | POST   | `request_approval`  | Submit a voucher for Manager approval.     |
| `/vouchers.php`    | POST   | `post`              | Approve and post a voucher (Manager/Admin).|
| `/vouchers.php`    | POST   | `reject`            | Reject a voucher with a reason.            |
| `/vouchers.php`    | GET    | `types`             | List available voucher types.              |
| `/vouchers.php`    | GET    | `timeline`          | Get a paginated timeline of vouchers.      |

---

## 📊 Reports & Insights (`reports.php` & `insights.php`)

| Endpoint           | Method | Action (`?action=`)   | Description                                |
| ------------------ | ------ | --------------------- | ------------------------------------------ |
| `/reports.php`     | GET    | `balance_sheet`       | Generate a Balance Sheet report.           |
| `/reports.php`     | GET    | `profit_and_loss`     | Generate a P&L statement.                  |
| `/reports.php`     | GET    | `ledger`              | Get ledger entries for an account.         |
| `/insights.php`    | GET    | `dashboard_summary`   | Get high-level stats for the dashboard.    |
| `/insights.php`    | GET    | `cash_flow_trends`    | Retrieve monthly cash flow data.           |

---

## 👤 User Management (`users.php`)

| Endpoint           | Method | Action (`?action=`) | Description                                |
| ------------------ | ------ | ------------------- | ------------------------------------------ |
| `/users.php`       | GET    | `list`              | List all users (Admin only).               |
| `/users.php`       | POST   | `update_profile`    | Update logged-in user's profile details.   |
| `/users.php`       | POST   | `upload_image`      | Upload a profile picture.                  |
| `/users.php`       | POST   | `toggle_active`     | Activate/Deactivate a user account.        |

---

## 🛑 Error Handling

The API uses standard HTTP status codes:
- **200 OK:** Request successful.
- **201 Created:** Resource created successfully.
- **400 Bad Request:** Missing parameters or invalid data.
- **401 Unauthorized:** Invalid or missing authentication.
- **403 Forbidden:** Insufficient permissions (Role-based).
- **404 Not Found:** Resource or endpoint not found.
- **500 Internal Server Error:** Server-side exception.

All errors return a JSON response:
```json
{
    "success": false,
    "error": "Detailed error message here"
}
```
