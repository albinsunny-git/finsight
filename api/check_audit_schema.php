<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$result = $conn->query("DESCRIBE audit_trail");
while ($row = $result->fetch_assoc()) {
    echo $row['Field'] . " - " . $row['Type'] . "\n";
}
?>
