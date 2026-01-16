<?php
require_once __DIR__ . '/../config/Database.php';

// Check if user is authenticated
function checkAuth() {
    if (!isset($_SESSION['user_id'])) {
        sendResponse(false, null, 'Unauthorized', 401);
    }
}

// Check user role
function checkRole($requiredRoles) {
    checkAuth();
    $userRole = strtolower(trim($_SESSION['role'] ?? ''));
    $required = array_map('strtolower', (array)$requiredRoles);
    
    if (!in_array($userRole, $required)) {
        sendResponse(false, null, 'Forbidden: Insufficient permissions', 403);
    }
}

class UserController {
    private $db;
    
    public function __construct() {
        $this->db = new Database();
    }
    
    public function getUsers() {
        checkAuth(); // Allow all authenticated users to view directory for feedback

        
        $sql = "SELECT id, email, username, first_name, last_name, phone, role, department, is_active, last_login, created_at
                FROM users
                ORDER BY created_at DESC";
        
        $result = $this->db->query($sql);
        $users = [];
        
        while ($row = $result->fetch_assoc()) {
            $users[] = $row;
        }
        
        sendResponse(true, $users, 'Users retrieved successfully');
    }

    // Get single user details
    public function getUser() {
        checkRole('admin');

        $userId = intval($_GET['id'] ?? 0);
        if (!$userId) sendResponse(false, null, 'User ID is required', 400);

        $stmt = $this->db->prepare("SELECT id, email, username, first_name, last_name, phone, role, department, is_active, last_login, created_at
                                   FROM users WHERE id = ?");
        $stmt->bind_param("i", $userId);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows === 0) {
            sendResponse(false, null, 'User not found', 404);
        }

        $user = $result->fetch_assoc();
        $stmt->close();

        sendResponse(true, $user, 'User retrieved successfully');
    }
    
    public function getUserCount() {
        checkRole(['admin', 'manager']);
        
        $result = $this->db->query("SELECT COUNT(*) as count FROM users WHERE is_active = TRUE");
        $row = $result->fetch_assoc();
        
        sendResponse(true, $row, 'User count retrieved');
    }
    
    public function createUser() {
        checkRole(['admin', 'manager']);
        
        $data = json_decode(file_get_contents('php://input'), true);
        
        $required = ['first_name', 'last_name', 'email', 'username', 'role'];
        foreach ($required as $field) {
            if (empty($data[$field])) {
                sendResponse(false, null, "Missing required field: $field", 400);
            }
        }
        
        // Check if user exists
        $stmt = $this->db->prepare("SELECT id FROM users WHERE email = ? OR username = ?");
        $stmt->bind_param("ss", $data['email'], $data['username']);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            sendResponse(false, null, 'Email or username already exists', 409);
        }
        $stmt->close();
        
        // Determine password: use provided one if any, else generate temporary
        $tempPassword = null;
        if (!empty($data['password'])) {
            if (!validatePassword($data['password'])) {
                sendResponse(false, null, 'Password does not meet requirements', 400);
            }
            $passwordHash = hashPassword($data['password']);
        } else {
            $tempPassword = bin2hex(random_bytes(4));
            $passwordHash = hashPassword($tempPassword);
        }

        $userId = $this->db->getValidatedUserId($_SESSION['user_id'] ?? null);
        
        $stmt = $this->db->prepare("INSERT INTO users (email, username, password_hash, first_name, last_name, role, department, created_by) 
                                   VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        if ($stmt) {
            $stmt->bind_param("sssssssi", 
                $data['email'], 
                $data['username'], 
                $passwordHash, 
                $data['first_name'], 
                $data['last_name'], 
                trim($data['role']), 
                $data['department'], 
                $userId
            );
            
            if ($stmt->execute()) {
                $newUserId = $this->db->getConnection()->insert_id;
                logAudit($userId, 'USER_CREATED', 'users', $newUserId);
                
                // If temp password was generated include it in the response; if admin provided password, don't include it
                $responseData = ['user_id' => $newUserId];
                if ($tempPassword) $responseData['temp_password'] = $tempPassword;

                $message = 'User created successfully.';
                if ($tempPassword) $message .= ' Temporary password: ' . $tempPassword;

                sendResponse(true, $responseData, $message, 201);
            } else {
                sendResponse(false, null, 'Failed to create user', 500);
            }
            $stmt->close();
        } else {
            sendResponse(false, null, 'Database error: ' . $this->db->getConnection()->error, 500);
        }
    }
    
