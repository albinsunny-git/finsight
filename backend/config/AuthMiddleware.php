<?php
require_once __DIR__ . '/Database.php';

function checkAuth() {
    // 1. Check existing session
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    if (isset($_SESSION['user_id'])) {
        return true;
    }
    
    // 2. Check Bearer Token (Authorization Header)
    $headers = null;
    if (isset($_SERVER['Authorization'])) {
        $headers = trim($_SERVER["Authorization"]);
    } else if (isset($_SERVER['HTTP_AUTHORIZATION'])) { // Apache/PHP-CGI
        $headers = trim($_SERVER["HTTP_AUTHORIZATION"]);
    } elseif (function_exists('apache_request_headers')) {
        $requestHeaders = apache_request_headers();
        $requestHeaders = array_combine(array_map('ucwords', array_keys($requestHeaders)), array_values($requestHeaders));
        if (isset($requestHeaders['Authorization'])) {
            $headers = trim($requestHeaders['Authorization']);
        }
    }
    
    if (!empty($headers)) {
        if (preg_match('/Bearer\s(\S+)/', $headers, $matches)) {
            $token = $matches[1];
            if (verifyFirebaseTokenAndSetSession($token)) {
                return true;
            }
        }
    }
    
    // 3. Failed
    sendResponse(false, null, 'Unauthorized', 401);
    exit;
}

function checkRole($requiredRoles) {
    checkAuth();
    $userRole = strtolower(trim($_SESSION['role'] ?? ''));
    $required = array_map('strtolower', (array)$requiredRoles);
    
    if (!in_array($userRole, $required)) {
        sendResponse(false, null, 'Forbidden: Insufficient permissions', 403);
        exit;
    }
}

function verifyFirebaseTokenAndSetSession($idToken) {
    // Verify id_token with Google's tokeninfo endpoint (Stateless verification for Firebase/Google Auth)
    // This allows the Android App (using Firebase Auth) to access the API without PHP Session Cookies
    
    $verifyUrl = 'https://oauth2.googleapis.com/tokeninfo?id_token=' . urlencode($idToken);

    $response = false;
    if (function_exists('curl_version')) {
        $ch = curl_init($verifyUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 5);
        $response = curl_exec($ch);
        curl_close($ch);
    } else {
        $response = @file_get_contents($verifyUrl);
    }

    if (!$response) {
        return false;
    }

    $payload = json_decode($response, true);
    if (empty($payload) || empty($payload['email'])) {
        return false;
    }

    // Validate Audience (support both Google Sign-In Client ID and Firebase Project ID)
    $aud = $payload['aud'] ?? '';
    $validAudience = false;
    
    // Check against configured IDs (ignoring placeholders)
    if (defined('GOOGLE_CLIENT_ID') && strpos(GOOGLE_CLIENT_ID, 'YOUR_') === false && $aud === GOOGLE_CLIENT_ID) {
        $validAudience = true;
    }
    if (defined('FIREBASE_PROJECT_ID') && strpos(FIREBASE_PROJECT_ID, 'YOUR_') === false && $aud === FIREBASE_PROJECT_ID) {
        $validAudience = true;
    }
    
    // If we can't verify audience against strict constants (e.g. dev environment), 
    // we might allow it if it's a valid Google Token, but logging a warning is safer.
    // For now, if we have valid definitions, enforce them.
    if ((defined('GOOGLE_CLIENT_ID') && strpos(GOOGLE_CLIENT_ID, 'YOUR_') === false) || 
        (defined('FIREBASE_PROJECT_ID') && strpos(FIREBASE_PROJECT_ID, 'YOUR_') === false)) {
        if (!$validAudience) {
            return false;
        }
    }

    // Token is valid Google/Firebase token. Now verify user exists in our DB.
    $email = $payload['email'];
    
    $db = new Database();
    $stmt = $db->prepare("SELECT id, email, username, first_name, last_name, role, is_active FROM users WHERE LOWER(email) = LOWER(?)");
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $result = $stmt->get_result();
    $user = $result->fetch_assoc();
    $stmt->close();
    
    if (!$user) {
        return false; // User must exist in DB
    }
    
    if (!$user['is_active']) {
        sendResponse(false, null, 'Account is inactive', 403);
        exit;
    }
    
    // Set Session Variables for this request (Simulating a session for the Controller logic)
    $_SESSION['user_id'] = $user['id'];
    $_SESSION['role'] = strtolower($user['role']);
    $_SESSION['email'] = $user['email'];
    $_SESSION['username'] = $user['username'];
    $_SESSION['first_name'] = $user['first_name'];
    $_SESSION['last_name'] = $user['last_name'];
    
    return true;
}
?>
