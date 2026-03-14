<?php
// debug_api_test.php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$baseUrl = 'http://localhost/finsight/backend/api';
$cookieFile = __DIR__ . '/cookie.txt';
if (file_exists($cookieFile)) unlink($cookieFile);

function callApi($endpoint, $method = 'GET', $data = null) {
    global $baseUrl, $cookieFile;
    $url = $baseUrl . $endpoint;
    echo "Request: $method $url\n";
    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_COOKIEJAR, $cookieFile);
    curl_setopt($ch, CURLOPT_COOKIEFILE, $cookieFile);
    curl_setopt($ch, CURLOPT_VERBOSE, false);
    
    if ($method === 'POST') {
        curl_setopt($ch, CURLOPT_POST, true);
        if ($data) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
            curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
        }
    }
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);
    
    if ($error) {
        echo "CURL Error: $error\n";
    }
    
    return ['code' => $httpCode, 'body' => $response];
}

// 1. Login
echo "--- 1. Testing Login ---\n";
// Add action to body as well for auth.php
$creds = ['email_or_username' => 'testadmin', 'password' => 'Password@123', 'action' => 'login']; 
// Note: We use 'admin' as username. In Step 324 we saw 'email_or_username' is used.
// We hope 'admin' exists. If not, this fails.

$res = callApi('/auth.php?action=login', 'POST', $creds);
echo "Response Code: " . $res['code'] . "\n";
echo "Response Body: " . $res['body'] . "\n";

$loginSuccess = false;
if ($res['code'] == 200) {
    $json = json_decode($res['body'], true);
    if (isset($json['success']) && $json['success']) {
        $loginSuccess = true;
        echo "LOGIN SUCCESS!\n";
    }
}

if ($loginSuccess) {
    // 2. Test Create Account
    echo "\n--- 2. Testing Create Account ---\n";
    $accCode = 'TEST-' . rand(1000,9999);
    $accountData = [
        'code' => $accCode,
        'name' => 'Test Account API',
        'type' => 'Expense',
        'sub_type' => 'General',
        'opening_balance' => 0
    ];
    $res = callApi('/accounts.php?action=create', 'POST', $accountData);
    echo "Response Code: " . $res['code'] . "\n";
    echo "Response Body: " . $res['body'] . "\n";
    
} else {
    echo "Skipping further tests due to login failure.\n";
}
?>
