<?php
require_once __DIR__ . '/../config/Database.php';

$db = new Database();
$conn = $db->getConnection();

$result = $conn->query("SELECT * FROM voucher_types");
$types = [];
while ($row = $result->fetch_assoc()) {
    $types[] = $row;
}

echo json_encode($types, JSON_PRETTY_PRINT);
?>
