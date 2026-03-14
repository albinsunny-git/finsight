<?php
// backend/api/system_check.php
header('Content-Type: text/plain');
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "--- System Check ---\n";

require_once __DIR__ . '/../config/config.php';

echo "DB_HOST: " . DB_HOST . "\n";
echo "DB_USER: " . DB_USER . "\n";
echo "DB_NAME: " . DB_NAME . "\n";

$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

if ($conn->connect_error) {
    die("Connection Failed: " . $conn->connect_error . "\n");
}

echo "Connection Successful!\n";

$result = $conn->query("SELECT id, username, email, role, is_active FROM users");
if ($result) {
    echo "Users Found: " . $result->num_rows . "\n";
    while ($row = $result->fetch_assoc()) {
        echo " - ID: {$row['id']}, User: {$row['username']}, Email: {$row['email']}, Role: {$row['role']}, Active: {$row['is_active']}\n";
    }
} else {
    echo "Error querying users: " . $conn->error . "\n";
}

$conn->close();
?>
