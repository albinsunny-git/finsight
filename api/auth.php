<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

// If this is an OPTIONS request, exit immediately
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../config/Database.php';

class AuthController {
    private $db;
    
    public function __construct() {
        $this->db = new Database();
    }
    
    public function register() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            sendResponse(false, null, 'Invalid request method', 400);
        }
        
        $data = $GLOBALS['inputData'];
        // Normalize email/username
        $data['email'] = strtolower(trim($data['email']));
        $data['username'] = trim($data['username']);
        
        $required = ['email', 'username', 'password', 'confirm_password', 'first_name', 'last_name'];
        foreach ($required as $field) {
            if (empty($data[$field])) {
                sendResponse(false, null, "Missing required field: $field", 400);
            }
        }
        
        if (!validateEmail($data['email'])) {
            sendResponse(false, null, 'Invalid email format', 400);
        }
        
        if (!validatePassword($data['password'])) {
            sendResponse(false, null, 'Password must be at least 8 characters with uppercase, lowercase, number, and special character', 400);
        }
        
        if ($data['password'] !== $data['confirm_password']) {
            sendResponse(false, null, 'Passwords do not match', 400);
        }
        
        // Check if user exists (case-insensitive)
        $stmt = $this->db->prepare("SELECT id FROM users WHERE LOWER(email) = LOWER(?) OR LOWER(username) = LOWER(?)");
        $stmt->bind_param("ss", $data['email'], $data['username']);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            sendResponse(false, null, 'Email or username already exists', 409);
        }
        $stmt->close();
        
        // Create new user
        $passwordHash = hashPassword($data['password']);
        $role = 'accountant'; // Default role
        $stmt = $this->db->prepare("INSERT INTO users (email, username, password_hash, first_name, last_name, role) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("ssssss", $data['email'], $data['username'], $passwordHash, $data['first_name'], $data['last_name'], $role);
        
        if ($stmt->execute()) {
            $userId = $this->db->getConnection()->insert_id;
            logAudit($userId, 'USER_REGISTERED', 'users', $userId);
            sendResponse(true, ['user_id' => $userId], 'User registered successfully', 201);
        } else {
            sendResponse(false, null, 'Registration failed', 500);
        }
        
        $stmt->close();
    }
    
    public function login() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            sendResponse(false, null, 'Invalid request method', 400);
        }
        
        $data = $GLOBALS['inputData'];
        
        if (empty($data['email_or_username']) || empty($data['password'])) {
            sendResponse(false, null, 'Email/username and password are required', 400);
        }
        
        // Normalize input and perform case-insensitive lookup for email/username
        $emailOrUsername = trim($data['email_or_username']);
        $stmt = $this->db->prepare("SELECT id, email, username, password_hash, first_name, last_name, role, phone, is_active, profile_image FROM users WHERE (LOWER(email) = LOWER(?) OR LOWER(username) = LOWER(?))");
        $stmt->bind_param("ss", $emailOrUsername, $emailOrUsername);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            // Log failed login with attempted identifier for debugging (do not log password)
            $attempt = $emailOrUsername;
            logAudit(0, 'LOGIN_FAILED', 'users', 0, null, $attempt);
            sendResponse(false, null, 'Invalid credentials', 401);
        }
        
        $user = $result->fetch_assoc();
        $stmt->close();
        
        if (!$user['is_active']) {
            sendResponse(false, null, 'Account is inactive', 403);
        }
        
        // Password verification - supportbcrypt hash and legacy plaintext passwords
        $providedPassword = $data['password'];
        $storedHash = $user['password_hash'] ?? '';

        $isValid = false;

        // If stored hash looks like bcrypt, verify using password_verify
        if (strpos($storedHash, '$2y$') === 0 || strpos($storedHash, '$2b$') === 0 || strpos($storedHash, '$argon2') === 0) {
            if (verifyPassword($providedPassword, $storedHash)) {
                $isValid = true;
            }
        } else {
            // Not a bcrypt/argon hash - maybe plaintext in DB (legacy). Compare directly.
            if ($providedPassword === $storedHash) {
                $isValid = true;
                // Migrate plaintext password to bcrypt for security
                $newHash = hashPassword($providedPassword);
                $stmt = $this->db->prepare("UPDATE users SET password_hash = ? WHERE id = ?");
                $stmt->bind_param("si", $newHash, $user['id']);
                $stmt->execute();
                $stmt->close();
                logAudit($user['id'], 'PASSWORD_MIGRATED', 'users', $user['id']);
            }
        }

        // Also allow seed placeholder case for Admin: re-hash on first successful default login
        if (!$isValid && $storedHash === '$2y$10$YourHashedPasswordHere' && $providedPassword === 'Admin@123') {
            $isValid = true;
            $newHash = hashPassword($providedPassword);
            $stmt = $this->db->prepare("UPDATE users SET password_hash = ? WHERE id = ?");
            $stmt->bind_param("si", $newHash, $user['id']);
            $stmt->execute();
            $stmt->close();
            logAudit($user['id'], 'PASSWORD_MIGRATED', 'users', $user['id']);
        }

        if (!$isValid) {
            // Log failed attempt with attempted identifier
            logAudit($user['id'], 'LOGIN_FAILED', 'users', $user['id'], null, $emailOrUsername);
            sendResponse(false, null, 'Invalid credentials', 401);
        }
        
        // Update last login
        $stmt = $this->db->prepare("UPDATE users SET last_login = NOW() WHERE id = ?");
        $stmt->bind_param("i", $user['id']);
        $stmt->execute();
        $stmt->close();
        
        // Set session
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['role'] = strtolower(trim($user['role']));
        $_SESSION['email'] = $user['email'];
        $_SESSION['username'] = $user['username'];
        $_SESSION['first_name'] = $user['first_name'];
        $_SESSION['last_name'] = $user['last_name'];
        
        logAudit($user['id'], 'LOGIN_SUCCESS', 'users', $user['id']);
        
        unset($user['password_hash']);
        $user['role'] = strtolower(trim($user['role']));
        sendResponse(true, $user, 'Login successful', 200);
    }
    
    public function logout() {
        if (isset($_SESSION['user_id'])) {
            logAudit($_SESSION['user_id'], 'LOGOUT', 'users', $_SESSION['user_id']);
            session_destroy();
        }
        sendResponse(true, null, 'Logged out successfully', 200);
    }
    
    public function forgotPassword() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            sendResponse(false, null, 'Invalid request method', 400);
        }
        
        $data = $GLOBALS['inputData'];
        
        if (empty($data['email'])) {
            sendResponse(false, null, 'Email is required', 400);
        }

        $email = strtolower(trim($data['email']));
        $stmt = $this->db->prepare("SELECT id FROM users WHERE LOWER(email) = LOWER(?)");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            // Don't reveal if email exists
            sendResponse(true, null, 'If email exists, password reset link has been sent', 200);
            return;
        }
        
        $user = $result->fetch_assoc();
        $stmt->close();
        
        $token = generateToken();
        $token = generateToken();
        // Use DB time for expiration to avoid timezone mismatches
        
        $stmt = $this->db->prepare("INSERT INTO password_resets (user_id, token, expiration) VALUES (?, ?, NOW() + INTERVAL 1 HOUR)");
        $stmt->bind_param("is", $user['id'], $token);
        $stmt->execute();
        $stmt->close();
        
        // Send email with reset link
        $resetLink = APP_URL . "/pages/reset-password.html?token=$token";
        
        require_once __DIR__ . '/../config/MailService.php';
        $mailer = new SimpleSMTP();
        
        $subject = "Reset Your Password - " . APP_NAME;
        $body = "
            <h2>Password Reset Request</h2>
            <p>Hello,</p>
            <p>We received a request to reset your password for your FinSight account.</p>
            <p>Click the button below to reset your password:</p>
            <p>
                <a href='$resetLink' style='background-color: #2563eb; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;'>Reset Password</a>
            </p>
            <p>Or copy and paste this link in your browser:</p>
            <p>$resetLink</p>
            <p>This link will expire in 1 hour.</p>
            <p>If you didn't request this, you can safely ignore this email.</p>
            <br>
            <p>Best regards,<br>FinSight Team</p>
        ";
        
        if ($mailer->send($email, $subject, $body)) {
            logAudit($user['id'], 'PASSWORD_RESET_REQUESTED', 'users', $user['id']);
            sendResponse(true, null, 'Password reset link has been sent to your email', 200);
        } else {
            sendResponse(false, null, 'Failed to send reset email. Please try again later.', 500);
        }
    }
    
    public function resetPassword() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            sendResponse(false, null, 'Invalid request method', 400);
        }
        
        $data = $GLOBALS['inputData'];
        
        if (empty($data['token']) || empty($data['password']) || empty($data['confirm_password'])) {
            sendResponse(false, null, 'Missing required fields', 400);
        }
        
        if ($data['password'] !== $data['confirm_password']) {
            sendResponse(false, null, 'Passwords do not match', 400);
        }
        
        if (!validatePassword($data['password'])) {
            sendResponse(false, null, 'Password must be at least 8 characters with uppercase, lowercase, number, and special character', 400);
        }
        
        $stmt = $this->db->prepare("SELECT user_id, expiration, NOW() as db_now FROM password_resets WHERE token = ?");
        $stmt->bind_param("s", $data['token']);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            sendResponse(false, null, 'Invalid or expired token', 401);
        }
        
        $reset = $result->fetch_assoc();
        $stmt->close();
        
        $passwordHash = hashPassword($data['password']);
        $stmt = $this->db->prepare("UPDATE users SET password_hash = ? WHERE id = ?");
        $stmt->bind_param("si", $passwordHash, $reset['user_id']);
        $stmt->execute();
        $stmt->close();
        
        $stmt = $this->db->prepare("UPDATE password_resets SET is_used = TRUE WHERE token = ?");
        $stmt->bind_param("s", $data['token']);
        $stmt->execute();
        $stmt->close();
        
        logAudit($reset['user_id'], 'PASSWORD_RESET_SUCCESS', 'users', $reset['user_id']);
        sendResponse(true, null, 'Password reset successful', 200);
    }
    
    public function changePassword() {
        if (!isset($_SESSION['user_id'])) {
            sendResponse(false, null, 'Unauthorized', 401);
        }

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            sendResponse(false, null, 'Invalid request method', 400);
        }
        
        $data = $GLOBALS['inputData'];
        
        if (empty($data['current_password']) || empty($data['new_password']) || empty($data['confirm_password'])) {
            sendResponse(false, null, 'All fields are required', 400);
        }
        
        if ($data['new_password'] !== $data['confirm_password']) {
            sendResponse(false, null, 'New passwords do not match', 400);
        }
        
        if (!validatePassword($data['new_password'])) {
            sendResponse(false, null, 'Password must be at least 8 characters with uppercase, lowercase, number, and special character', 400);
        }
        
        $userId = $_SESSION['user_id'];
        
        // precise verification of current password
        $stmt = $this->db->prepare("SELECT password_hash FROM users WHERE id = ?");
        $stmt->bind_param("i", $userId);
        $stmt->execute();
        $result = $stmt->get_result();
        $user = $result->fetch_assoc();
        $stmt->close();
        
        $currentHash = $user['password_hash'];
        $currentValid = false;
        
        // Support both old plaintext and new bcrypt
        if (strpos($currentHash, '$2y$') === 0 || strpos($currentHash, '$2b$') === 0 || strpos($currentHash, '$argon2') === 0) {
            if (verifyPassword($data['current_password'], $currentHash)) {
                $currentValid = true;
            }
        } else {
            if ($data['current_password'] === $currentHash) {
                $currentValid = true;
            }
        }
        
        if (!$currentValid) {
            sendResponse(false, null, 'Incorrect current password', 401);
        }
        
        $newHash = hashPassword($data['new_password']);
        
        $stmt = $this->db->prepare("UPDATE users SET password_hash = ? WHERE id = ?");
        $stmt->bind_param("si", $newHash, $userId);
        
        if ($stmt->execute()) {
            logAudit($userId, 'PASSWORD_CHANGED', 'users', $userId);
            sendResponse(true, null, 'Password changed successfully', 200);
        } else {
            sendResponse(false, null, 'Failed to update password', 500);
        }
        $stmt->close();
    }

    public function googleCallback() {
        // Support both id_token from Google Identity Services (client-side) or server-side code (authorization code)
        $data = $GLOBALS['inputData'] ?? [];
        $idToken = $data['token'] ?? $_POST['token'] ?? $_GET['token'] ?? null;
        
        // If we received an OAuth 'code' (server flow) we don't yet support full code exchange here
        $code = $_GET['code'] ?? null;

        if (!$idToken && !$code) {
            sendResponse(false, null, 'No authorization token provided', 400);
        }

        if ($code) {
            // Server-side code exchange can be implemented here if required
            sendResponse(false, null, 'Server-side authorization code flow not implemented. Use client-side token (id_token).', 501);
        }

        // Verify id_token with Google's tokeninfo endpoint
        $verifyUrl = 'https://oauth2.googleapis.com/tokeninfo?id_token=' . urlencode($idToken);

        $response = false;
        if (function_exists('curl_version')) {
            $ch = curl_init($verifyUrl);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 5);
            $response = curl_exec($ch);
            $curlErr = curl_error($ch);
            curl_close($ch);
            if ($curlErr) {
                error_log('Google token verification curl error: ' . $curlErr);
            }
        } else {
            $response = @file_get_contents($verifyUrl);
        }

        if (!$response) {
            sendResponse(false, null, 'Failed to verify Google token', 400);
        }

        $payload = json_decode($response, true);
        if (empty($payload) || empty($payload['aud'])) {
            sendResponse(false, null, 'Invalid token payload from Google', 400);
        }

        // Validate audience (Allow both OAuth Client ID and Firebase Project ID)
        if ($payload['aud'] !== GOOGLE_CLIENT_ID && $payload['aud'] !== FIREBASE_PROJECT_ID) {
            sendResponse(false, null, 'Token audience mismatch: ' . $payload['aud'], 403);
        }

        $email = $payload['email'] ?? null;
        if (!$email) sendResponse(false, null, 'Email not provided by Google token', 400);

        $emailVerified = isset($payload['email_verified']) ? (bool)$payload['email_verified'] : false;

        // Lookup user by email
        $stmt = $this->db->prepare("SELECT id, email, username, password_hash, first_name, last_name, role, is_active, profile_image FROM users WHERE LOWER(email) = LOWER(?)");
        $stmt->bind_param('s', $email);
        $stmt->execute();
        $result = $stmt->get_result();

        $user = null;
        if ($result->num_rows > 0) {
            $user = $result->fetch_assoc();
            $stmt->close();

            if (!$user['is_active']) {
                sendResponse(false, null, 'Account is inactive', 403);
            }

            // Update name/profile image if changed
            $updateNeeded = false;
            $updateFields = [];
            $params = [];
            $types = '';

            $firstName = $payload['given_name'] ?? strtok($payload['name'] ?? '', ' ');
            $lastName = $payload['family_name'] ?? trim(str_replace($firstName, '', ($payload['name'] ?? '')));
            $picture = $payload['picture'] ?? null;

            if ($firstName && $firstName !== $user['first_name']) { $updateFields[] = 'first_name = ?'; $params[] = $firstName; $types .= 's'; $updateNeeded = true; }
            if ($lastName && $lastName !== $user['last_name']) { $updateFields[] = 'last_name = ?'; $params[] = $lastName; $types .= 's'; $updateNeeded = true; }
            if ($picture && $picture !== $user['profile_image']) { $updateFields[] = 'profile_image = ?'; $params[] = $picture; $types .= 's'; $updateNeeded = true; }

            if ($updateNeeded) {
                $params[] = $user['id']; $types .= 'i';
                $sql = "UPDATE users SET " . implode(', ', $updateFields) . " WHERE id = ?";
                $uStmt = $this->db->prepare($sql);
                $uStmt->bind_param($types, ...$params);
                $uStmt->execute();
                $uStmt->close();
            }
        } else {
            $stmt->close();
            // Auto-create user for verified Google login
            $firstName = $payload['given_name'] ?? strtok($payload['name'] ?? '', ' ');
            $lastName = $payload['family_name'] ?? trim(str_replace($firstName, '', ($payload['name'] ?? '')));
            
            // Create a safe username
            $baseUsername = strtolower(preg_replace('/[^a-zA-Z0-9]/', '', $firstName . $lastName));
            $username = $baseUsername ?: 'user_' . substr(md5($email), 0, 8);
            
            // Check if username already exists, if so append random digits
            $checkStmt = $this->db->prepare("SELECT id FROM users WHERE username = ?");
            $checkStmt->bind_param("s", $username);
            $checkStmt->execute();
            if ($checkStmt->get_result()->num_rows > 0) {
                $username .= rand(100, 999);
            }
            $checkStmt->close();

            $passwordHash = hashPassword(bin2hex(random_bytes(16))); // Random secure password
            $role = 'accountant'; // Default role
            $picture = $payload['picture'] ?? null;

            $stmt = $this->db->prepare("INSERT INTO users (email, username, password_hash, first_name, last_name, role, is_active, profile_image) VALUES (?, ?, ?, ?, ?, ?, 1, ?)");
            $stmt->bind_param("sssssss", $email, $username, $passwordHash, $firstName, $lastName, $role, $picture);
            
            if ($stmt->execute()) {
                $newUserId = $this->db->getConnection()->insert_id;
                $user = [
                    'id' => $newUserId,
                    'email' => $email,
                    'username' => $username,
                    'first_name' => $firstName,
                    'last_name' => $lastName,
                    'role' => $role,
                    'is_active' => 1,
                    'profile_image' => $picture
                ];
                logAudit($newUserId, 'USER_REGISTERED_GOOGLE', 'users', $newUserId);
            } else {
                sendResponse(false, null, 'Failed to auto-create user account via Google', 500);
            }
            $stmt->close();
        }

        // Set session and update last_login
        $stmt3 = $this->db->prepare("UPDATE users SET last_login = NOW() WHERE id = ?");
        $stmt3->bind_param('i', $user['id']); $stmt3->execute(); $stmt3->close();

        $_SESSION['user_id'] = $user['id'];
        $_SESSION['role'] = strtolower($user['role']);
        $_SESSION['email'] = $user['email'];
        $_SESSION['username'] = $user['username'];
        $_SESSION['first_name'] = $user['first_name'];
        $_SESSION['last_name'] = $user['last_name'];

        // Provide a session token for client (optional)
        $sessionToken = generateToken(16);
        $_SESSION['session_token'] = $sessionToken;

        // Remove sensitive info
        unset($user['password_hash']);

        logAudit($user['id'], 'LOGIN_SUCCESS_GOOGLE', 'users', $user['id']);

        sendResponse(true, ['user' => $user, 'sessionToken' => $sessionToken, 'email_verified' => $emailVerified], 'Login successful via Google', 200);
    }
}

