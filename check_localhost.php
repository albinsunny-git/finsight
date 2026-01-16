<?php
echo "Checking localhost...\n";
$mysqli = mysqli_init();
$mysqli->options(MYSQLI_OPT_CONNECT_TIMEOUT, 3);
try {
    $r = $mysqli->real_connect('localhost', 'root', '', 'finsight_db');
    if ($r) {
        echo "SUCCESS: Connected to localhost\n";
    } else {
        echo "FAILURE: " . $mysqli->connect_error . "\n";
    }
} catch (Exception $e) {
    echo "EXCEPTION: " . $e->getMessage() . "\n";
}
?>