    public function updateUser() {
        checkRole(['admin', 'manager']);

        $data = json_decode(file_get_contents('php://input'), true);
        $userId = $data['user_id'] ?? null;

        if (!$userId) {
            sendResponse(false, null, 'User ID is required', 400);
        }

        $updateFields = [];
        $params = [];
        $types = '';

        if (!empty($data['first_name'])) {
            $updateFields[] = 'first_name = ?';
            $params[] = $data['first_name'];
            $types .= 's';
        }

        if (!empty($data['last_name'])) {
            $updateFields[] = 'last_name = ?';
            $params[] = $data['last_name'];
            $types .= 's';
        }

        if (!empty($data['role'])) {
            $updateFields[] = 'role = ?';
            $params[] = trim($data['role']);
            $types .= 's';
        }

        if (!empty($data['department'])) {
            $updateFields[] = 'department = ?';
            $params[] = $data['department'];
            $types .= 's';
        }

        // Admin can optionally update password for a user
        if (!empty($data['password'])) {
            if (!validatePassword($data['password'])) {
                sendResponse(false, null, 'Password does not meet requirements', 400);
            }
            $updateFields[] = 'password_hash = ?';
            $params[] = hashPassword($data['password']);
            $types .= 's';
        }

        if (empty($updateFields)) {
            sendResponse(false, null, 'No fields to update', 400);
        }

        // Append user id
        $params[] = $userId;
        $types .= 'i';

        $sql = "UPDATE users SET " . implode(', ', $updateFields) . " WHERE id = ?";
        $stmt = $this->db->prepare($sql);
        if ($stmt) {
            $stmt->bind_param($types, ...$params);

            if ($stmt->execute()) {
                $adminId = $_SESSION['user_id'];
                logAudit($adminId, 'USER_UPDATED', 'users', $userId);
                sendResponse(true, null, 'User updated successfully');
            } else {
                sendResponse(false, null, 'Failed to update user', 500);
            }
            $stmt->close();
        } else {
            sendResponse(false, null, 'Database error: ' . $this->db->getConnection()->error, 500);
        }
    }

    // Deactivate (or activate) a user
    public function deactivateUser() {
        checkRole(['admin', 'manager']);

        $data = json_decode(file_get_contents('php://input'), true);
        $userId = $data['user_id'] ?? null;
        if (!$userId) {
            sendResponse(false, null, 'User ID is required', 400);
        }

        // Optionally allow 'activate' flag
        $activate = isset($data['activate']) ? (bool)$data['activate'] : false;
        $newStatus = $activate ? 1 : 0;

        $stmt = $this->db->prepare("UPDATE users SET is_active = ? WHERE id = ?");
        $stmt->bind_param("ii", $newStatus, $userId);

        if ($stmt->execute()) {
            $adminId = $_SESSION['user_id'];
            logAudit($adminId, $activate ? 'USER_ACTIVATED' : 'USER_DEACTIVATED', 'users', $userId);
            sendResponse(true, null, $activate ? 'User activated successfully' : 'User deactivated successfully');
        } else {
            sendResponse(false, null, 'Failed to change user status', 500);
        }

        $stmt->close();
    }

    public function deleteUser() {
        checkRole('admin');
        
        $data = json_decode(file_get_contents('php://input'), true);
        $userId = $data['user_id'] ?? null;
        
        if (!$userId) sendResponse(false, null, 'User ID is required', 400);
        
        // Prevent deleting self
        if ($userId == $_SESSION['user_id']) {
            sendResponse(false, null, 'Cannot delete your own account', 400);
        }
        
        $stmt = $this->db->prepare("DELETE FROM users WHERE id = ?");
        $stmt->bind_param("i", $userId);
        
        if ($stmt->execute()) {
             logAudit($_SESSION['user_id'], 'USER_DELETED', 'users', $userId);
             sendResponse(true, null, 'User deleted successfully');
        } else {
             sendResponse(false, null, 'Failed to delete user', 500);
        }
        $stmt->close();
    }
}

// Route handling
$action = $_GET['action'] ?? null;
$user = new UserController();

switch ($action) {
    case 'list':
        $user->getUsers();
        break;
    case 'get':
        $user->getUser();
        break;
    case 'count':
        $user->getUserCount();
        break;
    case 'create':
        $user->createUser();
        break;
    case 'update':
        $user->updateUser();
        break;
    case 'deactivate':
    case 'activate':
        $user->deactivateUser();
        break;

    case 'delete':
        $user->deleteUser();
        break;
    default:
        sendResponse(false, null, 'Action not found', 404);
}
?>
