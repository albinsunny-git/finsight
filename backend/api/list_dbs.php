<?php
$conn = new mysqli('localhost', 'root', '');
$result = $conn->query("SHOW DATABASES");
while ($row = $result->fetch_assoc()) {
    echo $row['Database'] . "\n";
}
?>
