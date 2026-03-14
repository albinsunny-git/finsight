<?php
/**
 * FinSight Master Configuration
 */

// 1. Load .env file if it exists (Local Dev)
if (file_exists(__DIR__ . '/../.env')) {
    $lines = file(__DIR__ . '/../.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        list($name, $value) = explode('=', $line, 2);
        putenv(trim($name) . "=" . trim($value));
    }
}

// 2. Environment Detection
$isLocalhost = ($_SERVER['HTTP_HOST'] === 'localhost' || $_SERVER['SERVER_NAME'] === 'localhost' || $_SERVER['REMOTE_ADDR'] === '127.0.0.1');
$isRender = (getenv('RENDER') === 'true' || strpos($_SERVER['HTTP_HOST'] ?? '', 'onrender.com') !== false);

// 3. Database Configuration
if ($isLocalhost) {
    // Localhost XAMPP Settings
    define('DB_HOST', 'localhost');
    define('DB_USER', 'root');
    define('DB_PASS', '');
    define('DB_NAME', 'finsight_db');
    define('DB_PORT', '3306');
} else {
    /** 
     * RENDER PRODUCTION SETTINGS
     * We hardcode these to ensure they take precedence over old dashboard variables.
     */
    define('DB_HOST', 'dpg-d6qfreea2pns73a03q80-a.oregon-postgres.render.com'); 
    define('DB_USER', 'admin');
    define('DB_PASS', 'kln0b6ip4FqayZvh3x5Or6u9QuxsW3E2');
    define('DB_NAME', 'finsight_db_2i8q');
    define('DB_PORT', '5432');
}

// 4. Application Configuration
define('APP_NAME', 'FinSight');
define('APP_URL', $isLocalhost ? 'http://localhost/finsight' : 'https://finsight-1-a1ov.onrender.com');
define('APP_VERSION', '1.0.0');

// 5. Security & Secrets (Loaded from Env)
define('GOOGLE_CLIENT_ID', getenv('GOOGLE_CLIENT_ID') ?: '235402120316-oi9307meejpv5jlbtt7b4lfr4remn8js.apps.googleusercontent.com');
define('GOOGLE_CLIENT_SECRET', getenv('GOOGLE_CLIENT_SECRET') ?: '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');
define('MAIL_USER', getenv('MAIL_USER') ?: 'sunnyalbin3640@gmail.com');
define('MAIL_PASS', getenv('MAIL_PASS') ?: 'mdig dpag dila gfey');

// 6. Generic Settings
define('SESSION_TIMEOUT', 3600);
date_default_timezone_set('UTC');
error_reporting($isLocalhost ? E_ALL : 0);
ini_set('display_errors', $isLocalhost ? 1 : 0);

// 7. CORS & Session
if (isset($_SERVER['HTTP_ORIGIN'])) {
    header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
    header('Access-Control-Allow-Credentials: true');
}

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
    exit(0);
}

if (session_status() === PHP_SESSION_NONE && php_sapi_name() !== 'cli') {
    session_set_cookie_params(['lifetime' => 0, 'path' => '/', 'secure' => !$isLocalhost, 'httponly' => true, 'samesite' => 'Lax']);
    session_start();
}
