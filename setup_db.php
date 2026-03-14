<?php
/**
 * Global Database Seeder
 * This script ensures the 'users' table exists and has a default admin.
 * It works for both MySQL (Localhost) and PostgreSQL (Render).
 */

require_once __DIR__ . '/config/Database.php';

// Detect if we are on Postgres or MySQL
$db = new Database();
$pdo = $db->connect();
$driver = $pdo->getAttribute(PDO::ATTR_DRIVER_NAME);

try {
    echo "<h1>Database Setup</h1>";
    echo "Detected Driver: <b>$driver</b><br><br>";

    // 1. Create Users Table if not exists
    if ($driver === 'pgsql') {
        $sql = "CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            email VARCHAR(255) UNIQUE NOT NULL,
            username VARCHAR(255) UNIQUE NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            first_name VARCHAR(100),
            last_name VARCHAR(100),
            role VARCHAR(50) DEFAULT 'accountant',
            phone VARCHAR(20),
            profile_image TEXT,
            is_active SMALLINT DEFAULT 1,
            last_login TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )";
    } else {
        $sql = "CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            email VARCHAR(255) UNIQUE NOT NULL,
            username VARCHAR(255) UNIQUE NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            first_name VARCHAR(100),
            last_name VARCHAR(100),
            role VARCHAR(50) DEFAULT 'accountant',
            phone VARCHAR(20),
            profile_image TEXT,
            is_active TINYINT DEFAULT 1,
            last_login DATETIME,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )";
    }

    $pdo->exec($sql);
    echo "✅ Table 'users' is ready.<br>";

    // 2. Check for Admin User
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE username = 'admin' OR email = 'admin@finsight.com'");
    $stmt->execute();
    $count = $stmt->fetchColumn();

    if ($count == 0) {
        $password = password_hash('Admin@123', PASSWORD_BCRYPT);
        $stmt = $pdo->prepare("INSERT INTO users (email, username, password_hash, first_name, last_name, role, is_active) VALUES (?, ?, ?, ?, ?, ?, 1)");
        $stmt->execute(['admin@finsight.com', 'admin', $password, 'System', 'Admin', 'admin']);
        echo "✅ Default admin account created (admin/Admin@123).<br>";
    } else {
        echo "ℹ️ Admin account already exists.<br>";
    }

    echo "<br><p><b>Setup Complete!</b> Try logging in now.</p>";
    echo "<a href='index.html'>Go to Login Page</a>";

} catch (Exception $e) {
    echo "<h1>❌ Setup Failed</h1>";
    echo "Error: " . $e->getMessage();
}
