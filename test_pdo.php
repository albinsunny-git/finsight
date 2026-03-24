<?php
try {
    $c = new PDO('mysql:host=localhost;port=3306;dbname=finsight_db;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
        PDO::ATTR_PERSISTENT => true,
        PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4"
    ]);

    $sql = "INSERT INTO vouchers (voucher_number, voucher_type_id, from_account_id, to_account_id, voucher_date, narration, status, created_by, posted_by, posted_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    $stmt = $c->prepare($sql);

    echo "SUCCESS PDO PREPARE";
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage();
}
