<?php
$conn = new mysqli('localhost', 'root', '', 'finsight_db');
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$conn->query("SET FOREIGN_KEY_CHECKS = 0");

echo "Testing Raw User Insertion...\n";
$pass = password_hash('admin123', PASSWORD_DEFAULT);
$sql = "INSERT INTO `users` SET 
        `first_name` = 'Admin', 
        `last_name` = 'User', 
        `email` = 'admin@example.com', 
        `username` = 'admin', 
        `password_hash` = '$pass', 
        `role` = 'admin', 
        `department` = 'Finance', 
        `is_active` = 1, 
        `created_by` = NULL";

if ($conn->query($sql)) {
    echo "User inserted successfully.\n";
} else {
    echo "User insertion failed: " . $conn->error . "\n";
}
$conn->close();
?>
