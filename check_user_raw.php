<?php
$conn = mysqli_init();
$conn->real_connect('127.0.0.1', 'root', '', 'finsight_db');
if ($conn->connect_error) { die("Conn failed: " . $conn->connect_error); }

$email = 'admin@example.com';
$stmt = $conn->prepare("SELECT id, email, role FROM users WHERE email = ?");
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
