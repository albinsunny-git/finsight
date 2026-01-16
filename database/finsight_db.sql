-- FinSight Accounting Software Database Schema
-- MySQL Database for accounting, balance sheet, and P&L management

-- Create Database
CREATE DATABASE IF NOT EXISTS finsight_db;
USE finsight_db;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role ENUM('admin', 'manager', 'accountant', 'auditor') DEFAULT 'accountant',
    department VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    google_id VARCHAR(255) UNIQUE,
    profile_image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    created_by INT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Account Chart Table
CREATE TABLE IF NOT EXISTS account_chart (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    type ENUM('Asset', 'Liability', 'Equity', 'Income', 'Expense') NOT NULL,
    sub_type VARCHAR(100),
    description TEXT,
    opening_balance DECIMAL(15, 2) DEFAULT 0,
    balance DECIMAL(15, 2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Voucher Types Table
CREATE TABLE IF NOT EXISTS voucher_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vouchers Table
CREATE TABLE IF NOT EXISTS vouchers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    voucher_number VARCHAR(50) UNIQUE NOT NULL,
    voucher_type_id INT NOT NULL,
    voucher_date DATE NOT NULL,
    reference_number VARCHAR(100),
    narration TEXT,
    total_debit DECIMAL(15, 2) DEFAULT 0,
    total_credit DECIMAL(15, 2) DEFAULT 0,
    status ENUM('Draft', 'Posted', 'Rejected') DEFAULT 'Draft',
    posted_by INT,
    posted_at TIMESTAMP NULL,
    rejected_reason TEXT,
    rejected_by INT,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (voucher_type_id) REFERENCES voucher_types(id),
    FOREIGN KEY (posted_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (rejected_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_voucher_date (voucher_date),
    INDEX idx_status (status)
);

-- Voucher Details Table
CREATE TABLE IF NOT EXISTS voucher_details (
    id INT PRIMARY KEY AUTO_INCREMENT,
    voucher_id INT NOT NULL,
    account_id INT NOT NULL,
    debit DECIMAL(15, 2) DEFAULT 0,
    credit DECIMAL(15, 2) DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (voucher_id) REFERENCES vouchers(id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES account_chart(id) ON DELETE RESTRICT,
    INDEX idx_account (account_id)
);

-- General Ledger Table
CREATE TABLE IF NOT EXISTS general_ledger (
    id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    voucher_id INT NOT NULL,
    voucher_date DATE NOT NULL,
    debit DECIMAL(15, 2) DEFAULT 0,
    credit DECIMAL(15, 2) DEFAULT 0,
    running_balance DECIMAL(15, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES account_chart(id) ON DELETE RESTRICT,
    FOREIGN KEY (voucher_id) REFERENCES vouchers(id) ON DELETE CASCADE,
    INDEX idx_account_date (account_id, voucher_date)
);

-- Balance Sheet Entries Table
CREATE TABLE IF NOT EXISTS balance_sheet (
    id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    as_on_date DATE NOT NULL,
    debit DECIMAL(15, 2) DEFAULT 0,
    credit DECIMAL(15, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES account_chart(id),
    UNIQUE KEY unique_account_date (account_id, as_on_date)
);

-- P&L Report Table
CREATE TABLE IF NOT EXISTS profit_loss (
    id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    period_from DATE NOT NULL,
    period_to DATE NOT NULL,
    debit DECIMAL(15, 2) DEFAULT 0,
    credit DECIMAL(15, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES account_chart(id),
    UNIQUE KEY unique_account_period (account_id, period_from, period_to)
);

-- Audit Trail Table
CREATE TABLE IF NOT EXISTS audit_trail (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INT,
    old_value TEXT,
    new_value TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_user_date (user_id, created_at),
    INDEX idx_entity (entity_type, entity_id)
);

-- Password Reset Tokens Table
CREATE TABLE IF NOT EXISTS password_resets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    expiration TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_expiration (expiration)
);

-- Fiscal Year/Period Configuration Table
CREATE TABLE IF NOT EXISTS fiscal_periods (
    id INT PRIMARY KEY AUTO_INCREMENT,
    period_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_closed BOOLEAN DEFAULT FALSE,
    closed_by INT,
    closed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (closed_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY unique_period_dates (start_date, end_date)
);

-- Insert Default Roles/Voucher Types
INSERT INTO voucher_types (name, description) VALUES
('Cash Receipt Voucher', 'For recording cash receipts'),
('Cash Payment Voucher', 'For recording cash payments'),
('Bank Receipt Voucher', 'For recording bank deposits'),
('Bank Payment Voucher', 'For recording bank withdrawals'),
('Journal Entry', 'For general journal entries'),
('Contra Entry', 'For contra entries between accounts');

-- Create Basic Admin User (Password: Admin@123)
INSERT INTO users (email, username, password_hash, first_name, last_name, role) VALUES
('admin@finsight.com', 'admin', 'Admin@123', 'Admin', 'User', 'admin');

-- Create sample Accountant user
-- Credentials: username = 'accountant', password = 'Accountant@123'
INSERT INTO users (email, username, password_hash, first_name, last_name, role) VALUES
('accountant@finsight.com', 'accountant', 'Accountant@123', 'Jane', 'Account', 'accountant');

-- Create indexes for better performance
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_account_chart_type ON account_chart(type);
CREATE INDEX idx_vouchers_created_by ON vouchers(created_by);
CREATE INDEX idx_voucher_details_voucher ON voucher_details(voucher_id);
