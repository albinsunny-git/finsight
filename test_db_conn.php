<?php
$hosts = ['127.0.0.1', 'localhost', '::1'];
foreach ($hosts as $host) {
    echo "Testing $host:3306... ";
    try {
        $conn = new PDO("mysql:host=$host;port=3306", 'root', '');
        echo "SUCCESS!\n";
    } catch (PDOException $e) {
        echo "FAILED: " . $e->getMessage() . "\n";
    }
}
?>
