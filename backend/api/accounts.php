<?php
require_once __DIR__ . '/../config/Database.php';

function checkAuth() {
    if (!isset($_SESSION['user_id'])) {
        sendResponse(false, null, 'Unauthorized', 401);
    }
}

function checkRole($requiredRoles) {
    checkAuth();
    if (!in_array($_SESSION['role'], (array)$requiredRoles)) {
        sendResponse(false, null, 'Forbidden: Insufficient permissions', 403);
    }
}

class AccountController {
    private $db;
    
    public function __construct() {
        $this->db = new Database();
    }
    
    public function getAccounts() {
        checkAuth();
        
        $type = $_GET['type'] ?? null;
        
        $sql = "SELECT id, code, name, type, sub_type, description, opening_balance, balance, is_active, created_at
                FROM account_chart
                WHERE 1=1";
        
        if ($type) {
            $type = $this->db->escape($type);
            $sql .= " AND type = '$type'";
        }
        
        $sql .= " ORDER BY code";
        
        $result = $this->db->query($sql);
        $accounts = [];
        
        while ($row = $result->fetch_assoc()) {
            $accounts[] = $row;
        }
        
        sendResponse(true, $accounts, 'Accounts retrieved successfully');
    }
    
    public function getAccount() {
        checkAuth();
        
        $accountId = $_GET['id'] ?? null;
        
        if (!$accountId) {
            sendResponse(false, null, 'Account ID is required', 400);
        }
        
        $stmt = $this->db->prepare("SELECT * FROM account_chart WHERE id = ?");
        $stmt->bind_param("i", $accountId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            sendResponse(false, null, 'Account not found', 404);
        }
        
        $account = $result->fetch_assoc();
        $stmt->close();
        
        // Get account ledger
        $stmt = $this->db->prepare("SELECT SUM(debit) as total_debit, SUM(credit) as total_credit 
                                   FROM general_ledger 
                                   WHERE account_id = ?");
        $stmt->bind_param("i", $accountId);
        $stmt->execute();
        $result = $stmt->get_result();
        $ledger = $result->fetch_assoc();
        $stmt->close();
        
        $account['ledger'] = $ledger;
        
        sendResponse(true, $account, 'Account retrieved successfully');
    }
    
    public function createAccount() {
        checkRole(['admin', 'manager', 'accountant']);
        
        $data = json_decode(file_get_contents('php://input'), true);
        
        $required = ['code', 'name', 'type'];
        foreach ($required as $field) {
            if (empty($data[$field])) {
                sendResponse(false, null, "Missing required field: $field", 400);
            }
        }
        
        // Check if code exists
        $stmt = $this->db->prepare("SELECT id FROM account_chart WHERE code = ?");
        $stmt->bind_param("s", $data['code']);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            sendResponse(false, null, 'Account code already exists', 409);
        }
        $stmt->close();
        
        $userId = $this->db->getValidatedUserId($_SESSION['user_id'] ?? null);
        $balance = $data['opening_balance'] ?? 0;
        
        $stmt = $this->db->prepare("INSERT INTO account_chart (code, name, type, sub_type, description, opening_balance, balance, created_by) 
                                   VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sssssddi", 
            $data['code'], 
            $data['name'], 
            $data['type'], 
            $data['sub_type'], 
            $data['description'], 
            $balance, 
            $balance, 
            $userId
        );
        
        if ($stmt->execute()) {
            $accountId = $this->db->getConnection()->insert_id;
            logAudit($userId, 'ACCOUNT_CREATED', 'account_chart', $accountId);
            sendResponse(true, ['account_id' => $accountId], 'Account created successfully', 201);
        } else {
            sendResponse(false, null, 'Failed to create account', 500);
        }
        
        $stmt->close();
    }
    
