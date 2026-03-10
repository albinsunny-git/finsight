<?php
require_once 'c:/xampp/htdocs/finsight/backend/config/Database.php';
$_SERVER['REQUEST_METHOD'] = 'GET';
$_SERVER['HTTP_HOST'] = 'localhost';
$_GET['action'] = 'list';
// Fake session auth
session_start();
$_SESSION['user_id'] = 1;
$_SESSION['role'] = 'admin';
require 'c:/xampp/htdocs/finsight/backend/api/users.php';
