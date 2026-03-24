<?php
// FinSight Complete Database Seeding Script
require_once __DIR__ . '/../config/Database.php';

try {
    $db = new Database();
    $conn = $db->connect();
    
    echo "<h1>FinSight Database Seeder</h1>";

    // 1. Wipe old data
    echo "Cleaning up old data...<br>";
    $conn->exec("SET FOREIGN_KEY_CHECKS = 0");
    $conn->exec("DELETE FROM general_ledger");
    $conn->exec("DELETE FROM voucher_details");
    $conn->exec("DELETE FROM vouchers");
    $conn->exec("DELETE FROM account_chart");
    $conn->exec("DELETE FROM voucher_types");
    $conn->exec("SET FOREIGN_KEY_CHECKS = 1");

    // 2. Voucher Types
    echo "Seeding Voucher Types...<br>";
    $vt_stmt = $conn->prepare("INSERT INTO voucher_types (name, description) VALUES (?, ?)");
    $voucher_types = [
        ['Receipt', 'For money received'],
        ['Payment', 'For money paid out'],
        ['Journal', 'For adjustment entries']
    ];
    foreach ($voucher_types as $vt) $vt_stmt->execute($vt);

    // 3. Account Chart
    echo "Seeding Account Chart...<br>";
    $acc_stmt = $conn->prepare("INSERT INTO account_chart (code, name, type, sub_type, opening_balance, is_active) VALUES (?, ?, ?, ?, ?, 1)");
    $accounts = [
        ['1001', 'Cash in Hand', 'Asset', 'Cash', 500.00],
        ['1002', 'HDFC Bank', 'Asset', 'Bank', 5000.00],
        ['2001', 'Rent Payable', 'Liability', 'Liability', 0.00],
        ['3001', 'Owner Capital', 'Equity', 'Equity', 5500.00],
        ['4001', 'Sales Revenue', 'Income', 'Income', 0.00],
        ['5001', 'Office Rent', 'Expense', 'Expense', 0.00],
        ['5002', 'Employee Salary', 'Expense', 'Expense', 0.00]
    ];
    foreach ($accounts as $acc) $acc_stmt->execute($acc);

    // 4. Create Vouchers (Sample Transactions)
    echo "Seeding Sample Transactions...<br>";
    $voucher_stmt = $conn->prepare("INSERT INTO vouchers (voucher_number, voucher_type_id, voucher_date, narration, status, created_by) VALUES (?, ?, ?, ?, 'Posted', 1)");
    $vd_stmt = $conn->prepare("INSERT INTO voucher_details (voucher_id, account_id, debit, credit, description) VALUES (?, ?, ?, ?, ?)");
    $gl_stmt = $conn->prepare("INSERT INTO general_ledger (account_id, voucher_id, voucher_date, debit, credit) VALUES (?, ?, ?, ?, ?)");

    // Sample Transaction: Sales for $2000 in Cash
    $voucher_stmt->execute(['RV-001', 1, date('Y-m-d'), 'Customer Sales']);
    $vId = $conn->lastInsertId();
    
    // Debit Cash (1001), Credit Sales Revenue (4001)
    $vd_stmt->execute([$vId, 1, 2000.00, 0.00, 'Sales Receipt']);
    $vd_stmt->execute([$vId, 5, 0.00, 2000.00, 'Sales Revenue']); 
    
    // Manual GL Post
    $gl_stmt->execute([1, $vId, date('Y-m-d'), 2000.00, 0.00]);
    $gl_stmt->execute([5, $vId, date('Y-m-d'), 0.00, 2000.00]);

    // Sample Transaction: Rent Paid $1200 from Bank
    $voucher_stmt->execute(['PV-001', 2, date('Y-m-d'), 'September Rent']);
    $vId = $conn->lastInsertId();
    $vd_stmt->execute([$vId, 6, 1200.00, 0.00, 'Rent Paid']); 
    $vd_stmt->execute([$vId, 2, 0.00, 1200.00, 'Bank Payment']); 
    
    // Manual GL Post
    $gl_stmt->execute([6, $vId, date('Y-m-d'), 1200.00, 0.00]);
    $gl_stmt->execute([2, $vId, date('Y-m-d'), 0.00, 1200.00]);

    echo "✅ <b>Database Seeded Successfully!</b><br>";
    echo "<p>Please return to the app and refresh. You should now see Income, Expense and Balances.</p>";
    echo "<a href='../index.html'>Home</a>";

} catch (Exception $e) {
    echo "<h1>❌ Seeder Failed</h1>";
    echo "Error: " . $e->getMessage();
}
?>
