<?php
$c = new mysqli('localhost', 'root', '', 'finsight_db');
$res = $c->query("SHOW COLUMNS FROM vouchers");
while($row = $res->fetch_assoc()) echo $row['Field'] . "\n";
echo "===\n";
$res2 = $c->query("SHOW COLUMNS FROM voucher_details");
while($row = $res2->fetch_assoc()) echo $row['Field'] . "\n";
