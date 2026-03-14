<?php
require_once 'config/Database.php';
$db = new Database();
$res = $db->query("SHOW COLUMNS FROM users");
if ($res) {
    while ($row = $res->fetch_assoc()) {
        echo $row['Field'] . "\n";
    }
} else {
    echo "Failed to describe users";
}
?>
