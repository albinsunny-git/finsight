<?php
/**
 * FinSight Master Configuration
 */

// 1. Load .env file if it exists
if (file_exists(__DIR__ . '/../.env')) {
    $lines = file(__DIR__ . '/../.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        list($name, $value) = explode('=', $line, 2);
        $_ENV[trim($name)] = trim($value);
        putenv(trim($name) . "=" . trim($value));
    }
}

// 2. Environment Detection
$isLocalhost = ($_SERVER['HTTP_HOST'] === 'localhost' || $_SERVER['SERVER_NAME'] === 'localhost' || $_SERVER['REMOTE_ADDR'] === '127.0.0.1');

// 2. Database Configuration
// Priorities: 1. Environment Variable (Production) 2. Localhost Default 3. Railway Backup
if (getenv('DATABASE_URL')) {
    define('DATABASE_URL', getenv('DATABASE_URL'));
} elseif ($isLocalhost) {
    // Localhost XAMPP Settings
    define('DB_HOST', 'localhost');
    define('DB_USER', 'root');
    define('DB_PASS', '');
    define('DB_NAME', 'finsight_db');
    define('DB_PORT', '3306');
} else {
    // Production / Render / Railway Fallback
    // Based on your latest update for Render/Postgres:
    define('DB_HOST', getenv('DB_HOST') ?: 'dpg-d6qfreea2pns73a03q80-a.oregon-postgres.render.com'); // External host usually required if connecting from outside Render
    define('DB_USER', getenv('DB_USER') ?: 'admin');
    define('DB_PASS', getenv('DB_PASSWORD') ?: 'kln0b6ip4FqayZvh3x5Or6u9QuxsW3E2');
    define('DB_NAME', getenv('DB_NAME') ?: 'finsight_db_2i8q');
    define('DB_PORT', getenv('DB_PORT') ?: '5432');
}

// 3. Application Configuration
define('APP_NAME', 'FinSight');
if ($isLocalhost) {
    define('APP_URL', 'http://localhost/finsight');
} else {
    define('APP_URL', getenv('APP_URL') ?: 'https://finsight-1-a1ov.onrender.com');
}
define('APP_VERSION', '1.0.0');

// 4. Security Configuration
define('JWT_SECRET', getenv('JWT_SECRET') ?: 'albinsunny3640');
define('SESSION_TIMEOUT', 3600); // 1 hour
define('PASSWORD_RESET_TIMEOUT', 3600); // 1 hour

// 5. Email Configuration
define('MAIL_HOST', getenv('MAIL_HOST') ?: 'smtp.gmail.com');
define('MAIL_PORT', getenv('MAIL_PORT') ?: 587);
define('MAIL_USER', getenv('MAIL_USER') ?: 'PLACEHOLDER_EMAIL');
define('MAIL_PASS', getenv('MAIL_PASS') ?: 'PLACEHOLDER_APP_PASSWORD');
define('MAIL_FROM', getenv('MAIL_FROM') ?: 'noreply@finsight.com');

// 6. Google OAuth Configuration
define('GOOGLE_CLIENT_ID', getenv('GOOGLE_CLIENT_ID') ?: 'PLACEHOLDER_CLIENT_ID');
define('GOOGLE_CLIENT_SECRET', getenv('GOOGLE_CLIENT_SECRET') ?: 'PLACEHOLDER_CLIENT_SECRET');
define('GOOGLE_REDIRECT_URI', APP_URL . '/api/auth.php?action=google-callback');

// 7. Firebase Configuration (Keep existing)
define('FIREBASE_API_KEY', getenv('FIREBASE_API_KEY') ?: 'AIzaSyBIchbChhsl1arZvzUGjAZc4K2q-UAxXDM');
define('FIREBASE_PROJECT_ID', getenv('FIREBASE_PROJECT_ID') ?: 'finsight-159e0');

// 8. File Upload Configuration
define('MAX_FILE_SIZE', 5242880); // 5MB
define('UPLOAD_PATH', __DIR__ . '/../uploads/');
define('ALLOWED_EXTENSIONS', ['jpg', 'jpeg', 'png', 'pdf', 'csv', 'xlsx']);

// 9. Timezone
date_default_timezone_set('UTC');

// 10. Error Reporting
if ($isLocalhost) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(0);
    ini_set('display_errors', 0);
}

// 11. CORS & Headers
if (isset($_SERVER['HTTP_ORIGIN'])) {
    header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
    header('Access-Control-Allow-Credentials: true');
}

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
    exit(0);
}

// 12. Session Management
if (session_status() === PHP_SESSION_NONE && php_sapi_name() !== 'cli') {
    session_set_cookie_params([
        'lifetime' => SESSION_TIMEOUT,
        'path' => '/',
        'secure' => (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on'),
        'httponly' => true,
        'samesite' => 'Lax'
    ]);
    session_start();
}
