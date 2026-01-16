<?php
require_once __DIR__ . '/../config/Database.php';

$db = new Database();
$res = $db->query("SELECT at.*, u.email as user_email FROM audit_trail at LEFT JOIN users u ON at.user_id = u.id WHERE at.action = 'LOGIN_FAILED' ORDER BY at.id DESC LIMIT 50");
echo "Recent LOGIN_FAILED events:\n";
while ($row = $res->fetch_assoc()) {
    $time = $row['created_at'] ?? $row['timestamp'] ?? 'unknown';
    $userId = $row['user_id'];
    $entity = $row['entity_type'];
    $details = 'old:' . ($row['old_value'] ?? '') . ' new:' . ($row['new_value'] ?? '');
    $ip = $row['ip_address'] ?? '';
    echo "[{$time}] user_id={$userId} user_email={$row['user_email']} ip={$ip} details={$details}\n";
}

$db->closeConnection();
?>