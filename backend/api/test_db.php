<?php
$conn = mysqli_init();
$conn->options(MYSQLI_OPT_CONNECT_TIMEOUT, 2);
if ($conn->real_connect('127.0.0.1', 'root', '', 'finsight_db')) {
    echo json_encode(['db' => 'connected']);
} else {
    echo json_encode(['db' => 'failed', 'error' => mysqli_connect_error()]);
}
?>
