<?php
require_once __DIR__ . '/../config/Database.php';

$db = new Database();

$indexes = [
    ['table' => 'users', 'column' => 'username', 'name' => 'idx_username'],
    ['table' => 'vouchers', 'column' => 'voucher_date', 'name' => 'idx_voucher_date'],
    ['table' => 'voucher_details', 'column' => 'account_id', 'name' => 'idx_account_id'],
    ['table' => 'voucher_details', 'column' => 'voucher_id', 'name' => 'idx_voucher_id']
];

echo "Database Indexing Utility\n";
echo "--------------------------\n";

foreach ($indexes as $idx) {
    try {
        echo "Processing Index: {$idx['name']} on {$idx['table']}({$idx['column']})... ";
        
        // Check if index exists
        $check = $db->query("SELECT COUNT(*) as exists_count 
                           FROM INFORMATION_SCHEMA.STATISTICS 
                           WHERE table_schema = DATABASE() 
                           AND table_name = '{$idx['table']}' 
                           AND index_name = '{$idx['name']}'");
        
        $row = $check->fetch_assoc();
        
        if ($row['exists_count'] > 0) {
            echo "Already exists.\n";
        } else {
            $db->query("CREATE INDEX {$idx['name']} ON {$idx['table']}({$idx['column']})");
            echo "Created successfully.\n";
        }
    } catch (Exception $e) {
        echo "Error: " . $e->getMessage() . "\n";
    }
}

echo "\nDone.\n";
