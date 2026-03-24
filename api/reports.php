<?php
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../config/AuthMiddleware.php';

class ReportController {
    private $db;
    
    public function __construct() {
        $this->db = new Database();
    }
    
    public function getBalanceSheet() {
        checkAuth();
        
        $asOnDate = $_GET['as_on_date'] ?? date('Y-m-d');
        
        $sql = "SELECT ac.id, ac.code, ac.name, ac.type, ac.sub_type, 
                       COALESCE(
                           CASE 
                               WHEN ac.type IN ('Liability', 'Equity', 'Income') 
                               THEN SUM(COALESCE(gl.credit, 0)) - SUM(COALESCE(gl.debit, 0))
                               ELSE SUM(COALESCE(gl.debit, 0)) - SUM(COALESCE(gl.credit, 0))
                           END, 0) as balance,
                       SUM(COALESCE(gl.debit, 0)) as total_debit,
                       SUM(COALESCE(gl.credit, 0)) as total_credit
                FROM account_chart ac
                LEFT JOIN general_ledger gl ON ac.id = gl.account_id AND DATE(gl.voucher_date) <= '$asOnDate'
                WHERE ac.is_active = TRUE
                GROUP BY ac.id, ac.code, ac.name, ac.type, ac.sub_type
                ORDER BY ac.type, ac.code";
        
        $result = $this->db->query($sql);
        $accounts = [];
        $totalIncome = 0;
        $totalExpense = 0;
        
        while ($row = $result->fetch_assoc()) {
            if ($row['type'] == 'Income') {
                $totalIncome += $row['balance'];
            } elseif ($row['type'] == 'Expense') {
                // For BS logic, Expense balance is Dr - Cr. If we want impact on Equity, we treat it as negative.
                $totalExpense += $row['balance'];
            }
            // Only add real BS accounts to the main list (Asset, Liability, Equity)
            if (in_array($row['type'], ['Asset', 'Liability', 'Equity'])) {
                $accounts[] = $row;
            }
        }
        
        // Calculate Net Profit up to this date
        // Profit = Income - Expense
        $netProfit = $totalIncome - $totalExpense;
        
        // Add Net Profit as a virtual Equity account
        $accounts[] = [
            'id' => 0,
            'code' => 'PROFIT',
            'name' => 'Net Profit (Period)',
            'type' => 'Equity',
            'sub_type' => 'Retained Earnings',
            'balance' => $netProfit,
            'total_debit' => $totalIncome,
            'total_credit' => $totalExpense
        ];
        
        sendResponse(true, $accounts, 'Balance sheet retrieved');
    }
    
    public function getProfitLoss() {
        checkAuth();
        
        $fromDate = $_GET['from_date'] ?? date('Y-01-01');
        $toDate = $_GET['to_date'] ?? date('Y-m-d');
        
        // Use CASE to return correct positive balance based on account type
        $sql = "SELECT ac.id, ac.code, ac.name, ac.type, ac.sub_type,
                       COALESCE(
                           CASE 
                               WHEN ac.type = 'Income' 
                               THEN SUM(COALESCE(gl.credit, 0)) - SUM(COALESCE(gl.debit, 0))
                               ELSE SUM(COALESCE(gl.debit, 0)) - SUM(COALESCE(gl.credit, 0))
                           END, 0) as amount,
                       SUM(COALESCE(gl.debit, 0)) as total_debit,
                       SUM(COALESCE(gl.credit, 0)) as total_credit
                FROM account_chart ac
                LEFT JOIN general_ledger gl ON ac.id = gl.account_id 
                          AND DATE(gl.voucher_date) >= '$fromDate' 
                          AND DATE(gl.voucher_date) <= '$toDate'
                WHERE ac.type IN ('Income', 'Expense') AND ac.is_active = TRUE
                GROUP BY ac.id, ac.code, ac.name, ac.type, ac.sub_type
                ORDER BY ac.type DESC, ac.code";
        
        $result = $this->db->query($sql);
        $accounts = [];
        
        while ($row = $result->fetch_assoc()) {
            $accounts[] = $row;
        }
        
        sendResponse(true, $accounts, 'P&L report retrieved');
    }
    
