<?php
require_once __DIR__ . '/../config/Database.php';

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    echo "Updating schema...\n";
    $conn->query("ALTER TABLE vouchers MODIFY COLUMN status ENUM('Draft', 'Posted', 'Rejected', 'Pending Approval') DEFAULT 'Draft'");
    
    if ($conn->error) {
        echo "Error: " . $conn->error;
    } else {
        echo "Schema updated successfully!";
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
?>
