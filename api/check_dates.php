<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$res = $conn->query("SELECT voucher_date FROM vouchers LIMIT 5");
while($row = $res->fetch_assoc()) {
    echo $row['voucher_date'] . "\n";
}
echo "Current Date: " . date('Y-m-d') . "\n";
?>
