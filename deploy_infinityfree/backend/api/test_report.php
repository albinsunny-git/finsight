<?php
session_start();
$_SESSION['user_id'] = 1; // Assuming admin is 1
$_SESSION['role'] = 'administrator';
require_once __DIR__ . '/reports.php';
$_GET['as_on_date'] = '2026-01-06';
$controller = new ReportController();
$controller->getBalanceSheet();
?>
