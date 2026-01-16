<?php
require_once 'config/Database.php';

$db = new Database();
$conn = $db->getConnection();

// Add created_by column if not exists
try {
    $result = $conn->query("SHOW COLUMNS FROM users LIKE 'created_by'");
    if ($result->num_rows == 0) {
        $sql = "ALTER TABLE users ADD COLUMN created_by INT NULL";
        if ($conn->query($sql) === TRUE) {
            echo json_encode(["success" => true, "message" => "Column created_by added"]);
        } else {
            echo json_encode(["success" => false, "error" => $conn->error]);
        }
    } else {
        echo json_encode(["success" => true, "message" => "Column created_by already exists"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
