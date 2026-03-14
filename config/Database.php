<?php
// Database Connection Class - Refactored to use DATABASE_URL with mysqli compatibility shim
require_once __DIR__ . '/config.php';

class Database {
    private $pdo;
    
    public function __construct() {
        $this->pdo = $this->connect();
    }

    public function connect() {
        $host = defined('DB_HOST') ? DB_HOST : 'localhost';
        $db   = defined('DB_NAME') ? DB_NAME : '';
        $user = defined('DB_USER') ? DB_USER : 'root';
        $pass = defined('DB_PASS') ? DB_PASS : '';
        $port = defined('DB_PORT') ? DB_PORT : 3306;

        try {
            // Force MySQL TCP connection to avoid "No such file or directory" socket errors
            $dsn = "mysql:host=$host;port=$port;dbname=$db;charset=utf8mb4";
            
            $conn = new PDO($dsn, $user, $pass, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4"
            ]);
            return $conn;
        } catch (PDOException $e) {
            if (php_sapi_name() === 'cli') {
                die("Database connection error: " . $e->getMessage() . "\n");
            }
            $this->sendError("Database connection error: " . $e->getMessage());
        }
    }
    
    public function query($sql) {
        if (!$this->pdo) return false;
        try {
            $stmt = $this->pdo->query($sql);
            if (!$stmt) return false;
            return new ShimResult($stmt);
        } catch (PDOException $e) {
            return false;
        }
    }
    
    public function prepare($sql) {
        try {
            $stmt = $this->pdo->prepare($sql);
            return new ShimStatement($stmt, $this->pdo);
        } catch (PDOException $e) {
            return false;
        }
    }
    
    public function escape($string) {
        return trim($this->pdo->quote($string), "'");
    }
    
    public function getConnection() {
        return new ConnectionProxy($this->pdo);
    }
    
    public function closeConnection() {
        $this->pdo = null;
    }
    
    public function getValidatedUserId($id) {
        if (empty($id)) return null;
        try {
            $stmt = $this->pdo->prepare("SELECT id FROM users WHERE id = ?");
            $stmt->execute([$id]);
            $exists = $stmt->fetch();
            return $exists ? $id : null;
        } catch (PDOException $e) {
            return null;
        }
    }

    protected function sendError($message, $code = 500) {
        http_response_code($code);
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'message' => $message]);
        exit;
    }
}

// Shim to mimic mysqli_stmt behavior
class ShimStatement {
    private $stmt;
    private $pdo;
    private $params = [];

    public function __construct($stmt, $pdo) {
        $this->stmt = $stmt;
        $this->pdo = $pdo;
    }

    public function bind_param($types, ...$vars) {
        $this->params = $vars;
        return true;
    }

    public function execute() {
        try {
            return $this->stmt->execute($this->params);
        } catch (PDOException $e) {
            error_log("PDO Execute Error: " . $e->getMessage());
            return false;
        }
    }

    public function get_result() {
        return new ShimResult($this->stmt);
    }

    public function close() {
        return true;
    }
    
    public function __get($name) {
        if ($name === 'num_rows') {
            return $this->stmt->rowCount();
        }
        return null;
    }
}

// Shim to mimic mysqli_result behavior
class ShimResult {
    private $stmt;
    public $num_rows;

    public function __construct($stmt) {
        $this->stmt = $stmt;
        $this->num_rows = $stmt->rowCount();
    }

    public function fetch_assoc() {
        return $this->stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function fetch_all($mode = PDO::FETCH_ASSOC) {
        return $this->stmt->fetchAll($mode);
    }
    
    public function close() {
        return true;
    }
}

// Shim to mimic mysqli object properties
class ConnectionProxy {
    private $pdo;

    public function __construct($pdo) {
        $this->pdo = $pdo;
    }
    
    public function __get($name) {
        if ($name === 'insert_id') {
            return $this->pdo->lastInsertId();
        }
        if ($name === 'error') {
            $error = $this->pdo->errorInfo();
            return $error[2] ?? '';
        }
        return null;
    }
    
    public function close() {
        return true;
    }
}

// Helper Functions
if (!function_exists('sendResponse')) {
    function sendResponse($success, $data = null, $message = '', $code = 200) {
        http_response_code($code);
        echo json_encode([
            'success' => $success,
            'data' => $data,
            'message' => $message
        ]);
        exit;
    }
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
    
    $finalUserId = (empty($userId) || $userId === 0) ? null : $userId;
    
    $stmt = $db->prepare("INSERT INTO audit_trail (user_id, action, entity_type, entity_id, old_value, new_value, ip_address, user_agent) 
                          VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    if ($stmt) {
        $stmt->bind_param("ississss", $finalUserId, $action, $entityType, $entityId, $oldValue, $newValue, $ipAddress, $userAgent);
        $stmt->execute();
    }
}

function validateEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

function validatePassword($password) {
    $pattern = '/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/';
    return preg_match($pattern, $password);
}
?>
