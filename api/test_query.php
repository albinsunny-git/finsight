<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$asOnDate = date('Y-m-d');
$sql = "SELECT ac.name, SUM(gl.debit) as total_debit 
        FROM account_chart ac 
        LEFT JOIN general_ledger gl ON ac.id = gl.account_id AND DATE(gl.voucher_date) <= '$asOnDate'
        WHERE ac.id = 3
        GROUP BY ac.id";
$res = $db->query($sql);
print_r($res->fetch_assoc());
?>
