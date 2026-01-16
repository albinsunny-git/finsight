<?php
require_once __DIR__ . '/../config/Database.php';

// Check if user is authenticated
function checkAuth() {
    if (!isset($_SESSION['user_id'])) {
        sendResponse(false, null, 'Unauthorized', 401);
    }
}

// Check user role
function checkRole($requiredRoles) {
    checkAuth();
    if (!in_array($_SESSION['role'], (array)$requiredRoles)) {
        sendResponse(false, null, 'Forbidden: Insufficient permissions', 403);
    }
}

class VoucherController {
    private $db;
    
    public function __construct() {
        $this->db = new Database();
    }
    
    // Get all vouchers (with role-based filtering)
    public function getVouchers() {
        checkAuth();
        
        $userId = $_SESSION['user_id'];
        $role = $_SESSION['role'];
        $voucherType = $_GET['type'] ?? null;
        $status = $_GET['status'] ?? null;
        $startDate = $_GET['start_date'] ?? null;
        $endDate = $_GET['end_date'] ?? null;
        
        $sql = "SELECT v.*, u.first_name, u.last_name, vt.name as voucher_type_name 
                FROM vouchers v
                LEFT JOIN users u ON v.created_by = u.id
                JOIN voucher_types vt ON v.voucher_type_id = vt.id
                WHERE 1=1";
        
        // Role-based filtering
        if ($role === 'auditor') {
            $sql .= " AND v.status = 'Posted'";
        }
        
        if ($voucherType) {
            $sql .= " AND v.voucher_type_id = " . intval($voucherType);
        }
        
        if ($status) {
            $sql .= " AND v.status = '" . $this->db->escape($status) . "'";
        }
        
        if ($startDate) {
            $sql .= " AND DATE(v.voucher_date) >= '" . $this->db->escape($startDate) . "'";
        }
        
        if ($endDate) {
            $sql .= " AND DATE(v.voucher_date) <= '" . $this->db->escape($endDate) . "'";
        }
        
        $sql .= " ORDER BY v.voucher_date DESC, v.id DESC LIMIT 100";
        
        $result = $this->db->query($sql);
        $vouchers = [];
        
        while ($row = $result->fetch_assoc()) {
            $vouchers[] = $row;
        }
        
        sendResponse(true, $vouchers, 'Vouchers retrieved successfully');
    }
    