    public function getAnalyticsData() {
        // 1. Monthly Trends (Dynamic trailing 6 months based on actual latest data entry)
        $latestRes = $this->db->query("SELECT MAX(voucher_date) as latest FROM vouchers WHERE status != 'Rejected'")->fetch_assoc();
        $baseDate = ($latestRes && $latestRes['latest']) ? strtotime($latestRes['latest']) : time();
        
        $months = [];
        for ($i = 5; $i >= 0; $i--) {
            $months[] = date('Y-m', strtotime("-$i months", $baseDate));
        }

        $fromDate = $months[0] . "-01";
        $toDate = date('Y-m-t', $baseDate);
        
        // Optimized: Single query for all 6 months using conditional sums
        $sql = "SELECT 
                    DATE_FORMAT(v.voucher_date, '%Y-%m') as month_key,
                    SUM(CASE WHEN ac.type = 'Income' THEN vd.credit - vd.debit ELSE 0 END) as income_sum,
                    SUM(CASE WHEN ac.type = 'Expense' THEN vd.debit - vd.credit ELSE 0 END) as expense_sum
                FROM voucher_details vd
                JOIN vouchers v ON vd.voucher_id = v.id
                JOIN account_chart ac ON vd.account_id = ac.id
                WHERE v.status = 'Posted' 
                AND v.voucher_date >= ? AND v.voucher_date <= ?
                GROUP BY month_key";
        
        $stmt = $this->db->prepare($sql);
        // Use full date range
        $fullToDate = $toDate . " 23:59:59";
        $stmt->bind_param("ss", $fromDate, $fullToDate);
        $stmt->execute();
        $res = $stmt->get_result();
        
        $dataMap = [];
        if ($res) {
            while($row = $res->fetch_assoc()) {
                $dataMap[$row['month_key']] = $row;
            }
        }
        $stmt->close();
        
        $cashFlow = ['labels' => [], 'income' => [], 'expense' => []];
        foreach ($months as $m) {
            $income = $dataMap[$m]['income_sum'] ?? 0;
            $expense = $dataMap[$m]['expense_sum'] ?? 0;
            
            $cashFlow['labels'][] = date('M Y', strtotime($m . "-01"));
            $cashFlow['income'][] = (float)$income;
            $cashFlow['expense'][] = (float)$expense;
        }
        
        // 2. Account Type Distribution
        $sqlTypes = "SELECT ac.type, COUNT(*) as count FROM account_chart ac WHERE ac.is_active = 1 GROUP BY ac.type";
        $typeRes = $this->db->query($sqlTypes);
        $accountTypes = ['labels' => [], 'data' => []];
        if ($typeRes) {
            while($row = $typeRes->fetch_assoc()) {
                $accountTypes['labels'][] = $row['type'];
                $accountTypes['data'][] = (int)$row['count'];
            }
        }
 
        // 3. Top 5 Expenses (Year to Date based on latest entry year)
        $currentYear = date('Y', $baseDate);
        $sqlTopExp = "SELECT ac.name, SUM(vd.debit - vd.credit) as total
                      FROM voucher_details vd
                      JOIN vouchers v ON vd.voucher_id = v.id
                      JOIN account_chart ac ON vd.account_id = ac.id
                      WHERE ac.type = 'Expense' AND v.status = 'Posted' AND YEAR(v.voucher_date) = $currentYear
                      GROUP BY ac.id
                      HAVING total > 0
                      ORDER BY total DESC LIMIT 5";
        $topExpRes = $this->db->query($sqlTopExp);
        $topExpenses = ['labels' => [], 'data' => []];
        if ($topExpRes) {
            while($row = $topExpRes->fetch_assoc()) {
                $topExpenses['labels'][] = $row['name'];
                $topExpenses['data'][] = (float)$row['total'];
            }
        }
 
        sendResponse(true, [
            'cash_flow' => $cashFlow,
            'account_types' => $accountTypes,
            'top_expenses' => $topExpenses
        ], 'Analytics data retrieved (Dynamic Timeline)');
    }

