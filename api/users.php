<?php
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../config/AuthMiddleware.php';

class UserController {
    private $db;
    
    public function __construct() {
        $this->db = new Database();
    }
    public function getUsers() {
        checkAuth(); // Allow all authenticated users to view directory
        
        $sql = "SELECT id, email, username, first_name, last_name, phone, role, department, is_active, last_login, created_at, profile_image
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

        $stmt = $this->db->prepare("SELECT id, email, username, first_name, last_name, phone, role, department, is_active, last_login, created_at, profile_image
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

        if ($_SESSION['role'] === 'manager' && isset($data['role']) && trim(strtolower($data['role'])) !== 'accountant') {
            sendResponse(false, null, 'Managers can only create accountant users.', 403);
        }
        
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

        if ($_SESSION['role'] === 'manager') {
            $stmtRole = $this->db->prepare("SELECT role FROM users WHERE id = ?");
            $stmtRole->bind_param("i", $userId);
            $stmtRole->execute();
            if ($row = $stmtRole->get_result()->fetch_assoc()) {
                if (strtolower($row['role']) !== 'accountant') {
                    sendResponse(false, null, 'Managers can only manage accountant users.', 403);
                }
            }
            if (!empty($data['role']) && trim(strtolower($data['role'])) !== 'accountant') {
                sendResponse(false, null, 'Managers can only assign the accountant role.', 403);
            }
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
    
    // Update own profile
    public function updateProfile() {
        checkAuth();
        
        $data = json_decode(file_get_contents('php://input'), true);
        $userId = $_SESSION['user_id'];
        
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
        
        if (isset($data['phone'])) {
            $updateFields[] = 'phone = ?';
            $params[] = $data['phone'];
            $types .= 's';
        }
        
        if (!empty($data['department'])) {
            $updateFields[] = 'department = ?';
            $params[] = $data['department'];
            $types .= 's';
        }
        
        if (empty($updateFields)) {
            sendResponse(false, null, 'No fields to update', 400);
        }
        
        $params[] = $userId;
        $types .= 'i';
        
        $sql = "UPDATE users SET " . implode(', ', $updateFields) . " WHERE id = ?";
        $stmt = $this->db->prepare($sql);
        if ($stmt) {
            $stmt->bind_param($types, ...$params);
            if ($stmt->execute()) {
                logAudit($userId, 'PROFILE_UPDATED', 'users', $userId);
                sendResponse(true, null, 'Profile updated successfully');
            } else {
                sendResponse(false, null, 'Failed to update profile', 500);
            }
            $stmt->close();
        } else {
            sendResponse(false, null, 'Database error', 500);
        }
    }

    public function uploadProfileImage() {
        checkAuth();
        
        $userId = $_SESSION['user_id'];
        
        if (!isset($_FILES['profile_image']) || $_FILES['profile_image']['error'] !== UPLOAD_ERR_OK) {
            sendResponse(false, null, 'No valid image uploaded', 400);
        }
        
        $file = $_FILES['profile_image'];
        $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        $allowed = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
        
        if (!in_array($ext, $allowed)) {
            sendResponse(false, null, 'Invalid file type. Only JPG, PNG, GIF, WEBP allowed.', 400);
        }
        
        $filename = 'user_' . $userId . '_' . time() . '.' . $ext;
        $uploadDir = __DIR__ . '/../uploads/profiles/';
        
        if (!file_exists($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }
        
        $destPath = $uploadDir . $filename;
        
        if (move_uploaded_file($file['tmp_name'], $destPath)) {
            // Update db
            $dbPath = 'uploads/profiles/' . $filename;
            
            // Delete old one if exists
            $stmt = $this->db->prepare("SELECT profile_image FROM users WHERE id = ?");
            $stmt->bind_param("i", $userId);
            $stmt->execute();
            $res = $stmt->get_result();
            if ($row = $res->fetch_assoc()) {
                if (!empty($row['profile_image'])) {
                     $oldPath = __DIR__ . '/../' . $row['profile_image'];
                     if (file_exists($oldPath)) unlink($oldPath);
                }
            }
            $stmt->close();

            $stmt = $this->db->prepare("UPDATE users SET profile_image = ? WHERE id = ?");
            if ($stmt) {
                $stmt->bind_param("si", $dbPath, $userId);
                if ($stmt->execute()) {
                    logAudit($userId, 'PROFILE_IMAGE_UPDATED', 'users', $userId);
                    // generate full url for mobile response if possible, but relative path is ok too
                    sendResponse(true, ['profile_image' => $dbPath], 'Profile image updated');
                } else {
                    sendResponse(false, null, 'Database update failed', 500);
                }
                $stmt->close();
            } else {
                sendResponse(false, null, 'Database error', 500);
            }
        } else {
            sendResponse(false, null, 'Failed to save uploaded file', 500);
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

        if ($_SESSION['role'] === 'manager') {
            $stmtRole = $this->db->prepare("SELECT role FROM users WHERE id = ?");
            $stmtRole->bind_param("i", $userId);
            $stmtRole->execute();
            if ($row = $stmtRole->get_result()->fetch_assoc()) {
                if (strtolower($row['role']) !== 'accountant') {
                    sendResponse(false, null, 'Managers can only manage accountant users.', 403);
                }
            }
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
        checkRole(['admin', 'manager']);
        
        $data = json_decode(file_get_contents('php://input'), true);
        $userId = $data['user_id'] ?? null;
        
        if (!$userId) sendResponse(false, null, 'User ID is required', 400);
        
        if ($_SESSION['role'] === 'manager') {
            $stmtRole = $this->db->prepare("SELECT role FROM users WHERE id = ?");
            $stmtRole->bind_param("i", $userId);
            $stmtRole->execute();
            if ($row = $stmtRole->get_result()->fetch_assoc()) {
                if (strtolower($row['role']) !== 'accountant') {
                    sendResponse(false, null, 'Managers can only delete accountant users.', 403);
                }
            }
        }

        // Prevent deleting self
        if ($userId == $_SESSION['user_id']) {
            sendResponse(false, null, 'Cannot delete your own account', 400);
        }
        
        $stmt = $this->db->prepare("DELETE FROM users WHERE id = ?");
        $stmt->bind_param("i", $userId);
        
        try {
            if ($stmt->execute()) {
                 logAudit($_SESSION['user_id'], 'USER_DELETED', 'users', $userId);
                 sendResponse(true, null, 'User deleted successfully');
            } else {
                 sendResponse(false, null, 'Failed to delete user', 500);
            }
        } catch (Exception $e) {
            $msg = strtolower($e->getMessage());
            if (strpos($msg, 'foreign key constraint') !== false || strpos($msg, 'cannot delete or update a parent row') !== false) {
                 sendResponse(false, null, 'Cannot delete user: user is linked to existing records (like accounts or vouchers). Please deactivate them instead.', 400);
            } else {
                 sendResponse(false, null, 'Database error: ' . $e->getMessage(), 500);
            }
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
    case 'update-profile':
        $user->updateProfile();
        break;
    case 'upload-profile-image':
        $user->uploadProfileImage();
        break;

    case 'delete':
        $user->deleteUser();
        break;
    default:
        sendResponse(false, null, 'Action not found', 404);
}
?>