    // Get voucher details
    public function getVoucher() {
        checkAuth();
        
        $voucherId = $_GET['id'] ?? null;
        if (!$voucherId) {
            sendResponse(false, null, 'Voucher ID is required', 400);
        }
        
        $stmt = $this->db->prepare("SELECT v.*, u.first_name, u.last_name, vt.name as voucher_type_name 
                                   FROM vouchers v
                                   LEFT JOIN users u ON v.created_by = u.id
                                   JOIN voucher_types vt ON v.voucher_type_id = vt.id
                                   WHERE v.id = ?");
        $stmt->bind_param("i", $voucherId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            sendResponse(false, null, 'Voucher not found', 404);
        }
        
        $voucher = $result->fetch_assoc();
        $stmt->close();
        
        // Get voucher details
        $stmt = $this->db->prepare("SELECT vd.*, ac.code, ac.name 
                                   FROM voucher_details vd
                                   JOIN account_chart ac ON vd.account_id = ac.id
                                   WHERE vd.voucher_id = ?");
        $stmt->bind_param("i", $voucherId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $details = [];
        while ($row = $result->fetch_assoc()) {
            $details[] = $row;
        }
        $stmt->close();
        
        $voucher['details'] = $details;
        sendResponse(true, $voucher, 'Voucher details retrieved');
    }
    
    // Create voucher
    public function createVoucher() {
        try {
            checkRole(['accountant', 'admin', 'administrator']);
            
            $json = file_get_contents('php://input');
            $data = json_decode($json, true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                sendResponse(false, null, 'Invalid JSON input', 400);
            }
            
            $required = ['voucher_type_id', 'voucher_date', 'details'];
            foreach ($required as $field) {
                if (empty($data[$field])) {
                    sendResponse(false, null, "Missing required field: $field", 400);
                }
            }
            
            // Generate voucher number
            $voucherNumber = 'V-' . date('Ymd') . '-' . rand(1000, 9999);
            $userId = $this->db->getValidatedUserId($_SESSION['user_id'] ?? null);
            
            $status = 'Draft';
            $approvedBy = null;
            $approvedAt = null;

            // Allow Admin/Manager to post immediately
            if (isset($data['status']) && $data['status'] === 'Posted') {
                 if (in_array($_SESSION['role'], ['admin', 'administrator', 'manager'])) {
                     $status = 'Posted';
                     $approvedBy = $userId;
                     $approvedAt = date('Y-m-d H:i:s');
                 }
            }
            
            $stmt = $this->db->prepare("INSERT INTO vouchers (voucher_number, voucher_type_id, voucher_date, narration, status, created_by, approved_by, approved_at) 
                                       VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("sisssiss", $voucherNumber, $data['voucher_type_id'], $data['voucher_date'], $data['narration'], $status, $userId, $approvedBy, $approvedAt);
            
            if (!$stmt->execute()) {
                throw new Exception("Database Error: " . $stmt->error);
            }
            
            $voucherId = $this->db->getConnection()->insert_id;
            $stmt->close();
            
            // Add voucher details
            $totalDebit = 0;
            $totalCredit = 0;
            
            foreach ($data['details'] as $detail) {
                $stmt = $this->db->prepare("INSERT INTO voucher_details (voucher_id, account_id, debit, credit, description) 
                                           VALUES (?, ?, ?, ?, ?)");
                $stmt->bind_param("iidds", $voucherId, $detail['account_id'], $detail['debit'], $detail['credit'], $detail['description']);
                if (!$stmt->execute()) {
                     throw new Exception("Detail Insert Error: " . $stmt->error);
                }
                $stmt->close();
                
                $totalDebit += $detail['debit'] ?? 0;
                $totalCredit += $detail['credit'] ?? 0;
            }
            
            // Update voucher totals
            $stmt = $this->db->prepare("UPDATE vouchers SET total_debit = ?, total_credit = ? WHERE id = ?");
            $stmt->bind_param("ddi", $totalDebit, $totalCredit, $voucherId);
            $stmt->execute();
            $stmt->close();
            
            // If Posted, update Ledger immediately
            if ($status === 'Posted') {
                $this->updateGeneralLedger($voucherId);
                logAudit($userId, 'VOUCHER_POSTED_DIRECTLY', 'vouchers', $voucherId);
            } else {
                logAudit($userId, 'VOUCHER_CREATED', 'vouchers', $voucherId);
            }
            
            sendResponse(true, ['voucher_id' => $voucherId, 'voucher_number' => $voucherNumber], 'Voucher created successfully', 201);
            
        } catch (Throwable $e) {
            sendResponse(false, null, 'Voucher Creation Failed: ' . $e->getMessage(), 500);
        }
    }

    // Request Approval (Accountant, Draft only)
    public function requestApproval() {
        checkRole(['accountant', 'admin', 'administrator']);
        
        $data = json_decode(file_get_contents('php://input'), true);
        $voucherId = $data['voucher_id'] ?? null;
        
        if (!$voucherId) {
            sendResponse(false, null, 'Voucher ID is required', 400);
        }
        
        $userId = $_SESSION['user_id'];
        
        // Verify ownership and status
        $stmt = $this->db->prepare("SELECT created_by, status, voucher_number FROM vouchers WHERE id = ?");
        $stmt->bind_param("i", $voucherId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            sendResponse(false, null, 'Voucher not found', 404);
        }
        
        $voucher = $result->fetch_assoc();
        $stmt->close();
        
        if ($voucher['created_by'] != $userId) {
            sendResponse(false, null, 'Forbidden: not owner', 403);
        }
        
        if ($voucher['status'] !== 'Draft') {
            sendResponse(false, null, 'Only Draft vouchers can be submitted for approval', 400);
        }
        
        // Update status
        $stmt = $this->db->prepare("UPDATE vouchers SET status = 'Pending Approval' WHERE id = ?");
        $stmt->bind_param("i", $voucherId);
        
        if ($stmt->execute()) {
            logAudit($userId, 'VOUCHER_SUBMITTED', 'vouchers', $voucherId);
            
            // Notify Managers
            $this->notifyManagers("New voucher approval request: " . $voucher['voucher_number'], $voucherId);
            
            sendResponse(true, null, 'Voucher submitted for approval');
        } else {
            sendResponse(false, null, 'Failed to submit voucher', 500);
        }
        $stmt->close();
    }
    
    // Post voucher
    public function postVoucher() {
        checkRole(['manager', 'admin']);
        
        $data = json_decode(file_get_contents('php://input'), true);
        $voucherId = $data['voucher_id'] ?? null;
        
        if (!$voucherId) {
            sendResponse(false, null, 'Voucher ID is required', 400);
        }
        
        // Verify debit = credit
        $stmt = $this->db->prepare("SELECT total_debit, total_credit, status, created_by, voucher_number FROM vouchers WHERE id = ?");
        $stmt->bind_param("i", $voucherId);
        $stmt->execute();
        $result = $stmt->get_result();
        $voucher = $result->fetch_assoc();
        $stmt->close();
        
        if (abs($voucher['total_debit'] - $voucher['total_credit']) > 0.01) {
            sendResponse(false, null, 'Debit and Credit do not match', 400);
        }
        
        $userId = $_SESSION['user_id'];
        $stmt = $this->db->prepare("UPDATE vouchers SET status = 'Posted', posted_by = ?, posted_at = NOW() WHERE id = ?");
        $stmt->bind_param("ii", $userId, $voucherId);
        
        if ($stmt->execute()) {
            // Update general ledger
            $this->updateGeneralLedger($voucherId);
            logAudit($userId, 'VOUCHER_POSTED', 'vouchers', $voucherId);
            
            // Notify Creator
            $this->createNotification($voucher['created_by'], "Your voucher " . $voucher['voucher_number'] . " has been approved and posted.", 'success', $voucherId);
            
            // Send Email Notification
            $this->sendVoucherEmail($voucher['created_by'], $voucher['voucher_number'], 'approved');
            
            sendResponse(true, null, 'Voucher posted successfully');
        } else {
            sendResponse(false, null, 'Failed to post voucher', 500);
        }
        
        $stmt->close();
    }
    
    // Reject voucher
    public function rejectVoucher() {
        checkRole(['manager', 'admin']);
        
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (empty($data['voucher_id']) || empty($data['reason'])) {
            sendResponse(false, null, 'Voucher ID and reason are required', 400);
        }
        
        $voucherId = $data['voucher_id'];
        
        // Get creator
        $stmt = $this->db->prepare("SELECT created_by, voucher_number FROM vouchers WHERE id = ?");
        $stmt->bind_param("i", $voucherId);
        $stmt->execute();
        $voucher = $stmt->get_result()->fetch_assoc();
        $stmt->close();
        
        $userId = $_SESSION['user_id'];
        $stmt = $this->db->prepare("UPDATE vouchers SET status = 'Rejected', rejected_by = ?, rejected_reason = ?, rejected_at = NOW() WHERE id = ?");
        $stmt->bind_param("isi", $userId, $data['reason'], $voucherId);
        
        if ($stmt->execute()) {
            logAudit($userId, 'VOUCHER_REJECTED', 'vouchers', $voucherId);
            
            // Notify Creator
            $this->createNotification($voucher['created_by'], "Your voucher " . $voucher['voucher_number'] . " was rejected. Reason: " . $data['reason'], 'error', $voucherId);
            
            // Send Email Notification
            $this->sendVoucherEmail($voucher['created_by'], $voucher['voucher_number'], 'rejected', $data['reason']);
            
            sendResponse(true, null, 'Voucher rejected successfully');
        } else {
            sendResponse(false, null, 'Failed to reject voucher', 500);
        }
        
        $stmt->close();
    }

    // Helper to notify managers
    private function notifyManagers($message, $relatedId = null) {
        // Find all managers
        $result = $this->db->query("SELECT id FROM users WHERE role IN ('manager', 'admin')");
        while ($row = $result->fetch_assoc()) {
            $this->createNotification($row['id'], $message, 'info', $relatedId);
        }
    }
    
    // Helper to create notification
    private function createNotification($userId, $message, $type = 'info', $relatedId = null) {
        $stmt = $this->db->prepare("INSERT INTO notifications (user_id, message, type, related_id) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("issi", $userId, $message, $type, $relatedId);
        $stmt->execute();
        $stmt->close();
    }
    
    // Helper to send email notification
    private function sendVoucherEmail($userId, $voucherNumber, $status, $reason = null) {
        try {
            // Get user email
            $stmt = $this->db->prepare("SELECT email, first_name, last_name FROM users WHERE id = ?");
            $stmt->bind_param("i", $userId);
            $stmt->execute();
            $result = $stmt->get_result();
            $user = $result->fetch_assoc();
            $stmt->close();
            
            if (!$user || !$user['email']) {
                error_log("Cannot send email: User email not found for user ID $userId");
                return false;
            }
            
            $userEmail = $user['email'];
            $userName = $user['first_name'] . ' ' . $user['last_name'];
            
            // Prepare email content based on status
            if ($status === 'approved') {
                $subject = "Voucher Approved - " . $voucherNumber;
                $body = "
                    <html>
                    <head>
                        <style>
                            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                            .header { background: #22c55e; color: white; padding: 20px; border-radius: 8px 8px 0 0; }
                            .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
                            .voucher-number { font-size: 20px; font-weight: bold; color: #22c55e; margin: 15px 0; }
                            .footer { margin-top: 20px; padding-top: 20px; border-top: 1px solid #e5e7eb; font-size: 12px; color: #6b7280; }
                        </style>
                    </head>
                    <body>
                        <div class='container'>
                            <div class='header'>
                                <h2 style='margin: 0;'>✓ Voucher Approved</h2>
                            </div>
                            <div class='content'>
                                <p>Dear $userName,</p>
                                <p>Your voucher has been <strong>approved</strong> and posted to the general ledger.</p>
                                <div class='voucher-number'>Voucher: $voucherNumber</div>
                                <p>The voucher has been successfully processed and is now part of the financial records.</p>
                                <p>You can view the voucher details in your dashboard.</p>
                                <div class='footer'>
                                    <p>This is an automated notification from FinSight Accounting System.</p>
                                    <p>Please do not reply to this email.</p>
                                </div>
                            </div>
                        </div>
                    </body>
                    </html>
                ";
            } else if ($status === 'rejected') {
                $subject = "Voucher Rejected - " . $voucherNumber;
                $reasonText = $reason ? htmlspecialchars($reason) : 'No reason provided';
                $body = "
                    <html>
                    <head>
                        <style>
                            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                            .header { background: #ef4444; color: white; padding: 20px; border-radius: 8px 8px 0 0; }
                            .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
                            .voucher-number { font-size: 20px; font-weight: bold; color: #ef4444; margin: 15px 0; }
                            .reason-box { background: #fee2e2; border-left: 4px solid #ef4444; padding: 15px; margin: 20px 0; border-radius: 4px; }
                            .footer { margin-top: 20px; padding-top: 20px; border-top: 1px solid #e5e7eb; font-size: 12px; color: #6b7280; }
                        </style>
                    </head>
                    <body>
                        <div class='container'>
                            <div class='header'>
                                <h2 style='margin: 0;'>✗ Voucher Rejected</h2>
                            </div>
                            <div class='content'>
                                <p>Dear $userName,</p>
                                <p>Your voucher has been <strong>rejected</strong> by the approver.</p>
                                <div class='voucher-number'>Voucher: $voucherNumber</div>
                                <div class='reason-box'>
                                    <strong>Rejection Reason:</strong><br>
                                    $reasonText
                                </div>
                                <p>Please review the rejection reason and make necessary corrections before resubmitting.</p>
                                <p>You can edit and resubmit the voucher from your dashboard.</p>
                                <div class='footer'>
                                    <p>This is an automated notification from FinSight Accounting System.</p>
                                    <p>Please do not reply to this email.</p>
                                </div>
                            </div>
                        </div>
                    </body>
                    </html>
                ";
            } else {
                return false;
            }
            
            // Send email using SimpleSMTP
            require_once __DIR__ . '/../config/MailService.php';
            $mailer = new SimpleSMTP();
            $result = $mailer->send($userEmail, $subject, $body);
            
            if ($result) {
                error_log("Voucher email sent successfully to $userEmail for voucher $voucherNumber ($status)");
            } else {
                error_log("Failed to send voucher email to $userEmail for voucher $voucherNumber ($status)");
            }
            
            return $result;
            
        } catch (Exception $e) {
            error_log("Error sending voucher email: " . $e->getMessage());
            return false;
        }
    }

    // Update voucher (Accountant, owner, Draft only)
    public function updateVoucher() {
        checkRole(['accountant', 'admin', 'administrator']);

        $data = json_decode(file_get_contents('php://input'), true);
        $required = ['voucher_id', 'voucher_type_id', 'voucher_date', 'details'];
        foreach ($required as $field) {
            if (empty($data[$field]) && $data[$field] !== 0) {
                sendResponse(false, null, "Missing required field: $field", 400);
            }
        }

        $voucherId = intval($data['voucher_id']);
        $userId = $_SESSION['user_id'];

        // Verify voucher exists and user owns it and it is Draft
        $stmt = $this->db->prepare("SELECT created_by, status FROM vouchers WHERE id = ?");
        $stmt->bind_param("i", $voucherId);
        $stmt->execute();
        $result = $stmt->get_result();
        if ($result->num_rows === 0) {
            sendResponse(false, null, 'Voucher not found', 404);
        }
        $row = $result->fetch_assoc();
        $stmt->close();

        if ($row['created_by'] != $userId) {
            sendResponse(false, null, 'Forbidden: not owner', 403);
        }

        if ($row['status'] !== 'Draft') {
            sendResponse(false, null, 'Only Draft vouchers can be edited', 400);
        }

        // Begin transaction
        $conn = $this->db->getConnection();
        $conn->begin_transaction();

        try {
            // Update voucher header
            $stmt = $this->db->prepare("UPDATE vouchers SET voucher_type_id = ?, voucher_date = ?, narration = ? WHERE id = ?");
            $stmt->bind_param("issi", $data['voucher_type_id'], $data['voucher_date'], $data['narration'], $voucherId);
            $stmt->execute();
            $stmt->close();

            // Remove existing details
            $stmt = $this->db->prepare("DELETE FROM voucher_details WHERE voucher_id = ?");
            $stmt->bind_param("i", $voucherId);
            $stmt->execute();
            $stmt->close();

            // Insert new details and compute totals
            $totalDebit = 0;
            $totalCredit = 0;
            foreach ($data['details'] as $detail) {
                $stmt = $this->db->prepare("INSERT INTO voucher_details (voucher_id, account_id, debit, credit, description) VALUES (?, ?, ?, ?, ?)");
                $stmt->bind_param("iidds", $voucherId, $detail['account_id'], $detail['debit'], $detail['credit'], $detail['description']);
                $stmt->execute();
                $stmt->close();

                $totalDebit += $detail['debit'] ?? 0;
                $totalCredit += $detail['credit'] ?? 0;
            }

            // Update totals
            $stmt = $this->db->prepare("UPDATE vouchers SET total_debit = ?, total_credit = ? WHERE id = ?");
            $stmt->bind_param("ddi", $totalDebit, $totalCredit, $voucherId);
            $stmt->execute();
            $stmt->close();

            $conn->commit();

            logAudit($userId, 'VOUCHER_UPDATED', 'vouchers', $voucherId);
            sendResponse(true, null, 'Voucher updated successfully');
        } catch (Exception $e) {
            $conn->rollback();
            sendResponse(false, null, 'Failed to update voucher: ' . $e->getMessage(), 500);
        }
    }

    // Delete voucher (Accountant owner, Draft only)
    public function deleteVoucher() {
        checkRole(['accountant', 'admin', 'administrator']);

        $data = json_decode(file_get_contents('php://input'), true);
        $voucherId = intval($data['voucher_id'] ?? 0);
        if (!$voucherId) {
            sendResponse(false, null, 'Voucher ID is required', 400);
        }

        $userId = $_SESSION['user_id'];

        // Verify voucher exists and belongs to user and is Draft
        $stmt = $this->db->prepare("SELECT created_by, status FROM vouchers WHERE id = ?");
        $stmt->bind_param("i", $voucherId);
        $stmt->execute();
        $res = $stmt->get_result();
        if ($res->num_rows === 0) {
            sendResponse(false, null, 'Voucher not found', 404);
        }
        $row = $res->fetch_assoc();
        $stmt->close();

        if ($row['created_by'] != $userId) {
            sendResponse(false, null, 'Forbidden: not owner', 403);
        }

        if ($row['status'] !== 'Draft') {
            sendResponse(false, null, 'Only Draft vouchers can be deleted', 400);
        }

        $stmt = $this->db->prepare("DELETE FROM vouchers WHERE id = ?");
        $stmt->bind_param("i", $voucherId);
        if ($stmt->execute()) {
            logAudit($userId, 'VOUCHER_DELETED', 'vouchers', $voucherId);
            sendResponse(true, null, 'Voucher deleted successfully');
        } else {
            sendResponse(false, null, 'Failed to delete voucher', 500);
        }
        $stmt->close();
    }
    
    // Get voucher types
    public function getVoucherTypes() {
        checkAuth();
        $result = $this->db->query("SELECT * FROM voucher_types WHERE is_active = 1 ORDER BY id");
        $types = [];
        while ($row = $result->fetch_assoc()) {
            $types[] = $row;
        }
        sendResponse(true, $types, 'Voucher types retrieved');
    }

    private function updateGeneralLedger($voucherId) {
        $stmt = $this->db->prepare("SELECT account_id, debit, credit FROM voucher_details WHERE voucher_id = ?");
        $stmt->bind_param("i", $voucherId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $voucherDate = null;
        $voucherQuery = $this->db->query("SELECT voucher_date FROM vouchers WHERE id = $voucherId");
        $voucherRow = $voucherQuery->fetch_assoc();
        $voucherDate = $voucherRow['voucher_date'];
        
        // Prepare statements
        $glStmt = $this->db->prepare("INSERT INTO general_ledger (account_id, voucher_id, voucher_date, debit, credit, running_balance) VALUES (?, ?, ?, ?, ?, 0)");
        
        // Update account balance: Add Debit, Subtract Credit (Net Debit Approach)
        // Note: For Liabilities/Income, this will make the balance more negative (which is correct for Net Debit storage)
        $acStmt = $this->db->prepare("UPDATE account_chart SET balance = balance + ? - ? WHERE id = ?");
        
        while ($detail = $result->fetch_assoc()) {
            // Insert GL Entry
            $glStmt->bind_param("iisdd", $detail['account_id'], $voucherId, $voucherDate, $detail['debit'], $detail['credit']);
            $glStmt->execute();
            
            // Update Account Master Balance
            $acStmt->bind_param("ddi", $detail['debit'], $detail['credit'], $detail['account_id']);
            $acStmt->execute();
        }
        
        $glStmt->close();
        $acStmt->close();
        $stmt->close();
    }
}

// Route handling
$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? null;

$voucher = new VoucherController();

switch ($action) {
    case 'types':
        $voucher->getVoucherTypes();
        break;
    case 'list':
        $voucher->getVouchers();
        break;
    case 'get':
    case 'view':
        $voucher->getVoucher();
        break;
    case 'create':
        $voucher->createVoucher();
        break;
        case 'update':
            $voucher->updateVoucher();
            break;
        case 'delete':
            $voucher->deleteVoucher();
            break;
    case 'request_approval':
        $voucher->requestApproval();
        break;
    case 'post':
        $voucher->postVoucher();
        break;
    case 'reject':
        $voucher->rejectVoucher();
        break;
    default:
        sendResponse(false, null, 'Action not found', 404);
}
?>
