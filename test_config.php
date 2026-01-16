<?php
echo "Session Status: " . session_status() . "\n";
echo "PHP_SESSION_NONE: " . PHP_SESSION_NONE . "\n";
echo "PHP_SESSION_ACTIVE: " . PHP_SESSION_ACTIVE . "\n";
require_once __DIR__ . '/backend/config/config.php';
echo "After config\n";
?>
