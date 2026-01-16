<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$res = $conn->query("SELECT id, username, role FROM users");
while($row = $res->fetch_assoc()) {
    print_r($row);
}
?>
