<?php
require_once __DIR__ . '/config/Database.php';
$db = new Database();
$conn = $db->connect();

echo "<h1>Restoring Default Users...</h1>";

$users = [
    ['admin@finsight.com', 'admin', password_hash('Admin@123', PASSWORD_BCRYPT), 'System', 'Admin', 'admin'],
    ['accountant@finsight.com', 'accountant', password_hash('Accountant@123', PASSWORD_BCRYPT), 'Jane', 'Account', 'accountant']
];

$stmt = $conn->prepare("INSERT INTO users (email, username, password_hash, first_name, last_name, role, is_active) VALUES (?, ?, ?, ?, ?, ?, 1)");

foreach ($users as $u) {
    try {
        $stmt->execute($u);
        echo "✅ Created user: " . $u[1] . "<br>";
    } catch (Exception $e) {
        echo "ℹ️ User already exists or error: " . $e->getMessage() . "<br>";
    }
}
?>
