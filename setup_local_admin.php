<?php
/**
 * Setup Local Admin Script
 * Run this by visiting http://localhost/finsight/setup_local_admin.php
 */

require_once __DIR__ . '/config/Database.php';

$db = new Database();
$conn = $db->getConnection();

// 1. Ensure users table exists (it should, but just in case)
// We already know it exists from our CLI check.

// 2. Add a default admin user if the table is empty
$check = $db->query("SELECT id FROM users LIMIT 1");
if ($check->num_rows === 0) {
    $email = 'admin@finsight.com';
    $username = 'admin';
    $password = 'Admin@123';
    $firstName = 'System';
    $lastName = 'Admin';
    $role = 'admin';
    
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);
    
    $stmt = $db->prepare("INSERT INTO users (email, username, password_hash, first_name, last_name, role, is_active) VALUES (?, ?, ?, ?, ?, ?, 1)");
    $stmt->bind_param("ssssss", $email, $username, $passwordHash, $firstName, $lastName, $role);
    
    if ($stmt->execute()) {
        echo "<h1>✅ Local Admin Created!</h1>";
        echo "<p>You can now log in using:</p>";
        echo "<ul>";
        echo "<li><b>Email/Username:</b> $username</li>";
        echo "<li><b>Password:</b> $password</li>";
        echo "</ul>";
        echo "<p><a href='index.html'>Go to Login Page</a></p>";
    } else {
        echo "<h1>❌ Failed to create admin</h1>";
        echo "<p>Error: " . $conn->error . "</p>";
    }
} else {
    echo "<h1>ℹ️ Users already exist</h1>";
    echo "<p>Your database already has users. No changes made.</p>";
    echo "<p><a href='index.html'>Go to Login Page</a></p>";
}
?>
