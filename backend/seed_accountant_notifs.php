<?php
require_once __DIR__ . '/config/Database.php';

header('Content-Type: application/json');

try {
    $db = new Database();
    $conn = $db->getConnection();
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    exit;
}

$response = ['success' => true, 'actions' => []];

// Find accountant user
$res = $conn->query("SELECT id, username FROM users WHERE role = 'accountant' LIMIT 1");
if ($res && $res->num_rows > 0) {
    $row = $res->fetch_assoc();
    $uid = $row['id'];
    $response['accountant_found'] = $row['username'];
    
    // Add test notifications for voucher approval/rejection
    $notifications = [
        "Your voucher V-" . date('Ymd') . "-001 has been approved by Admin",
        "Your voucher V-" . date('Ymd') . "-002 has been rejected: Incorrect account code",
        "Your voucher V-" . date('Ymd') . "-003 is pending approval"
    ];
    
    foreach ($notifications as $msg) {
        $type = strpos($msg, 'approved') !== false ? 'success' : (strpos($msg, 'rejected') !== false ? 'error' : 'info');
        $stmt = $conn->prepare("INSERT INTO notifications (user_id, message, type, is_read) VALUES (?, ?, ?, 0)");
        $stmt->bind_param("iss", $uid, $msg, $type);
        
        if ($stmt->execute()) {
            $response['actions'][] = "Added: $msg";
        } else {
            $response['errors'][] = $stmt->error;
        }
    }
} else {
    $response['success'] = false;
    $response['error'] = 'No accountant user found';
}

echo json_encode($response, JSON_PRETTY_PRINT);
?>
