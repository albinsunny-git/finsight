<?php
require_once __DIR__ . '/config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$res = $conn->query("SHOW CREATE TABLE users");
$row = $res->fetch_assoc();
echo $row['Create Table'];
?>
