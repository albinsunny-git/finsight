<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();

echo "Modifying account_chart table...\n";
$sql = "ALTER TABLE account_chart MODIFY created_by int(11) DEFAULT NULL";

if ($conn->query($sql)) {
    echo "Table modified successfully.\n";
} else {
    echo "Table modification failed: " . $conn->error . "\n";
}
?>
