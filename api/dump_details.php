<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$res = $conn->query("SELECT * FROM voucher_details LIMIT 10");
while($row = $res->fetch_assoc()) {
    print_r($row);
}
?>