    public function updateAccount() {
        checkRole(['admin', 'manager', 'accountant']);
        
        $data = json_decode(file_get_contents('php://input'), true);
        $accountId = $data['account_id'] ?? null;
        
        if (!$accountId) {
            sendResponse(false, null, 'Account ID is required', 400);
        }
        
        $updateFields = [];
        $params = [];
        $types = '';
        
        if (!empty($data['name'])) {
            $updateFields[] = 'name = ?';
            $params[] = $data['name'];
            $types .= 's';
        }
        
        if (!empty($data['sub_type'])) {
            $updateFields[] = 'sub_type = ?';
            $params[] = $data['sub_type'];
            $types .= 's';
        }
        
        if (!empty($data['code'])) {
            $updateFields[] = 'code = ?';
            $params[] = $data['code'];
            $types .= 's';
        }

        if (!empty($data['type'])) {
            $updateFields[] = 'type = ?';
            $params[] = $data['type'];
            $types .= 's';
        }

        if (isset($data['balance'])) {
            $updateFields[] = 'balance = ?';
            $params[] = $data['balance'];
            $types .= 'd';
        }

        if (isset($data['is_active'])) {
            $updateFields[] = 'is_active = ?';
            $params[] = $data['is_active'] ? 1 : 0;
            $types .= 'i';
        }
        
        if (empty($updateFields)) {
            sendResponse(false, null, 'No fields to update', 400);
        }
        
        $params[] = $accountId;
        $types .= 'i';
        
        $sql = "UPDATE account_chart SET " . implode(', ', $updateFields) . " WHERE id = ?";
        $stmt = $this->db->prepare($sql);
        $stmt->bind_param($types, ...$params);
        
        if ($stmt->execute()) {
            logAudit($_SESSION['user_id'], 'ACCOUNT_UPDATED', 'account_chart', $accountId);
            sendResponse(true, null, 'Account updated successfully');
        } else {
            sendResponse(false, null, 'Failed to update account', 500);
        }
        
        $stmt->close();
    }
    
    public function getAccountType() {
        checkAuth();
        
        $type = $_GET['type'] ?? null;
        
        if (!$type) {
            sendResponse(false, null, 'Account type is required', 400);
        }
        
        $type = $this->db->escape($type);
        $result = $this->db->query("SELECT id, code, name, balance FROM account_chart WHERE type = '$type' ORDER BY name");
        $accounts = [];
        
        while ($row = $result->fetch_assoc()) {
            $accounts[] = $row;
        }
        
        sendResponse(true, $accounts, 'Accounts retrieved');
    }

    public function deactivateAccount() {
        checkRole(['admin', 'manager', 'accountant']);
        $data = json_decode(file_get_contents('php://input'), true);
        $accountId = $data['account_id'] ?? null;

        if (!$accountId) {
            sendResponse(false, null, 'Account ID is required', 400);
        }

        $activate = isset($data['activate']) ? (bool)$data['activate'] : false;
        $newStatus = $activate ? 1 : 0;

        $stmt = $this->db->prepare("UPDATE account_chart SET is_active = ? WHERE id = ?");
        $stmt->bind_param("ii", $newStatus, $accountId);

        if ($stmt->execute()) {
            $action = $activate ? 'ACCOUNT_ACTIVATED' : 'ACCOUNT_DEACTIVATED';
            logAudit($_SESSION['user_id'], $action, 'account_chart', $accountId);
            sendResponse(true, null, 'Account status updated successfully');
        } else {
            sendResponse(false, null, 'Failed to update account status', 500);
        }
        $stmt->close();
    }

    public function deleteAccount() {
        checkRole(['admin']);
        $data = json_decode(file_get_contents('php://input'), true);
        $accountId = $data['account_id'] ?? null;

        if (!$accountId) {
            sendResponse(false, null, 'Account ID is required', 400);
        }

        // Check if account has transactions
        $stmt = $this->db->prepare("SELECT id FROM general_ledger WHERE account_id = ? LIMIT 1");
        $stmt->bind_param("i", $accountId);
        $stmt->execute();
        if ($stmt->get_result()->num_rows > 0) {
            sendResponse(false, null, 'Cannot delete account with existing transactions. Deactivate it instead.', 400);
            return;
        }
        $stmt->close();

        $stmt = $this->db->prepare("DELETE FROM account_chart WHERE id = ?");
        $stmt->bind_param("i", $accountId);

        if ($stmt->execute()) {
            logAudit($_SESSION['user_id'], 'ACCOUNT_DELETED', 'account_chart', $accountId);
            sendResponse(true, null, 'Account deleted successfully');
        } else {
            sendResponse(false, null, 'Failed to delete account', 500);
        }
        $stmt->close();
    }
}

// Route handling
$action = $_GET['action'] ?? null;
$account = new AccountController();

switch ($action) {
    case 'list':
        $account->getAccounts();
        break;
    case 'get':
        $account->getAccount();
        break;
    case 'create':
        $account->createAccount();
        break;
    case 'update':
        $account->updateAccount();
        break;
    case 'by-type':
        $account->getAccountType();
        break;
    case 'activate':
    case 'deactivate':
        $account->deactivateAccount();
        break;
    case 'delete':
        $account->deleteAccount();
        break;
    default:
        sendResponse(false, null, 'Action not found', 404);
}
?>
