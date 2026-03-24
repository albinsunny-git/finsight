<?php
$_GET['action'] = 'create';
$_SESSION['role'] = 'admin';
$_SESSION['user_id'] = 1;

$payload = json_encode([
    'voucher_type_id' => 1,
    'voucher_date' => '2026-03-24',
    'narration' => 'Test',
    'status' => 'Draft',
    'details' => [
        ['account_id' => 1, 'debit' => 100, 'credit' => 0, 'description' => 'Test']
    ]
]);

// Mock php://input
function file_get_contents_mock($file) {
    global $payload;
    if ($file === 'php://input') return $payload;
    return \file_get_contents($file);
}

// Rename the internal function to mimic the mock if needed, but easier to just write the logic here.
require_once 'config/Database.php';
$db = new Database();
// ...
