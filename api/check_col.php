<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$result = $conn->query("DESCRIBE users");
while ($row = $result->fetch_assoc()) {
    if ($row['Field'] == 'created_by') {
        print_r($row);
    }
}
?>
