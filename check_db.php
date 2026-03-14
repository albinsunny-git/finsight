<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/Database.php';

header('Content-Type: text/html');

echo "<h1>FinSight Database Diagnostic</h1>";
echo "Current Time: " . date('Y-m-d H:i:s') . " UTC<br>";
echo "Environment: " . ($_SERVER['HTTP_HOST'] === 'localhost' ? 'LOCAL' : 'PRODUCTION') . "<br><br>";

echo "<h3>Connection Details Attempted:</h3>";
echo "Host: " . DB_HOST . "<br>";
echo "Port: " . DB_PORT . "<br>";
echo "User: " . DB_USER . "<br>";
echo "DB Name: " . DB_NAME . "<br>";

$dbUrl = defined('DATABASE_URL') ? DATABASE_URL : 'Not Defined';
echo "Full URL Type: " . (strpos($dbUrl, 'mysql') === 0 ? 'MySQL' : 'PostgreSQL/Other') . "<br><br>";

try {
    echo "<h3>Attempting Connection...</h3>";
    $db = new Database();
    $conn = $db->connect();
    
    if ($conn) {
        echo "<h2 style='color: green;'>✅ Success! Connected to Database.</h2>";
        $driver = $conn->getAttribute(PDO::ATTR_DRIVER_NAME);
        echo "Driver Used: <b>$driver</b><br>";
        
        $stmt = $conn->query("SHOW TABLES");
        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
        echo "Tables Found: " . implode(', ', $tables) ?: 'None';
    }
} catch (Exception $e) {
    echo "<h2 style='color: red;'>❌ Connection Failed</h2>";
    echo "Error Message: " . $e->getMessage();
}