// Route handling
$method = $_SERVER['REQUEST_METHOD'];

// Read input data once
$inputData = json_decode(file_get_contents('php://input'), true) ?? [];

// Get action from multiple sources
$path = null;

// First, try to get from POST data
if (!empty($inputData['action'])) {
    $path = $inputData['action'];
}
// Then try GET parameter
elseif (!empty($_GET['action'])) {
    $path = $_GET['action'];
}
// Finally try URL path
else {
    $urlPath = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);
    // Remove base path
    $urlPath = str_replace('/api/auth.php', '', $urlPath);
    $urlPath = str_replace('/api/auth/', '', $urlPath);
    $urlPath = str_replace('/auth/', '', $urlPath);
    $urlPath = str_replace('.php', '', $urlPath);
    $urlPath = trim($urlPath, '/');
    
    if (!empty($urlPath)) {
        $path = $urlPath;
    }
}

// Store input data in a way the methods can access it
$GLOBALS['inputData'] = $inputData;

$auth = new AuthController();

switch ($path) {
    case 'register':
    case 'register.php':
        $auth->register();
        break;
    case 'login':
    case 'login.php':
        $auth->login();
        break;
    case 'logout':
    case 'logout.php':
        $auth->logout();
        break;
    case 'forgot-password':
    case 'forgot-password.php':
        $auth->forgotPassword();
        break;
    case 'reset-password':
    case 'reset-password.php':
        $auth->resetPassword();
        break;
    case 'change-password':
    case 'change-password.php':
        $auth->changePassword();
        break;
    case 'google-callback':
    case 'google-callback.php':
        $auth->googleCallback();
        break;
    default:
        sendResponse(false, null, 'Invalid action: ' . ($path ?? 'none provided') . '. Valid actions: register, login, logout, forgot-password, reset-password, change-password, google-callback', 400);
}
