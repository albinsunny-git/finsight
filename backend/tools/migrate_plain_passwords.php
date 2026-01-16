<?php
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../api/auth.php';

$db = new Database();
$conn = $db->getConnection();

$result = $db->query("SELECT id, password_hash FROM users");
$updated = 0;
while ($row = $result->fetch_assoc()) {
    $id = $row['id'];
    $pw = $row['password_hash'];
    if (strpos($pw, '$2y$') === 0 || strpos($pw, '$2b$') === 0 || strpos($pw, '$argon2') === 0) {
        continue;
    }
    // Treat as plaintext and migrate
    $newHash = hashPassword($pw);
    $stmt = $db->prepare("UPDATE users SET password_hash = ? WHERE id = ?");
    $stmt->bind_param("si", $newHash, $id);
    $stmt->execute();
    $stmt->close();
    $updated++;
}

echo "Migration complete. Updated $updated users to bcrypt hashes.\n";

$db->closeConnection();
?>