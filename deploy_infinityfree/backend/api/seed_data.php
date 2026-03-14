<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Mock $_SERVER for CLI execution
$_SERVER['REMOTE_ADDR'] = '127.0.0.1';
$_SERVER['HTTP_USER_AGENT'] = 'CLI-Seed-Script';
$_SERVER['REQUEST_METHOD'] = 'POST';

require_once __DIR__ . '/../config/Database.php';

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    // Disable foreign key checks for seeding
    $conn->query("SET FOREIGN_KEY_CHECKS = 0");
    
    // Set mysqli to throw exceptions
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

    echo "Starting data seed...\n";

    // 0. Cleanup existing data
    echo "Cleaning up existing data...\n";
    $conn->query("DELETE FROM general_ledger");
    $conn->query("DELETE FROM voucher_details");
    $conn->query("DELETE FROM vouchers");
    $conn->query("DELETE FROM users");
    $conn->query("DELETE FROM account_chart");

    // 1. Create Users
    $users = [
        ['Admin', 'User', 'admin@example.com', 'admin', 'admin123', 'admin']
    ];

    foreach ($users as $u) {
        $pass = password_hash($u[4], PASSWORD_DEFAULT);
        $email = $u[2];
        $username = $u[3];
        $check = $conn->query("SELECT id FROM users WHERE email='$email' OR username='$username'");
        if ($check->num_rows == 0) {
            echo "Inserting user: $email\n";
            try {
                $stmt = $conn->prepare("INSERT INTO users (first_name, last_name, email, username, password_hash, role, department, is_active, created_by) VALUES (?, ?, ?, ?, ?, ?, 'Finance', 1, 1)");
                
                $firstName = $u[0];
                $lastName = $u[1];
                $username = $u[3];
                $role = $u[5];
                
                $stmt->bind_param("ssssss", $firstName, $lastName, $email, $username, $pass, $role);
                $stmt->execute();
                $stmt->close();
            } catch (Exception $e) {
                echo "Error inserting user $email: " . $e->getMessage() . "\n";
            }
        }
    }
    echo "Users seeded (Admin Only).\n";

    // 2. Create Accounts (Empty - User requested to clear dummy accounts)
    $accounts = []; 
    // If you need default system accounts (like Retained Earnings), add them here, 
    // but the user asked to remove "feeded dummy data", so we leave it empty.
   
    echo "Accounts cleared (No dummy accounts seeded).\n";

    // 3. Create Voucher Types (System Data - Keeping these as they are structural, not 'dummy data' per se, but necessary for the system to function if users create vouchers)
    $vTypes = ['Journal', 'Payment', 'Receipt', 'Sales', 'Purchase'];
    foreach ($vTypes as $vt) {
        $conn->query("INSERT IGNORE INTO voucher_types (name, description) VALUES ('$vt', '$vt Voucher')");
    }
    echo "Voucher Types seeded.\n";

    // 4. Create Vouchers & GL Entries (None)
    echo "No dummy vouchers seeded.\n";

    // Re-enable foreign key checks
    $conn->query("SET FOREIGN_KEY_CHECKS = 1");

    echo "Done.\n";
    echo "Done.\n";

} catch (Exception $e) {
    echo "FATAL ERROR: " . $e->getMessage() . "\n";
    echo "File: " . $e->getFile() . " on line " . $e->getLine() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
