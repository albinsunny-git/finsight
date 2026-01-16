<?php
require_once __DIR__ . '/../config/Database.php';

$db = new Database();
$conn = $db->getConnection();

function createUser($db, $email, $username, $password, $first, $last, $role) {
    // Check exists
    $stmt = $db->prepare("SELECT id FROM users WHERE LOWER(email) = LOWER(?) OR LOWER(username) = LOWER(?)");
    $stmt->bind_param("ss", $email, $username);
    $stmt->execute();
    $res = $stmt->get_result();
    if ($res->num_rows > 0) {
        $stmt->close();
        echo "User $email or $username already exists\n";
        return;
    }
    $stmt->close();

    $hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 10]);
    $stmt = $db->prepare("INSERT INTO users (email, username, password_hash, first_name, last_name, role, is_active, created_at) VALUES (?, ?, ?, ?, ?, ?, 1, NOW())");
    $stmt->bind_param("ssssss", $email, $username, $hash, $first, $last, $role);
    if ($stmt->execute()) {
        echo "Created user: $email ($username) role=$role\n";
    } else {
        echo "Failed to create $email: " . $stmt->error . "\n";
    }
    $stmt->close();
}

echo "Creating sample users...\n";
createUser($db, 'accountant@finsight.com', 'accountant', 'Acct@123', 'Account', 'User', 'accountant');
createUser($db, 'manager@finsight.com', 'manager', 'Mgr@123', 'Manager', 'User', 'manager');
echo "Done.\n";

$db->closeConnection();
?>