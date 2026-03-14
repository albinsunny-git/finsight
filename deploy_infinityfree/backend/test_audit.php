<?php
ini_set('display_errors', 0); // Suppress HTML errors
require_once 'config/Database.php';

try {
    // Fake session user
    $_SESSION['user_id'] = 1;
    
    // Call logAudit
    logAudit(1, 'TEST_DEBUG', 'debug', 123);
    
    echo json_encode(['success' => true]);
} catch (Throwable $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
}
?>
