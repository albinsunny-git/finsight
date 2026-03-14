<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$result = $conn->query("DESCRIBE users");
echo str_pad("Field", 20) . str_pad("Type", 20) . str_pad("Null", 10) . str_pad("Key", 10) . str_pad("Default", 20) . str_pad("Extra", 20) . "\n";
echo str_repeat("-", 100) . "\n";
while ($row = $result->fetch_assoc()) {
    echo str_pad($row['Field'], 20) . 
         str_pad($row['Type'], 20) . 
         str_pad($row['Null'], 10) . 
         str_pad($row['Key'], 10) . 
         str_pad($row['Default'], 20) . 
         str_pad($row['Extra'], 20) . "\n";
}
?>
