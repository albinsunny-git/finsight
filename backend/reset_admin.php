<?php
ini_set('display_errors', 0);
require_once 'config/Database.php';

$db = new Database();
$conn = $db->getConnection();
header('Content-Type: text/plain');

try {
    $email = 'admin@finsight.com';
    $username = 'admin';
    $password = 'Admin@123';
    $hash = hashPassword($password);

    // Check exist by email OR username
    $sql = "SELECT id, email FROM users WHERE email='$email' OR username='$username'";
    $res = $conn->query($sql);
    
    if ($res && $res->num_rows > 0) {
        $row = $res->fetch_assoc();
        echo "Updating existing user (ID: " . $row['id'] . ")...\n";
        
        // Update password and ensure role/active
        // Also ensure email matches what we promise the user
        $conn->query("UPDATE users SET password_hash='$hash', role='admin', is_active=1, email='$email', username='$username' WHERE id=" . $row['id']);
        echo "Updated.\n";
    } else {
        echo "Inserting...\n";
        $sql = "INSERT INTO users (email, username, password_hash, first_name, last_name, role, department, is_active, phone) 
                VALUES ('$email', '$username', '$hash', 'Super', 'Admin', 'admin', 'IT', 1, '1234567890')";
        
        if ($conn->query($sql) === TRUE) {
            echo "Inserted.\n";
        } else {
            throw new Exception("Insert Error: " . $conn->error);
        }
    }
    
    echo "Done.\n\nCredentials:\nEmail: $email\nPassword: $password";
} catch (Throwable $e) {
    echo "Fatal Error: " . $e->getMessage() . "\n";
}
?>
