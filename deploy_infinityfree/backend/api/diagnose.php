<?php
header('Content-Type: application/json');
$results = [];

// 1. Check PHP Version
$results['php_version'] = phpversion();

// 2. Check Config
$configFile = __DIR__ . '/../config/config.php';
if (file_exists($configFile)) {
    require_once $configFile;
    $results['config_loaded'] = true;
    $results['db_host'] = DB_HOST;
    $results['db_user'] = DB_USER;
    $results['db_name'] = DB_NAME;
} else {
    $results['config_error'] = "Config file not found at $configFile";
    echo json_encode($results);
    exit;
}

// 3. Test Connection
$start = microtime(true);
try {
    $mysqli = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    
    if ($mysqli->connect_errno) {
        $results['db_status'] = 'error';
        $results['db_error'] = $mysqli->connect_error;
    } else {
        $results['db_status'] = 'connected';
        $results['db_ping'] = $mysqli->ping() ? 'pong' : 'failed';
        $results['db_info'] = $mysqli->host_info;
        $mysqli->close();
    }
} catch (Exception $e) {
    $results['db_status'] = 'exception';
    $results['db_exception'] = $e->getMessage();
}
$results['connection_time_ms'] = (microtime(true) - $start) * 1000;

echo json_encode($results, JSON_PRETTY_PRINT);
?>
