<?php
error_reporting(E_ERROR | E_PARSE);
require_once __DIR__ . '/../config/Database.php';

$db = new Database();
$conn = $db->getConnection();

$tables = ['account_chart', 'general_ledger', 'vouchers', 'voucher_details', 'voucher_types', 'users'];

foreach ($tables as $table) {
    echo "Table: $table\n";
    $result = $conn->query("DESCRIBE $table");
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            echo "{$row['Field']} - {$row['Type']}\n";
        }
    } else {
        echo "Error describing $table: " . $conn->error . "\n";
    }
    echo "-------------------\n";
}
?>
