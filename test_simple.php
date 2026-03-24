<?php
require_once __DIR__ . '/config/Database.php';
$db = new Database();
$res = $db->query("SELECT COUNT(*) as cnt FROM vouchers");
if ($res) {
    $row = $res->fetch_assoc();
    echo "Voucher Count: " . $row['cnt'] . "\n";
} else {
    echo "Query failed\n";
}
?>
