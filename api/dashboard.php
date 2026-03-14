<?php
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../config/AuthMiddleware.php';

// Enable Gzip compression if possible
if (!in_array('ob_gzhandler', ob_list_handlers()) && php_sapi_name() !== 'cli') {
    ob_start("ob_gzhandler");
}

class DashboardController {
    private $db;
    private $cacheFile = __DIR__ . '/../cache/dashboard_data.json';
    private $cacheTTL = 30; // 30 seconds

    public function __construct() {
        $this->db = new Database();
        
        // Ensure cache directory exists
        if (!file_exists(__DIR__ . '/../cache')) {
            mkdir(__DIR__ . '/../cache', 0777, true);
        }
    }

    public function getDashboardSummary() {
        checkAuth();
        $userId = $_SESSION['user_id'];
        $role = $_SESSION['role'];

        // Try to serve from cache first
        if (file_exists($this->cacheFile) && (time() - filemtime($this->cacheFile) < $this->cacheTTL)) {
            $cacheData = json_decode(file_get_contents($this->cacheFile), true);
            // Check if user has unread notifications separately as it changes frequently
            $cacheData['unread_notifications'] = $this->getUnreadNotificationsCount($userId);
            sendResponse(true, $cacheData, 'Dashboard data retrieved (cached)');
        }

        try {
            $data = [];

            // 1. User Count
            $userResult = $this->db->query("SELECT COUNT(id) as count FROM users WHERE is_active = 1");
            $data['user_count'] = $userResult->fetch_assoc()['count'] ?? 0;

            // 2. Account Stats
            $accResult = $this->db->query("SELECT type, SUM(balance) as total FROM account_chart GROUP BY type");
            $accounts = [];
            while ($row = $accResult->fetch_assoc()) {
                $accounts[$row['type']] = floatval($row['total']);
            }
            $data['account_stats'] = $accounts;

            // 3. Recent Vouchers (Limit columns, avoid SELECT *)
            $vouchResult = $this->db->query("SELECT v.id, v.voucher_number, v.voucher_date, v.total_debit, v.status, vt.name as voucher_type_name, u.first_name 
                                            FROM vouchers v 
                                            JOIN voucher_types vt ON v.voucher_type_id = vt.id 
                                            LEFT JOIN users u ON v.created_by = u.id 
                                            ORDER BY v.created_at DESC LIMIT 5");
            $vouchers = [];
            while ($row = $vouchResult->fetch_assoc()) {
                $vouchers[] = $row;
            }
            $data['recent_vouchers'] = $vouchers;

            // 4. Financial Status (Profit & Loss summary)
            // Income usually has negative balance in net-debit, Expenses positive
            $data['revenue'] = abs($accounts['Income'] ?? 0);
            $data['expenses'] = abs($accounts['Expense'] ?? 0);
            $data['profit'] = $data['revenue'] - $data['expenses'];

            // Save to cache
            file_put_contents($this->cacheFile, json_encode($data));

            // 5. Add non-cacheable items
            $data['unread_notifications'] = $this->getUnreadNotificationsCount($userId);

            sendResponse(true, $data, 'Dashboard data retrieved fresh');

        } catch (Exception $e) {
            sendResponse(false, null, 'Error loading dashboard: ' . $e->getMessage(), 500);
        }
    }

    private function getUnreadNotificationsCount($userId) {
        $stmt = $this->db->prepare("SELECT COUNT(id) as count FROM notifications WHERE user_id = ? AND is_read = 0");
        $stmt->bind_param("i", $userId);
        $stmt->execute();
        $count = $stmt->get_result()->fetch_assoc()['count'] ?? 0;
        $stmt->close();
        return $count;
    }
}

$controller = new DashboardController();
$controller->getDashboardSummary();