    public function getTrialBalance() {
        checkAuth();
        
        $asOnDate = $_GET['as_on_date'] ?? date('Y-m-d');
        
        $sql = "SELECT ac.id, ac.code, ac.name,
                       COALESCE(SUM(gl.debit), 0) as total_debit,
                       COALESCE(SUM(gl.credit), 0) as total_credit
                FROM account_chart ac
                LEFT JOIN general_ledger gl ON ac.id = gl.account_id AND DATE(gl.voucher_date) <= '$asOnDate'
                WHERE ac.is_active = TRUE
                GROUP BY ac.id, ac.code, ac.name
                HAVING SUM(gl.debit) != 0 OR SUM(gl.credit) != 0
                ORDER BY ac.code";
        
        $result = $this->db->query($sql);
        $accounts = [];
        $totalDebit = 0;
        $totalCredit = 0;
        
        while ($row = $result->fetch_assoc()) {
            $accounts[] = $row;
            $totalDebit += $row['total_debit'];
            $totalCredit += $row['total_credit'];
        }
        
        $accounts[] = [
            'name' => 'TOTAL',
            'total_debit' => $totalDebit,
            'total_credit' => $totalCredit
        ];
        
        sendResponse(true, $accounts, 'Trial balance retrieved');
    }
    
    public function getCashFlow() {
        checkAuth();
        
        $fromDate = $_GET['from_date'] ?? date('Y-01-01');
        $toDate = $_GET['to_date'] ?? date('Y-m-d');
        
        // Get cash accounts
        $sql = "SELECT ac.id, ac.code, ac.name,
                       COALESCE(SUM(gl.debit) - SUM(gl.credit), 0) as net_flow
                FROM account_chart ac
                LEFT JOIN general_ledger gl ON ac.id = gl.account_id
                          AND DATE(gl.voucher_date) >= '$fromDate'
                          AND DATE(gl.voucher_date) <= '$toDate'
                WHERE ac.type = 'Asset' AND ac.name LIKE '%Cash%'
                GROUP BY ac.id, ac.code, ac.name
                ORDER BY ac.code";
        
        $result = $this->db->query($sql);
        $cashAccounts = [];
        
        while ($row = $result->fetch_assoc()) {
            $cashAccounts[] = $row;
        }
        
        sendResponse(true, $cashAccounts, 'Cash flow retrieved');
    }
    
