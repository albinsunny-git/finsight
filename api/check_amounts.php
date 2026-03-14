<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$res = $conn->query("SELECT debit, credit FROM voucher_details WHERE debit > 0 OR credit > 0 LIMIT 5");
while($row = $res->fetch_assoc()) {
    echo "Debit: " . $row['debit'] . ", Credit: " . $row['credit'] . "\n";
}
?>
