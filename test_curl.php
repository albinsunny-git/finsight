<?php
$url = 'http://localhost/finsight/api/vouchers.php?action=create';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_POST, 1);
$payload = json_encode([
    'voucher_type_id' => 1,
    'voucher_date' => '2026-03-24',
    'narration' => 'Test',
    'status' => 'Draft',
    'details' => [['account_id' => 1, 'debit' => 100, 'credit' => 0, 'description' => 'Test'], ['account_id' => 2, 'debit' => 0, 'credit' => 100, 'description' => 'Test']]
]);
curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json', 'Cookie: PHPSESSID=' . (isset($_GET['s']) ? $_GET['s'] : '')));

$output = curl_exec($ch);
echo $output;
curl_close($ch);
