<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
$mysqli = new mysqli('127.0.0.1', 'root', '', 'finsight_db');
if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
}
$result = $mysqli->query("SHOW CREATE TABLE users");
if ($row = $result->fetch_assoc()) {
    echo $row['Create Table'];
}
$mysqli->close();
?>
