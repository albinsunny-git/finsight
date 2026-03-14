<?php
require_once 'config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$sql = "ALTER TABLE users MODIFY phone VARCHAR(20) NULL";
if ($conn->query($sql) === TRUE) {
    echo "Phone modified to NULLable.";
} else {
    echo "Error modifying phone: " . $conn->error;
}
?>
