<?php
require_once __DIR__ . '/backend/config/Database.php';

$db = new Database();
$email = 'admin@example.com';
$stmt = $db->prepare("SELECT id, email, role FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    echo "User exists: ";
    print_r($result->fetch_assoc());
} else {
    echo "User NOT found.\n";
}
?>
