<?php
require 'config/Database.php';
$db = new Database();
$pdo = $db->connect();
$users = $pdo->query('SELECT first_name, last_name, username FROM users')->fetchAll(PDO::FETCH_ASSOC);
print_r($users);
