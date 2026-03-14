<?php
echo "Checking 127.0.0.1...\n";
$mysqli = mysqli_init();
$mysqli->options(MYSQLI_OPT_CONNECT_TIMEOUT, 3);
try {
    $r = $mysqli->real_connect('127.0.0.1', 'root', '', 'finsight_db');
    if ($r) {
        echo "SUCCESS: Connected to 127.0.0.1\n";
    } else {
        echo "FAILURE: " . $mysqli->connect_error . "\n";
    }
} catch (Exception $e) {
    echo "EXCEPTION: " . $e->getMessage() . "\n";
}
?>
