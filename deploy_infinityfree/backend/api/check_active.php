<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$res = $conn->query("SELECT is_active, count(*) as count FROM account_chart GROUP BY is_active");
while($row = $res->fetch_assoc()) {
    echo $row['is_active'] . ": " . $row['count'] . "\n";
}
?>
