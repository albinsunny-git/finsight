<?php
/**
 * FinSight Master Configuration
 */

// 1. Force Production if not on a known local host
$host = $_SERVER['HTTP_HOST'] ?? '';
$isLocalhost = ($host === 'localhost' || $host === '127.0.0.1' || strpos($host, '192.168.') === 0 || empty($host));

// 2. Database Configuration (RAILWAY MYSQL)
if ($isLocalhost) {
    define('DB_HOST', '127.0.0.1');
    define('DB_USER', 'root');
    define('DB_PASS', '');
    define('DB_NAME', 'finsight_db');
    define('DB_PORT', '3306');
} else {
    // Railway MySQL Credentials (FROM YOUR SCREENSHOT)
    define('DB_HOST', 'turntable.proxy.rlwy.net');
    define('DB_USER', 'root');
    define('DB_PASS', 'JFdaAfOpwWsyXermUpsXMISgOyiqHDHO');
    define('DB_NAME', 'railway');
    define('DB_PORT', '43079');
}

// 4. Application Configuration
define('APP_NAME', 'FinSight');
define('APP_URL', $isLocalhost ? 'http://localhost/finsight' : 'https://finsight-1-a1ov.onrender.com');

// 5. Secrets
define('GOOGLE_CLIENT_ID', '235402120316-oi9307meejpv5jlbtt7b4lfr4remn8js.apps.googleusercontent.com');
define('MAIL_USER', 'sunnyalbin3640@gmail.com');
define('MAIL_PASS', 'mdig dpag dila gfey');

// Meta
date_default_timezone_set('UTC');
error_reporting($isLocalhost ? E_ALL : 0);
ini_set('display_errors', $isLocalhost ? 1 : 0);

if (session_status() === PHP_SESSION_NONE && php_sapi_name() !== 'cli') {
    session_start();
}
