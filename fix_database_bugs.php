<?php
require_once __DIR__ . '/config/Database.php';
$db = new Database();
$conn = $db->getConnection();

echo "<h1>Updating Database Schema...</h1>";

// 1. Alter audit_trail to allow NULL user_id for system/failed login logs
$sql = "ALTER TABLE audit_trail MODIFY user_id INT NULL";
try {
    $db->query($sql);
    echo "<p>✅ Successfully made audit_trail.user_id NULLABLE.</p>";
} catch (Exception $e) {
    echo "<p>❌ Failed to modify audit_trail.user_id: " . $e->getMessage() . "</p>";
}

// 2. Clear old audit logs with user_id = 0 which might cause FK issues
$sql = "UPDATE audit_trail SET user_id = NULL WHERE user_id = 0";
try {
    $db->query($sql);
    echo "<p>✅ Successfully updated old logs with user_id=0 to NULL.</p>";
} catch (Exception $e) {
     echo "<p>❌ Failed to update old logs: " . $e->getMessage() . "</p>";
}

echo "<p><a href='index.html'>Back to system</a></p>";
?>
