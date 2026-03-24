<?php
require_once 'config/Database.php';

$db = new Database();
$data = [
    'voucher_type_id' => 1,
    'voucher_date' => '2026-03-24',
    'narration' => 'Test',
    'status' => 'Draft',
    'details' => [
        ['account_id' => 1, 'debit' => 100, 'credit' => 0, 'description' => 'Test']
    ]
];

$userId = 1;
$status = 'Draft';
$approvedBy = null;
$approvedAt = null;
$voucherNumber = 'V-' . date('Ymd') . '-' . rand(1000, 9999);

try {
    $stmt = $db->prepare("INSERT INTO vouchers (voucher_number, voucher_type_id, from_account_id, to_account_id, voucher_date, narration, status, created_by, posted_by, posted_at) 
                               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $fromAcc = $data['from_account_id'] ?? null;
    $toAcc = $data['to_account_id'] ?? null;
    
    // Will throw exception here if prepare failed
    $stmt->bind_param("siiisssiss", $voucherNumber, $data['voucher_type_id'], $fromAcc, $toAcc, $data['voucher_date'], $data['narration'], $status, $userId, $approvedBy, $approvedAt);
    
    if (!$stmt->execute()) {
        echo "EXECUTE ERROR: " . $stmt->error;
    } else {
        echo "SUCCESS INSERT VOUCHER\n";
    }
} catch (Throwable $e) {
    echo "CAUGHT ERROR: " . $e->getMessage() . "\n";
}
