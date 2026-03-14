<?php
require_once 'config/Database.php';

$db = new Database();
$conn = $db->getConnection();

$sql = "CREATE TABLE IF NOT EXISTS audit_trail (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    action VARCHAR(255) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INT NULL,
    old_value TEXT NULL,
    new_value TEXT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "Audit table created or exists"]);
} else {
    echo json_encode(["success" => false, "error" => $conn->error]);
}
?>
