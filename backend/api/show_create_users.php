<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$result = $conn->query("SHOW CREATE TABLE users");
$row = $result->fetch_assoc();
echo $row['Create Table'];
?>
