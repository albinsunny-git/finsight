<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$res = $conn->query("SELECT status, count(*) as count FROM vouchers GROUP BY status");
while($row = $res->fetch_assoc()) {
    echo $row['status'] . ": " . $row['count'] . "\n";
}
$res = $conn->query("SELECT count(*) as count FROM general_ledger");
echo "General Ledger entries: " . $res->fetch_assoc()['count'] . "\n";
?>
