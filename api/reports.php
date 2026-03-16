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
        // 1. Monthly Cash Flow (Last 6 Months)
        $months = [];
        for ($i = 5; $i >= 0; $i--) {
            $months[] = date('Y-m', strtotime("-$i months"));
        }
        
        $cashFlow = ['labels' => [], 'income' => [], 'expense' => []];
        
        foreach ($months as $m) {
            $parts = explode('-', $m);
            $year = $parts[0];
            $month = $parts[1];
            
            // Income (Type = Income) - Include all non-rejected vouchers
            $sqlInc = "SELECT COALESCE(ABS(SUM(vd.credit - vd.debit)), 0) as total FROM voucher_details vd
                       JOIN vouchers v ON vd.voucher_id = v.id
                       JOIN account_chart ac ON vd.account_id = ac.id
                       WHERE ac.type = 'Income' AND v.status != 'Rejected'
                       AND YEAR(v.voucher_date) = $year AND MONTH(v.voucher_date) = $month";
            $incRes = $this->db->query($sqlInc)->fetch_assoc();
            
            // Expense (Type = Expense) - Include all non-rejected vouchers
            $sqlExp = "SELECT COALESCE(SUM(vd.debit - vd.credit), 0) as total FROM voucher_details vd
                       JOIN vouchers v ON vd.voucher_id = v.id
                       JOIN account_chart ac ON vd.account_id = ac.id
                       WHERE ac.type = 'Expense' AND v.status != 'Rejected'
                       AND YEAR(v.voucher_date) = $year AND MONTH(v.voucher_date) = $month";
            $expRes = $this->db->query($sqlExp)->fetch_assoc();
            
            $cashFlow['labels'][] = date('M Y', strtotime("$year-$month-01"));
            $cashFlow['income'][] = (float)$incRes['total'];
            $cashFlow['expense'][] = (float)$expRes['total'];
        }
        
        // 2. Account Type Distribution
        $sqlTypes = "SELECT ac.type, COUNT(*) as count FROM account_chart ac WHERE ac.is_active = 1 GROUP BY ac.type";
        $typeRes = $this->db->query($sqlTypes);
        $accountTypes = ['labels' => [], 'data' => []];
        while($row = $typeRes->fetch_assoc()) {
            $accountTypes['labels'][] = $row['type'];
            $accountTypes['data'][] = (int)$row['count'];
        }
 
        // 3. Top 5 Expenses (Year to Date)
        $currentYear = date('Y');
        $sqlTopExp = "SELECT ac.name, SUM(vd.debit - vd.credit) as total
                      FROM voucher_details vd
                      JOIN vouchers v ON vd.voucher_id = v.id
                      JOIN account_chart ac ON vd.account_id = ac.id
                      WHERE ac.type = 'Expense' AND v.status != 'Rejected' AND YEAR(v.voucher_date) = $currentYear
                      GROUP BY ac.id
                      HAVING total > 0
                      ORDER BY total DESC LIMIT 5";
        $topExpRes = $this->db->query($sqlTopExp);
        $topExpenses = ['labels' => [], 'data' => []];
        while($row = $topExpRes->fetch_assoc()) {
            $topExpenses['labels'][] = $row['name'];
            $topExpenses['data'][] = (float)$row['total'];
        }
 
        sendResponse(true, [
            'cash_flow' => $cashFlow,
            'account_types' => $accountTypes,
            'top_expenses' => $topExpenses
        ], 'Analytics data retrieved (Provisional)');
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

        // 2. Calculate movements (All Vouchers: Posted + Draft + Pending)
        // Note: User requested "based on vouchers entered", implying inclusion of unposted/draft vouchers.
        
        $sqlPrev = "SELECT COALESCE(SUM(vd.debit), 0) as tot_debit, COALESCE(SUM(vd.credit), 0) as tot_credit 
                    FROM voucher_details vd
                    JOIN vouchers v ON vd.voucher_id = v.id
                    WHERE vd.account_id = $accountId 
                    AND v.voucher_date < '$fromDate'
                    AND v.status != 'Rejected'"; // Exclude Rejected, include Draft/Posted/Pending
                    
        $prevRes = $this->db->query($sqlPrev)->fetch_assoc();
        
        $prevMovement = ($prevRes['tot_debit'] - $prevRes['tot_credit']);
        $openingBalanceAsOfDate = $effectiveInitialOB + $prevMovement;
        
        // 3. Fetch Transactions (All statuses except Rejected)
        $sql = "SELECT vd.id, v.voucher_date, v.voucher_number, v.narration, v.status, vd.debit, vd.credit, vd.description
                FROM voucher_details vd
                JOIN vouchers v ON vd.voucher_id = v.id
                WHERE vd.account_id = $accountId 
                AND v.voucher_date BETWEEN '$fromDate' AND '$toDate'
                AND v.status != 'Rejected'
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
        
        $summary = [];
        
        // Assets
        $result = $this->db->query("SELECT COALESCE(SUM(debit) - SUM(credit), 0) as total 
                                   FROM general_ledger gl
                                   JOIN account_chart ac ON gl.account_id = ac.id
                                   WHERE ac.type = 'Asset' AND DATE(gl.voucher_date) <= '$asOnDate'");
        $summary['assets'] = $result->fetch_assoc()['total'];
        
        // Liabilities
        $result = $this->db->query("SELECT COALESCE(SUM(credit) - SUM(debit), 0) as total 
                                   FROM general_ledger gl
                                   JOIN account_chart ac ON gl.account_id = ac.id
                                   WHERE ac.type = 'Liability' AND DATE(gl.voucher_date) <= '$asOnDate'");
        $summary['liabilities'] = $result->fetch_assoc()['total'];
        
        // Equity
        $result = $this->db->query("SELECT COALESCE(SUM(credit) - SUM(debit), 0) as total 
                                   FROM general_ledger gl
                                   JOIN account_chart ac ON gl.account_id = ac.id
                                   WHERE ac.type = 'Equity' AND DATE(gl.voucher_date) <= '$asOnDate'");
        $summary['equity'] = $result->fetch_assoc()['total'];
        
        // Income (Year to Date)
        $result = $this->db->query("SELECT COALESCE(SUM(credit) - SUM(debit), 0) as total FROM general_ledger gl JOIN account_chart ac ON gl.account_id = ac.id WHERE ac.type = 'Income'");
        $summary['total_income'] = (float)$result->fetch_assoc()['total'];

        // Expense (Year to Date)
        $result = $this->db->query("SELECT COALESCE(SUM(debit) - SUM(credit), 0) as total FROM general_ledger gl JOIN account_chart ac ON gl.account_id = ac.id WHERE ac.type = 'Expense'");
        $summary['total_expense'] = (float)$result->fetch_assoc()['total'];

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
        
        // Get Total Income
        $sqlInc = "SELECT COALESCE(SUM(vd.credit - vd.debit), 0) as total 
                   FROM voucher_details vd
                   JOIN vouchers v ON vd.voucher_id = v.id
                   JOIN account_chart ac ON vd.account_id = ac.id
                   WHERE ac.type = 'Income' AND v.status = 'Posted'
                   AND v.voucher_date BETWEEN '$fromDate' AND '$toDate'";
        $incRes = $this->db->query($sqlInc)->fetch_assoc();
        
        // Get Total Expense
        $sqlExp = "SELECT COALESCE(SUM(vd.debit - vd.credit), 0) as total 
                   FROM voucher_details vd
                   JOIN vouchers v ON vd.voucher_id = v.id
                   JOIN account_chart ac ON vd.account_id = ac.id
                   WHERE ac.type = 'Expense' AND v.status = 'Posted'
                   AND v.voucher_date BETWEEN '$fromDate' AND '$toDate'";
        $expRes = $this->db->query($sqlExp)->fetch_assoc();
        
        sendResponse(true, [
            'total_income' => (float)$incRes['total'],
            'total_expense' => (float)$expRes['total'],
            'period' => ['from' => $fromDate, 'to' => $toDate]
        ], 'Performance report retrieved');
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
    default:
        sendResponse(false, null, 'Report type not found', 404);
}
?>
