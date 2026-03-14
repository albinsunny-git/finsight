<?php
require_once __DIR__ . '/../config/Database.php';

$db = new Database();
$conn = $db->getConnection();

$username = 'testadmin';
$email = 'testadmin@example.com';
$password = 'Password@123';
$role = 'admin';

// Check if exists
$stmt = $db->prepare("SELECT id FROM users WHERE username = ?");
$stmt->bind_param("s", $username);
$stmt->execute();
$res = $stmt->get_result();

if ($res->num_rows > 0) {
    echo "User $username already exists. Updating password...\n";
    $hash = hashPassword($password);
    $stmt = $db->prepare("UPDATE users SET password_hash = ? WHERE username = ?");
    $stmt->bind_param("ss", $hash, $username);
    if ($stmt->execute()) {
        echo "Password updated to '$password'.\n";
    } else {
        echo "Failed to update password.\n";
    }
} else {
    echo "Creating user $username...\n";
    $hash = hashPassword($password);
    $stmt = $db->prepare("INSERT INTO users (username, email, password_hash, first_name, last_name, role, is_active) VALUES (?, ?, ?, 'Test', 'Admin', ?, 1)");
    $stmt->bind_param("ssss", $username, $email, $hash, $role);
    if ($stmt->execute()) {
        echo "User created. Password: '$password'\n";
    } else {
        echo "Failed to create user: " . $conn->error . "\n";
    }
}
?>
