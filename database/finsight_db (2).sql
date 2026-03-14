-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 14, 2026 at 11:16 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `finsight_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `account_chart`
--

CREATE TABLE `account_chart` (
  `id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` enum('Asset','Liability','Equity','Income','Expense') NOT NULL,
  `sub_type` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `opening_balance` decimal(15,2) DEFAULT 0.00,
  `balance` decimal(15,2) DEFAULT 0.00,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `account_chart`
--

INSERT INTO `account_chart` (`id`, `code`, `name`, `type`, `sub_type`, `description`, `opening_balance`, `balance`, `is_active`, `created_at`, `updated_at`, `created_by`) VALUES
(1, 'A100', 'Cash in Hand', 'Asset', 'Cash', 'Physical cash available', 20000.00, 8000.00, 1, '2026-03-05 15:05:37', '2026-03-05 16:29:41', 1),
(2, 'A101', 'Cash at Bank', 'Asset', 'Bank', 'Bank account balance', 150000.00, 109500.00, 1, '2026-03-05 15:05:37', '2026-03-05 16:30:24', 1),
(3, 'A102', 'Accounts Receivable', 'Asset', 'Debtors', 'Amount receivable from customers', 25000.00, 29500.00, 1, '2026-03-05 15:05:37', '2026-03-11 08:03:42', 1),
(4, 'A103', 'Inventory', 'Asset', 'Stock', 'Goods available for sale', 60000.00, 760500.00, 1, '2026-03-05 15:05:37', '2026-03-11 08:03:42', 1),
(5, 'A104', 'Petty Cash', 'Asset', 'Cash', 'Small day-to-day cash expenses', 5000.00, 5000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:05:37', 1),
(6, 'A105', 'Prepaid Expenses', 'Asset', 'Current Asset', 'Expenses paid in advance', 3000.00, 3000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:05:37', 1),
(7, 'A200', 'Furniture', 'Asset', 'Fixed Asset', 'Office furniture', 80000.00, 80000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:05:37', 1),
(8, 'A201', 'Computer Equipment', 'Asset', 'Fixed Asset', 'Computers and accessories', 70000.00, 68000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:18:22', 1),
(9, 'A202', 'Office Equipment', 'Asset', 'Fixed Asset', 'Printers and scanners', 30000.00, 34500.00, 1, '2026-03-05 15:05:37', '2026-03-05 16:31:35', 1),
(10, 'A203', 'Accumulated Depreciation', 'Asset', 'Contra Asset', 'Depreciation of assets', 0.00, 0.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:05:37', 1),
(11, 'L100', 'Accounts Payable', 'Liability', 'Creditors', 'Amount payable to suppliers', 20000.00, 15000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:18:16', 1),
(12, 'L101', 'GST Payable', 'Liability', 'Tax', 'GST collected from customers', 5000.00, 5000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:05:37', 1),
(13, 'L102', 'Outstanding Expenses', 'Liability', 'Current Liability', 'Expenses yet to be paid', 4000.00, 4000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:05:37', 1),
(14, 'L103', 'Salary Payable', 'Liability', 'Current Liability', 'Salary yet to be paid', 10000.00, 10000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:05:37', 1),
(15, 'L200', 'Bank Loan', 'Liability', 'Loan', 'Loan taken from bank', 100000.00, 127000.00, 1, '2026-03-05 15:05:37', '2026-03-05 16:29:01', 1),
(16, 'E100', 'Capital Account', 'Equity', 'Capital', 'Owner investment in business', 250000.00, -250000.00, 1, '2026-03-05 15:05:37', '2026-03-05 16:34:23', 1),
(17, 'E101', 'Drawings', 'Equity', 'Drawings', 'Owner withdrawals', 5000.00, 5000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:05:37', 1),
(18, 'E102', 'Retained Earnings', 'Equity', 'Capital', 'Accumulated profits', 20000.00, 15000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:14:39', 1),
(19, 'I100', 'Sales Revenue', 'Income', 'Sales', 'Income from sale of goods', 0.00, -113000.00, 1, '2026-03-05 15:05:37', '2026-03-05 16:34:23', 1),
(20, 'I101', 'Service Income', 'Income', 'Service', 'Income from services', 0.00, 25000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:18:16', 1),
(21, 'I102', 'Other Income', 'Income', 'Other', 'Miscellaneous income', 0.00, -1500.00, 1, '2026-03-05 15:05:37', '2026-03-05 16:31:35', 1),
(22, 'I103', 'Interest Income', 'Income', 'Finance', 'Interest received from bank', 0.00, 1000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:05:37', 1),
(23, 'X100', 'Purchase Expense', 'Expense', 'Purchase', 'Cost of goods purchased', 0.00, 43000.00, 1, '2026-03-05 15:05:37', '2026-03-05 16:28:28', 1),
(24, 'X101', 'Salary Expense', 'Expense', 'Salary', 'Employee salary expense', 0.00, 50000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:26:36', 1),
(25, 'X102', 'Rent Expense', 'Expense', 'Rent', 'Office rent', 0.00, 0.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:26:42', 1),
(26, 'X103', 'Electricity Expense', 'Expense', 'Utilities', 'Electricity charges', 0.00, 5000.00, 1, '2026-03-05 15:05:37', '2026-03-05 16:29:41', 1),
(27, 'X104', 'Internet Expense', 'Expense', 'Utilities', 'Internet charges', 0.00, 1500.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:05:37', 1),
(28, 'X105', 'Office Supplies', 'Expense', 'Office', 'Stationery and office materials', 0.00, 4000.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:18:22', 1),
(29, 'X106', 'Travel Expense', 'Expense', 'Travel', 'Business travel expenses', 0.00, 4500.00, 1, '2026-03-05 15:05:37', '2026-03-05 16:30:24', 1),
(30, 'X107', 'Maintenance Expense', 'Expense', 'Maintenance', 'Repair and maintenance', 0.00, 2500.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:05:37', 1),
(31, 'X108', 'Bank Charges', 'Expense', 'Finance', 'Bank service charges', 0.00, 1300.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:26:36', 1),
(32, 'X109', 'Depreciation Expense', 'Expense', 'Depreciation', 'Depreciation of fixed assets', 0.00, 0.00, 1, '2026-03-05 15:05:37', '2026-03-05 15:05:37', 1),
(35, 'A999', 'Test Savings', 'Asset', NULL, NULL, 0.00, 0.00, 1, '2026-03-11 08:04:37', '2026-03-11 08:04:37', 1);

-- --------------------------------------------------------

--
-- Table structure for table `audit_trail`
--

CREATE TABLE `audit_trail` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(50) NOT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `old_value` text DEFAULT NULL,
  `new_value` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_trail`
--

