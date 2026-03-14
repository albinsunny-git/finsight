<?php
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../config/AuthMiddleware.php';

class NotificationController {
    private $db;
    
    public function __construct() {
        $this->db = new Database();
    }
    
    public function getNotifications() {
        checkAuth();
        $userId = $_SESSION['user_id'];
        
        $sql = "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 50";
        $stmt = $this->db->prepare($sql);
        $stmt->bind_param("i", $userId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $notifications = [];
        $unreadCount = 0;
        while ($row = $result->fetch_assoc()) {
            if ($row['is_read'] == 0) {
                $unreadCount++;
            }
            $notifications[] = $row;
        }
        $stmt->close();
        
        sendResponse(true, ['notifications' => $notifications, 'unread_count' => $unreadCount], 'Notifications retrieved successfully');
    }
    
    public function markAsRead() {
        checkAuth();
        $userId = $_SESSION['user_id'];
        
        $data = json_decode(file_get_contents('php://input'), true);
        $notificationId = $data['id'] ?? null;
        
        if ($notificationId) {
            $stmt = $this->db->prepare("UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?");
            $stmt->bind_param("ii", $notificationId, $userId);
        } else {
            // Mark all as read
            $stmt = $this->db->prepare("UPDATE notifications SET is_read = 1 WHERE user_id = ?");
            $stmt->bind_param("i", $userId);
        }
        
        if ($stmt->execute()) {
            sendResponse(true, null, 'Marked as read successfully');
        } else {
            sendResponse(false, null, 'Failed to mark as read', 500);
        }
        $stmt->close();
    }
    
    public function clearNotifications() {
        checkAuth();
        $userId = $_SESSION['user_id'];
        
        $stmt = $this->db->prepare("DELETE FROM notifications WHERE user_id = ?");
        $stmt->bind_param("i", $userId);
        
        if ($stmt->execute()) {
            sendResponse(true, null, 'Notifications cleared successfully');
        } else {
            sendResponse(false, null, 'Failed to clear notifications', 500);
        }
        $stmt->close();
    }
}

// Route handling
$action = $_GET['action'] ?? null;
$controller = new NotificationController();

switch ($action) {
    case 'list':
        $controller->getNotifications();
        break;
    case 'mark-read':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $controller->markAsRead();
        } else {
            sendResponse(false, null, 'Method not allowed', 405);
        }
        break;
    case 'clear':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $controller->clearNotifications();
        } else {
            sendResponse(false, null, 'Method not allowed', 405);
        }
        break;
    default:
        sendResponse(false, null, 'Action not found', 404);
}
?>
