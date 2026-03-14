<?php
// Database Connection Class
require_once __DIR__ . '/config.php';

class Database {
    private $connection;
    
    public function __construct() {
        try {
            $this->connection = mysqli_init();
            if (!$this->connection) {
                throw new Exception("mysqli_init failed");
            }

            $this->connection->options(MYSQLI_OPT_CONNECT_TIMEOUT, 5);
            $this->connection->real_connect(DB_HOST, DB_USER, DB_PASS, DB_NAME);
            
            if ($this->connection->connect_error) {
                throw new Exception("Connection failed: " . $this->connection->connect_error);
            }
            
            $this->connection->set_charset("utf8mb4");
        } catch (Exception $e) {
            $this->sendError("Database connection error: " . $e->getMessage());
        }
    }
    
    public function query($sql) {
        return $this->connection->query($sql);
    }
    
    public function prepare($sql) {
        return $this->connection->prepare($sql);
    }
    
    public function escape($string) {
        return $this->connection->real_escape_string($string);
    }
    
    public function getConnection() {
        return $this->connection;
    }
    
    public function closeConnection() {
        if ($this->connection) {
            $this->connection->close();
        }
    }
    
    public function getValidatedUserId($id) {
        if (empty($id)) return null;
        $stmt = $this->connection->prepare("SELECT id FROM users WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();
        $exists = ($result->num_rows > 0);
        $stmt->close();
        return $exists ? $id : null;
    }

    protected function sendError($message, $code = 500) {
        http_response_code($code);
        echo json_encode(['success' => false, 'error' => $message]);
        exit;
    }
}

// Helper Functions
function sendResponse($success, $data = null, $message = '', $code = 200) {
    http_response_code($code);
    echo json_encode([
        'success' => $success,
        'data' => $data,
        'message' => $message
    ]);
    exit;
}

function hashPassword($password) {
    return password_hash($password, PASSWORD_BCRYPT, ['cost' => 10]);
}

function verifyPassword($password, $hash) {
    return password_verify($password, $hash);
}

function generateToken($length = 32) {
    return bin2hex(random_bytes($length));
}

function logAudit($userId, $action, $entityType, $entityId, $oldValue = null, $newValue = null) {
    $db = new Database();
    $ipAddress = $_SERVER['REMOTE_ADDR'] ?? '';
    $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
    
    // Ensure userId is null if it's 0 or empty to avoid foreign key issues
    $finalUserId = (empty($userId) || $userId === 0) ? null : $userId;
    
    $stmt = $db->prepare("INSERT INTO audit_trail (user_id, action, entity_type, entity_id, old_value, new_value, ip_address, user_agent) 
                          VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    if ($stmt) {
        $stmt->bind_param("ississss", $finalUserId, $action, $entityType, $entityId, $oldValue, $newValue, $ipAddress, $userAgent);
        $stmt->execute();
        $stmt->close();
    } else {
        error_log("Audit Log Error: " . $db->getConnection()->error);
    }
}

function validateEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

function validatePassword($password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character
    $pattern = '/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/';
    return preg_match($pattern, $password);
}
?>
