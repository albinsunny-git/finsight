<?php
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../config/AuthMiddleware.php';

class AuditController {
    private $db;
    
    public function __construct() {
        $this->db = new Database();
    }
    
    public function getAuditTrail() {
        checkRole(['admin', 'manager']);
        
        $userId = $_GET['user_id'] ?? null;
        $fromDate = $_GET['from_date'] ?? null;
        $toDate = $_GET['to_date'] ?? null;
        $action = $_GET['action'] ?? null;
        $limit = $_GET['limit'] ?? 500;
        
        $sql = "SELECT at.id, at.created_at, at.action, at.entity_type, at.entity_id, at.old_value, at.new_value, at.ip_address, at.user_agent,
                       u.first_name, u.last_name, u.email
                FROM audit_trail at
                LEFT JOIN users u ON at.user_id = u.id
                WHERE 1=1";
        
        if ($userId) {
            $userId = intval($userId);
            $sql .= " AND at.user_id = $userId";
        }
        
        if ($fromDate) {
            $fromDate = $this->db->escape($fromDate);
            $sql .= " AND DATE(at.created_at) >= '$fromDate'";
        }
        
        if ($toDate) {
            $toDate = $this->db->escape($toDate);
            $sql .= " AND DATE(at.created_at) <= '$toDate'";
        }
        
        if ($action) {
            $action = $this->db->escape($action);
            $sql .= " AND at.action LIKE '%$action%'";
        }
        
        $sql .= " ORDER BY at.created_at DESC LIMIT " . intval($limit);
        
        $result = $this->db->query($sql);
        $logs = [];
        
        while ($row = $result->fetch_assoc()) {
            $logs[] = [
                'id' => $row['id'],
                'timestamp' => $row['created_at'],
                'user_name' => $row['first_name'] . ' ' . $row['last_name'],
                'user_email' => $row['email'],
                'action' => $row['action'],
                'entity_type' => $row['entity_type'],
                'entity_id' => $row['entity_id'],
                'old_value' => $row['old_value'],
                'new_value' => $row['new_value'],
                'ip_address' => $row['ip_address'],
                'user_agent' => $row['user_agent']
            ];
        }
        
        sendResponse(true, $logs, 'Audit trail retrieved');
    }
    
    public function getUserActivity() {
        checkRole(['admin', 'manager']);
        
        $userId = $_GET['user_id'] ?? null;
        
        if (!$userId) {
            sendResponse(false, null, 'User ID is required', 400);
        }
        
        $sql = "SELECT action, COUNT(*) as count, MAX(created_at) as last_activity
                FROM audit_trail
                WHERE user_id = " . intval($userId) . "
                GROUP BY action
                ORDER BY last_activity DESC";
        
        $result = $this->db->query($sql);
        $activity = [];
        
        while ($row = $result->fetch_assoc()) {
            $activity[] = $row;
        }
        
        sendResponse(true, $activity, 'User activity retrieved');
    }
    
    public function getEntityChanges() {
        checkRole(['admin', 'manager']);
        
        $entityType = $_GET['entity_type'] ?? null;
        $entityId = $_GET['entity_id'] ?? null;
        
        if (!$entityType || !$entityId) {
            sendResponse(false, null, 'Entity type and ID are required', 400);
        }
        
        $entityType = $this->db->escape($entityType);
        $entityId = intval($entityId);
        
        $sql = "SELECT at.id, at.created_at, at.action, at.old_value, at.new_value,
                       u.first_name, u.last_name
                FROM audit_trail at
                LEFT JOIN users u ON at.user_id = u.id
                WHERE at.entity_type = '$entityType' AND at.entity_id = $entityId
                ORDER BY at.created_at DESC";
        
        $result = $this->db->query($sql);
        $changes = [];
        
        while ($row = $result->fetch_assoc()) {
            $changes[] = [
                'timestamp' => $row['created_at'],
                'action' => $row['action'],
                'changed_by' => $row['first_name'] . ' ' . $row['last_name'],
                'old_value' => $row['old_value'],
                'new_value' => $row['new_value']
            ];
        }
        
        sendResponse(true, $changes, 'Entity changes retrieved');
    }
    
    public function getLoginHistory() {
        checkRole(['admin', 'manager']);
        
        $userId = $_GET['user_id'] ?? null;
        $days = $_GET['days'] ?? 30;
        
        $sql = "SELECT at.id, at.created_at, at.ip_address, at.user_agent,
                       u.first_name, u.last_name, u.email
                FROM audit_trail at
                LEFT JOIN users u ON at.user_id = u.id
                WHERE at.action = 'LOGIN_SUCCESS'
                AND at.created_at >= DATE_SUB(NOW(), INTERVAL " . intval($days) . " DAY)";
        
        if ($userId) {
            $userId = intval($userId);
            $sql .= " AND at.user_id = $userId";
        }
        
        $sql .= " ORDER BY at.created_at DESC LIMIT 1000";
        
        $result = $this->db->query($sql);
        $logins = [];
        
        while ($row = $result->fetch_assoc()) {
            $logins[] = [
                'timestamp' => $row['created_at'],
                'user' => $row['first_name'] . ' ' . $row['last_name'],
                'email' => $row['email'],
                'ip_address' => $row['ip_address']
            ];
        }
        
        sendResponse(true, $logins, 'Login history retrieved');
    }
    
    public function getFailedLoginAttempts() {
        checkRole(['admin', 'manager']);
        
        $days = $_GET['days'] ?? 7;
        
        $sql = "SELECT u.email, u.username, COUNT(*) as attempts, MAX(at.created_at) as last_attempt
                FROM audit_trail at
                LEFT JOIN users u ON at.user_id = u.id
                WHERE at.action = 'LOGIN_FAILED'
                AND at.created_at >= DATE_SUB(NOW(), INTERVAL " . intval($days) . " DAY)
                GROUP BY u.email, u.username
                HAVING attempts > 2
                ORDER BY attempts DESC";
        
        $result = $this->db->query($sql);
        $failedLogins = [];
        
        while ($row = $result->fetch_assoc()) {
            $failedLogins[] = [
                'email' => $row['email'],
                'username' => $row['username'],
                'attempts' => $row['attempts'],
                'last_attempt' => $row['last_attempt']
            ];
        }
        
        sendResponse(true, $failedLogins, 'Failed login attempts retrieved');
    }
}

// Route handling
$action = $_GET['action'] ?? null;
$audit = new AuditController();

switch ($action) {
    case 'list':
        $audit->getAuditTrail();
        break;
    case 'user-activity':
        $audit->getUserActivity();
        break;
    case 'entity-changes':
        $audit->getEntityChanges();
        break;
    case 'login-history':
        $audit->getLoginHistory();
        break;
    case 'failed-logins':
        $audit->getFailedLoginAttempts();
        break;
    default:
        sendResponse(false, null, 'Action not found', 404);
}
?>
