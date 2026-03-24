<?php
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
try {
    $c = new mysqli('localhost', 'root', '', 'finsight_db');
    $sql = "INSERT INTO vouchers (voucher_number, voucher_type_id, from_account_id, to_account_id, voucher_date, narration, status, created_by, posted_by, posted_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    $s = $c->prepare($sql);
    if (!$s) {
        echo "PREPARE ERROR: " . $c->error;
    } else {
        echo "SUCCESS PREPARE";
    }
} catch (Exception $e) {
    echo "EXCEPTION: " . $e->getMessage();
}
