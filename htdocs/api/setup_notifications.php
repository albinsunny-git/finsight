<?php
require_once __DIR__ . '/../config/Database.php';

$db = new Database();
$conn = $db->getConnection();

$sql = file_get_contents(__DIR__ . '/../sql/create_notifications_table.sql');

if ($conn->multi_query($sql)) {
    echo "Notifications table created successfully.";
} else {
    echo "Error creating table: " . $conn->error;
}
?>
