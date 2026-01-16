<?php
session_start();
$_SESSION['user_id'] = 30; // Check your admin ID
$_SESSION['role'] = 'manager'; // or admin
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$res = $conn->query("SELECT id FROM users WHERE email='admin@example.com'");
$_SESSION['user_id'] = $res->fetch_assoc()['id'];
$_SESSION['role'] = 'admin';

$_GET['type'] = 'balance-sheet';
require_once __DIR__ . '/reports.php';
?>
