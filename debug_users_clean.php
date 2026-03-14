<?php
require 'config/Database.php';
$db = new Database();
$pdo = $db->connect();
$users = $pdo->query('SELECT first_name, last_name, username FROM users')->fetchAll(PDO::FETCH_ASSOC);
foreach ($users as $u) {
    echo "User: {$u['first_name']} {$u['last_name']} ({$u['username']})\n";
}
echo "Total: " . count($users) . "\n";
