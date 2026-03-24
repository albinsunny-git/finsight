<?php
require_once __DIR__ . '/../config/Database.php';

$db = new Database();
$conn = $db->getConnection();

$queries = [
    "ALTER TABLE general_ledger ADD INDEX idx_acc_date (account_id, voucher_date)",
    "ALTER TABLE general_ledger ADD INDEX idx_date (voucher_date)",
    "ALTER TABLE vouchers ADD INDEX idx_status_date (status, voucher_date)",
    "ALTER TABLE voucher_details ADD INDEX idx_voucher_id (voucher_id)",
    "ALTER TABLE voucher_details ADD INDEX idx_acc_id (account_id)"
];

foreach ($queries as $sql) {
    echo "Executing: $sql... ";
    if ($conn->query($sql)) {
        echo "SUCCESS!\n";
    } else {
        echo "FAILED (maybe already exists): " . $conn->error . "\n";
    }
}
?>
