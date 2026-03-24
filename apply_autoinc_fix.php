<?php
/**
 * Refined AUTO_INCREMENT Fix for Railway tables.
 */
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/Database.php';

echo "=== Applying Robust AUTO_INCREMENT Fix ===\n\n";

try {
    $db = new Database();
    $conn = $db->connect();
    
    $tables = [
        'users',
        'account_chart',
        'voucher_types',
        'vouchers',
        'voucher_details',
        'general_ledger',
        'audit_trail',
        'notifications',
        'password_resets',
        'fiscal_periods',
        'balance_sheet',
        'profit_loss'
    ];
    
    foreach ($tables as $table) {
        echo "Processing $table... ";
        try {
            // First, try to add primary key if missing on id
            try {
               @$conn->exec("ALTER TABLE `$table` ADD PRIMARY KEY (id)");
            } catch (Exception $e) {
               // Primary key may already exist, ignore this error
            }

            // Now, modify to be auto_increment
            $conn->exec("ALTER TABLE `$table` MODIFY COLUMN id INT AUTO_INCREMENT");
            echo "SUCCESS!\n";
        } catch (Exception $e) {
            echo "FAILED: " . $e->getMessage() . "\n";
        }
    }
    
    echo "\n=== Verifying Fix ===\n";
    foreach ($tables as $table) {
        $stmt = $conn->query("SHOW COLUMNS FROM `$table` WHERE Field = 'id'");
        $col = $stmt->fetch(PDO::FETCH_ASSOC);
        $hasAutoInc = stripos($col['Extra'], 'auto_increment') !== false;
        echo "$table.id: Extra=" . $col['Extra'] . " [" . ($hasAutoInc ? 'OK' : 'FAIL') . "]\n";
    }
    
    echo "\n=== Fix Complete ===\n";
} catch (Exception $e) {
    echo "CRITICAL ERROR: " . $e->getMessage() . "\n";
}
