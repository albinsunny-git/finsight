<?php
require 'config/Database.php';
$db = new Database();
$pdo = $db->connect();
$tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
echo "Tables:\n";
foreach ($tables as $table) {
    $count = $pdo->query("SELECT COUNT(*) FROM $table")->fetchColumn();
    echo "- $table: $count rows\n";
}
