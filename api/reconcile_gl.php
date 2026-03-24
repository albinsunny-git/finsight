<?php
require_once __DIR__ . '/../config/Database.php';

$db = new Database();
echo "Connected to Database.\n";
var_dump($db);
$conn = $db->getConnection();

echo "Starting Reconciliation of General Ledger...\n";

$conn->begin_transaction();

try {
    // 1. Clear existing General Ledger
    echo "Clearing General Ledger...\n";
    $conn->query("DELETE FROM general_ledger");

    // 2. Reset account balances to Opening Balance
    echo "Resetting Account Chart Balances...\n";
    $conn->query("UPDATE account_chart SET balance = opening_balance");

    // 3. Re-process all Posted vouchers
    echo "Fetching all Posted Vouchers...\n";
    $vouchersRes = $conn->query("SELECT id, voucher_date FROM vouchers WHERE status = 'Posted' ORDER BY voucher_date ASC, id ASC");
    if (!$vouchersRes) {
        throw new Exception("Voucher list query failed: " . ($conn->error ?? 'Unknown error'));
    }
    
    $vCount = 0;
    while ($v = $vouchersRes->fetch_assoc()) {
        $vId = $v['id'];
        $vDate = $v['voucher_date'];
        
        $detailsRes = $conn->query("SELECT account_id, debit, credit FROM voucher_details WHERE voucher_id = $vId");
        
        while ($d = $detailsRes->fetch_assoc()) {
            $accId = $d['account_id'];
            $dr = $d['debit'];
            $cr = $d['credit'];
            
            // Insert into GL
            $conn->query("INSERT INTO general_ledger (account_id, voucher_id, voucher_date, debit, credit, running_balance) 
                          VALUES ($accId, $vId, '$vDate', $dr, $cr, 0)");
            
            // Update Account Balance
            $conn->query("UPDATE account_chart SET balance = balance + ($dr - $cr) WHERE id = $accId");
        }
        $vCount++;
    }

    $conn->commit();
    echo "Reconciliation SUCCESSFUL! Processed $vCount vouchers.\n";

} catch (Exception $e) {
    $conn->rollback();
    echo "RECONCILIATION FAILED: " . $e->getMessage() . "\n";
}
?>
