<?php
/**
 * Master Config - Unified for Local and Production
 */

// 1. Environment Detection (Much stricter)
$isRender = (getenv('RENDER') === 'true' || (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'onrender.com') !== false));
$isLocalhost = !$isRender;

// 2. Database Configuration
if ($isLocalhost) {
    define('DB_HOST', '127.0.0.1');
    define('DB_USER', 'root');
    define('DB_PASS', '');
    define('DB_NAME', 'finsight_db');
    define('DB_PORT', '3306');
} else {
    // RAILWAY MYSQL PRODUCTION
    define('DB_HOST', getenv('DB_HOST') ?: 'turntable.proxy.rlwy.net');
    define('DB_USER', getenv('DB_USER') ?: 'root');
    define('DB_PASS', getenv('DB_PASS') ?: 'JFdaAfOpwWsyXermUpsXMISgOyiqHDHO');
    define('DB_NAME', getenv('DB_NAME') ?: 'railway');
    define('DB_PORT', getenv('DB_PORT') ?: '43079');
}

// 3. Application Configuration
define('APP_NAME', 'FinSight');
define('APP_URL', $isLocalhost ? 'http://localhost/finsight' : 'https://finsight-1-a1ov.onrender.com');

// 4. Secrets
define('GOOGLE_CLIENT_ID', '235402120316-oi9307meejpv5jlbtt7b4lfr4remn8js.apps.googleusercontent.com');
define('FIREBASE_PROJECT_ID', 'finsight-1-a1ov'); // Extracted from provided Google Client ID structure
define('MAIL_USER', 'sunnyalbin3640@gmail.com');
define('MAIL_PASS', 'mdig dpag dila gfey');
define('MAIL_HOST', 'smtp.gmail.com');
define('MAIL_PORT', 587);

// Meta
date_default_timezone_set('UTC');
error_reporting($isLocalhost ? E_ALL : 0);
ini_set('display_errors', 0); // Never display errors directly in API output
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/../php_error.log');

// 5. Session Setup
if (php_sapi_name() !== 'cli') {
    if (session_status() === PHP_SESSION_NONE) {
        // Ensure cookies work across all paths and are secure on Render
        session_set_cookie_params([
            'lifetime' => 0,
            'path' => $isLocalhost ? '/finsight/' : '/',
            'domain' => '',
            'secure' => $isRender,
            'httponly' => true,
            'samesite' => 'Lax'
        ]);
        session_start();
    }
}

// Enable Gzip compression for all output
if (php_sapi_name() !== 'cli' && !in_array('ob_gzhandler', ob_list_handlers())) {
    ob_start("ob_gzhandler");
}
