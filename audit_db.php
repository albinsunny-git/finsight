<?php
require_once __DIR__ . '/config/Database.php';

try {
    $db = new Database();
    $conn = $db->connect();
    
    echo "<h1>Database Table Audit</h1>";
    
    $tables = ['users', 'account_chart', 'voucher_types', 'vouchers', 'voucher_details', 'general_ledger', 'audit_trail'];
    
    foreach ($tables as $table) {
        try {
            $stmt = $conn->query("SELECT COUNT(*) FROM $table");
            $count = $stmt->fetchColumn();
            echo "Table <b>$table</b>: ✅ EXISTS ($count rows)<br>";
        } catch (PDOException $e) {
            echo "Table <b>$table</b>: ❌ MISSING (" . $e->getMessage() . ")<br>";
        }
    }
    
    // Check if there are any accounts
    $stmt = $conn->query("SELECT id, name, type FROM account_chart LIMIT 5");
    $accounts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    if ($accounts) {
        echo "<h3>First 5 Accounts:</h3><pre>";
        print_r($accounts);
        echo "</pre>";
    } else {
        echo "<h3>No accounts found in account_chart.</h3>";
    }

} catch (Exception $e) {
    echo "<h1>❌ Audit Failed</h1>";
    echo "Error: " . $e->getMessage();
}
?>
