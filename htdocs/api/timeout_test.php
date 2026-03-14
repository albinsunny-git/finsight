<?php
// Simple timeout test
echo "Time: " . time() . "\n";
echo "Init...\n";
$m = mysqli_init();
$m->options(MYSQLI_OPT_CONNECT_TIMEOUT, 2);
echo "Connecting (timeout 2s)...\n";
$start = microtime(true);
$res = @$m->real_connect('127.0.0.1', 'root', '', 'finsight_db');
$end = microtime(true);
echo "Done. Result: " . ($res ? "Success" : "Failed") . "\n";
echo "Error: " . $m->connect_error . "\n";
echo "Duration: " . number_format($end - $start, 4) . "s\n";
?>
