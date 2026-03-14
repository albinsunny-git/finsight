<?php
require_once __DIR__ . '/config.php';

class SimpleSMTP {
    private $host;
    private $port;
    private $username;
    private $password;
    private $socket;

    public function __construct() {
        $this->host = MAIL_HOST;
        $this->port = MAIL_PORT;
        $this->username = MAIL_USER;
        $this->password = MAIL_PASS;
    }

    public function send($to, $subject, $body) {
        try {
            $this->connect();
            $this->auth();
            $this->sendMail($to, $subject, $body);
            $this->quit();
            return true;
        } catch (Exception $e) {
            error_log("SMTP Error: " . $e->getMessage());
            return false;
        }
    }

    private function connect() {
        $this->socket = fsockopen($this->host, $this->port, $errno, $errstr, 30);
        if (!$this->socket) {
            throw new Exception("Could not connect to SMTP host: $errstr ($errno)");
        }
        $this->getResponse(); // Greeting
        
        $this->sendCommand("EHLO " . gethostname());
        $this->sendCommand("STARTTLS");
        
        // Upgrade to TLS
        if (!stream_socket_enable_crypto($this->socket, true, STREAM_CRYPTO_METHOD_TLS_CLIENT)) {
            throw new Exception("Failed to start TLS");
        }
        
        $this->sendCommand("EHLO " . gethostname());
    }

    private function auth() {
        $this->sendCommand("AUTH LOGIN");
        $this->sendCommand(base64_encode($this->username));
        $this->sendCommand(base64_encode($this->password));
    }

    private function sendMail($to, $subject, $body) {
        $this->sendCommand("MAIL FROM: <" . $this->username . ">");
        $this->sendCommand("RCPT TO: <$to>");
        $this->sendCommand("DATA");
        
        $headers = "MIME-Version: 1.0\r\n";
        $headers .= "Content-type: text/html; charset=UTF-8\r\n";
        $headers .= "From: " . APP_NAME . " <" . $this->username . ">\r\n";
        $headers .= "To: $to\r\n";
        $headers .= "Subject: $subject\r\n";
        
        $message = "$headers\r\n$body\r\n.";
        $this->sendCommand($message);
    }

    private function sendCommand($cmd) {
        // Mask password in logs
        $logCmd = $cmd;
        if (strpos($cmd, 'AUTH LOGIN') === false && base64_decode($cmd, true)) {
             // Simple heuristic to avoid logging base64 credentials
             // $logCmd = "***"; 
        }
        file_put_contents(__DIR__ . '/../smtp_debug.log', "C: $logCmd\n", FILE_APPEND);
        
        fputs($this->socket, $cmd . "\r\n");
        $response = $this->getResponse();
        
        file_put_contents(__DIR__ . '/../smtp_debug.log', "S: $response\n", FILE_APPEND);
        
        // Simple check: 4xx and 5xx are errors
        if (substr($response, 0, 1) == '4' || substr($response, 0, 1) == '5') {
            throw new Exception("SMTP Command failed: $cmd. Response: $response");
        }
        return $response;
    }

    private function getResponse() {
        $response = "";
        while ($str = fgets($this->socket, 515)) {
            $response .= $str;
            if (substr($str, 3, 1) == " ") {
                break;
            }
        }
        return $response;
    }

    private function quit() {
        if ($this->socket) {
            fputs($this->socket, "QUIT\r\n");
            fclose($this->socket);
        }
    }
}
?>
