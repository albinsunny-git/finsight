<?php
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../config/AuthMiddleware.php';

class SettingsController {
    private $db;
    
    public function __construct() {
        $this->db = new Database();
        $this->ensureTableExists();
    }
    
    private function ensureTableExists() {
        $sql = "CREATE TABLE IF NOT EXISTS company_settings (
            id INT PRIMARY KEY AUTO_INCREMENT,
            company_name VARCHAR(255) NOT NULL,
            company_address TEXT,
            company_phone VARCHAR(50),
            company_email VARCHAR(255),
            company_website VARCHAR(255),
            company_tagline VARCHAR(255),
            company_logo VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )";
        $this->db->query($sql);
        
        // Seed if empty
        $result = $this->db->query("SELECT COUNT(*) as count FROM company_settings");
        $row = $result->fetch_assoc();
        if ($row['count'] == 0) {
            $this->db->query("INSERT INTO company_settings (company_name, company_tagline, company_email) 
                             VALUES ('FinSight Private Limited', 'Your Accurate Financial Partner', 'info@finsight.com')");
        }
    }
    
    public function getSettings() {
        checkAuth();
        $result = $this->db->query("SELECT * FROM company_settings LIMIT 1");
        $settings = $result->fetch_assoc();
        sendResponse(true, $settings, 'Settings retrieved');
    }
    
    public function updateSettings() {
        checkRole(['admin', 'administrator']);
        
        $json = file_get_contents('php://input');
        $data = json_decode($json, true);
        
        if (!$data) {
            sendResponse(false, null, 'Invalid JSON', 400);
        }
        
        $fields = ['company_name', 'company_address', 'company_phone', 'company_email', 'company_website', 'company_tagline'];
        $updateParts = [];
        $types = "";
        $values = [];
        
        foreach ($fields as $field) {
            if (isset($data[$field])) {
                $updateParts[] = "$field = ?";
                $types .= "s";
                $values[] = $data[$field];
            }
        }
        
        if (empty($updateParts)) {
            sendResponse(false, null, 'No fields to update', 400);
        }
        
        $sql = "UPDATE company_settings SET " . implode(", ", $updateParts) . " WHERE id = 1";
        $stmt = $this->db->prepare($sql);
        $stmt->bind_param($types, ...$values);
        
        if ($stmt->execute()) {
            sendResponse(true, null, 'Settings updated successfully');
        } else {
            sendResponse(false, null, 'Failed to update settings', 500);
        }
    }
}

$method = $_SERVER['REQUEST_METHOD'];
$settings = new SettingsController();

if ($method === 'GET') {
    $settings->getSettings();
} elseif ($method === 'POST' || $method === 'PUT') {
    $settings->updateSettings();
} else {
    sendResponse(false, null, 'Method not allowed', 405);
}
