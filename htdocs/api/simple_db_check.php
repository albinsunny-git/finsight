<?php
echo "Attempting connection with timeout...\n";
$mysqli = mysqli_init();
if (!$mysqli) {
    die("mysqli_init failed");
}

$mysqli->options(MYSQLI_OPT_CONNECT_TIMEOUT, 5);

echo "Connecting to localhost...\n";
try {
    $r = $mysqli->real_connect('localhost', 'root', '', 'finsight_db');
    if ($r) {
        echo "Connected to localhost!\n";
        $mysqli->close();
    } else {
        echo "Failed to connect to localhost: " . $mysqli->connect_error . "\n";
    }
} catch (Exception $e) {
    echo "Exception localhost: " . $e->getMessage() . "\n";
}

$mysqli = mysqli_init();
$mysqli->options(MYSQLI_OPT_CONNECT_TIMEOUT, 5);
echo "Connecting to 127.0.0.1...\n";
try {
    $r = $mysqli->real_connect('127.0.0.1', 'root', '', 'finsight_db');
    if ($r) {
        echo "Connected to 127.0.0.1!\n";
        $mysqli->close();
    } else {
        echo "Failed to connect to 127.0.0.1: " . $mysqli->connect_error . "\n";
    }
} catch (Exception $e) {
    echo "Exception 127.0.0.1: " . $e->getMessage() . "\n";
}
?>
