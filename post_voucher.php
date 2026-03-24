<?php
$_SERVER['REMOTE_ADDR'] = '127.0.0.1';
$_SERVER['HTTP_USER_AGENT'] = 'CLI';

session_start();
$_SESSION['user_id'] = 1;
$_SESSION['role'] = 'admin';

// Simulate JSON input
$json = json_encode(['voucher_id' => 14]);
file_put_contents('php://memory', $json);
// Wait, we can't mock php://input easily with file_get_contents('php://input'). 
// Instead, let's just use the Database and mimic it.
require 'api/vouchers.php';

$voucher = new VoucherController();
// Better: just run SQL manually because postVoucher() uses file_get_contents('php://input') which is hard to mock in CLI.
?>
