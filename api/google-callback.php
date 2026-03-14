<?php
// Google OAuth Callback Handler
// Include configuration and database
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../config/Database.php';

// Initialize database
$db = new Database();

// Get the JWT library or create a simple token verification
function verifyGoogleToken($token, $clientId) {
    // Decode the JWT token
    // For production, use proper JWT library like firebase/php-jwt
    
    try {
        // Simple JWT decode (without verification for initial setup)
        // In production, use a proper library
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return false;
        }
        
        // Decode payload
        $payload = json_decode(base64_decode($parts[1]), true);
        
        // Verify token not expired
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            return false;
        }
        
        // Verify client ID
        if ($payload['aud'] !== $clientId) {
            return false;
        }
        
        return $payload;
    } catch (Exception $e) {
        return false;
    }
}

// Main handler
header('Content-Type: application/json');

try {
    // Get the token
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['token'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Token not provided']);
        exit;
    }
    
    $token = $input['token'];
    
    // Verify token with Google
    $payload = verifyGoogleToken($token, GOOGLE_CLIENT_ID);
    
    if (!$payload) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Invalid token']);
        exit;
    }
    
    // Extract user info
    $email = $payload['email'] ?? null;
    $name = $payload['name'] ?? 'Google User';
    $googleId = $payload['sub'] ?? null;
    $picture = $payload['picture'] ?? null;
    
    if (!$email || !$googleId) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid token data']);
        exit;
    }
    
    // Check if user exists
    $user = $db->query(
        "SELECT id, email, username, role, is_active FROM users WHERE google_id = ? OR email = ?",
        [$googleId, $email]
    )->fetch_assoc();
    
    if ($user) {
        // User exists - update last login
        if ($user['is_active']) {
            $db->query(
                "UPDATE users SET last_login = NOW() WHERE id = ?",
                [$user['id']]
            );
            
            $db->logAudit(
                $user['id'],
                'LOGIN',
                'user',
                $user['id'],
                null,
                'Google OAuth Sign In successful'
            );
        } else {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'User account is inactive']);
            exit;
        }
    } else {
        // Create new user from Google data
        // Extract names
        $nameParts = explode(' ', $name, 2);
        $firstName = $nameParts[0] ?? 'Google';
        $lastName = $nameParts[1] ?? 'User';
        
        // Generate unique username from email
        $baseUsername = explode('@', $email)[0];
        $username = $baseUsername;
        $counter = 1;
        
        while ($db->query(
            "SELECT id FROM users WHERE username = ?",
            [$username]
        )->num_rows > 0) {
            $username = $baseUsername . $counter;
            $counter++;
        }
        
        // Insert new user
        $result = $db->query(
            "INSERT INTO users (email, username, password_hash, first_name, last_name, google_id, profile_image, role, is_active, created_at) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, NOW())",
            [
                $email,
                $username,
                null, // No password for OAuth users
                $firstName,
                $lastName,
                $googleId,
                $picture ?? null,
                'accountant' // Default role
            ]
        );
        
        if (!$result) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to create user']);
            exit;
        }
        
        $userId = $db->connection->insert_id;
        
        // Log the signup
        $db->logAudit(
            $userId,
            'REGISTER',
            'user',
            $userId,
            null,
            'New user registered via Google OAuth'
        );
        
        $user = [
            'id' => $userId,
            'email' => $email,
            'username' => $username,
            'role' => 'accountant',
            'is_active' => 1
        ];
    }
    
    // Create session token
    $sessionData = [
        'user_id' => $user['id'],
        'email' => $user['email'],
        'role' => $user['role'],
        'timestamp' => time()
    ];
    
    $sessionToken = bin2hex(random_bytes(32));
    
    // Store in session
    session_start();
    $_SESSION['user_id'] = $user['id'];
    $_SESSION['email'] = $user['email'];
    $_SESSION['role'] = $user['role'];
    
    // Return success with user data
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Google Sign In successful',
        'user' => [
            'id' => $user['id'],
            'email' => $user['email'],
            'username' => $user['username'] ?? '',
            'role' => $user['role'],
            'is_active' => $user['is_active']
        ],
        'sessionToken' => $sessionToken
    ]);
    
} catch (Exception $e) {
    error_log('Google OAuth Error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'An error occurred']);
}
?>