    public function getAccountLedger() {
        checkAuth();
        
        $accountId = $_GET['account_id'] ?? null;
        $fromDate = $_GET['from'] ?? date('Y-m-01');
        $toDate = $_GET['to'] ?? date('Y-m-d');
        
        if (!$accountId) {
            sendResponse(false, null, 'Account ID is required', 400);
        }
        
        // 1. Get Initial Opening Balance & Type
        $stmt = $this->db->prepare("SELECT opening_balance, type, name, code FROM account_chart WHERE id = ?");
        $stmt->bind_param("i", $accountId);
        $stmt->execute();
        $accResult = $stmt->get_result();
        if ($accResult->num_rows === 0) sendResponse(false, null, 'Account not found', 404);
        $accRow = $accResult->fetch_assoc();
        $initialOB = (float)$accRow['opening_balance'];
        
        // Determine effective initial balance (Net Debit terms)
        // Assets/Expenses: Positive
        // Liabilities/Equity/Income: Negative (if stored as positive absolute value)
        $effectiveInitialOB = $initialOB;
        if (in_array($accRow['type'], ['Liability', 'Equity', 'Income'])) {
             // Assuming opening balance is stored as positive absolute value in DB
             // We convert to negative for Dr-Cr calculation
             $effectiveInitialOB = -$initialOB; 
        } else {
             // For Assets (like Bank) if it's overdrawn, it might be stored as negative?
             // Let's assume standard storage: signed balance is best, but if OB is absolute, we infer sign from Type.
             // If the user manually set a negative opening balance for an asset, respect it.
             $effectiveInitialOB = $initialOB;
        }

        // 2. Calculate movements (Only Posted Vouchers)
        // Note: Switched to 'Posted' status for "proper" financial reporting.
        
        $sqlPrev = "SELECT COALESCE(SUM(vd.debit), 0) as tot_debit, COALESCE(SUM(vd.credit), 0) as tot_credit 
                    FROM voucher_details vd
                    JOIN vouchers v ON vd.voucher_id = v.id
                    WHERE vd.account_id = $accountId 
                    AND v.voucher_date < '$fromDate'
                    AND v.status = 'Posted'";
                    
        $prevRes = $this->db->query($sqlPrev)->fetch_assoc();
        
        $prevMovement = ($prevRes['tot_debit'] - $prevRes['tot_credit']);
        $openingBalanceAsOfDate = $effectiveInitialOB + $prevMovement;
        
        // 3. Fetch Transactions (Only Posted)
        $sql = "SELECT vd.id, v.voucher_date, v.voucher_number, v.narration, v.status, vd.debit, vd.credit, vd.description
                FROM voucher_details vd
                JOIN vouchers v ON vd.voucher_id = v.id
                WHERE vd.account_id = $accountId 
                AND v.voucher_date BETWEEN '$fromDate' AND '$toDate'
                AND v.status = 'Posted'
                ORDER BY v.voucher_date ASC, v.id ASC";
        
        $result = $this->db->query($sql);
        $transactions = [];
        
        $runningBalance = $openingBalanceAsOfDate;
        $periodDebit = 0;
        $periodCredit = 0;
        
        while ($row = $result->fetch_assoc()) {
            $dr = (float)$row['debit'];
            $cr = (float)$row['credit'];
            
            $runningBalance += ($dr - $cr);
            $periodDebit += $dr;
            $periodCredit += $cr;
            
            $row['running_balance'] = $runningBalance;
            $transactions[] = $row;
        }
        
        sendResponse(true, [
            'account' => $accRow,
            'opening_balance' => $openingBalanceAsOfDate,
            'period_debit' => $periodDebit,
            'period_credit' => $periodCredit,
            'closing_balance' => $runningBalance,
            'transactions' => $transactions,
            'period' => ['from' => $fromDate, 'to' => $toDate]
        ], 'Account ledger retrieved (including provisional)');
    }
    
    public function getFinancialSummary() {
        checkAuth();
        $asOnDate = $_GET['as_on_date'] ?? date('Y-m-d');
        
        // Single optimized query for all primary types
        $sql = "SELECT ac.type, 
                       SUM(CASE WHEN ac.type IN ('Liability', 'Equity', 'Income') THEN gl.credit - gl.debit ELSE gl.debit - gl.credit END) as net_balance
                FROM general_ledger gl
                JOIN account_chart ac ON gl.account_id = ac.id
                WHERE DATE(gl.voucher_date) <= ?
                GROUP BY ac.type";
        
        $stmt = $this->db->prepare($sql);
        $stmt->bind_param("s", $asOnDate);
        $stmt->execute();
        $res = $stmt->get_result();
        
        $typeMap = [];
        if ($res) {
            while($row = $res->fetch_assoc()) {
                $typeMap[$row['type']] = (float)$row['net_balance'];
            }
        }
        $stmt->close();
        
        $summary = [
            'assets' => $typeMap['Asset'] ?? 0,
            'liabilities' => $typeMap['Liability'] ?? 0,
            'equity' => $typeMap['Equity'] ?? 0,
            'total_income' => $typeMap['Income'] ?? 0,
            'total_expense' => $typeMap['Expense'] ?? 0
        ];

        $summary['net_profit'] = $summary['total_income'] - $summary['total_expense'];
        
        // Ratios
        $summary['profit_margin'] = $summary['total_income'] > 0 ? ($summary['net_profit'] / $summary['total_income']) * 100 : 0;
        $summary['current_ratio'] = $summary['liabilities'] > 0 ? ($summary['assets'] / $summary['liabilities']) : 0;

        sendResponse(true, $summary, 'Financial summary and health ratios retrieved');
    }

