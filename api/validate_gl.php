<?php
require_once __DIR__ . '/../config/Database.php';
$db = new Database();
$conn = $db->getConnection();
$res = $conn->query("SELECT DISTINCT account_id FROM general_ledger");
while($row = $res->fetch_assoc()) {
    $aid = $row['account_id'];
    $check = $conn->query("SELECT name FROM account_chart WHERE id = $aid");
    if($check->num_rows == 0) {
        echo "Account ID $aid in GL NOT FOUND in account_chart\n";
    } else {
        echo "Account ID $aid: " . $check->fetch_assoc()['name'] . "\n";
    }
}
?>
