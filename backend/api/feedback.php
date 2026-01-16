<?php
// Disable error display to prevent breaking JSON
ini_set('display_errors', 0);
error_reporting(E_ALL);

require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../config/MailService.php';

// Check auth
if (!isset($_SESSION['user_id'])) {
    sendResponse(false, null, 'Unauthorized', 401);
}

$action = $_GET['action'] ?? '';

// Ensure History Table Exists (Quick Fix since Migration Tool Failed)
$db = new Database();
$db->query("CREATE TABLE IF NOT EXISTS feedback_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sender_id INT NOT NULL,
    recipients TEXT NOT NULL,
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_sender (sender_id)
)");

if ($action === 'send') {
    try {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception('Invalid JSON payload');
        }
        
        $recipients = $data['recipients'] ?? [];
        $subject = $data['subject'] ?? 'No Subject';
        $message = $data['message'] ?? '';
        
        if (empty($recipients) || empty($message)) {
            sendResponse(false, null, 'Recipients and message are required', 400);
        }
        
        $mailer = new SimpleSMTP();
        $sentCount = 0;
        $failedList = [];
        
        $senderName = $_SESSION['first_name'] . ' ' . $_SESSION['last_name'];
        $senderEmail = $_SESSION['email'] ?? 'unknown';
        
        $fullBody = "<h3>Feedback from $senderName ($senderEmail)</h3>";
        $fullBody .= "<p>" . nl2br(htmlspecialchars($message)) . "</p>";
        $fullBody .= "<hr><small>Sent via FinSight Feedback System at " . date('Y-m-d H:i:s') . "</small>";
        
        foreach ($recipients as $to) {
            if (!filter_var($to, FILTER_VALIDATE_EMAIL)) {
                $failedList[] = $to;
                continue;
            }
            
            if ($mailer->send($to, "Feedback: $subject", $fullBody)) {
                $sentCount++;
            } else {
                $failedList[] = $to;
            }
        }
        
        if ($sentCount > 0) {
            // Store in History
            $stmt = $db->prepare("INSERT INTO feedback_history (sender_id, recipients, subject, message) VALUES (?, ?, ?, ?)");
            if ($stmt) {
                $recipientStr = implode(', ', $recipients);
                $userId = $_SESSION['user_id'];
                $stmt->bind_param("isss", $userId, $recipientStr, $subject, $message);
                $stmt->execute();
                $stmt->close();
            }
            
            sendResponse(true, ['sent' => $sentCount, 'failed' => $failedList], 'Feedback sent successfully');
        } else {
             sendResponse(false, ['failed' => $failedList], 'Failed to send email. Check SMTP settings.', 500);
        }

    } catch (Exception $e) {
        error_log("Feedback Error: " . $e->getMessage());
        sendResponse(false, null, 'Internal Server Error: ' . $e->getMessage(), 500);
    } // End Try
} else if ($action === 'get_history') {
    $userId = $_SESSION['user_id'];
    $stmt = $db->prepare("SELECT id, recipients, subject, message, sent_at FROM feedback_history WHERE sender_id = ? ORDER BY sent_at DESC");
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $history = [];
    while ($row = $result->fetch_assoc()) {
        $history[] = $row;
    }
    $stmt->close();
    
    sendResponse(true, $history, 'History retrieved');

} else {
    sendResponse(false, null, 'Invalid action', 400);
}
?>
