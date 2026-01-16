<?php
require_once __DIR__ . '/config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$res = $conn->query("DESCRIBE users");
while ($row = $res->fetch_assoc()) {
    echo "COL: {$row['Field']} | NULL: {$row['Null']} | KEY: {$row['Key']} | DEF: " . var_export($row['Default'], true) . " | EXTRA: {$row['Extra']}\n";
}
?>
