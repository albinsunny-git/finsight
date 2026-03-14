<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();
echo "MySQL Version: " . $conn->server_info . "\n";
?>
