<?php
require_once __DIR__ . '/config/Database.php';

$db = new Database();
$conn = $db->getConnection();
$result = $conn->query("ALTER TABLE users ADD COLUMN profile_image VARCHAR(255) NULL");

if ($result) {
    echo "Column 'profile_image' added successfully.\n";
} else {
    echo "Error adding column: " . $conn->error . "\n";
}
?>
