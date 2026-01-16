-- Summarized SQL schema for FinSight (main tables)

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  username VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255),
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  role ENUM('admin','manager','accountant','auditor') DEFAULT 'accountant',
  is_active TINYINT(1) DEFAULT 1,
  google_id VARCHAR(200),
  profile_image VARCHAR(255),
  last_login DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE account_chart (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(200) NOT NULL,
  type ENUM('Asset','Liability','Equity','Income','Expense') NOT NULL,
  sub_type VARCHAR(100),
  description TEXT,
  opening_balance DECIMAL(18,2) DEFAULT 0,
  balance DECIMAL(18,2) DEFAULT 0,
  is_active TINYINT(1) DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE voucher_types (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  is_active TINYINT(1) DEFAULT 1
);

CREATE TABLE vouchers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  voucher_number VARCHAR(100) NOT NULL UNIQUE,
  voucher_type_id INT,
  voucher_date DATE,
  reference_number VARCHAR(100),
  narration TEXT,
  total_debit DECIMAL(18,2),
  total_credit DECIMAL(18,2),
  status ENUM('Draft','Posted','Rejected') DEFAULT 'Draft',
  posted_by INT NULL,
  posted_at DATETIME NULL,
  rejected_reason TEXT,
  rejected_by INT NULL,
  created_by INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (voucher_type_id) REFERENCES voucher_types(id)
);

CREATE TABLE voucher_details (
  id INT AUTO_INCREMENT PRIMARY KEY,
  voucher_id INT NOT NULL,
  account_id INT NOT NULL,
  debit DECIMAL(18,2) DEFAULT 0,
  credit DECIMAL(18,2) DEFAULT 0,
  description TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (voucher_id) REFERENCES vouchers(id) ON DELETE CASCADE,
  FOREIGN KEY (account_id) REFERENCES account_chart(id)
);

CREATE TABLE general_ledger (
  id INT AUTO_INCREMENT PRIMARY KEY,
  account_id INT NOT NULL,
  voucher_id INT,
  voucher_date DATE,
  debit DECIMAL(18,2) DEFAULT 0,
  credit DECIMAL(18,2) DEFAULT 0,
  running_balance DECIMAL(18,2) DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (account_id) REFERENCES account_chart(id),
  FOREIGN KEY (voucher_id) REFERENCES vouchers(id)
);

CREATE TABLE audit_trail (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  action VARCHAR(100),
  entity_type VARCHAR(100),
  entity_id INT,
  old_value TEXT,
  new_value TEXT,
  ip_address VARCHAR(45),
  user_agent VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE password_resets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  token VARCHAR(255) NOT NULL,
  expiration DATETIME,
  is_used TINYINT(1) DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE fiscal_periods (
  id INT AUTO_INCREMENT PRIMARY KEY,
  period_name VARCHAR(100),
  start_date DATE,
  end_date DATE,
  is_closed TINYINT(1) DEFAULT 0,
  closed_by INT NULL,
  closed_at DATETIME NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Index suggestions
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_vouchers_date ON vouchers(voucher_date);
CREATE INDEX idx_gl_account ON general_ledger(account_id);

-- End of summarized schema
