# Features & User Roles - FinSight

FinSight is a multi-user accounting platform with specific features tailored to different organizational roles.

## 👥 User Roles (RBAC)

### 1. Administrator (`admin`)
-   **Full System Control:** Manage all users, accounts, and system settings.
-   **Data Security:** Access to the complete `audit_trail` to monitor system activity.
-   **Configuration:** Define Voucher Types and Fiscal Periods.
-   **Overrides:** Ability to edit or delete any record if necessary.

### 2. Manager (`manager`)
-   **Approval Workflow:** Review vouchers submitted by Accountants.
-   **Decision Making:** Approve (Post) or Reject vouchers with comments.
-   **Reporting:** Access to all financial reports (Balance Sheet, P&L, Ledgers).
-   **Insights:** View high-level dashboard analytics and cash flow trends.

### 3. Accountant (`accountant`)
-   **Data Entry:** Create and edit financial vouchers in `Draft` mode.
-   **Submission:** Submit vouchers for manager approval.
-   **Record Keeping:** Manage the Chart of Accounts (COA).
-   **Basic Reports:** View personal activity and limited reports.

---

## 🚀 Key Modules

### 📊 Dashboard & Insights
-   **Real-time Stats:** View Total Assets, Liabilities, Income, and Expenses at a glance.
-   **Trends:** Monthly Income vs. Expense charts.
-   **Activity Feed:** Recent vouchers and notifications.

### 🎫 Voucher Management
-   **Drafting:** Save work-in-progress transactions.
-   **Double-Entry Validation:** Ensures debits and credits match before submission.
-   **Automation:** Automatically updates the General Ledger once a voucher is `Posted`.
-   **Attachments:** (Optional) Support for uploading related documents (PDF/Images).

### 📈 Financial Reporting
-   **Balance Sheet:** Snapshots of Assets, Liabilities, and Equity.
-   **Profit & Loss (P&L):** Dynamic calculation of Net Profit/Loss over custom date ranges.
-   **Ledgers:** Detailed drill-down into specific account transactions.

### 🔐 Security & Audit
-   **Audit Trail:** Detailed logging of who did what, when, and from where (IP/User-Agent).
-   **Secure Auth:** password hashing (bcrypt) and Google OAuth2 integration.
-   **Session Management:** Secure cookie-based sessions with timeout enforcement.

### 📱 Mobile Experience
-   **Sync:** Real-time synchronization between Web, Mobile, and Backend.
-   **Push Notifications:** Alerts for voucher approvals or rejections.
-   **Biometric Login:** (Mobile specific) Faster access to financial data.
