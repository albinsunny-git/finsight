<?php
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../config/AuthMiddleware.php';

class InsightsController {
    private $db;
    
    public function __construct() {
        $this->db = new Database();
    }
    
    public function getMonthlyInsights() {
        checkAuth();
        
        $month = $_GET['month'] ?? date('m');
        $year = $_GET['year'] ?? date('Y');
        
        // Calculate Previous Month/Year
        $prevMonth = $month - 1;
        $prevYear = $year;
        if ($prevMonth == 0) {
            $prevMonth = 12;
            $prevYear = $year - 1;
        }
        
        // Helper to get totals for a specific month
        $getTotals = function($m, $y) {
            $sql = "SELECT ac.type, COALESCE(SUM(gl.credit - gl.debit), 0) as credit_sum, COALESCE(SUM(gl.debit - gl.credit), 0) as debit_sum
                    FROM general_ledger gl
                    JOIN account_chart ac ON gl.account_id = ac.id
                    WHERE MONTH(gl.voucher_date) = $m AND YEAR(gl.voucher_date) = $y
                    AND ac.type IN ('Income', 'Expense')
                    GROUP BY ac.type";
            
            $result = $this->db->query($sql);
            $totals = ['Income' => 0, 'Expense' => 0];
            
            while ($row = $result->fetch_assoc()) {
                if ($row['type'] == 'Expense') {
                    $totals['Expense'] = (float)$row['debit_sum'];
                } elseif ($row['type'] == 'Income') {
                    $totals['Income'] = (float)$row['credit_sum'];
                }
            }
            return $totals;
        };
        
        $current = $getTotals($month, $year);
        $previous = $getTotals($prevMonth, $prevYear);
        
        $currentProfit = $current['Income'] - $current['Expense'];
        $prevProfit = $previous['Income'] - $previous['Expense'];
        
        // Generate Insights Text
        $insights = [];
        
        // 1. Profit Explanation
        if ($currentProfit > $prevProfit) {
            $diff = $currentProfit - $prevProfit;
            $text = "Profit is higher this month by " . number_format($diff) . ".";
            if ($current['Income'] > $previous['Income']) {
                $text .= " This is mainly due to an increase in sales/income.";
            } elseif ($current['Expense'] < $previous['Expense']) {
                $text .= " You managed to reduce expenses compared to last month.";
            }
            $insights[] = $text;
        } else {
            $diff = $prevProfit - $currentProfit;
            $text = "Profit is lower this month by " . number_format($diff) . ".";
            if ($current['Expense'] > $previous['Expense']) {
                $text .= " Expenses have increased significantly.";
            } elseif ($current['Income'] < $previous['Income']) {
                $text .= " Sales/Income has reduced compared to last month.";
            }
            $insights[] = $text;
        }
        
        // 2. Top Expense
        $sqlTop = "SELECT ac.name, SUM(gl.debit - gl.credit) as total
                   FROM general_ledger gl
                   JOIN account_chart ac ON gl.account_id = ac.id
                   WHERE ac.type = 'Expense' 
                   AND MONTH(gl.voucher_date) = $month AND YEAR(gl.voucher_date) = $year
                   GROUP BY ac.id
                   ORDER BY total DESC LIMIT 1";
        $topRes = $this->db->query($sqlTop);
        if ($topRes->num_rows > 0) {
            $top = $topRes->fetch_assoc();
            $insights[] = "Your highest expense is " . $top['name'] . " (" . number_format($top['total']) . ").";
        }
        
        // 3. Cash Flow Warning (Simple check if cash is low)
        $sqlCash = "SELECT SUM(gl.debit - gl.credit) as balance 
                    FROM general_ledger gl
                    JOIN account_chart ac ON gl.account_id = ac.id
                    WHERE ac.type = 'Asset' AND (ac.name LIKE '%Cash%' OR ac.name LIKE '%Bank%')";
        $cashRes = $this->db->query($sqlCash)->fetch_assoc();
        $cashBalance = $cashRes['balance'] ?? 0;
        
        $burnRate = $current['Expense']; 
        $runway = 100;
        if ($burnRate > 0) {
            $runway = $cashBalance / $burnRate;
            if ($runway < 1) {
                $insights[] = "⚠️ Warning: Cash balance is very low. Less than 1 month of expenses covered.";
            }
        }
        
        // 4. Calculate Business Health Score based on overall Accounts (Assets vs Liabilities)
        $sqlAccounts = "SELECT ac.type, COALESCE(SUM(gl.debit - gl.credit), 0) as debit_sum, COALESCE(SUM(gl.credit - gl.debit), 0) as credit_sum
                        FROM general_ledger gl
                        JOIN account_chart ac ON gl.account_id = ac.id
                        WHERE ac.type IN ('Asset', 'Liability')
                        GROUP BY ac.type";
        $accRes = $this->db->query($sqlAccounts);
        
        $totalAssets = 0;
        $totalLiabilities = 0;
        while ($row = $accRes->fetch_assoc()) {
            if ($row['type'] == 'Asset') {
                $totalAssets = (float)$row['debit_sum'];
            } elseif ($row['type'] == 'Liability') {
                $totalLiabilities = (float)$row['credit_sum'];
            }
        }

        $healthScore = 'Average';
        $healthReason = 'Stable performance.';
        
        $assetRatio = 1.0;
        if ($totalLiabilities > 0) {
            $assetRatio = $totalAssets / $totalLiabilities;
        } elseif ($totalAssets > 0) {
            $assetRatio = 2.0; // Infinite ratio, very healthy
        }

        if ($currentProfit > 0 && $assetRatio >= 1.5) {
            $healthScore = 'Good';
            $healthReason = 'Profitable with a strong asset-to-liability ratio.';
        } elseif ($currentProfit < 0 && $assetRatio < 1.0) {
            $healthScore = 'Poor';
            $healthReason = 'Loss-making and liabilities exceed assets.';
        } elseif ($currentProfit > 0 && $assetRatio < 1.0) {
            $healthScore = 'Average';
            $healthReason = 'Profitable, but high liabilities compared to assets.';
        } elseif ($currentProfit <= 0 && $assetRatio >= 1.5) {
             $healthScore = 'Average';
             $healthReason = 'Loss-making, but backed by strong asset reserves.';
        } elseif ($assetRatio < 1.0) {
             $healthScore = 'Poor';
             $healthReason = 'Critical: Liabilities currently exceed total assets.';
        }

        sendResponse(true, [
            'text_insights' => $insights,
            'health_score' => $healthScore,
            'health_reason' => $healthReason,
            'data' => [
                'current_profit' => $currentProfit,
                'prev_profit' => $prevProfit,
                'top_expense' => $topRes->num_rows > 0 ? $top : null
            ]
        ], 'Insights generated');
    }
}

$controller = new InsightsController();
$action = $_GET['action'] ?? 'monthly';

if ($action == 'monthly') {
    $controller->getMonthlyInsights();
}
?>
