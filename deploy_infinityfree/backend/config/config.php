<?php
// Database Configuration
define('DB_HOST', getenv('DB_HOST') ?: 'dpg-d6qfreea2pns73a03q80-a');
define('DB_USER', getenv('DB_USER') ?: 'admin');
define('DB_PASS', getenv('DB_PASSWORD') ?: 'kln0b6ip4FqayZvh3x5Or6u9QuxsW3E2');
define('DB_NAME', getenv('DB_NAME') ?: 'finsight_db_2i8q');
define('DB_PORT', getenv('DB_PORT') ?: '5432');

// Application Configuration
define('APP_NAME', 'FinSight');
define('APP_URL', getenv('APP_URL') ?: 'http://localhost/finsight');
define('APP_VERSION', '1.0.0');

// Security Configuration
define('JWT_SECRET', getenv('JWT_SECRET') ?: 'albinsunny3640');
define('SESSION_TIMEOUT', 3600); // 1 hour in seconds
define('PASSWORD_RESET_TIMEOUT', 3600); // 1 hour

// Email Configuration
define('MAIL_HOST', getenv('MAIL_HOST') ?: 'smtp.gmail.com');
define('MAIL_PORT', getenv('MAIL_PORT') ?: 587);
define('MAIL_USER', getenv('MAIL_USER') ?: 'your_email@gmail.com');
define('MAIL_PASS', getenv('MAIL_PASS') ?: 'your_app_password');
define('MAIL_FROM', getenv('MAIL_FROM') ?: 'noreply@finsight.com');

// Google OAuth Configuration
define('GOOGLE_CLIENT_ID', getenv('GOOGLE_CLIENT_ID') ?: '235402120316-oi9307meejpv5jlbtt7b4lfr4remn8js.apps.googleusercontent.com');
define('GOOGLE_CLIENT_SECRET', getenv('GOOGLE_CLIENT_SECRET') ?: 'YOUR_GOOGLE_CLIENT_SECRET');
define('GOOGLE_REDIRECT_URI', APP_URL . '/backend/api/auth/google-callback.php');

// Firebase Configuration
define('FIREBASE_API_KEY', getenv('FIREBASE_API_KEY') ?: 'AIzaSyBIchbChhsl1arZvzUGjAZc4K2q-UAxXDM');
define('FIREBASE_AUTH_DOMAIN', getenv('FIREBASE_AUTH_DOMAIN') ?: 'finsight-159e0.firebaseapp.com');
define('FIREBASE_DATABASE_URL', getenv('FIREBASE_DATABASE_URL') ?: 'https://your-project.firebaseio.com');
define('FIREBASE_PROJECT_ID', getenv('FIREBASE_PROJECT_ID') ?: 'finsight-159e0');
define('FIREBASE_STORAGE_BUCKET', getenv('FIREBASE_STORAGE_BUCKET') ?: 'finsight-159e0.firebasestorage.app');
define('FIREBASE_MESSAGING_SENDER_ID', getenv('FIREBASE_MESSAGING_SENDER_ID') ?: '235402120316');
define('FIREBASE_APP_ID', getenv('FIREBASE_APP_ID') ?: '1:235402120316:web:86248fc504288e10b54df9');
define('FIREBASE_WEB_CLIENT_ID', getenv('FIREBASE_WEB_CLIENT_ID') ?: '235402120316-oi9307meejpv5jlbtt7b4lfr4remn8js.apps.googleusercontent.com');

// File Upload Configuration
define('MAX_FILE_SIZE', 5242880); // 5MB
define('UPLOAD_PATH', __DIR__ . '/../../uploads/');
define('ALLOWED_EXTENSIONS', ['jpg', 'jpeg', 'png', 'pdf', 'csv', 'xlsx']);

// Timezone
date_default_timezone_set('UTC');

// Error Reporting (Set to 0 in production)
error_reporting(E_ALL);
ini_set('display_errors', 0);

// Session Configuration
if (session_status() === PHP_SESSION_NONE) {
    session_set_cookie_params([
        'lifetime' => SESSION_TIMEOUT,
        'path' => '/',
        'domain' => '',
        'secure' => (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on'),
        'httponly' => true,
        'samesite' => 'Lax'
    ]);
}

// CORS Headers
// CORS Headers
if (isset($_SERVER['HTTP_ORIGIN'])) {
    header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
    header('Access-Control-Allow-Credentials: true');
    header('Access-Control-Max-Age: 86400');    // cache for 1 day
}

if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']))
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']))
        header("Access-Control-Allow-Headers: {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");
    exit(0);
}

// Only send Content-Type for HTTP requests (not CLI)
if (php_sapi_name() !== 'cli') {
    header('Content-Type: application/json');
}

// Start Session with above parameters
if (session_status() === PHP_SESSION_NONE && php_sapi_name() !== 'cli') {
    session_start();
}
?>
