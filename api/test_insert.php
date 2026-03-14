<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();

$conn->query("SET FOREIGN_KEY_CHECKS = 0");

echo "Testing User Insertion...\n";
$pass = password_hash('admin123', PASSWORD_DEFAULT);
$sql = "INSERT INTO users (id, first_name, last_name, email, username, password_hash, role, department, is_active, created_by) 
        VALUES (1, 'Admin', 'User', 'admin@example.com', 'admin', '$pass', 'admin', 'Finance', 1, 1)";

if ($conn->query($sql)) {
    echo "User inserted successfully.\n";
} else {
    echo "User insertion failed: " . $conn->error . "\n";
}

$adminId = $conn->insert_id;

echo "Testing Voucher Insertion...\n";
$vNum = 'TEST-' . time();
$sql = "INSERT INTO vouchers (voucher_number, voucher_type_id, voucher_date, narration, status, created_by, posted_by, posted_at, total_debit, total_credit) 
        VALUES ('$vNum', 1, CURDATE(), 'Test Narration', 'Posted', $adminId, $adminId, NOW(), 100.00, 100.00)";

if ($conn->query($sql)) {
    echo "Voucher inserted successfully.\n";
} else {
    echo "Voucher insertion failed: " . $conn->error . "\n";
}
?>
