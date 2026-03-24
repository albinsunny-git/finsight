<?php
$url = 'http://localhost/finsight/api/vouchers.php?action=create';
$data = [
    'voucher_type_id' => 1,
    'voucher_date' => '2026-03-24',
    'narration' => 'Test voucher',
    'status' => 'Draft',
    'details' => [
        [
            'account_id' => 1,
            'debit' => 100,
            'credit' => 0,
            'description' => 'Test dev'
        ]
    ]
];

$options = [
    'http' => [
        'header'  => "Content-Type: application/json\r\n",
        'method'  => 'POST',
        'content' => json_encode($data)
    ]
];

$context  = stream_context_create($options);
$result = file_get_contents($url, false, $context);

echo $result;
