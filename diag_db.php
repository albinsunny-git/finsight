<?php
$host = '127.0.0.1';
$user = 'root';
// Try with both empty and the possible password
$passwords = ['', 'Leelamma@3640'];

foreach ($passwords as $pass) {
    try {
        echo "Testing with password: '" . ($pass ? '********' : 'EMPTY') . "'... ";
        $pdo = new PDO("mysql:host=$host", $user, $pass);
        echo "✅ SUCCESS!<br>";
        
        $stmt = $pdo->query("SHOW DATABASES");
        $dbs = $stmt->fetchAll(PDO::FETCH_COLUMN);
        echo "Databases found: " . implode(', ', $dbs) . "<br>";
        
        if (in_array('finsight_db', $dbs)) {
            echo "<b>✅ 'finsight_db' EXISTS.</b><br>";
        } else {
             echo "<b>❌ 'finsight_db' NOT FOUND.</b><br>";
        }
        break; // Stop once we find a working one
    } catch (PDOException $e) {
        echo "❌ FAILED: " . $e->getMessage() . "<br>";
    }
}
?>
