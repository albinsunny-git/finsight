<?php
$url = 'http://localhost/finsight/backend/api/auth.php';
$data = array('action' => 'login', 'email_or_username' => 'admin@example.com', 'password' => 'wrongpass');
$options = array(
    'http' => array(
        'header'  => "Content-type: application/json\r\n",
        'method'  => 'POST',
        'content' => json_encode($data)
    )
);
$context  = stream_context_create($options);
$result = file_get_contents($url, false, $context);
if ($result === FALSE) { 
    echo "Error fetching URL"; 
    // print error details if available
    print_r(error_get_last());
}
echo "RAW OUTPUT START\n";
echo $result;
echo "\nRAW OUTPUT END\n";
?>