INSERT INTO `audit_trail` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `old_value`, `new_value`, `ip_address`, `user_agent`, `created_at`) VALUES
(76, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 03:22:15'),
(77, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 03:28:05'),
(78, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 03:40:48'),
(79, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:02:08'),
(80, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:02:28'),
(81, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:03:04'),
(82, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:04:27'),
(83, 4, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 12, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:08:53'),
(84, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:09:32'),
(85, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:12:11'),
(86, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:18:51'),
(87, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:25:25'),
(88, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:34:50'),
(89, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:38:09'),
(90, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:50:20'),
(91, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:52:17'),
(92, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:52:32'),
(93, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 04:52:55'),
(94, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 05:06:57'),
(95, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 05:13:48'),
(96, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:21:47'),
(97, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:22:05'),
(98, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:24:48'),
(99, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:27:27'),
(100, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:30:09'),
(101, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:37:05'),
(102, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:45:31'),
(103, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:47:30'),
(104, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:50:39'),
(105, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:50:55'),
(106, 3, 'VOUCHER_CREATED', 'vouchers', 13, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:55:12'),
(107, 3, 'VOUCHER_SUBMITTED', 'vouchers', 13, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:55:17'),
(108, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:55:27'),
(109, 4, 'VOUCHER_POSTED', 'vouchers', 13, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:55:39'),
(110, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:58:44'),
(111, 3, 'VOUCHER_CREATED', 'vouchers', 14, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:59:11'),
(112, 3, 'VOUCHER_CREATED', 'vouchers', 15, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 06:59:40'),
(113, 3, 'VOUCHER_SUBMITTED', 'vouchers', 15, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 07:44:17'),
(114, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 07:44:27'),
(115, 4, 'VOUCHER_POSTED', 'vouchers', 14, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 07:44:45'),
(116, 4, 'VOUCHER_POSTED', 'vouchers', 14, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 07:44:50'),
(117, 4, 'VOUCHER_REJECTED', 'vouchers', 15, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 07:45:02'),
(118, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 07:47:46'),
(119, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 09:43:04'),
(120, 3, 'VOUCHER_CREATED', 'vouchers', 16, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 09:43:26'),
(121, 3, 'VOUCHER_SUBMITTED', 'vouchers', 16, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 09:43:32'),
(122, 3, 'VOUCHER_CREATED', 'vouchers', 17, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 09:43:38'),
(123, 3, 'VOUCHER_CREATED', 'vouchers', 18, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 09:43:51'),
(124, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 09:44:13'),
(125, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 09:44:46'),
(126, 3, 'VOUCHER_SUBMITTED', 'vouchers', 18, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 09:44:52'),
(127, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 10:21:37'),
(128, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 10:21:52'),
(129, 4, 'VOUCHER_POSTED', 'vouchers', 17, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 10:22:09'),
(130, 4, 'VOUCHER_POSTED', 'vouchers', 18, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 10:22:14'),
(131, 4, 'VOUCHER_POSTED', 'vouchers', 16, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 10:22:18'),
(132, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 16:52:13'),
(133, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:36:40'),
(134, 4, 'ACCOUNT_DEACTIVATED', 'account_chart', 10, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:44:54'),
(135, 4, 'ACCOUNT_ACTIVATED', 'account_chart', 10, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:45:10'),
(136, 4, 'ACCOUNT_DEACTIVATED', 'account_chart', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:51:50'),
(137, 4, 'ACCOUNT_ACTIVATED', 'account_chart', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:51:55'),
(138, 4, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 19, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:53:24'),
(139, 4, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 20, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:54:21'),
(140, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:56:53'),
(141, 3, 'VOUCHER_CREATED', 'vouchers', 21, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:57:37'),
(142, 3, 'VOUCHER_SUBMITTED', 'vouchers', 21, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:57:43'),
(143, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:57:53'),
(144, 4, 'VOUCHER_POSTED', 'vouchers', 21, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:58:02'),
(145, 4, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 22, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:58:54'),
(146, 4, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 23, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:59:53'),
(147, 4, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 24, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 04:01:22'),
(148, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 04:02:19'),
(149, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 04:09:32'),
(150, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 04:16:49'),
(151, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 04:17:09'),
(152, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 04:19:41'),
(153, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 04:20:00'),
(154, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 04:22:14'),
(155, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 04:22:32'),
(156, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 04:22:50'),
(157, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 04:45:34'),
(158, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 04:48:11'),
(159, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-15 10:42:38'),
(160, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 01:34:01'),
(161, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 01:34:13'),
(162, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 01:39:53'),
(163, 3, 'LOGIN_FAILED', 'users', 3, NULL, 'albinsunny2028@mca.ajce.in', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 01:56:03'),
(164, 3, 'LOGIN_FAILED', 'users', 3, NULL, 'albinsunny2028@mca.ajce.in', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 01:56:13'),
(165, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 01:56:18'),
(166, 3, 'PASSWORD_CHANGED', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 02:20:34'),
(167, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 02:20:47'),
(168, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 03:52:21'),
(169, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 03:53:02'),
(170, 4, 'ACCOUNT_UPDATED', 'account_chart', 2, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 03:53:54'),
(171, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 03:56:20'),
(172, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 04:03:03'),
(173, 4, 'USER_CREATED', 'users', 5, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 04:04:19'),
(174, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 04:04:35'),
(175, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 04:16:27'),
(176, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 04:21:16'),
(177, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 04:23:18'),
(178, 4, 'USER_CREATED', 'users', 6, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 04:26:55'),
(179, 6, 'LOGIN_SUCCESS', 'users', 6, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 04:27:07'),
(180, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 04:48:53'),
(181, 6, 'LOGIN_SUCCESS', 'users', 6, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 04:49:20'),
(182, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 04:49:28'),
(183, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-16 04:58:45'),
(184, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-20 03:42:04'),
(185, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-20 03:55:58'),
(186, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-20 04:01:27'),
(187, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-20 04:28:00'),
(188, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-20 04:42:08'),
(189, 1, 'LOGIN_FAILED', 'users', 1, NULL, 'Admin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-20 04:44:59'),
(190, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-20 04:45:05'),
(191, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-20 05:19:15'),
(192, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-20 05:26:54'),
(193, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-20 08:00:48'),
(194, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-20 08:40:17'),
(195, 4, 'LOGIN_SUCCESS', 'users', 4, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-20 10:04:48'),
(196, 1, 'LOGIN_FAILED', 'users', 1, NULL, 'admin', '::1', '', '2026-01-21 00:20:43'),
(197, 7, 'LOGIN_SUCCESS', 'users', 7, NULL, NULL, '::1', '', '2026-01-21 00:21:39'),
(198, 7, 'ACCOUNT_CREATED', 'account_chart', 19, NULL, NULL, '::1', '', '2026-01-21 00:21:39'),
(199, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-29 15:39:37'),
(200, 6, 'LOGIN_SUCCESS', 'users', 6, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-29 15:40:43'),
(201, 3, 'LOGIN_FAILED', 'users', 3, NULL, 'albinsunny2028@mca.ajce.in', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-29 15:41:14'),
(202, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-29 15:42:37'),
(203, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-29 16:43:49'),
(204, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-29 17:22:48'),
(205, 6, 'LOGIN_FAILED', 'users', 6, NULL, 'albinsunny0420@gmail.com', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-30 04:06:45'),
(206, 6, 'LOGIN_SUCCESS', 'users', 6, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-30 04:06:52'),
(207, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-30 04:08:26'),
(208, 3, 'VOUCHER_CREATED', 'vouchers', 25, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-30 04:08:56'),
(209, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-30 04:10:21'),
(210, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-30 06:54:06'),
(211, 3, 'VOUCHER_SUBMITTED', 'vouchers', 25, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-30 06:54:13'),
(212, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-30 06:54:26'),
(213, 1, 'VOUCHER_POSTED', 'vouchers', 25, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-30 06:54:32'),
(214, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-01-30 10:38:39'),
(215, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-30 11:09:22'),
(216, 1, 'LOGIN_FAILED', 'users', 1, NULL, 'admin', '10.33.211.213', 'Dart/3.10 (dart:io)', '2026-02-02 01:11:36'),
(217, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '10.33.211.213', 'Dart/3.10 (dart:io)', '2026-02-02 01:11:44'),
(218, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', '2026-02-02 04:23:55'),
(219, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-02-02 06:11:13'),
(220, 3, 'VOUCHER_CREATED', 'vouchers', 26, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-02-02 06:21:04'),
(221, 3, 'VOUCHER_SUBMITTED', 'vouchers', 26, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-02-02 06:21:15'),
(222, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-02 06:21:40'),
(223, 1, 'VOUCHER_REJECTED', 'vouchers', 26, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-02 06:22:03'),
(224, 1, 'VOUCHER_POSTED', 'vouchers', 26, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-02 06:22:29'),
(225, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-02 08:45:49'),
(226, 1, 'LOGIN_FAILED', 'users', 1, NULL, 'admin', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-02 10:09:40'),
(227, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-02 10:09:45'),
(228, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-03 03:43:05'),
(229, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-03 03:49:02'),
(230, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-03 03:56:59'),
(231, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-03 05:24:27'),
(232, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-02-03 05:25:22'),
(233, 6, 'LOGIN_SUCCESS', 'users', 6, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-02-03 05:28:05'),
(234, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-02-03 05:28:36'),
(235, 3, 'VOUCHER_CREATED', 'vouchers', 27, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-02-03 05:34:43'),
(236, 3, 'VOUCHER_SUBMITTED', 'vouchers', 27, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-02-03 05:37:08'),
(237, 3, 'VOUCHER_CREATED', 'vouchers', 28, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-02-03 05:39:46'),
(238, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-04 05:16:55'),
(239, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-18 14:43:24'),
(240, 1, 'VOUCHER_POSTED', 'vouchers', 27, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-18 14:43:56'),
(241, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-18 14:45:49'),
(242, 1, 'ACCOUNT_UPDATED', 'account_chart', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-18 14:47:31'),
(243, 1, 'VOUCHER_POSTED', 'vouchers', 28, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-18 14:48:26'),
(244, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-18 14:55:53'),
(245, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-18 15:36:07'),
(246, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-18 15:44:54'),
(247, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-19 02:00:32'),
(248, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-19 02:01:00'),
(249, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-19 03:05:29'),
(250, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-19 03:06:06'),
(251, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-20 09:36:57'),
(252, 1, 'PROFILE_UPDATED', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-20 10:21:48'),
(253, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 13:32:38'),
(254, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 14:25:00'),
(255, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 14:45:57'),
(256, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-22 14:53:08'),
(257, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 15:18:14'),
(258, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 15:20:17'),
(259, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-22 15:21:41'),
(260, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 16:22:22'),
(261, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-22 16:38:02'),
(262, 1, 'VOUCHER_CREATED', 'vouchers', 29, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 16:42:50'),
(263, 1, 'USER_UPDATED', 'users', 3, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 17:35:24'),
(264, 1, 'USER_UPDATED', 'users', 3, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 17:35:33'),
(265, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 18:09:51'),
(266, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 18:10:26'),
(267, 1, 'LOGIN_FAILED', 'users', 1, NULL, 'admin', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 18:11:02'),
(268, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 18:11:09'),
(269, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 18:11:14'),
(270, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 18:11:20'),
(271, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 18:11:49'),
(272, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-22 18:11:53'),
(273, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:04:51'),
(274, 5, 'LOGIN_SUCCESS_GOOGLE', 'users', 5, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:07:19'),
(275, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:08:17'),
(276, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:13:50'),
(277, 1, 'USER_DELETED', 'users', 8, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:14:27'),
(278, 1, 'VOUCHER_POSTED', 'vouchers', 29, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:14:48'),
(279, 1, 'VOUCHER_POSTED', 'vouchers', 29, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:14:56'),
(280, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:16:02'),
(281, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:21:17'),
(282, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:23:08'),
(283, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:28:24'),
(284, 1, 'USER_DEACTIVATED', 'users', 7, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:29:19'),
(285, 1, 'USER_ACTIVATED', 'users', 7, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:29:28'),
(286, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:53:43'),
(287, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 16:56:41'),
(288, 6, 'LOGIN_SUCCESS', 'users', 6, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 17:16:20'),
(289, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 17:16:39'),
(290, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 17:22:49'),
(291, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 17:26:15'),
(292, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 18:01:00'),
(293, 1, 'LOGIN_FAILED', 'users', 1, NULL, 'admin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 18:09:24'),
(294, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 18:11:32'),
(295, 1, 'USER_DEACTIVATED', 'users', 7, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 18:23:46'),
(296, 1, 'USER_ACTIVATED', 'users', 7, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-24 18:23:52'),
(297, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 14:39:31'),
(298, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 14:45:35'),
(299, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 14:50:23'),
(300, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 14:56:18'),
(301, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:12:39'),
(302, 6, 'LOGIN_SUCCESS', 'users', 6, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:14:26'),
(303, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:14:34'),
(304, 3, 'VOUCHER_CREATED', 'vouchers', 30, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:14:51'),
(305, 3, 'VOUCHER_SUBMITTED', 'vouchers', 30, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:15:01'),
(306, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:15:10'),
(307, 1, 'VOUCHER_POSTED', 'vouchers', 30, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:15:21'),
(308, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:32:23'),
(309, 3, 'VOUCHER_CREATED', 'vouchers', 31, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:32:59'),
(310, 3, 'VOUCHER_SUBMITTED', 'vouchers', 31, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:33:13'),
(311, 6, 'LOGIN_SUCCESS', 'users', 6, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:33:27'),
(312, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:33:37'),
(313, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:34:01'),
(314, 1, 'VOUCHER_POSTED', 'vouchers', 31, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:34:12'),
(315, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:34:27'),
(316, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:34:44'),
(317, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 15:47:42'),
(318, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 16:46:42'),
(319, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-02-25 16:50:09'),
(320, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-02-25 18:06:18'),
(321, 1, 'USER_CREATED', 'users', 9, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:41:59'),
(322, 9, 'LOGIN_SUCCESS', 'users', 9, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:42:21'),
(323, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:43:15'),
(324, 5, 'LOGIN_FAILED', 'users', 5, NULL, 'sunnyalbin3640@gmail.com', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:47:34'),
(325, 5, 'LOGIN_FAILED', 'users', 5, NULL, 'sunnyalbin3640@gmail.com', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:47:37'),
(326, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:47:43'),
(327, 5, 'VOUCHER_CREATED', 'vouchers', 32, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:54:36'),
(328, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:55:06'),
(329, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:55:36'),
(330, 5, 'VOUCHER_SUBMITTED', 'vouchers', 32, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:55:40'),
(331, 1, 'LOGIN_FAILED', 'users', 1, NULL, 'admin', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:56:09'),
(332, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:56:15'),
(333, 1, 'VOUCHER_REJECTED', 'vouchers', 32, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:56:40'),
(334, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 11:57:37'),
(335, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 12:13:30'),
(336, 5, 'VOUCHER_CREATED', 'vouchers', 33, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 12:14:14'),
(337, 5, 'VOUCHER_SUBMITTED', 'vouchers', 33, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 12:14:18'),
(338, 5, 'VOUCHER_POSTED', 'vouchers', 33, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 12:14:26'),
(339, 5, 'VOUCHER_CREATED', 'vouchers', 34, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 12:15:22'),
(340, 5, 'VOUCHER_SUBMITTED', 'vouchers', 34, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 12:15:25'),
(341, 5, 'VOUCHER_POSTED', 'vouchers', 34, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 12:15:27'),
(342, 5, 'VOUCHER_CREATED', 'vouchers', 35, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 12:17:38'),
(343, 5, 'VOUCHER_SUBMITTED', 'vouchers', 35, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 12:17:41'),
(344, 5, 'VOUCHER_POSTED', 'vouchers', 35, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 12:17:43'),
(345, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 12:33:14'),
(346, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-01 12:41:39'),
(347, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-01 16:03:22'),
(348, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-02 03:19:11'),
(349, 1, 'USER_UPDATED', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-02 03:20:53'),
(350, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-02 04:08:00'),
(351, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '2026-03-02 04:11:52'),
(352, 1, 'LOGIN_FAILED', 'users', 1, NULL, 'admin', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-02 05:18:17'),
(353, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-02 05:18:22'),
(354, 1, 'PROFILE_UPDATED', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-02 05:24:47'),
(355, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-02 17:06:01'),
(356, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-02 18:49:46'),
(357, 1, 'PROFILE_UPDATED', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-02 19:41:30'),
(358, 3, 'LOGIN_FAILED', 'users', 3, NULL, 'albinsunny2028@mca.ajce.in', '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 09:04:15'),
(359, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 09:04:20'),
(360, 3, 'PROFILE_UPDATED', 'users', 3, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 09:04:50'),
(361, 3, 'LOGIN_SUCCESS', 'users', 3, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 09:52:42'),
(362, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 09:52:52'),
(363, 1, 'PROFILE_UPDATED', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 10:09:50'),
(364, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 14:39:25'),
(365, 1, 'VOUCHER_CREATED', 'vouchers', 46, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:11:37'),
(366, 1, 'VOUCHER_SUBMITTED', 'vouchers', 46, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:11:46'),
(367, 1, 'VOUCHER_POSTED', 'vouchers', 46, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:12:02'),
(368, 1, 'VOUCHER_CREATED', 'vouchers', 47, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:12:55'),
(369, 1, 'VOUCHER_CREATED', 'vouchers', 48, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:14:21'),
(370, 1, 'VOUCHER_SUBMITTED', 'vouchers', 47, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:14:31'),
(371, 1, 'VOUCHER_POSTED', 'vouchers', 47, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:14:32'),
(372, 1, 'VOUCHER_SUBMITTED', 'vouchers', 48, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:14:37'),
(373, 1, 'VOUCHER_POSTED', 'vouchers', 48, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:14:39'),
(374, 1, 'VOUCHER_CREATED', 'vouchers', 49, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:15:48');
INSERT INTO `audit_trail` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `old_value`, `new_value`, `ip_address`, `user_agent`, `created_at`) VALUES
(375, 1, 'VOUCHER_SUBMITTED', 'vouchers', 49, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:16:00'),
(376, 1, 'VOUCHER_POSTED', 'vouchers', 49, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:16:02'),
(377, 1, 'VOUCHER_CREATED', 'vouchers', 50, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:17:15'),
(378, 1, 'VOUCHER_CREATED', 'vouchers', 51, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:18:05'),
(379, 1, 'VOUCHER_SUBMITTED', 'vouchers', 51, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:18:14'),
(380, 1, 'VOUCHER_POSTED', 'vouchers', 51, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:18:16'),
(381, 1, 'VOUCHER_SUBMITTED', 'vouchers', 50, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:18:21'),
(382, 1, 'VOUCHER_POSTED', 'vouchers', 50, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:18:22'),
(383, 1, 'VOUCHER_CREATED', 'vouchers', 52, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:24:14'),
(384, 1, 'VOUCHER_CREATED', 'vouchers', 53, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:25:19'),
(385, 1, 'VOUCHER_CREATED', 'vouchers', 54, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:26:19'),
(386, 1, 'VOUCHER_SUBMITTED', 'vouchers', 54, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:26:28'),
(387, 1, 'VOUCHER_POSTED', 'vouchers', 54, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:26:29'),
(388, 1, 'VOUCHER_SUBMITTED', 'vouchers', 53, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:26:35'),
(389, 1, 'VOUCHER_POSTED', 'vouchers', 53, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:26:36'),
(390, 1, 'VOUCHER_SUBMITTED', 'vouchers', 52, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:26:40'),
(391, 1, 'VOUCHER_POSTED', 'vouchers', 52, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-05 15:26:42'),
(392, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 16:27:46'),
(393, 1, 'VOUCHER_CREATED', 'vouchers', 55, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 16:28:22'),
(394, 1, 'VOUCHER_POSTED', 'vouchers', 55, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 16:28:28'),
(395, 1, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 56, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 16:29:01'),
(396, 1, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 57, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 16:29:41'),
(397, 1, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 58, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 16:30:24'),
(398, 1, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 59, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 16:31:35'),
(399, 1, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 60, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 16:32:26'),
(400, 1, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 61, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 16:33:22'),
(401, 1, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 62, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-05 16:34:23'),
(402, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-06 02:18:32'),
(403, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-06 02:58:51'),
(404, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-06 03:00:12'),
(405, 1, 'PROFILE_IMAGE_UPDATED', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-06 03:24:27'),
(406, 1, 'ACCOUNT_UPDATED', 'account_chart', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-06 04:17:42'),
(407, 1, 'ACCOUNT_UPDATED', 'account_chart', 4, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-06 04:17:57'),
(408, 1, 'USER_UPDATED', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-06 05:56:26'),
(409, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-06 06:09:40'),
(410, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-06 06:16:19'),
(411, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0', '2026-03-06 10:06:33'),
(412, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-06 10:37:50'),
(413, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-09 14:16:25'),
(414, 5, 'LOGIN_SUCCESS', 'users', 5, NULL, NULL, '127.0.0.1', 'Dart/3.10 (dart:io)', '2026-03-10 06:49:09'),
(415, 1, 'LOGIN_SUCCESS', 'users', 1, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-11 08:00:26'),
(416, 1, 'USER_CREATED', 'users', 10, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-11 08:01:31'),
(417, 1, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', 63, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-11 08:03:42'),
(418, 1, 'ACCOUNT_CREATED', 'account_chart', 35, NULL, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-11 08:04:37');

-- --------------------------------------------------------

--
-- Table structure for table `balance_sheet`
--

CREATE TABLE `balance_sheet` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `as_on_date` date NOT NULL,
  `debit` decimal(15,2) DEFAULT 0.00,
  `credit` decimal(15,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `company_settings`
--

CREATE TABLE `company_settings` (
  `id` int(11) NOT NULL,
  `company_name` varchar(255) NOT NULL,
  `company_address` text DEFAULT NULL,
  `company_phone` varchar(50) DEFAULT NULL,
  `company_email` varchar(255) DEFAULT NULL,
  `company_website` varchar(255) DEFAULT NULL,
  `company_tagline` varchar(255) DEFAULT NULL,
  `company_logo` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `company_settings`
--

INSERT INTO `company_settings` (`id`, `company_name`, `company_address`, `company_phone`, `company_email`, `company_website`, `company_tagline`, `company_logo`, `created_at`, `updated_at`) VALUES
(1, 'FinSight Private Limited', '', '', 'info@globalfintech.com', '', 'Your Accurate Financial Partner', NULL, '2026-02-20 09:53:55', '2026-02-23 04:32:22');

-- --------------------------------------------------------

--
-- Table structure for table `feedback_history`
--

CREATE TABLE `feedback_history` (
  `id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `recipients` text NOT NULL,
  `subject` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `feedback_history`
--

INSERT INTO `feedback_history` (`id`, `sender_id`, `recipients`, `subject`, `message`, `sent_at`) VALUES
(1, 4, 'admin@finsight.com', 'the vouchers are perfectily alright', 'sample message', '2026-01-16 04:59:42'),
(2, 4, 'albinsunny90808@gmail.com', 'the vouchers are perfectily alright', 'sample message', '2026-01-16 05:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `fiscal_periods`
--

CREATE TABLE `fiscal_periods` (
  `id` int(11) NOT NULL,
  `period_name` varchar(100) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `is_closed` tinyint(1) DEFAULT 0,
  `closed_by` int(11) DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `general_ledger`
--

CREATE TABLE `general_ledger` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `voucher_id` int(11) NOT NULL,
  `voucher_date` date NOT NULL,
  `debit` decimal(15,2) DEFAULT 0.00,
  `credit` decimal(15,2) DEFAULT 0.00,
  `running_balance` decimal(15,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `general_ledger`
--

INSERT INTO `general_ledger` (`id`, `account_id`, `voucher_id`, `voucher_date`, `debit`, `credit`, `running_balance`, `created_at`) VALUES
(7, 3, 11, '2026-01-13', 5.00, 0.00, 0.00, '2026-01-13 03:01:02'),
(8, 7, 11, '2026-01-13', 0.00, 5.00, 0.00, '2026-01-13 03:01:02'),
(9, 10, 12, '2026-01-13', 50.00, 0.00, 0.00, '2026-01-13 04:08:53'),
(10, 8, 12, '2026-01-13', 0.00, 50.00, 0.00, '2026-01-13 04:08:53'),
(11, 1, 13, '2026-01-13', 5000.00, 0.00, 0.00, '2026-01-13 06:55:39'),
(12, 11, 13, '2026-01-13', 0.00, 5000.00, 0.00, '2026-01-13 06:55:39'),
(13, 5, 14, '2026-01-13', 500.00, 0.00, 0.00, '2026-01-13 07:44:45'),
(14, 7, 14, '2026-01-13', 0.00, 500.00, 0.00, '2026-01-13 07:44:45'),
(15, 5, 14, '2026-01-13', 500.00, 0.00, 0.00, '2026-01-13 07:44:50'),
(16, 7, 14, '2026-01-13', 0.00, 500.00, 0.00, '2026-01-13 07:44:50'),
(17, 3, 17, '2026-01-13', 5000.00, 0.00, 0.00, '2026-01-13 10:22:09'),
(18, 9, 17, '2026-01-13', 0.00, 5000.00, 0.00, '2026-01-13 10:22:09'),
(19, 3, 18, '2026-01-13', 50000.00, 0.00, 0.00, '2026-01-13 10:22:14'),
(20, 9, 18, '2026-01-13', 0.00, 50000.00, 0.00, '2026-01-13 10:22:14'),
(21, 3, 16, '2026-01-13', 5000.00, 0.00, 0.00, '2026-01-13 10:22:18'),
(22, 9, 16, '2026-01-13', 0.00, 5000.00, 0.00, '2026-01-13 10:22:18'),
(76, 23, 55, '2026-03-05', 5000.00, 0.00, 0.00, '2026-03-05 16:28:28'),
(77, 1, 55, '2026-03-05', 0.00, 5000.00, 0.00, '2026-03-05 16:28:28'),
(78, 15, 56, '2026-03-05', 25000.00, 0.00, 0.00, '2026-03-05 16:29:01'),
(79, 2, 56, '2026-03-05', 0.00, 25000.00, 0.00, '2026-03-05 16:29:01'),
(80, 26, 57, '2026-03-05', 5000.00, 0.00, 0.00, '2026-03-05 16:29:41'),
(81, 1, 57, '2026-03-05', 0.00, 5000.00, 0.00, '2026-03-05 16:29:41'),
(82, 29, 58, '2026-03-05', 1000.00, 0.00, 0.00, '2026-03-05 16:30:24'),
(83, 2, 58, '2026-03-05', 0.00, 1000.00, 0.00, '2026-03-05 16:30:24'),
(84, 9, 59, '2026-03-05', 4500.00, 0.00, 0.00, '2026-03-05 16:31:35'),
(85, 21, 59, '2026-03-05', 0.00, 4500.00, 0.00, '2026-03-05 16:31:35'),
(86, 19, 60, '2026-03-05', 50000.00, 0.00, 0.00, '2026-03-05 16:32:26'),
(87, 4, 60, '2026-03-05', 0.00, 50000.00, 0.00, '2026-03-05 16:32:26'),
(88, 4, 61, '2026-03-05', 750000.00, 0.00, 0.00, '2026-03-05 16:33:22'),
(89, 19, 61, '2026-03-05', 0.00, 750000.00, 0.00, '2026-03-05 16:33:22'),
(90, 19, 62, '2026-03-05', 500000.00, 0.00, 0.00, '2026-03-05 16:34:23'),
(91, 16, 62, '2026-03-05', 0.00, 500000.00, 0.00, '2026-03-05 16:34:23'),
(92, 4, 63, '2026-03-11', 500.00, 0.00, 0.00, '2026-03-11 08:03:42'),
(93, 3, 63, '2026-03-11', 0.00, 500.00, 0.00, '2026-03-11 08:03:42');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `message` text NOT NULL,
  `type` varchar(50) DEFAULT 'info',
  `is_read` tinyint(1) DEFAULT 0,
  `related_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `message`, `type`, `is_read`, `related_id`, `created_at`) VALUES
(2, 4, NULL, 'New voucher approval request: V-20260112-7790', 'info', 1, 3, '2026-01-12 09:45:34'),
(3, 3, NULL, 'Your voucher V-20260112-7790 has been approved and posted.', 'success', 1, 3, '2026-01-12 09:46:25'),
(5, 4, NULL, 'New voucher approval request: V-20260112-8671', 'info', 1, 4, '2026-01-12 09:47:24'),
(6, 3, NULL, 'Your voucher V-20260112-8671 has been approved and posted.', 'success', 1, 4, '2026-01-12 09:47:51'),
(8, 4, NULL, 'New voucher approval request: V-20260112-3083', 'info', 1, 5, '2026-01-12 09:52:57'),
(9, 3, NULL, 'Your voucher V-20260112-3083 has been approved and posted.', 'success', 1, 5, '2026-01-12 09:53:15'),
(10, 4, NULL, 'Your voucher V-20260112-5389 has been approved and posted.', 'success', 1, 7, '2026-01-12 10:20:09'),
(11, 4, NULL, 'Your voucher V-20260112-4094 has been approved and posted.', 'success', 1, 6, '2026-01-12 10:20:14'),
(13, 4, NULL, 'New voucher approval request: V-20260112-8811', 'info', 1, 8, '2026-01-12 10:32:10'),
(14, 3, NULL, 'Your voucher V-20260112-8811 was rejected. Reason: not proper', 'error', 1, 8, '2026-01-12 10:32:41'),
(16, 4, NULL, 'New voucher approval request: V-20260112-3842', 'info', 1, 9, '2026-01-12 17:10:29'),
(17, 3, NULL, 'Your voucher V-20260112-3842 has been approved and posted.', 'success', 1, 9, '2026-01-12 17:10:52'),
(19, 4, NULL, 'New voucher approval request: V-20260113-8739', 'info', 1, 10, '2026-01-13 02:48:16'),
(20, 3, NULL, 'Your voucher V-20260113-8739 was rejected. Reason: not original', 'error', 1, 10, '2026-01-13 02:48:51'),
(21, 3, NULL, 'Voucher #1001 was rejected by Admin (Reason: Incorrect Amount)', 'error', 1, NULL, '2026-01-13 02:56:08'),
(23, 4, NULL, 'New voucher approval request: V-20260113-3307', 'info', 1, 11, '2026-01-13 03:00:43'),
(24, 3, NULL, 'Your voucher V-20260113-3307 has been approved and posted.', 'success', 1, 11, '2026-01-13 03:01:02'),
(26, 3, NULL, 'Your voucher V-20260113-001 has been approved by Admin', 'success', 1, NULL, '2026-01-13 06:29:04'),
(27, 3, NULL, 'Your voucher V-20260113-002 has been rejected: Incorrect account code', 'error', 1, NULL, '2026-01-13 06:29:04'),
(28, 3, NULL, 'Your voucher V-20260113-003 is pending approval', 'info', 1, NULL, '2026-01-13 06:29:04'),
(30, 4, NULL, 'New voucher approval request: V-20260113-7294', 'info', 1, 13, '2026-01-13 06:55:17'),
(31, 3, NULL, 'Your voucher V-20260113-7294 has been approved and posted.', 'success', 1, 13, '2026-01-13 06:55:39'),
(33, 4, NULL, 'New voucher approval request: V-20260113-6235', 'info', 1, 15, '2026-01-13 07:44:17'),
(34, 3, NULL, 'Your voucher V-20260113-2934 has been approved and posted.', 'success', 1, 14, '2026-01-13 07:44:45'),
(35, 3, NULL, 'Your voucher V-20260113-2934 has been approved and posted.', 'success', 1, 14, '2026-01-13 07:44:50'),
(36, 3, NULL, 'Your voucher V-20260113-6235 was rejected. Reason: not propper', 'error', 1, 15, '2026-01-13 07:45:02'),
(38, 4, NULL, 'New voucher approval request: V-20260113-4539', 'info', 1, 16, '2026-01-13 09:43:32'),
(40, 4, NULL, 'New voucher approval request: V-20260113-3990', 'info', 1, 18, '2026-01-13 09:44:52'),
(41, 3, NULL, 'Your voucher V-20260113-7686 has been approved and posted.', 'success', 1, 17, '2026-01-13 10:22:09'),
(42, 3, NULL, 'Your voucher V-20260113-3990 has been approved and posted.', 'success', 1, 18, '2026-01-13 10:22:14'),
(43, 3, NULL, 'Your voucher V-20260113-4539 has been approved and posted.', 'success', 1, 16, '2026-01-13 10:22:18'),
(45, 4, NULL, 'New voucher approval request: V-20260114-6862', 'info', 1, 21, '2026-01-14 03:57:43'),
(46, 3, NULL, 'Your voucher V-20260114-6862 has been approved and posted.', 'success', 1, 21, '2026-01-14 03:58:02'),
(48, 4, NULL, 'New voucher approval request: V-20260130-7871', 'info', 0, 25, '2026-01-30 06:54:14'),
(49, 7, NULL, 'New voucher approval request: V-20260130-7871', 'info', 0, 25, '2026-01-30 06:54:14'),
(51, 3, NULL, 'Your voucher V-20260130-7871 has been approved and posted.', 'success', 1, 25, '2026-01-30 06:54:32'),
(53, 4, NULL, 'New voucher approval request: V-20260202-1582', 'info', 0, 26, '2026-02-02 06:21:15'),
(54, 7, NULL, 'New voucher approval request: V-20260202-1582', 'info', 0, 26, '2026-02-02 06:21:15'),
(56, 3, NULL, 'Your voucher V-20260202-1582 was rejected. Reason: not accepted ', 'error', 1, 26, '2026-02-02 06:22:03'),
(57, 3, NULL, 'Your voucher V-20260202-1582 has been approved and posted.', 'success', 1, 26, '2026-02-02 06:22:29'),
(59, 4, NULL, 'New voucher approval request: V-20260203-5729', 'info', 0, 27, '2026-02-03 05:37:08'),
(60, 7, NULL, 'New voucher approval request: V-20260203-5729', 'info', 0, 27, '2026-02-03 05:37:08'),
(62, 3, NULL, 'Your voucher V-20260203-5729 has been approved and posted.', 'success', 1, 27, '2026-02-18 14:43:56'),
(63, 3, NULL, 'Your voucher V-20260203-3351 has been approved and posted.', 'success', 1, 28, '2026-02-18 14:48:26'),
(67, 4, NULL, 'New voucher approval request: V-20260225-9119', 'info', 0, 30, '2026-02-25 15:15:01'),
(68, 7, NULL, 'New voucher approval request: V-20260225-9119', 'info', 0, 30, '2026-02-25 15:15:01'),
(70, 3, NULL, 'Your voucher V-20260225-9119 has been approved and posted.', 'success', 1, 30, '2026-02-25 15:15:21'),
(72, 4, NULL, 'New voucher approval request: V-20260225-5024', 'info', 0, 31, '2026-02-25 15:33:13'),
(73, 7, NULL, 'New voucher approval request: V-20260225-5024', 'info', 0, 31, '2026-02-25 15:33:13'),
(75, 3, NULL, 'Your voucher V-20260225-5024 has been approved and posted.', 'success', 1, 31, '2026-02-25 15:34:12'),
(77, 4, NULL, 'New voucher approval request: V-20260301-3890', 'info', 0, 32, '2026-03-01 11:55:40'),
(78, 7, NULL, 'New voucher approval request: V-20260301-3890', 'info', 0, 32, '2026-03-01 11:55:40'),
(82, 4, NULL, 'New voucher approval request: V-20260301-4150', 'info', 0, 33, '2026-03-01 12:14:18'),
(83, 7, NULL, 'New voucher approval request: V-20260301-4150', 'info', 0, 33, '2026-03-01 12:14:18'),
(87, 4, NULL, 'New voucher approval request: V-20260301-1899', 'info', 0, 34, '2026-03-01 12:15:25'),
(88, 7, NULL, 'New voucher approval request: V-20260301-1899', 'info', 0, 34, '2026-03-01 12:15:25'),
(92, 4, NULL, 'New voucher approval request: V-20260301-4315', 'info', 0, 35, '2026-03-01 12:17:41'),
(93, 7, NULL, 'New voucher approval request: V-20260301-4315', 'info', 0, 35, '2026-03-01 12:17:41'),
(97, 4, NULL, 'New voucher approval request: V-20260305-5852', 'info', 0, 46, '2026-03-05 15:11:46'),
(98, 7, NULL, 'New voucher approval request: V-20260305-5852', 'info', 0, 46, '2026-03-05 15:11:46'),
(102, 4, NULL, 'New voucher approval request: V-20260305-4355', 'info', 0, 47, '2026-03-05 15:14:31'),
(103, 7, NULL, 'New voucher approval request: V-20260305-4355', 'info', 0, 47, '2026-03-05 15:14:31'),
(107, 4, NULL, 'New voucher approval request: V-20260305-5433', 'info', 0, 48, '2026-03-05 15:14:37'),
(108, 7, NULL, 'New voucher approval request: V-20260305-5433', 'info', 0, 48, '2026-03-05 15:14:37'),
(112, 4, NULL, 'New voucher approval request: V-20260305-2144', 'info', 0, 49, '2026-03-05 15:16:00'),
(113, 7, NULL, 'New voucher approval request: V-20260305-2144', 'info', 0, 49, '2026-03-05 15:16:00'),
(117, 4, NULL, 'New voucher approval request: V-20260305-6168', 'info', 0, 51, '2026-03-05 15:18:14'),
(118, 7, NULL, 'New voucher approval request: V-20260305-6168', 'info', 0, 51, '2026-03-05 15:18:14'),
(122, 4, NULL, 'New voucher approval request: V-20260305-8325', 'info', 0, 50, '2026-03-05 15:18:21'),
(123, 7, NULL, 'New voucher approval request: V-20260305-8325', 'info', 0, 50, '2026-03-05 15:18:21'),
(127, 4, NULL, 'New voucher approval request: V-20260305-2808', 'info', 0, 54, '2026-03-05 15:26:28'),
(128, 7, NULL, 'New voucher approval request: V-20260305-2808', 'info', 0, 54, '2026-03-05 15:26:28'),
(132, 4, NULL, 'New voucher approval request: V-20260305-8237', 'info', 0, 53, '2026-03-05 15:26:35'),
(133, 7, NULL, 'New voucher approval request: V-20260305-8237', 'info', 0, 53, '2026-03-05 15:26:35'),
(137, 4, NULL, 'New voucher approval request: V-20260305-7468', 'info', 0, 52, '2026-03-05 15:26:40'),
(138, 7, NULL, 'New voucher approval request: V-20260305-7468', 'info', 0, 52, '2026-03-05 15:26:40');

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `expiration` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_used` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `profit_loss`
--

CREATE TABLE `profit_loss` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `period_from` date NOT NULL,
  `period_to` date NOT NULL,
  `debit` decimal(15,2) DEFAULT 0.00,
  `credit` decimal(15,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `role` enum('admin','manager','accountant') DEFAULT 'accountant',
  `department` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `google_id` varchar(255) DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_login` timestamp NULL DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `username`, `password_hash`, `first_name`, `last_name`, `phone`, `role`, `department`, `is_active`, `google_id`, `profile_image`, `created_at`, `updated_at`, `last_login`, `created_by`) VALUES
(1, 'admin@finsight.com', 'admin', '$2y$10$.hVTXW5PysxwMaQOVyTbi.JHq2dOyznIbfowp/QtQ/o7xPVqn8E2a', 'Derish', 'Abraham', '9645686798', 'admin', 'General', 1, NULL, 'uploads/profiles/user_1_1772767467.jpg', '2026-01-12 09:19:30', '2026-03-11 08:00:26', '2026-03-11 08:00:26', NULL),
(3, 'albinsunny2028@mca.ajce.in', 'admin@finsight.com', '$2y$10$rZyj36vH9nDxbFWVxOdWXe8uvqudKI3T6OnDdRjQ4Sp9CFd.r4ZP.', 'Albin', 'Sunny', '96458679848', 'accountant', 'finance', 1, NULL, NULL, '2026-01-12 09:30:35', '2026-03-05 09:52:42', '2026-03-05 09:52:42', 1),
(4, 'albinsunny90808@gmail.com', 'albin@admin', '$2y$10$bVLNU7iHrnnIGq8BIAxuZuGb5os1xB5mF1cl/kp2HL9aYW/ONCZZa', 'Albin', 'Sunny', NULL, 'admin', 'finance', 1, NULL, NULL, '2026-01-12 09:31:47', '2026-01-20 10:04:48', '2026-01-20 10:04:48', 1),
(5, 'sunnyalbin3640@gmail.com', 'Albins', '$2y$10$SwSDA7hMi9AXJWt0p0.i9.NMQuMvintFS/MAdZJRoK51ntJH0FP1C', 'Albin', 'Sunny', NULL, 'manager', 'finance', 1, NULL, 'https://lh3.googleusercontent.com/a/ACg8ocKlZwEXRv34nVbZmEpjlbtnLP3W29TU22fev3-1g8Xn-h4_l6ZP=s96-c', '2026-01-16 04:04:19', '2026-03-10 06:49:09', '2026-03-10 06:49:09', 4),
(6, 'albinsunny0420@gmail.co', 'Albinsu', '$2y$10$Vi9NWLRQIrPXm7lps5FPmOkIhzJEBi3uJe6fnXZ.0sE2NYnrxtNla', 'Albin', 'Sunny', NULL, 'accountant', 'Accounts', 1, NULL, NULL, '2026-01-16 04:26:55', '2026-03-01 16:13:50', '2026-02-25 15:33:27', 4),
(7, 'testadmin@example.com', 'testadmin', '$2y$10$o44ow4ig12u.EEgSLH65UujGIgNXbzMIgXegJwW2MPU30wVFmOU0u', 'Test', 'Admin', NULL, 'admin', NULL, 1, NULL, NULL, '2026-01-21 00:21:18', '2026-02-24 18:23:52', '2026-01-21 00:21:39', NULL),
(9, 'albin@gmail.com', 'albinsunn', '$2y$10$HNT08KA3GHh5DJaztQ1HK.B7VpEqBVXnU62JWtfzlmqwEx3MWarKy', 'albin', 'sunny', NULL, '', 'General', 1, NULL, NULL, '2026-03-01 11:41:59', '2026-03-01 11:42:21', '2026-03-01 11:42:21', 1),
(10, 'rahul.test@finsight.com', 'adminrahultest', '$2y$10$iDFGXPk/EIjiQRFBa1XFz.Tvs0wimZgIB5IKeiz3MFu6M.bRguRjW', 'Rahul', 'Test', NULL, 'manager', 'Testing', 1, NULL, NULL, '2026-03-11 08:01:31', '2026-03-11 08:01:31', NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `vouchers`
--

CREATE TABLE `vouchers` (
  `id` int(11) NOT NULL,
  `voucher_number` varchar(50) NOT NULL,
  `voucher_type_id` int(11) NOT NULL,
  `from_account_id` int(11) DEFAULT NULL,
  `to_account_id` int(11) DEFAULT NULL,
  `voucher_date` date NOT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `narration` text DEFAULT NULL,
  `total_debit` decimal(15,2) DEFAULT 0.00,
  `total_credit` decimal(15,2) DEFAULT 0.00,
  `status` enum('Draft','Pending Approval','Posted','Rejected') DEFAULT 'Draft',
  `posted_by` int(11) DEFAULT NULL,
  `posted_at` timestamp NULL DEFAULT NULL,
  `rejected_reason` text DEFAULT NULL,
  `rejected_by` int(11) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `rejected_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vouchers`
--

INSERT INTO `vouchers` (`id`, `voucher_number`, `voucher_type_id`, `from_account_id`, `to_account_id`, `voucher_date`, `reference_number`, `narration`, `total_debit`, `total_credit`, `status`, `posted_by`, `posted_at`, `rejected_reason`, `rejected_by`, `created_by`, `created_at`, `updated_at`, `approved_by`, `approved_at`, `rejected_at`) VALUES
(55, 'V-20260305-8202', 1, NULL, NULL, '2026-03-05', NULL, 'purchase', 5000.00, 5000.00, 'Posted', 1, '2026-03-05 16:28:28', NULL, NULL, 1, '2026-03-05 16:28:22', '2026-03-05 16:28:28', NULL, NULL, NULL),
(56, 'V-20260305-4940', 3, NULL, NULL, '2026-03-05', NULL, 'loan', 25000.00, 25000.00, 'Posted', NULL, NULL, NULL, NULL, 1, '2026-03-05 16:29:01', '2026-03-05 16:29:01', 1, '2026-03-05 16:29:01', NULL),
(57, 'V-20260305-4878', 1, NULL, NULL, '2026-03-05', NULL, 'electricity', 5000.00, 5000.00, 'Posted', NULL, NULL, NULL, NULL, 1, '2026-03-05 16:29:41', '2026-03-05 16:29:41', 1, '2026-03-05 16:29:41', NULL),
(58, 'V-20260305-8532', 1, NULL, NULL, '2026-03-05', NULL, 'travel', 1000.00, 1000.00, 'Posted', NULL, NULL, NULL, NULL, 1, '2026-03-05 16:30:24', '2026-03-05 16:30:24', 1, '2026-03-05 16:30:24', NULL),
(59, 'V-20260305-1139', 1, NULL, NULL, '2026-03-05', NULL, 'servicing', 4500.00, 4500.00, 'Posted', NULL, NULL, NULL, NULL, 1, '2026-03-05 16:31:35', '2026-03-05 16:31:35', 1, '2026-03-05 16:31:35', NULL),
(60, 'V-20260305-3719', 1, NULL, NULL, '2026-03-05', NULL, 'sales income', 50000.00, 50000.00, 'Posted', NULL, NULL, NULL, NULL, 1, '2026-03-05 16:32:26', '2026-03-05 16:32:26', 1, '2026-03-05 16:32:26', NULL),
(61, 'V-20260305-8066', 1, NULL, NULL, '2026-03-05', NULL, '', 750000.00, 750000.00, 'Posted', NULL, NULL, NULL, NULL, 1, '2026-03-05 16:33:22', '2026-03-05 16:33:22', 1, '2026-03-05 16:33:22', NULL),
(62, 'V-20260305-8442', 1, NULL, NULL, '2026-03-05', NULL, 'income', 500000.00, 500000.00, 'Posted', NULL, NULL, NULL, NULL, 1, '2026-03-05 16:34:23', '2026-03-05 16:34:23', 1, '2026-03-05 16:34:23', NULL),
(63, 'V-20260311-4160', 2, NULL, NULL, '2026-03-11', NULL, 'Automated Test Voucher', 500.00, 500.00, 'Posted', NULL, NULL, NULL, NULL, 1, '2026-03-11 08:03:42', '2026-03-11 08:03:42', 1, '2026-03-11 08:03:42', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `voucher_details`
--

CREATE TABLE `voucher_details` (
  `id` int(11) NOT NULL,
  `voucher_id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `debit` decimal(15,2) DEFAULT 0.00,
  `credit` decimal(15,2) DEFAULT 0.00,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `voucher_details`
--

INSERT INTO `voucher_details` (`id`, `voucher_id`, `account_id`, `debit`, `credit`, `description`, `created_at`) VALUES
(21, 11, 3, 5.00, 0.00, '', '2026-01-13 03:00:38'),
(22, 11, 7, 0.00, 5.00, '', '2026-01-13 03:00:38'),
(23, 12, 10, 50.00, 0.00, '', '2026-01-13 04:08:53'),
(24, 12, 8, 0.00, 50.00, '', '2026-01-13 04:08:53'),
(25, 13, 1, 5000.00, 0.00, '', '2026-01-13 06:55:12'),
(26, 13, 11, 0.00, 5000.00, '', '2026-01-13 06:55:12'),
(27, 14, 5, 500.00, 0.00, '', '2026-01-13 06:59:11'),
(28, 14, 7, 0.00, 500.00, '', '2026-01-13 06:59:11'),
(29, 15, 12, 5000.00, 0.00, '', '2026-01-13 06:59:40'),
(30, 15, 10, 0.00, 5000.00, '', '2026-01-13 06:59:40'),
(31, 16, 3, 5000.00, 0.00, '', '2026-01-13 09:43:26'),
(32, 16, 9, 0.00, 5000.00, '', '2026-01-13 09:43:26'),
(33, 17, 3, 5000.00, 0.00, '', '2026-01-13 09:43:38'),
(34, 17, 9, 0.00, 5000.00, '', '2026-01-13 09:43:38'),
(35, 18, 3, 50000.00, 0.00, '', '2026-01-13 09:43:51'),
(36, 18, 9, 0.00, 50000.00, '', '2026-01-13 09:43:51'),
(90, 55, 23, 5000.00, 0.00, 'purchase', '2026-03-05 16:28:22'),
(91, 55, 1, 0.00, 5000.00, 'purchase', '2026-03-05 16:28:22'),
(92, 56, 15, 25000.00, 0.00, 'loan', '2026-03-05 16:29:01'),
(93, 56, 2, 0.00, 25000.00, 'loan', '2026-03-05 16:29:01'),
(94, 57, 26, 5000.00, 0.00, 'electricity', '2026-03-05 16:29:41'),
(95, 57, 1, 0.00, 5000.00, 'electricity', '2026-03-05 16:29:41'),
(96, 58, 29, 1000.00, 0.00, 'travel', '2026-03-05 16:30:24'),
(97, 58, 2, 0.00, 1000.00, 'travel', '2026-03-05 16:30:24'),
(98, 59, 9, 4500.00, 0.00, 'servicing', '2026-03-05 16:31:35'),
(99, 59, 21, 0.00, 4500.00, 'servicing', '2026-03-05 16:31:35'),
(100, 60, 19, 50000.00, 0.00, 'sales income', '2026-03-05 16:32:26'),
(101, 60, 4, 0.00, 50000.00, 'sales income', '2026-03-05 16:32:26'),
(102, 61, 4, 750000.00, 0.00, '', '2026-03-05 16:33:22'),
(103, 61, 19, 0.00, 750000.00, '', '2026-03-05 16:33:22'),
(104, 62, 19, 500000.00, 0.00, 'income', '2026-03-05 16:34:23'),
(105, 62, 16, 0.00, 500000.00, 'income', '2026-03-05 16:34:23'),
(106, 63, 4, 500.00, 0.00, 'Automated Test Voucher', '2026-03-11 08:03:42'),
(107, 63, 3, 0.00, 500.00, 'Automated Test Voucher', '2026-03-11 08:03:42');

-- --------------------------------------------------------

--
-- Table structure for table `voucher_types`
--

CREATE TABLE `voucher_types` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `voucher_types`
--

INSERT INTO `voucher_types` (`id`, `name`, `description`, `is_active`, `created_at`) VALUES
(1, 'Cash Receipt Voucher', 'For recording cash receipts', 1, '2026-01-12 09:19:30'),
(2, 'Cash Payment Voucher', 'For recording cash payments', 1, '2026-01-12 09:19:30'),
(3, 'Bank Receipt Voucher', 'For recording bank deposits', 1, '2026-01-12 09:19:30'),
(4, 'Bank Payment Voucher', 'For recording bank withdrawals', 1, '2026-01-12 09:19:30'),
(5, 'Journal Entry', 'For general journal entries', 1, '2026-01-12 09:19:30'),
(6, 'Contra Entry', 'For contra entries between accounts', 1, '2026-01-12 09:19:30');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `account_chart`
--
ALTER TABLE `account_chart`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_account_chart_type` (`type`);

--
-- Indexes for table `audit_trail`
--
ALTER TABLE `audit_trail`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_date` (`user_id`,`created_at`),
  ADD KEY `idx_entity` (`entity_type`,`entity_id`);

--
-- Indexes for table `balance_sheet`
--
ALTER TABLE `balance_sheet`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_account_date` (`account_id`,`as_on_date`);

--
-- Indexes for table `company_settings`
--
ALTER TABLE `company_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `feedback_history`
--
ALTER TABLE `feedback_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sender` (`sender_id`);

--
-- Indexes for table `fiscal_periods`
--
ALTER TABLE `fiscal_periods`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_period_dates` (`start_date`,`end_date`),
  ADD KEY `closed_by` (`closed_by`);

--
-- Indexes for table `general_ledger`
--
ALTER TABLE `general_ledger`
  ADD PRIMARY KEY (`id`),
  ADD KEY `voucher_id` (`voucher_id`),
  ADD KEY `idx_account_date` (`account_id`,`voucher_date`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_token` (`token`),
  ADD KEY `idx_expiration` (`expiration`);

--
-- Indexes for table `profit_loss`
--
ALTER TABLE `profit_loss`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_account_period` (`account_id`,`period_from`,`period_to`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `google_id` (`google_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_users_role` (`role`),
  ADD KEY `idx_users_email` (`email`);

--
-- Indexes for table `vouchers`
--
ALTER TABLE `vouchers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `voucher_number` (`voucher_number`),
  ADD KEY `voucher_type_id` (`voucher_type_id`),
  ADD KEY `posted_by` (`posted_by`),
  ADD KEY `rejected_by` (`rejected_by`),
  ADD KEY `idx_voucher_date` (`voucher_date`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_vouchers_created_by` (`created_by`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `from_account_id` (`from_account_id`),
  ADD KEY `to_account_id` (`to_account_id`);

--
-- Indexes for table `voucher_details`
--
ALTER TABLE `voucher_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_account` (`account_id`),
  ADD KEY `idx_voucher_details_voucher` (`voucher_id`);

--
-- Indexes for table `voucher_types`
--
ALTER TABLE `voucher_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `account_chart`
--
ALTER TABLE `account_chart`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `audit_trail`
--
ALTER TABLE `audit_trail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=419;

--
-- AUTO_INCREMENT for table `balance_sheet`
--
ALTER TABLE `balance_sheet`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `company_settings`
--
ALTER TABLE `company_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `feedback_history`
--
ALTER TABLE `feedback_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `fiscal_periods`
--
ALTER TABLE `fiscal_periods`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `general_ledger`
--
ALTER TABLE `general_ledger`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=142;

--
-- AUTO_INCREMENT for table `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `profit_loss`
--
ALTER TABLE `profit_loss`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `vouchers`
--
ALTER TABLE `vouchers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT for table `voucher_details`
--
ALTER TABLE `voucher_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=108;

--
-- AUTO_INCREMENT for table `voucher_types`
--
ALTER TABLE `voucher_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `account_chart`
--
ALTER TABLE `account_chart`
  ADD CONSTRAINT `account_chart_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `audit_trail`
--
ALTER TABLE `audit_trail`
  ADD CONSTRAINT `audit_trail_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `balance_sheet`
--
ALTER TABLE `balance_sheet`
  ADD CONSTRAINT `balance_sheet_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `account_chart` (`id`);

--
-- Constraints for table `feedback_history`
--
ALTER TABLE `feedback_history`
  ADD CONSTRAINT `feedback_history_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `fiscal_periods`
--
ALTER TABLE `fiscal_periods`
  ADD CONSTRAINT `fiscal_periods_ibfk_1` FOREIGN KEY (`closed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `general_ledger`
--
ALTER TABLE `general_ledger`
  ADD CONSTRAINT `general_ledger_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `account_chart` (`id`),
  ADD CONSTRAINT `general_ledger_ibfk_2` FOREIGN KEY (`voucher_id`) REFERENCES `vouchers` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD CONSTRAINT `password_resets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `profit_loss`
--
ALTER TABLE `profit_loss`
  ADD CONSTRAINT `profit_loss_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `account_chart` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `vouchers`
--
ALTER TABLE `vouchers`
  ADD CONSTRAINT `vouchers_ibfk_1` FOREIGN KEY (`voucher_type_id`) REFERENCES `voucher_types` (`id`),
  ADD CONSTRAINT `vouchers_ibfk_2` FOREIGN KEY (`posted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `vouchers_ibfk_3` FOREIGN KEY (`rejected_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `vouchers_ibfk_4` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `vouchers_ibfk_5` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `vouchers_ibfk_6` FOREIGN KEY (`from_account_id`) REFERENCES `account_chart` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `vouchers_ibfk_7` FOREIGN KEY (`to_account_id`) REFERENCES `account_chart` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `voucher_details`
--
ALTER TABLE `voucher_details`
  ADD CONSTRAINT `voucher_details_ibfk_1` FOREIGN KEY (`voucher_id`) REFERENCES `vouchers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `voucher_details_ibfk_2` FOREIGN KEY (`account_id`) REFERENCES `account_chart` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