    public function getTransactionHistory() {
        checkAuth();
        
        $sql = "SELECT 
                    DATE_FORMAT(voucher_date, '%b %Y') as month,
                    SUM(total_debit) as debit,
                    SUM(total_credit) as credit
                FROM vouchers
                WHERE status = 'Posted'
                GROUP BY month
                ORDER BY MIN(voucher_date) ASC
                LIMIT 12";
        
        $result = $this->db->query($sql);
        $history = [];
        
        while ($row = $result->fetch_assoc()) {
            $history[] = $row;
        }
        
        sendResponse(true, $history, 'Transaction history retrieved');
    }

    public function getPerformanceReport() {
        checkAuth();
        $fromDate = $_GET['from'] ?? date('Y-m-01');
        $toDate = $_GET['to'] ?? date('Y-m-d');
        
        // Combined query for performance
        $sql = "SELECT ac.type, 
                       SUM(CASE WHEN ac.type = 'Income' THEN vd.credit - vd.debit ELSE vd.debit - vd.credit END) as amount
                FROM voucher_details vd
                JOIN vouchers v ON vd.voucher_id = v.id
                JOIN account_chart ac ON vd.account_id = ac.id
                WHERE ac.type IN ('Income', 'Expense') AND v.status = 'Posted'
                AND v.voucher_date BETWEEN ? AND ?
                GROUP BY ac.type";
        
        $stmt = $this->db->prepare($sql);
        $fullToDate = $toDate . " 23:59:59";
        $stmt->bind_param("ss", $fromDate, $fullToDate);
        $stmt->execute();
        $res = $stmt->get_result();
        
        $perf = ['Income' => 0, 'Expense' => 0];
        if ($res) {
            while($row = $res->fetch_assoc()) {
                $perf[$row['type']] = (float)$row['amount'];
            }
        }
        $stmt->close();
        
        sendResponse(true, [
            'total_income' => $perf['Income'],
            'total_expense' => $perf['Expense'],
            'period' => ['from' => $fromDate, 'to' => $toDate]
        ], 'Performance report retrieved (Optimized)');
    }

    public function getAuditLogs() {
        checkRole(['admin', 'administrator']);
        
        $sql = "SELECT a.id, a.action, a.entity_type, a.entity_id, a.created_at, 
                       u.first_name, u.last_name, u.role, v.voucher_number
                FROM audit_trail a
                LEFT JOIN users u ON a.user_id = u.id
                LEFT JOIN vouchers v ON a.entity_id = v.id AND a.entity_type = 'vouchers'
                ORDER BY a.created_at DESC LIMIT 200";
                
        $result = $this->db->query($sql);
        $logs = [];
        while ($row = $result->fetch_assoc()) {
            $logs[] = $row;
        }
        
        sendResponse(true, $logs, 'Audit logs retrieved successfully');
    }
}

// Route handling
$type = $_GET['type'] ?? null;
$report = new ReportController();

switch ($type) {
    case 'balance-sheet':
        $report->getBalanceSheet();
        break;
    case 'profit-loss':
        $report->getProfitLoss();
        break;
    case 'trial-balance':
        $report->getTrialBalance();
        break;
    case 'cash-flow':
        $report->getCashFlow();
        break;
    case 'ledger':
        $report->getAccountLedger();
        break;
    case 'summary':
        $report->getFinancialSummary();
        break;
    case 'transaction-history':
        $report->getTransactionHistory();
        break;
    case 'analytics':
        $report->getAnalyticsData();
        break;
    case 'performance':
        $report->getPerformanceReport();
        break;
    case 'audit-logs':
        $report->getAuditLogs();
        break;
    default:
        sendResponse(false, null, 'Report type not found', 404);
}
?>
