<?php
// Suppress warnings for CLI
error_reporting(E_ERROR | E_PARSE);
require_once __DIR__ . '/../config/Database.php';

$db = new Database();
$conn = $db->getConnection();

echo "Checking Users...\n";
$result = $conn->query("SELECT id, email, username, password_hash, is_active FROM users");

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        echo "ID: " . $row['id'] . " | Email: " . $row['email'] . " | User: " . $row['username'] . " | Active: " . $row['is_active'] . " | Hash: " . substr($row['password_hash'], 0, 10) . "...\n";
    }
} else {
    echo "No users found.\n";
}
?>
