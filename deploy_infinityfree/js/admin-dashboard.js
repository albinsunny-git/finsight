// Use API_URL from dashboard.js or define it if missing
const API_URL = typeof DB_API_URL !== 'undefined' ? DB_API_URL : 'http://localhost/finsight/backend/api';

// Helper: Fetch with Timeout (Polyfill if missing)
if (typeof fetchWithTimeout === 'undefined') {
    window.fetchWithTimeout = async function (resource, options = {}) {
        const { timeout = 8000 } = options;
        const controller = new AbortController();
        const id = setTimeout(() => controller.abort(), timeout);

        try {
            const response = await fetch(resource, {
                ...options,
                signal: controller.signal
            });
            clearTimeout(id);
            return response;
        } catch (error) {
            clearTimeout(id);
            throw error;
        }
    };
}

// Global abort controller for notification fetches
let _notificationAbortController = null;

// Admin-specific initialization
async function initAdminDashboard() {
    const user = localStorage.getItem('user');

    if (!user) {
        window.location.href = '../index.html';
        return;
    }

    const currentUser = JSON.parse(user);

    if (currentUser.role !== 'admin' && currentUser.role !== 'manager' && currentUser.role !== 'accountant') {
        alert('Access denied. Generalized dashboard access required.');
        window.location.href = '../index.html';
        return;
    }

    const nameEl = document.getElementById('userName') || document.getElementById('user-name') || document.getElementById('sidebarUserName');
    if (nameEl) nameEl.textContent = `${currentUser.first_name} ${currentUser.last_name}`;

    const roleEl = document.getElementById('userRole') || document.getElementById('user-role') || document.getElementById('sidebarUserRole');
    if (roleEl) roleEl.textContent = currentUser.role.charAt(0).toUpperCase() + currentUser.role.slice(1);

    const avatarEl = document.getElementById('userAvatar') || document.getElementById('user-avatar') || document.getElementById('sidebarUserAvatar');
    if (avatarEl) avatarEl.textContent = (currentUser.first_name || 'U').charAt(0).toUpperCase();

    // Separate Sidebar Avatar/Name updates if IDs differ (handled above via ORs usually, but just in case)

    // Render Role-Based Sidebar
    renderSidebar(currentUser.role);

    // Initialize Mock Data if empty (for Demo Speed)
    initMockDataIfEmpty();

    // Load initial data (dont block UI if slow)
    if (currentUser.role === 'admin') {
        loadAdminStats();
        loadFinancialInsights();
    }
    if (currentUser.role === 'accountant') {
        loadAccountantStats();
        loadFinancialInsights(); // Also useful for them
    }
}

async function loadUsers() {
    const tbody = document.getElementById('usersTableBody');
    if (!tbody) return;

    try {
        const response = await fetchWithTimeout(`${API_URL}/users.php?action=list`, { credentials: 'include' });
        const data = await response.json();

        if (data.success) {
            if (data.data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7" class="text-center">No users found</td></tr>';
                return;
            }

            tbody.innerHTML = data.data.map(user => `
                <tr>
                    <td>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <div class="avatar-circle" style="width:32px;height:32px;background:var(--primary-color);color:white;display:flex;align-items:center;justify-content:center;border-radius:50%;font-size:14px;">${user.first_name.charAt(0).toUpperCase()}</div>
                            <div>
                                <div style="font-weight: 600;">${user.first_name} ${user.last_name}</div>
                                <div style="font-size: 12px; color: var(--text-muted);">@${user.username}</div>
                            </div>
                        </div>
                    </td>
                    <td>${user.email}</td>
                    <td style="text-transform: capitalize;">${user.role}</td>
                    <td>${user.department || '-'}</td>
                    <td>
                        <span class="badge ${user.is_active == 1 ? 'badge-success' : 'badge-danger'}" style="padding:4px 8px;border-radius:12px;font-size:12px;background:${user.is_active == 1 ? '#dcfce7' : '#fee2e2'};color:${user.is_active == 1 ? '#166534' : '#991b1b'}">
                            ${user.is_active == 1 ? 'Active' : 'Inactive'}
                        </span>
                    </td>
                    <td>${user.last_login ? new Date(user.last_login).toLocaleDateString() : 'Never'}</td>
                    <td>
                        <div class="action-buttons" style="display:flex;gap:8px;">
                             <button class="btn-icon" onclick="editUser(${user.id})" title="Edit" style="border:none;background:none;cursor:pointer;color:var(--text-muted);"><i class="fas fa-edit"></i></button>
                             <button class="btn-icon" 
                                     onclick="toggleUserStatus(${user.id}, ${user.is_active == 1 ? 'false' : 'true'})" 
                                     title="${user.is_active == 1 ? 'Deactivate' : 'Activate'}"
                                     style="border:none;background:none;cursor:pointer;color:${user.is_active == 1 ? '#ef4444' : '#10b981'};">
                                 <i class="fas ${user.is_active == 1 ? 'fa-ban' : 'fa-check-circle'}"></i>
                             </button>
                        </div>
                    </td>
                </tr>
            `).join('');
        } else {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center text-danger">Failed to load users: ' + data.message + '</td></tr>';
        }
    } catch (error) {
        console.error('Error loading users:', error);
        tbody.innerHTML = '<tr><td colspan="7" class="text-center text-danger">Error loading users</td></tr>';
    }
}

function renderSidebar(role) {
    const nav = document.querySelector('.sidebar-nav');
    if (!nav) return;

    const currentPage = window.location.pathname.split('/').pop();

    let items = [];
    if (role === 'admin') {
        items = [
            { icon: 'fa-columns', text: 'Dashboard', href: 'dashboard.html' },
            { icon: 'fa-users', text: 'Users', href: 'users.html' },
            { icon: 'fa-sitemap', text: 'Accounts', href: 'accounts.html' },
            { icon: 'fa-receipt', text: 'Vouchers', href: 'vouchers.html' },
            { icon: 'fa-chart-pie', text: 'Reports', href: 'reports.html' },
            { icon: 'fa-cog', text: 'Settings', href: 'settings.html' }
        ];
    } else if (role === 'manager') {
        items = [

            { icon: 'fa-columns', text: 'Dashboard', href: 'dashboard.html' },
            { icon: 'fa-sitemap', text: 'Accounts', href: 'accounts.html' },
            { icon: 'fa-receipt', text: 'Vouchers', href: 'vouchers.html' },
            { icon: 'fa-chart-pie', text: 'Reports', href: 'reports.html' },
            { icon: 'fa-cog', text: 'Settings', href: 'settings.html' }
        ];
    } else if (role === 'accountant') {
        items = [
            // No Home link required by user spec ("only need... dashboard, accounts...")
            { icon: 'fa-columns', text: 'Dashboard', href: 'dashboard.html' },
            { icon: 'fa-sitemap', text: 'Accounts', href: 'accounts.html' },
            { icon: 'fa-receipt', text: 'Vouchers', href: 'vouchers.html' },
            { icon: 'fa-chart-pie', text: 'Reports', href: 'reports.html' },
            { icon: 'fa-cog', text: 'Settings', href: 'settings.html' }
        ];
    }

    nav.innerHTML = items.map(item => {
        const isActive = currentPage === item.href;
        return `
            <a href="${item.href}" class="nav-link ${isActive ? 'active' : ''}">
                <i class="fas ${item.icon}"></i>
                <span>${item.text}</span>
            </a>
        `;
    }).join('');
}

async function loadAccountantStats() {
    try {
        // Parallel fetching of Vouchers and P&L
        const [vouchersRes, pnlRes] = await Promise.allSettled([
            fetchWithTimeout(`${API_URL}/vouchers.php?action=list`, { credentials: 'include' }),
            fetchWithTimeout(`${API_URL}/reports.php?type=profit-loss&from_date=1970-01-01`, { credentials: 'include' })
        ]);

        // 1. Process Vouchers
        if (vouchersRes.status === 'fulfilled' && vouchersRes.value.ok) {
            const data = await vouchersRes.value.json();
            if (data.success) {
                const allVouchers = data.data;
                const draft = allVouchers.filter(v => v.status === 'Draft').length;
                const posted = allVouchers.filter(v => v.status === 'Posted').length;
                const rejected = allVouchers.filter(v => v.status === 'Rejected').length;

                if (document.getElementById('stat-draft-vouchers')) document.getElementById('stat-draft-vouchers').textContent = draft;
                if (document.getElementById('stat-posted-vouchers')) document.getElementById('stat-posted-vouchers').textContent = posted;
                if (document.getElementById('stat-rejected-vouchers')) document.getElementById('stat-rejected-vouchers').textContent = rejected;
            }
        }

        // 2. Process Financials (P&L)
        if (pnlRes.status === 'fulfilled' && pnlRes.value.ok) {
            const data = await pnlRes.value.json();
            if (data.success) {
                const accounts = data.data || [];
                let totalIncome = 0;
                let totalExpense = 0;

                accounts.forEach(acc => {
                    // API returns Net Debit:
                    // Expenses = Debit Balance (Positive)
                    // Income = Credit Balance (Negative)

                    const balance = parseFloat(acc.amount || acc.balance || 0);

                    if (acc.type === 'Income') {
                        // Income is usually Credit (Negative in Net Debit system)
                        // Use ABS to get the magnitude for display
                        totalIncome += Math.abs(balance);
                    } else if (acc.type === 'Expense') {
                        // Expense is usually Debit (Positive in Net Debit system)
                        totalExpense += Math.abs(balance);

                        // If an expense has negative balance (reversal/credit), abs might be wrong if we just want sum of expenses. 
                        // But usually P&L sums up net balances. If expense is negative, it reduces total expense.
                        // However, for "Total Expenses" display, we usually sum up the positive magnitude of expense accounts.
                        // Let's stick to ABS for simple magnitude display unless user strictly wants net flow. 
                        // Standard P&L: Revenue (Cr) - Expense (Dr)
                    }
                });

                // Net Profit = Income - Expenses
                const netProfit = totalIncome - totalExpense;

                const elRev = document.getElementById('stat-revenue');
                const elExp = document.getElementById('stat-expenses');
                const elProf = document.getElementById('stat-profit');

                if (elRev) elRev.textContent = formatCurrency(totalIncome);
                if (elExp) elExp.textContent = formatCurrency(totalExpense);
                if (elProf) {
                    elProf.textContent = formatCurrency(netProfit);
                    if (netProfit < 0) elProf.style.color = 'var(--danger-color)';
                    else elProf.style.color = 'var(--success-color)';
                }
            }
        }

    } catch (e) {
        console.error('Error loading accountant stats', e);
        // Fallback to mock for vouchers only (P&L complex to mock here without duplicating logic)
        const v = getMockVouchers();
        const draft = v.filter(x => x.status === 'Draft').length;
        const posted = v.filter(x => x.status === 'Posted').length;
        const rejected = v.filter(x => x.status === 'Rejected').length;

        if (document.getElementById('stat-draft-vouchers')) document.getElementById('stat-draft-vouchers').textContent = draft;
        if (document.getElementById('stat-posted-vouchers')) document.getElementById('stat-posted-vouchers').textContent = posted;
        if (document.getElementById('stat-rejected-vouchers')) document.getElementById('stat-rejected-vouchers').textContent = rejected;
    }
}

function initMockDataIfEmpty() {
    // Check for specific dummy data signatures and clear them if found

    // 1. Accounts
    const accounts = JSON.parse(localStorage.getItem('mock_accounts') || '[]');
    const hasDummyAccount = accounts.some(a => a.code === '1001' && a.name === 'Petty Cash' && a.balance === 10000);
    if (hasDummyAccount) {
        console.log('Clearing dummy accounts...');
        saveMockAccounts([]);
    } else if (!localStorage.getItem('mock_accounts')) {
        saveMockAccounts([]);
    }

    // 2. Vouchers
    const vouchers = JSON.parse(localStorage.getItem('mock_vouchers') || '[]');
    const hasDummyVoucher = vouchers.some(v => v.voucher_number === 'VCH-2025-001');
    if (hasDummyVoucher) {
        console.log('Clearing dummy vouchers...');
        saveMockVouchers([]);
    } else if (!localStorage.getItem('mock_vouchers')) {
        saveMockVouchers([]);
    }

    // 3. Users: Ensure only Admin exists
    const users = JSON.parse(localStorage.getItem('mock_users') || '[]');
    const hasDummyUsers = users.length > 1 || (users.length === 1 && users[0].firstName !== 'Admin');

    // Always reset to just Admin if completely empty OR if it has dirty dummy data
    if (hasDummyUsers || !localStorage.getItem('mock_users')) {
        const adminUser = {
            id: 1,
            first_name: 'Admin',
            last_name: 'User',
            email: 'admin@finsight.com',
            role: 'admin',
            department: 'IT',
            is_active: 1,
            last_login: new Date()
        };
        saveMockUsers([adminUser]);
    }
}

async function loadAdminStats() {
    try {
        // Parallel fetching
        const [uRes, pnlRes] = await Promise.allSettled([
            fetchWithTimeout(`${API_URL}/users.php?action=count`, { timeout: 3000, credentials: 'include' }),
            fetchWithTimeout(`${API_URL}/reports.php?type=profit-loss&from_date=1970-01-01`, { timeout: 3000, credentials: 'include' })
        ]);

        // 1. Users Stats
        if (uRes.status === 'fulfilled' && uRes.value.ok) {
            const data = await uRes.value.json();
            if (data.success) {
                const el = document.getElementById('stat-users');
                if (el) el.textContent = data.data.count || 0;
            }
        }

        // 2. Financial Stats (Revenue, Profit, Expenses)
        if (pnlRes.status === 'fulfilled' && pnlRes.value.ok) {
            const data = await pnlRes.value.json();
            if (data.success) {
                const accounts = data.data || [];

                // Calculate Totals using absolute values
                let totalIncome = 0;
                let totalExpense = 0;

                accounts.forEach(acc => {
                    const balance = parseFloat(acc.amount || acc.balance || 0);
                    // In P&L API:
                    // Income accounts usually have Credit balance (stored as negative in net-debit system or handled in API response)
                    // Expense accounts usually have Debit balance (positive)

                    if (acc.type === 'Income') {
                        // Assuming API return raw Net Debit (so Income is negative). We take absolute for display.
                        totalIncome += Math.abs(balance);
                    } else if (acc.type === 'Expense') {
                        totalExpense += Math.abs(balance);
                    }
                });

                // Net Profit = Income - Expenses
                const netProfit = totalIncome - totalExpense;

                const elRev = document.getElementById('stat-revenue');
                const elProf = document.getElementById('stat-profit');
                const elExp = document.getElementById('stat-expenses');

                // Format and display
                if (elRev) elRev.textContent = formatCurrency(totalIncome);
                if (elExp) elExp.textContent = formatCurrency(totalExpense);

                if (elProf) {
                    elProf.textContent = formatCurrency(netProfit);
                    // Optional styling for loss
                    if (netProfit < 0) elProf.style.color = 'var(--danger-color)';
                    else elProf.style.color = 'var(--success-color)';
                }
            }
        } else {
            console.warn('P&L fetch failed');
        }

    } catch (error) {
        console.error('Error loading admin stats:', error);
    }
}

function updateStatsFromMock() {
    const elUsers = document.getElementById('stat-users');
    if (elUsers) elUsers.textContent = getMockUsers().length;

    const elVouchers = document.getElementById('stat-vouchers');
    if (elVouchers) elVouchers.textContent = getMockVouchers().length;

    const elAccounts = document.getElementById('stat-accounts');
    const elBalance = document.getElementById('stat-balance');
    const accs = getMockAccounts();
    if (elAccounts) elAccounts.textContent = accs.length;
    if (elBalance) {
        const bal = accs.reduce((sum, a) => sum + (parseFloat(a.balance) || 0), 0);
        elBalance.textContent = formatCurrency(bal);
    }
}

// Utility: Open Modal
function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('active');
    }
}

// Utility: Close Modal
function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('active');
    }
}

// Utility: Format Date
function formatDate(dateStr) {
    if (!dateStr) return 'Never';
    return new Date(dateStr).toLocaleDateString('en-IN', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR',
        minimumFractionDigits: 2
    }).format(amount || 0);
}

function renderLedgerEntries(entries) {
    const tbody = document.getElementById('ledgerTableBody');
    if (!tbody) return;
    tbody.innerHTML = '';

    if (!entries || entries.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="text-center">No transactions found for this account.</td></tr>';
        return;
    }

    entries.forEach(entry => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${formatDate(entry.voucher_date)}</td>
            <td>${entry.voucher_number || '-'}</td>
            <td>${entry.narration || 'Journal Entry'}</td>
            <td class="text-right" style="color: var(--danger-color)">${entry.debit > 0 ? formatCurrency(entry.debit) : '-'}</td>
            <td class="text-right" style="color: var(--secondary-color)">${entry.credit > 0 ? formatCurrency(entry.credit) : '-'}</td>
            <td class="text-right" style="font-weight: 600;">${formatCurrency(entry.running_balance)}</td>
        `;
        tbody.appendChild(row);
    });
}

// Load and display users with paginationwhen  
async function loadUsersWithPagination(page = 1) {
    // Immediate fallback load
    loadUsersFromMock(page);

    try {
        const response = await fetchWithTimeout(`${API_URL}/users.php?action=list&page=${page}`, { timeout: 3000, credentials: 'include' });
        const data = await response.json();

        if (data.success) {
            const tbody = document.getElementById('usersTableBody');
            if (!tbody) return;
            tbody.innerHTML = '';

            if (data.data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7" class="text-center">No users found</td></tr>';
                return;
            }

            data.data.forEach(user => {
                const lastLogin = formatDate(user.last_login);
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${user.first_name} ${user.last_name}</td>
                    <td>${user.email}</td>
                    <td><span class="badge badge-role-${user.role}">${user.role}</span></td>
                    <td>${user.department || '-'}</td>
                    <td><span class="badge badge-${(user.is_active == 1 || user.is_active === true) ? 'active' : 'inactive'}">${(user.is_active == 1 || user.is_active === true) ? 'Active' : 'Inactive'}</span></td>
                    <td>${lastLogin}</td>
                    <td>
                        <button class="btn-sm btn-sm-secondary" onclick="editUserModal(${user.id})"><i class="fas fa-edit"></i> Edit</button>
                        <button class="btn-sm btn-sm-danger" onclick="confirmDeleteUser(${user.id}, '${user.first_name}')" style="margin: 0 4px;"><i class="fas fa-trash"></i></button>
                        ${getActionButton(user)}
                    </td>
                `;
                tbody.appendChild(row);
            });
        }
    } catch (error) {
        console.warn('Silent fail in users fetch, using mock.');
    }
}

// Load and display accounts
async function loadAccountsWithType() {
    // Immediate load from Mock
    loadAccountsFromMock();

    try {
        const response = await fetchWithTimeout(`${API_URL}/accounts.php?action=list`, { timeout: 3000, credentials: 'include' });
        const data = await response.json();

        if (data.success) {
            const tbody = document.getElementById('accountsTableBody');
            if (!tbody) return;
            tbody.innerHTML = '';

            if (data.data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" class="text-center">No accounts found</td></tr>';
                return;
            }

            data.data.forEach(account => {
                const balance = parseFloat(account.balance) || 0;
                const balanceClass = balance >= 0 ? 'positive' : 'negative';

                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${account.code}</td>
                    <td>${account.name}</td>
                    <td>
                        <span class="badge badge-type-${account.type.toLowerCase()}">
                            ${account.type}
                        </span>
                    </td>
                    <td class="balance-${balanceClass}">
                        ${formatCurrency(balance)}
                    </td>
                    <td>
                        <span class="badge badge-${(account.is_active == 1 || account.is_active === true) ? 'active' : 'inactive'}">
                            ${(account.is_active == 1 || account.is_active === true) ? 'Active' : 'Inactive'}
                        </span>
                    </td>
                    <td>
                        <button class="btn btn-sm btn-sm-secondary" onclick="editAccountModal(${account.id})"><i class="fas fa-edit"></i> Edit</button>
                        <button class="btn btn-sm btn-sm-info" onclick="viewLedger(${account.id}, '${account.name.replace(/'/g, "\\'")}')" style="margin: 0 4px;"><i class="fas fa-book"></i> Ledger</button>
                        <button class="btn btn-sm btn-danger" onclick="confirmDeleteAccount(${account.id}, '${account.name.replace(/'/g, "\\'")}')" style="margin: 0 4px;"><i class="fas fa-trash"></i></button>
                        ${getAccountActionButton(account)}
                    </td>
                `;
                tbody.appendChild(row);
            });
        }
    } catch (error) {
        console.warn('Error loading accounts from API, falling back to mock if available:', error);
        loadAccountsFromMock();
    }
}

// Utility function to edit user
async function editUserModal(userId) {
    const form = document.getElementById('addUserForm');
    const editingIdEl = document.getElementById('editingUserId');

    try {
        // Try to fetch user from API
        const res = await fetchWithTimeout(`${API_URL}/users.php?action=get&id=${userId}`, { credentials: 'include' });
        const data = await res.json();
        if (data.success && data.data) {
            const u = data.data;
            document.getElementById('newUserFirstName').value = u.first_name || '';
            document.getElementById('newUserLastName').value = u.last_name || '';
            document.getElementById('newUserEmail').value = u.email || '';
            document.getElementById('newUserUsername').value = u.username || '';
            document.getElementById('newUserRole').value = u.role || 'accountant';
            document.getElementById('newUserDepartment').value = u.department || '';
            editingIdEl.value = u.id;
            const modal = document.getElementById('addUserModal'); if (modal) modal.classList.add('active');
            return;
        }
    } catch (err) {
        // Show real error instead of fallback
        console.error(err);
        alert('Failed to load user details: ' + err.message);
        return;
    }

    /* Fallback removed to prevent "User not found" confusion
    const mock = getMockUsers();
    ... */

    // Fallback to mock
    const mock = getMockUsers();
    const user = mock.find(x => x.id == userId);
    if (user) {
        document.getElementById('newUserFirstName').value = user.first_name || '';
        document.getElementById('newUserLastName').value = user.last_name || '';
        document.getElementById('newUserEmail').value = user.email || '';
        document.getElementById('newUserUsername').value = user.username || '';
        document.getElementById('newUserRole').value = user.role || 'accountant';
        document.getElementById('newUserDepartment').value = user.department || '';
        editingIdEl.value = user.id;
        const modal = document.getElementById('addUserModal'); if (modal) modal.classList.add('active');
    } else {
        alert('User not found');
    }
}

// Button generator helper
function getActionButton(user) {
    const currentUser = JSON.parse(localStorage.getItem('user') || '{}');

    // Do not show toggle for the currently logged-in user
    if (user.id == currentUser.id) {
        return '<span class="text-muted" style="font-size: 12px; font-style: italic;">(You)</span>';
    }

    const isChecked = (user.is_active == 1 || user.is_active === true) ? 'checked' : '';

    return `
        <label class="toggle-switch status-toggle" style="margin: 0;">
            <input type="checkbox" ${isChecked} onchange="confirmToggleUserStatus(this, ${user.id}, '${user.first_name}')">
            <span class="toggle-slider"></span>
        </label>
    `;
}

// Handler for toggle change
function confirmToggleUserStatus(checkbox, userId, userName) {
    const isActivating = checkbox.checked;
    const action = isActivating ? 'activate' : 'deactivate';

    // Revert state temporarily until confirmed so the UI reflects the "current" reality
    checkbox.checked = !isActivating;

    // Use a small timeout to allow UI to repaint the revert before alert (optional but good)
    setTimeout(() => {
        window.customConfirm(
            `Are you sure you want to ${action} ${userName}?`,
            () => {
                // Optimistically set it to the new state
                checkbox.checked = isActivating;

                if (isActivating) {
                    activateUserAPI(userId);
                } else {
                    deactivateUserAPI(userId);
                }
            },
            null,
            { title: 'Confirm Status Change', confirmText: 'Yes', icon: 'fas fa-question-circle' }
        );
    }, 10);
}

// --- Mock data helpers (localStorage fallback) ---
function getMockUsers() {
    return JSON.parse(localStorage.getItem('mock_users') || '[]');
}

function saveMockUsers(arr) {
    localStorage.setItem('mock_users', JSON.stringify(arr));
}

function getMockVouchers() {
    return JSON.parse(localStorage.getItem('mock_vouchers') || '[]');
}

function saveMockVouchers(arr) {
    localStorage.setItem('mock_vouchers', JSON.stringify(arr));
}

function getMockAccounts() {
    return JSON.parse(localStorage.getItem('mock_accounts') || '[]');
}

function saveMockAccounts(arr) {
    localStorage.setItem('mock_accounts', JSON.stringify(arr));
}

function loadAccountsFromMock() {
    const tbody = document.getElementById('accountsTableBody');
    if (!tbody) return;
    const accounts = getMockAccounts();
    if (!accounts || accounts.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="text-center">No accounts found</td></tr>';
        return;
    }
    tbody.innerHTML = '';
    accounts.forEach(account => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${account.code}</td>
            <td>${account.name}</td>
            <td><span class="badge badge-type-${(account.type || 'Asset').toLowerCase()}">${account.type || 'Asset'}</span></td>
            <td>${formatCurrency(account.balance)}</td>
            <td><span class="badge badge-${(account.is_active == 1 || account.is_active === true) ? 'active' : 'inactive'}">${(account.is_active == 1 || account.is_active === true) ? 'Active' : 'Inactive'}</span></td>
            <td>
                <button class="btn btn-sm btn-sm-secondary" onclick="editAccountModal(${account.id})">
                    <i class="fas fa-edit"></i> Edit
                </button>
                <button class="btn btn-sm btn-sm-info" onclick="viewLedger(${account.id}, '${account.name.replace(/'/g, "\\'")}')" style="margin: 0 4px;"><i class="fas fa-book"></i> Ledger</button>
                <button class="btn btn-sm btn-danger" onclick="confirmDeleteAccount(${account.id}, '${account.name.replace(/'/g, "\\'")}')" style="margin: 0 4px;"><i class="fas fa-trash"></i></button>
                ${getAccountActionButton(account)}
            </td>
        `;
        tbody.appendChild(row);
    });
}

// Helper for account action buttons (activate/deactivate)
function getAccountActionButton(account) {
    const isChecked = (account.is_active == 1 || account.is_active === true) ? 'checked' : '';
    return `
        <label class="toggle-switch status-toggle" style="margin: 0; margin-left: 8px;">
            <input type="checkbox" ${isChecked} onchange="confirmToggleAccountStatus(this, ${account.id}, '${account.name}')">
            <span class="toggle-slider"></span>
        </label>
    `;
}

function confirmDeleteAccount(accountId, accountName) {
    window.customConfirm(
        `Are you sure you want to delete account "${accountName}"? This action cannot be undone.`,
        () => deleteAccount(accountId),
        null,
        { title: 'Delete Account', confirmText: 'Delete', icon: 'fas fa-trash' }
    );
}

async function deleteAccount(accountId) {
    try {
        const response = await fetchWithTimeout(`${API_URL}/accounts.php?action=delete`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ account_id: accountId }),
            credentials: 'include'
        });
        const data = await response.json();
        if (data.success) {
            alert('Account deleted successfully');
            loadAccountsWithType();
            return;
        } else {
            if (data.message && data.message.toLowerCase().includes('existing transactions')) {
                window.customConfirm(
                    'Delete failed: Account has existing transactions. Would you like to DEACTIVATE this account instead?',
                    () => deactivateAccountAPI(accountId),
                    null,
                    { title: 'Deactivate Account?', confirmText: 'Deactivate', icon: 'fas fa-exclamation-triangle' }
                );
            } else {
                alert(data.message || 'Unknown error');
            }
        }
    } catch (error) {
        console.warn('Delete account API failed, trying mock:', error);
        deleteMockAccount(accountId);
    }
}

function deleteMockAccount(accountId) {
    const accounts = getMockAccounts();
    const initialLength = accounts.length;
    const updated = accounts.filter(a => a.id != accountId);

    if (updated.length === initialLength) {
        alert('Account not found in demo data.');
        return;
    }

    saveMockAccounts(updated);
    loadAccountsWithType();
    alert('Account deleted successfully (Demo Mode)');
}

function saveMockAccounts(arr) {
    localStorage.setItem('mock_accounts', JSON.stringify(arr));
}

// Handler for account toggle change
function confirmToggleAccountStatus(checkbox, accountId, accountName) {
    const isActivating = checkbox.checked;
    const action = isActivating ? 'activate' : 'deactivate';

    checkbox.checked = !isActivating; // Revert temporarily

    setTimeout(() => {
        window.customConfirm(
            `Are you sure you want to ${action} account "${accountName}"?`,
            () => {
                checkbox.checked = isActivating; // Optimistically set
                if (isActivating) {
                    activateAccountAPI(accountId);
                } else {
                    deactivateAccountAPI(accountId);
                }
            },
            null,
            { title: 'Confirm Status Change', confirmText: 'Yes', icon: 'fas fa-question-circle' }
        );
    }, 10);
}

// Deactivate account via API with fallback to mock
async function deactivateAccountAPI(accountId) {
    try {
        const response = await fetchWithTimeout(`${API_URL}/accounts.php?action=deactivate`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ account_id: accountId, activate: false }),
            credentials: 'include'
        });
        const data = await response.json();
        if (data.success) {
            alert('Account deactivated successfully');
            loadAccountsWithType();
        } else {
            alert('Error: ' + (data.message || 'Failed to deactivate account'));
        }
    } catch (error) {
        console.warn('API deactivate account failed, falling back to mock:', error);
        deactivateMockAccount(accountId);
    }
}

// Activate account via API with fallback to mock
async function activateAccountAPI(accountId) {
    try {
        const response = await fetchWithTimeout(`${API_URL}/accounts.php?action=activate`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ account_id: accountId, activate: true }),
            credentials: 'include'
        });
        const data = await response.json();
        if (data.success) {
            alert('Account activated successfully');
            loadAccountsWithType();
        } else {
            alert('Error: ' + (data.message || 'Failed to activate account'));
        }
    } catch (error) {
        console.warn('API activate account failed, falling back to mock:', error);
        activateMockAccount(accountId);
    }
}

function deactivateMockAccount(accountId) {
    const accounts = getMockAccounts();
    const idx = accounts.findIndex(a => a.id == accountId);
    if (idx !== -1) {
        accounts[idx].is_active = 0;
        saveMockAccounts(accounts);
        alert('Account deactivated (local demo)');
        loadAccountsWithType();
    } else {
        alert('Account not found in mock data');
    }
}

function activateMockAccount(accountId) {
    const accounts = getMockAccounts();
    const idx = accounts.findIndex(a => a.id == accountId);
    if (idx !== -1) {
        accounts[idx].is_active = 1;
        saveMockAccounts(accounts);
        alert('Account activated (local demo)');
        loadAccountsWithType();
    } else {
        alert('Account not found in mock data');
    }
}

async function submitAddAccountForm(e) {
    e.preventDefault();
    const form = e.target;
    const editingId = document.getElementById('newAccountCode').dataset.editingId;
    const payload = {
        code: document.getElementById('newAccountCode').value,
        name: document.getElementById('newAccountName').value,
        type: document.getElementById('newAccountType').value,
        balance: Number(document.getElementById('newAccountBalance').value) || 0
    };

    console.log('Account payload:', payload); // Debug log

    if (editingId) {
        // Try update API
        try {
            const res = await fetchWithTimeout(`${API_URL}/accounts.php?action=update`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ account_id: editingId, ...payload }),
                credentials: 'include'
            });
            const data = await res.json();
            console.log('Update response:', data);
            if (data.success) {
                resetAddAccountModal();
                closeModal('addAccountModal');
                await loadAccountsWithType();
                alert('✓ Account updated successfully!');
                return;
            } else {
                alert('❌ Update failed: ' + (data.message || 'Unknown error'));
                return;
            }
        } catch (err) {
            console.error('Account update API failed:', err);
            alert('❌ Network error: ' + err.message);
            return;
        }
    } else {
        // Create
        try {
            const res = await fetchWithTimeout(`${API_URL}/accounts.php?action=create`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload),
                credentials: 'include'
            });
            const data = await res.json();
            console.log('Create response:', data);
            if (data.success) {
                resetAddAccountModal();
                closeModal('addAccountModal');
                await loadAccountsWithType();
                alert('✓ Account created successfully!');
                return;
            } else {
                alert('❌ Creation failed: ' + (data.message || 'Unknown error'));
                return;
            }
        } catch (err) {
            console.error('Accounts API create failed:', err);
            alert('❌ Network error: ' + err.message);
            return;
        }
    }
}

function seedDemoData() {
    // If mock data already present, do not overwrite unless explicitly requested
    if (!localStorage.getItem('mock_users')) {
        const users = [
            { id: 1001, first_name: 'Demo', last_name: 'Admin', email: 'admin@demo.com', username: 'admin', role: 'admin', department: 'IT', is_active: 1, last_login: new Date().toISOString() },
            { id: 1002, first_name: 'John', last_name: 'Doe', email: 'john@example.com', username: 'jdoe', role: 'accountant', department: 'Accounts', is_active: 1, last_login: new Date().toISOString() }
        ];
        saveMockUsers(users);
    }

    if (!localStorage.getItem('mock_vouchers')) {
        const vouchers = [
            { id: 2001, voucher_number: 'VCH-2025-001', voucher_type_name: 'Payment', voucher_date: new Date().toISOString(), total_debit: 15000, status: 'Posted', first_name: 'Demo', last_name: 'Admin' },
            { id: 2002, voucher_number: 'VCH-2025-002', voucher_type_name: 'Receipt', voucher_date: new Date().toISOString(), total_debit: 7500, status: 'Draft', first_name: 'John', last_name: 'Doe' }
        ];
        saveMockVouchers(vouchers);
    }

    // Reload UI
    loadUsers();
    loadVouchers();
    loadAuditTrail();
    alert('Demo data seeded (local only).');
}


// Deactivate user via API with fallback to mock
async function deactivateUserAPI(userId) {
    try {
        const response = await fetchWithTimeout(`${API_URL}/users.php?action=deactivate`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user_id: userId, activate: false }),
            credentials: 'include'
        });

        const data = await response.json();
        if (data.success) {
            alert('User deactivated successfully');
            loadUsers();
            return;
        } else {
            alert('Error: ' + (data.message || 'Failed to deactivate'));
        }
    } catch (error) {
        console.warn('API deactivate failed, falling back to mock:', error);
        deactivateMockUser(userId);
    }
}

// Activate user via API with fallback to mock
async function activateUserAPI(userId) {
    try {
        const response = await fetchWithTimeout(`${API_URL}/users.php?action=activate`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user_id: userId, activate: true }),
            credentials: 'include'
        });

        const data = await response.json();
        if (data.success) {
            alert('User activated successfully');
            loadUsers();
            return;
        } else {
            alert('Error: ' + (data.message || 'Failed to activate'));
        }
    } catch (error) {
        console.warn('API activate failed, falling back to mock:', error);
        activateMockUser(userId);
    }
}

function deactivateMockUser(userId) {
    const users = getMockUsers();
    const idx = users.findIndex(u => u.id == userId);
    if (idx !== -1) {
        users[idx].is_active = 0;
        saveMockUsers(users);
        alert('User deactivated (local demo)');
        loadUsers();
    } else {
        alert('User not found');
    }
}

function activateMockUser(userId) {
    const users = getMockUsers();
    const idx = users.findIndex(u => u.id == userId);
    if (idx !== -1) {
        users[idx].is_active = 1;
        saveMockUsers(users);
        alert('User activated (local demo)');
        loadUsers();
    } else {
        alert('User not found');
    }
}

// Confirm delete user
function confirmDeleteUser(userId, userName) {
    window.customConfirm(
        `Are you sure you want to PERMANENTLY DELETE user ${userName}? This action cannot be undone.`,
        () => deleteUserAPI(userId),
        null,
        { title: 'Delete User', confirmText: 'Delete', icon: 'fas fa-trash' }
    );
}

// Delete user via API with fallback to mock
async function deleteUserAPI(userId) {
    try {
        const response = await fetchWithTimeout(`${API_URL}/users.php?action=delete`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user_id: userId }),
            credentials: 'include'
        });

        const data = await response.json();
        if (data.success) {
            alert('User deleted successfully');
            loadUsers();
            return;
        } else {
            alert('Error: ' + (data.message || 'Failed to delete'));
        }
    } catch (error) {
        console.warn('API delete failed:', error);
        alert('Failed to delete user: ' + error.message);
    }
}

function deleteMockUser(userId) {
    const users = getMockUsers();
    const idx = users.findIndex(u => u.id == userId);
    if (idx !== -1) {
        users.splice(idx, 1);
        saveMockUsers(users);
        alert('User deleted (local demo)');
        loadUsers();
    } else {
        alert('User not found');
    }
}

// Reset Add Account Modal UI
function resetAddAccountModal() {
    const modal = document.getElementById('addAccountModal');
    if (!modal) return;

    delete document.getElementById('newAccountCode').dataset.editingId;
    const title = modal.querySelector('h2');
    const btn = modal.querySelector('button[type="submit"]');
    if (title) title.innerHTML = '<i class="fas fa-plus-circle"></i> Create New Account';
    if (btn) btn.innerHTML = '<i class="fas fa-check-circle"></i> Create Account';

    const form = document.getElementById('addAccountForm');
    if (form) form.reset();
}

// Edit account modal
async function editAccountModal(accountId) {
    resetAddAccountModal();

    let account = null;
    try {
        const res = await fetchWithTimeout(`${API_URL}/accounts.php?action=get&id=${accountId}`, { credentials: 'include' });
        const data = await res.json();
        if (data.success) account = data.data;
    } catch (err) {
        console.warn('API account get failed, falling back to mock', err);
    }

    if (!account) {
        const accs = getMockAccounts();
        account = accs.find(x => x.id == accountId);
    }

    if (account) {
        const modal = document.getElementById('addAccountModal');
        const title = modal.querySelector('h2');
        const btn = modal.querySelector('button[type="submit"]');

        if (title) title.innerHTML = '<i class="fas fa-edit"></i> Edit Account';
        if (btn) btn.innerHTML = '<i class="fas fa-save"></i> Update Account';

        document.getElementById('newAccountCode').value = account.code || '';
        document.getElementById('newAccountName').value = account.name || '';
        document.getElementById('newAccountType').value = account.type || 'Asset';
        document.getElementById('newAccountBalance').value = account.balance || 0;
        modal.classList.add('active');
        document.getElementById('newAccountCode').dataset.editingId = account.id;
    } else {
        alert('Account not found');
    }
}

// Ledger Global State
let currentLedgerAccountId = null;

// View account ledger
function viewLedger(accountId, accountName) {
    currentLedgerAccountId = accountId;
    console.log('View ledger for account:', accountId, accountName);
    const modal = document.getElementById('ledgerModal');
    if (!modal) return;

    const nameEl = document.getElementById('ledgerAccountName');
    if (nameEl) nameEl.textContent = accountName;

    // Set default dates if inputs exist and are empty
    const today = new Date();
    const financialYearStart = new Date(today.getFullYear(), 3, 1);
    if (today.getMonth() < 3) financialYearStart.setFullYear(today.getFullYear() - 1);

    const fromInput = document.getElementById('ledgerFromDate');
    const toInput = document.getElementById('ledgerToDate');
    if (fromInput && !fromInput.value) fromInput.valueAsDate = financialYearStart;
    if (toInput && !toInput.value) toInput.valueAsDate = today;

    modal.classList.add('active');

    loadLedgerData(accountId);
}

// Filter button handler
function filterLedger() {
    if (currentLedgerAccountId) {
        loadLedgerData(currentLedgerAccountId);
    }
}

async function loadLedgerData(accountId) {
    const tbody = document.getElementById('ledgerTableBody');
    if (!tbody) return;

    tbody.innerHTML = '<tr><td colspan="6" class="text-center"><i class="fas fa-spinner fa-spin"></i> Loading transactions...</td></tr>';

    const fromDate = document.getElementById('ledgerFromDate')?.value || '';
    const toDate = document.getElementById('ledgerToDate')?.value || '';

    try {
        let url = `${API_URL}/reports.php?action=ledger&account_id=${accountId}`;
        if (fromDate) url += `&from=${fromDate}`;
        if (toDate) url += `&to=${toDate}`;

        const res = await fetchWithTimeout(url, { credentials: 'include' });
        const data = await res.json();

        if (data.success) {
            renderLedgerEntries(data.data);
        } else {
            throw new Error(data.message);
        }
    } catch (err) {
        console.warn('Ledger API failed, using empty/mock state', err);
        tbody.innerHTML = '<tr><td colspan="6" class="text-center">No transactions found for this account.</td></tr>';
        resetLedgerSummary();
    }
}

function resetLedgerSummary() {
    ['ledgerOpeningBalance', 'ledgerTotalDebit', 'ledgerTotalCredit', 'ledgerFooterDebit', 'ledgerFooterCredit', 'ledgerClosingBalance'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.textContent = '₹0.00';
    });
}

function renderLedgerEntries(data) {
    const tbody = document.getElementById('ledgerTableBody');
    if (!tbody) return;
    tbody.innerHTML = '';

    // Handle data structure
    let entries = [];
    let openingBalance = 0;
    let periodDebit = 0;
    let periodCredit = 0;
    let closingBalance = 0;

    if (Array.isArray(data)) {
        // Legacy fallback
        entries = data;
    } else if (data && typeof data === 'object') {
        entries = data.transactions || [];
        openingBalance = parseFloat(data.opening_balance) || 0;
        // Use backend provided totals if available, otherwise we will calculate from visible entries
        periodDebit = (data.period_debit !== undefined) ? parseFloat(data.period_debit) : null;
        periodCredit = (data.period_credit !== undefined) ? parseFloat(data.period_credit) : null;
        closingBalance = (data.closing_balance !== undefined) ? parseFloat(data.closing_balance) : null;
    }

    // Update Opening Balance with Dr/Cr
    const obEl = document.getElementById('ledgerOpeningBalance');
    if (obEl) {
        // Format: ₹1,000.00 Dr
        const absOB = Math.abs(openingBalance);
        const suffix = openingBalance >= 0 ? 'Dr' : 'Cr'; // Asset/Expense > 0 is Dr. Liability/Income < 0 is Cr.
        // Note: Check backend logic. 
        // Backend says: Assets/Expense (positive), Liability/Equity/Income (negative).
        // Standard accounting: Positive = Debit, Negative = Credit.
        obEl.textContent = `${formatCurrency(absOB)} ${suffix}`;
        obEl.style.color = openingBalance >= 0 ? 'var(--text-main)' : 'var(--text-main)'; // Neutral color generally best for OB
    }

    // If we don't have backend totals yet (legacy), we'll sum them in the loop
    let calcDebit = 0;
    let calcCredit = 0;
    let runningBalance = openingBalance;

    if (!entries || entries.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="text-center" style="padding: 40px; color: var(--text-muted);">No transactions found for this period.</td></tr>';
    } else {
        entries.forEach(entry => {
            const date = entry.date || entry.voucher_date || entry.created_at;
            const desc = entry.narration || entry.description || entry.particulars || '-';
            const vNo = entry.voucher_number || entry.id || '-';
            const debit = parseFloat(entry.debit) || 0;
            const credit = parseFloat(entry.credit) || 0;

            calcDebit += debit;
            calcCredit += credit;
            runningBalance += (debit - credit); // Ensure running balance logic matches backend

            // Use backend running balance if provided for perfect consistency
            const displayBalance = (entry.running_balance !== undefined) ? parseFloat(entry.running_balance) : runningBalance;
            const balSuffix = displayBalance >= 0 ? 'Dr' : 'Cr';

            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${formatDate(date)}</td>
                <td style="font-family:monospace; color:var(--primary-color);">${vNo}</td>
                <td>${desc}</td>
                <td class="text-right" style="color: var(--danger-color);">${debit > 0 ? formatCurrency(debit) : '-'}</td>
                <td class="text-right" style="color: var(--success-color);">${credit > 0 ? formatCurrency(credit) : '-'}</td>
                <td class="text-right" style="font-weight: 600;">
                    ${formatCurrency(Math.abs(displayBalance))} ${balSuffix}
                </td>
            `;
            tbody.appendChild(row);
        });
    }

    // Finalize Totals using Backend values if present, else calculated
    const finalDebit = (periodDebit !== null) ? periodDebit : calcDebit;
    const finalCredit = (periodCredit !== null) ? periodCredit : calcCredit;

    // For closing balance: Backend value is best, else calculated last running balance
    // Note: If entries is empty, runningBalance is still openingBalance.
    // If backend provided closing_balance, use it (it considers period sum).
    const finalClosing = (closingBalance !== null) ? closingBalance : runningBalance;
    const finalClosingSuffix = finalClosing >= 0 ? 'Dr' : 'Cr';

    if (document.getElementById('ledgerTotalDebit')) document.getElementById('ledgerTotalDebit').textContent = formatCurrency(finalDebit);
    if (document.getElementById('ledgerTotalCredit')) document.getElementById('ledgerTotalCredit').textContent = formatCurrency(finalCredit);

    // Footer totals
    if (document.getElementById('ledgerFooterDebit')) document.getElementById('ledgerFooterDebit').textContent = formatCurrency(finalDebit);
    if (document.getElementById('ledgerFooterCredit')) document.getElementById('ledgerFooterCredit').textContent = formatCurrency(finalCredit);

    // Closing Balance footer
    if (document.getElementById('ledgerClosingBalance')) {
        document.getElementById('ledgerClosingBalance').innerHTML = `
            ${formatCurrency(Math.abs(finalClosing))} <span style="font-size:0.8em; color:var(--text-muted);">${finalClosingSuffix}</span>
        `;
    }
}

// Export Functions for Ledger
function exportLedgerPDF() {
    alert('📄 PDF export functionality will be implemented with a PDF library like jsPDF');
}

function exportLedgerExcel() {
    alert('📊 Excel export functionality will be implemented with a library like SheetJS');
}

function printLedger() {
    window.print();
}


// Utility: Populate Account Selects in Vouchers
// Utility: Populate Account Selects in Vouchers
let _cachedAccounts = null;

async function populateAccountSelects() {
    const selects = document.querySelectorAll('.account-dropdown');
    if (selects.length === 0) return;

    // Use memory cache if available, otherwise fetch
    if (!_cachedAccounts) {
        try {
            const res = await fetchWithTimeout(`${API_URL}/accounts.php?action=list`, { credentials: 'include' });
            const data = await res.json();
            if (data.success) {
                _cachedAccounts = data.data;
            } else {
                console.warn('Failed to load accounts:', data.message);
                _cachedAccounts = [];
            }
        } catch (e) {
            console.error('Network error loading accounts:', e);
            // Fallback to local storage mock if API fails completely
            _cachedAccounts = JSON.parse(localStorage.getItem('mock_accounts') || '[]');
        }
    }

    selects.forEach(select => {
        // Only populate if it's empty (has 1 or fewer options like "Select Account")
        if (select.options.length <= 1) {
            if (_cachedAccounts && _cachedAccounts.length > 0) {
                _cachedAccounts.forEach(acc => {
                    const opt = document.createElement('option');
                    opt.value = acc.id;
                    opt.textContent = `${acc.code} - ${acc.name}`;
                    select.appendChild(opt);
                });
            } else {
                const opt = document.createElement('option');
                opt.textContent = "No accounts found";
                opt.disabled = true;
                select.appendChild(opt);
            }
        }
    });
}

// Close all dropdowns
document.addEventListener('click', (e) => {
    if (!e.target.closest('.user-menu')) {
        const dropdown = document.getElementById('userDropdown');
        if (dropdown) dropdown.classList.remove('active');
    }
});

// Initialized on load

// Vouchers management 
async function loadVouchers() {
    loadVouchersFromMock(); // Instant load

    try {
        const filter = document.getElementById('voucherFilter')?.value || document.getElementById('voucherStatusFilter')?.value || '';
        const url = filter ? `${API_URL}/vouchers.php?action=list&status=${filter}` : `${API_URL}/vouchers.php?action=list`;
        const response = await fetchWithTimeout(url, { timeout: 3000, credentials: 'include' });
        const data = await response.json();
        if (data.success) {
            const tbody = document.getElementById('vouchersTableBody');
            if (!tbody) return;
            tbody.innerHTML = '';
            if (data.data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="7" class="text-center">No vouchers found</td></tr>';
                return;
            }
            data.data.forEach(voucher => {
                const row = document.createElement('tr');
                const statusClass = (voucher.status || '').toLowerCase().replace(' ', '-');
                const user = JSON.parse(localStorage.getItem('user') || '{}');
                const isAdmin = user.role === 'admin' || user.role === 'manager';

                row.innerHTML = `
                    <td>${voucher.voucher_number || ''}</td>
                    <td>${voucher.voucher_type_name || ''}</td>
                    <td>${formatDate(voucher.voucher_date)}</td>
                    <td>${formatCurrency(voucher.total_debit || 0)}</td>
                    <td><span class="badge badge-${statusClass}">${voucher.status || ''}</span></td>
                    <td>${voucher.first_name || ''} ${voucher.last_name || ''}</td>
                    <td>
                        <div style="display: flex; gap: 5px;">
                            <button onclick="viewVoucher('${voucher.id}')" class="btn-sm btn-sm-primary" style="display: flex; align-items: center; gap: 5px;">
                                <i class="fas fa-eye"></i> View
                            </button>
                            ${voucher.status === 'Draft' && user.role === 'accountant' ?
                        `<button onclick="requestApproval('${voucher.id}')" class="btn-sm" style="background:var(--warning-color); color:white; display: flex; align-items: center; gap: 5px;">
                                    <i class="fas fa-paper-plane"></i> Request
                                </button>` : ''}
                            
                            ${voucher.status === 'Draft' && isAdmin ?
                        `<button onclick="approveVoucher('${voucher.id}')" class="btn-sm" style="background:var(--success-color); color:white; display: flex; align-items: center; gap: 5px;">
                                    <i class="fas fa-check-circle"></i> Post
                                </button>` : ''}

                            ${voucher.status === 'Pending Approval' && isAdmin ?
                        `<button onclick="approveVoucher('${voucher.id}')" class="btn-sm" style="background:var(--success-color); color:white; display: flex; align-items: center; gap: 5px;">
                                    <i class="fas fa-check"></i> Approve
                                </button>
                                 <button onclick="rejectVoucher('${voucher.id}')" class="btn-sm" style="background:var(--danger-color); color:white; display: flex; align-items: center; gap: 5px;">
                                    <i class="fas fa-times"></i> Reject
                                </button>` : ''}
                        </div>
                    </td>
                `;
                tbody.appendChild(row);
            });
        }
    } catch (error) {
        console.warn('Vouchers API failed, sticking with mock.');
    }
}

function loadVouchersFromMock() {
    const tbody = document.getElementById('vouchersTableBody');
    if (!tbody) return;
    const items = getMockVouchers();
    if (!items || items.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="text-center">No vouchers found</td></tr>';
        return;
    }
    tbody.innerHTML = '';
    items.forEach(v => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${v.voucher_number}</td>
            <td>${v.voucher_type_name}</td>
            <td>${formatDate(v.voucher_date)}</td>
            <td>${formatCurrency(v.total_debit)}</td>
            <td><span class="badge badge-${(v.status || '').toLowerCase()}">${v.status}</span></td>
            <td>${v.first_name || ''} ${v.last_name || ''}</td>
            <td><button class="btn btn-sm btn-sm-secondary" onclick="viewVoucher('${v.id}')"><i class="fas fa-eye"></i> View</button></td>
        `;
        tbody.appendChild(row);
    });
}

// Audit Trail (copied from dashboard.js but guarded)
async function loadAuditTrail() {
    try {
        const fromDate = document.getElementById('auditFromDate')?.value;
        const toDate = document.getElementById('auditToDate')?.value;
        let url = `${API_URL}/audit.php?action=list`;
        if (fromDate) url += `&from_date=${fromDate}`;
        if (toDate) url += `&to_date=${toDate}`;
        const response = await fetchWithTimeout(url, { credentials: 'include' });
        const data = await response.json();
        if (data.success) {
            const tbody = document.getElementById('auditTableBody');
            if (!tbody) return;
            tbody.innerHTML = '';
            data.data.forEach(log => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${new Date(log.created_at).toLocaleString()}</td>
                    <td>${log.user_name || ''}</td>
                    <td>${log.action || ''}</td>
                    <td>${log.entity_type || ''} #${log.entity_id || ''}</td>
                    <td><small>${log.old_value ? 'Changed' : 'Created'}</small></td>
                    <td>${log.ip_address || ''}</td>
                `;
                tbody.appendChild(row);
            });
        }
    } catch (error) {
        console.error('Error loading audit trail:', error);
    }
}

// Helper to load financial insights
async function loadFinancialInsights() {
    const container = document.getElementById('insightsContent');
    if (!container) return; // Not on dashboard page

    try {
        const response = await fetchWithTimeout(`${API_URL}/insights.php?action=monthly`, { credentials: 'include' });
        const data = await response.json();

        if (data.success) {
            container.innerHTML = '';

            // 1. Health Score Badge
            const healthScore = data.health_score || 'Average';
            const healthColor = healthScore === 'Good' ? '#22c55e' : (healthScore === 'Poor' ? '#ef4444' : '#f59e0b');
            const healthBg = healthScore === 'Good' ? 'var(--bg-success-light, #dcfce7)' : (healthScore === 'Poor' ? 'var(--bg-danger-light, #fee2e2)' : 'var(--bg-warning-light, #fef3c7)');

            const healthDiv = document.createElement('div');
            healthDiv.style.cssText = `
                display: flex; 
                align-items: center; 
                justify-content: space-between; 
                background: ${healthBg}; 
                padding: 15px; 
                border-radius: 12px; 
                border: 1px solid ${healthColor}40;
                margin-bottom: 20px;
            `;
            healthDiv.innerHTML = `
                <div>
                    <div style="font-size: 13px; font-weight: 600; color: ${healthColor}; text-transform: uppercase; letter-spacing: 0.5px;">Business Health Score</div>
                    <div style="font-size: 24px; font-weight: 800; color: ${healthColor}; margin-top: 4px;">${healthScore}</div>
                    <div style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">${data.health_reason || ''}</div>
                </div>
                <div style="width: 50px; height: 50px; background: var(--bg-card); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 24px; color: ${healthColor}; box-shadow: var(--shadow-sm);">
                    <i class="fas fa-heartbeat"></i>
                </div>
            `;
            container.appendChild(healthDiv);

            // 2. Text Insights
            if (data.text_insights && data.text_insights.length > 0) {
                const list = document.createElement('div');
                list.style.display = 'flex';
                list.style.flexDirection = 'column';
                list.style.gap = '12px';

                data.text_insights.forEach(text => {
                    const item = document.createElement('div');
                    item.style.cssText = `
                        display: flex;
                        align-items: flex-start;
                        gap: 12px;
                        padding: 12px;
                        background: #f8fafc;
                        border-radius: 10px;
                        border-left: 4px solid var(--primary-color);
                    `;
                    item.innerHTML = `
                        <i class="fas fa-info-circle" style="color: var(--primary-color); margin-top: 3px;"></i>
                        <div style="font-size: 14px; color: var(--text-main); line-height: 1.5;">${text}</div>
                    `;
                    list.appendChild(item);
                });
                container.appendChild(list);
            } else {
                container.innerHTML += '<div style="text-align:center; color: var(--text-muted);">No insights available for this month yet.</div>';
            }

        } else {
            container.innerHTML = `<div style="color: var(--danger-color);">Unable to load insights: ${data.message}</div>`;
        }
    } catch (error) {
        console.error('Insights error:', error);
        container.innerHTML = `<div style="color: var(--text-muted);">Insights unavailable offline.</div>`;
    }
}

// Small wrappers so pages can call generic names
function loadUsers() {
    // default to page 1
    loadUsersWithPagination(1);
}

function loadAccounts() {
    loadAccountsWithType();
}

// Load users from mock
function loadUsersFromMock(page = 1) {
    const tbody = document.getElementById('usersTableBody');
    if (!tbody) return;
    const users = getMockUsers();
    if (!users || users.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="text-center">No users found</td></tr>';
        return;
    }
    tbody.innerHTML = '';
    users.forEach(user => {
        const lastLogin = user.last_login ? new Date(user.last_login).toLocaleString('en-IN') : 'Never';
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${user.first_name} ${user.last_name}</td>
            <td>${user.email}</td>
            <td><span class="badge badge-role-${user.role}">${user.role}</span></td>
            <td>${user.department || '-'}</td>
            <td><span class="badge badge-${(user.is_active == 1 || user.is_active === true) ? 'active' : 'inactive'}">${(user.is_active == 1 || user.is_active === true) ? 'Active' : 'Inactive'}</span></td>
            <td>${lastLogin}</td>
            <td>
                <button class="btn btn-sm btn-sm-secondary" onclick="editUserModal(${user.id})"><i class="fas fa-edit"></i> Edit</button>
                <button class="btn btn-sm btn-danger" onclick="confirmDeleteUser(${user.id}, '${user.first_name}')" style="margin: 0 4px;"><i class="fas fa-trash"></i></button>
                ${getActionButton(user)}
            </td>
        `;
        tbody.appendChild(row);
    });
}

// Add / Edit User form submission
async function submitAddUserForm(e) {
    e.preventDefault();
    const form = e.target;
    const editingIdEl = document.getElementById('editingUserId');
    const editingId = editingIdEl ? editingIdEl.value : null;

    const payload = {
        first_name: document.getElementById('newUserFirstName').value,
        last_name: document.getElementById('newUserLastName').value,
        email: document.getElementById('newUserEmail').value,
        username: document.getElementById('newUserUsername').value,
        role: document.getElementById('newUserRole').value,
        department: document.getElementById('newUserDepartment').value || '',
        password: document.getElementById('newUserPassword').value || ''
    };

    console.log('User payload:', payload); // Debug log

    if (editingId) {
        // Update user via API
        try {
            const res = await fetchWithTimeout(`${API_URL}/users.php?action=update`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ user_id: editingId, ...payload }),
                credentials: 'include',
                timeout: 5000
            });
            const data = await res.json();
            console.log('Update response:', data);

            if (data.success) {
                form.reset();
                closeModal('addUserModal');
                // Force fresh reload from API
                await loadUsersWithPagination(1);
                alert('✓ User updated successfully!');
                return;
            } else {
                alert('❌ Update failed: ' + (data.message || 'Unknown error'));
                return;
            }
        } catch (err) {
            console.error('Update API failed:', err);
            alert('❌ Network error: ' + err.message);
            return;
        }
    } else {
        // Create user via API
        try {
            const res = await fetchWithTimeout(`${API_URL}/users.php?action=create`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload),
                credentials: 'include',
                timeout: 5000
            });

            console.log('Create response status:', res.status);
            const data = await res.json();
            console.log('Create response data:', data);

            if (data.success) {
                form.reset();
                closeModal('addUserModal');
                // Force fresh reload from API
                await loadUsersWithPagination(1);

                let message = '✓ User created successfully!';
                if (data.data && data.data.temp_password) {
                    message += `\n\nTemporary Password: ${data.data.temp_password}\n\nPlease save this password and share it securely with the user.`;
                }
                alert(message);
                return;
            } else {
                alert('❌ Creation failed: ' + (data.message || 'Unknown error'));
                return;
            }
        } catch (err) {
            console.error('Create API failed:', err);
            alert('❌ Network error: ' + err.message);
            return;
        }
    }
}

// Add Voucher modal/show and submit
async function showAddVoucherModal() {
    const m = document.getElementById('addVoucherModal');
    if (m) m.classList.add('active');

    // Load types dynamically
    const typeSelect = document.getElementById('newVoucherType');
    if (typeSelect && typeSelect.options.length <= 1) { // Only load if not loaded
        try {
            const res = await fetchWithTimeout(`${API_URL}/vouchers.php?action=types`, { credentials: 'include' });
            const data = await res.json();
            if (data.success && data.data) {
                typeSelect.innerHTML = '';
                data.data.forEach(t => {
                    const opt = document.createElement('option');
                    opt.value = t.id;
                    opt.textContent = t.name;
                    typeSelect.appendChild(opt);
                });
            }
        } catch (e) {
            console.error('Failed to load voucher types', e);
            // Fallback (keep existing static options if any, or add minimal)
            if (typeSelect.options.length === 0) {
                typeSelect.innerHTML = '<option value="1">Payment</option><option value="2">Receipt</option>';
            }
        }
    }
}

async function submitAddVoucherForm(arg) {
    if (arg && arg.preventDefault) arg.preventDefault(); // Handle event object

    let targetStatus = 'Draft';
    if (typeof arg === 'string') targetStatus = arg;

    // Capture standard fields
    const typeId = document.getElementById('newVoucherType').value;
    const date = document.getElementById('newVoucherDate').value;
    const narration = document.getElementById('newVoucherNarration').value;

    // Capture journal entries
    const entries = [];
    let totalDebit = 0;
    let totalCredit = 0;

    document.querySelectorAll('.voucher-entry').forEach(row => {
        const sourceSelect = row.querySelector('.source-select');
        const expenseSelect = row.querySelector('.expense-select');
        const amountInput = row.querySelector('.entry-amount');

        if (sourceSelect && sourceSelect.value && expenseSelect && expenseSelect.value && amountInput) {
            const amount = parseFloat(amountInput.value) || 0;
            if (amount > 0) {
                // Debit Entry (Destination/Expense)
                entries.push({
                    account_id: expenseSelect.value,
                    account_name: expenseSelect.options[expenseSelect.selectedIndex].text,
                    debit: amount,
                    credit: 0
                });

                // Credit Entry (Source)
                entries.push({
                    account_id: sourceSelect.value,
                    account_name: sourceSelect.options[sourceSelect.selectedIndex].text,
                    debit: 0,
                    credit: amount
                });

                totalDebit += amount;
                totalCredit += amount;
            }
        }
    });

    if (entries.length < 2) {
        alert('At least one valid source and expense entry is required.');
        return;
    }

    if (Math.abs(totalDebit - totalCredit) > 0.01) {
        alert('Internal Error: Generated voucher is not balanced.');
        return;
    }

    const typeSelect = document.getElementById('newVoucherType');
    const typeName = typeSelect.options[typeSelect.selectedIndex].text;

    const payload = {
        voucher_type_id: typeId,
        voucher_date: date,
        narration: narration,
        voucher_type_name: typeName,
        status: targetStatus, // Send status to backend
        details: entries.map(e => ({
            account_id: e.account_id,
            debit: e.debit,
            credit: e.credit,
            description: narration
        }))
    };

    try {
        const res = await fetchWithTimeout(`${API_URL}/vouchers.php?action=create`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload),
            credentials: 'include'
        });
        const data = await res.json();
        if (data.success) {
            closeModal('addVoucherModal');
            loadVouchers();
            alert('✓ Voucher created successfully!');
            return;
        } else {
            console.error('Create failed:', data);
            alert('❌ Creation failed: ' + (data.message || 'Unknown error'));
            return; // Stop here, do not save to mock if API explicitly rejected it
        }
    } catch (err) {
        console.warn('Voucher API create failed, saving to mock', err);
        // Only if it's a network error (exception) do we consider falling back to mock
        // But for now, let's validly alert the user about the network error too
        alert('⚠️ Network error: ' + err.message + '. Saving locally (demo mode).');
    }

    // Fallback: save in mock
    const v = getMockVouchers();
    const newV = { id: Date.now(), ...payload, first_name: 'Local', last_name: 'User' };
    v.push(newV);
    saveMockVouchers(v);

    // Also save to recent transactions for dashboard
    const recent = JSON.parse(localStorage.getItem('mock_recent_transactions') || '[]');
    recent.unshift({
        id: newV.id,
        date: newV.voucher_date,
        description: newV.narration || newV.voucher_type_name,
        amount: newV.total_debit,
        type: 'debit'
    });
    localStorage.setItem('mock_recent_transactions', JSON.stringify(recent.slice(0, 10)));

    closeModal('addVoucherModal');
    loadVouchers();
    alert('Voucher created successfully (Demo Mode)');
}

// Request Approval
async function requestApproval(id) {
    if (!confirm('Send this voucher for Main Admin approval?')) return;

    try {
        const res = await fetchWithTimeout(`${API_URL}/vouchers.php?action=request_approval`, {
            method: 'POST',
            body: JSON.stringify({ voucher_id: id }),
            credentials: 'include'
        });
        const data = await res.json();
        if (data.success) {
            alert('✓ Audit request sent successfully!');
            loadVouchers(); // Refresh list
        } else {
            alert('❌ Failed: ' + data.message);
        }
    } catch (e) {
        console.error(e);
        alert('Error sending request');
    }
}

// Admin Actions
async function approveVoucher(id) {
    if (!confirm('Approve and Post this voucher? This cannot be undone.')) return;
    try {
        const res = await fetch(`${API_URL}/vouchers.php?action=post`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ voucher_id: id }),
            credentials: 'include'
        });

        if (!res.ok) {
            throw new Error(`HTTP ${res.status}`);
        }

        const data = await res.json();
        if (data.success) {
            alert('✓ Voucher Approved and Posted! Accountant has been notified via email.');
            closeModal('viewVoucherModal');
            loadVouchers();
        } else {
            alert('❌ Approval Failed: ' + data.message);
        }
    } catch (e) {
        console.error('Approval error:', e);
        alert('Error: ' + e.message);
    }
}

function rejectVoucher(id) {
    const modal = document.getElementById('rejectVoucherModal');
    if (!modal) {
        // Fallback if modal missing
        const reason = prompt("Please enter rejection reason:");
        if (reason) confirmRejectVoucherAPI(id, reason);
        return;
    }

    document.getElementById('rejectVoucherId').value = id;
    document.getElementById('rejectReason').value = ''; // Reset
    openModal('rejectVoucherModal');
}

async function confirmRejectVoucher() {
    const id = document.getElementById('rejectVoucherId').value;
    const reason = document.getElementById('rejectReason').value;

    if (!reason.trim()) {
        alert('Please enter a rejection reason.');
        return;
    }

    await confirmRejectVoucherAPI(id, reason);
    closeModal('rejectVoucherModal');
}

async function confirmRejectVoucherAPI(id, reason) {
    try {
        const res = await fetch(`${API_URL}/vouchers.php?action=reject`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ voucher_id: id, reason: reason }),
            credentials: 'include'
        });

        if (!res.ok) {
            throw new Error(`HTTP ${res.status}`);
        }

        const data = await res.json();
        if (data.success) {
            alert('✓ Voucher Rejected. Accountant has been notified via email.');
            closeModal('viewVoucherModal'); // Close the view modal too
            loadVouchers();
        } else {
            alert('❌ Rejection Failed: ' + data.message);
        }
    } catch (e) {
        console.error('Rejection error:', e);
        alert('Error: ' + e.message);
    }
}

async function viewVoucher(id) {
    // 1. Fetch latest details
    try {
        const res = await fetchWithTimeout(`${API_URL}/vouchers.php?action=get&id=${id}`, { credentials: 'include' });
        const data = await res.json();

        if (data.success) {
            const v = data.data;
            document.getElementById('viewVoucherNumber').innerText = v.voucher_number || '#';
            document.getElementById('viewVoucherDate').innerText = formatDate(v.voucher_date);
            document.getElementById('viewVoucherType').innerText = v.voucher_type_name || '-';

            const badgeClass = `badge-${(v.status || 'draft').toLowerCase().replace(' ', '-')}`;
            document.getElementById('viewVoucherStatus').innerHTML = `<span class="badge ${badgeClass}">${v.status || 'Draft'}</span>`;

            document.getElementById('viewVoucherNarration').innerText = v.narration || 'No narration provided.';

            const tbody = document.getElementById('viewVoucherEntries');
            tbody.innerHTML = '';

            let totalDr = 0;
            let totalCr = 0;

            if (v.details && v.details.length > 0) {
                v.details.forEach(d => {
                    const dr = parseFloat(d.debit) || 0;
                    const cr = parseFloat(d.credit) || 0;
                    totalDr += dr;
                    totalCr += cr;

                    const row = document.createElement('tr');
                    row.innerHTML = `
                        <td>${d.code ? d.code + ' - ' : ''}${d.name}</td>
                        <td class="text-right">${dr > 0 ? formatCurrency(dr) : '-'}</td>
                        <td class="text-right">${cr > 0 ? formatCurrency(cr) : '-'}</td>
                    `;
                    tbody.appendChild(row);
                });
            }

            document.getElementById('viewTotalDebit').innerText = formatCurrency(totalDr);
            document.getElementById('viewTotalCredit').innerText = formatCurrency(totalCr);

            // Show Admin controls if pending approval and user is admin/manager
            const user = JSON.parse(localStorage.getItem('user') || '{}');
            const canApprove = (user.role === 'admin' || user.role === 'manager') && v.status === 'Pending Approval';

            const footer = document.querySelector('#viewVoucherModal .modal-footer');

            // Clean up old dynamic buttons first
            const oldBtns = footer.querySelectorAll('.admin-action-btn');
            oldBtns.forEach(b => b.remove());

            if (canApprove) {
                const approveBtn = document.createElement('button');
                approveBtn.className = 'btn btn-success admin-action-btn';
                approveBtn.innerHTML = '<i class="fas fa-check"></i> Approve';
                approveBtn.onclick = () => approveVoucher(id);
                approveBtn.style.background = 'var(--success-color)';
                approveBtn.style.color = 'white';
                approveBtn.style.border = 'none';
                approveBtn.style.marginRight = '10px';

                const rejectBtn = document.createElement('button');
                rejectBtn.className = 'btn btn-danger admin-action-btn';
                rejectBtn.innerHTML = '<i class="fas fa-times"></i> Reject';
                rejectBtn.onclick = () => rejectVoucher(id);
                rejectBtn.style.background = 'var(--danger-color)';
                rejectBtn.style.color = 'white';
                rejectBtn.style.border = 'none';
                rejectBtn.style.marginRight = '10px';

                footer.insertBefore(rejectBtn, footer.firstChild);
                footer.insertBefore(approveBtn, footer.firstChild);
            }

            openModal('viewVoucherModal');
        }
    } catch (e) {
        console.error('Fetch voucher error', e);
    }
}

// End of viewVoucher logic

// --- Dynamic Reporting Logic (New Format) ---
async function generateDynamicReport(type) {
    const container = document.getElementById('report-container');
    if (!container) return;

    container.innerHTML = `
        <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 300px;">
            <i class="fas fa-spinner fa-spin" style="font-size: 40px; color: var(--primary-color); margin-bottom: 20px;"></i>
            <p style="color: var(--text-muted); font-weight: 500;">Generating financial statement...</p>
        </div>
    `;

    try {
        const res = await fetchWithTimeout(`${API_URL}/reports.php?type=${type}`, { timeout: 5000, credentials: 'include' });
        const json = await res.json();

        if (!json.success) {
            container.innerHTML = `
                <div class="alert alert-danger" style="margin-top: 50px; text-align: center;">
                    <i class="fas fa-exclamation-circle"></i> ${json.message || 'Failed to load report data.'}
                </div>`;
            return;
        }

        const data = json.data;
        const today = new Date().toLocaleDateString('en-IN', { year: 'numeric', month: 'long', day: 'numeric' });
        let content = '';

        if (type === 'balance-sheet') {
            content = renderNewBalanceSheet(data, today);
        } else if (type === 'profit-loss') {
            content = renderNewProfitLoss(data, today);
        } else if (type === 'trial-balance') {
            content = renderNewTrialBalance(data, today);
        }

        container.innerHTML = content;
    } catch (err) {
        console.error('Report Error:', err);
        container.innerHTML = '<div class="alert alert-danger text-center">Error connecting to report server. Using local cache...</div>';
    }
}

function renderNewBalanceSheet(accounts, date) {
    // Grouping
    const assets = accounts.filter(a => a.type === 'Asset');
    const liabilities = accounts.filter(a => a.type === 'Liability');
    const equity = accounts.filter(a => a.type === 'Equity');

    const totalAssets = assets.reduce((s, a) => s + parseFloat(a.balance || 0), 0);
    const totalLiabilities = liabilities.reduce((s, a) => s + parseFloat(a.balance || 0), 0);
    const totalEquity = equity.reduce((s, a) => s + parseFloat(a.balance || 0), 0);

    // Grouping by sub_type
    const groupBySub = (accs) => {
        return accs.reduce((groups, a) => {
            const sub = a.sub_type || 'General';
            if (!groups[sub]) groups[sub] = { accounts: [], total: 0 };
            groups[sub].accounts.push(a);
            groups[sub].total += parseFloat(a.balance || 0);
            return groups;
        }, {});
    };

    const assetGroups = groupBySub(assets);
    const liabGroups = groupBySub(liabilities);
    const equiGroups = groupBySub(equity);

    const renderRows = (groups) => {
        let html = '';
        for (const [name, group] of Object.entries(groups)) {
            html += `<tr style="background: rgba(0,0,0,0.02);"><td colspan="2"><strong style="font-size: 13px; text-transform: uppercase; color: var(--text-muted);">${name}</strong></td></tr>`;
            group.accounts.forEach(a => {
                html += `<tr><td style="padding-left: 24px;">${a.name}</td><td class="text-right">${formatCurrency(a.balance)}</td></tr>`;
            });
            html += `<tr style="border-bottom: 1px solid var(--border-color);"><td class="text-right"><em>Total ${name}</em></td><td class="text-right" style="font-weight: 600;">${formatCurrency(group.total)}</td></tr>`;
        }
        return html;
    };

    return `
        <div class="report-view animate-fadeIn" style="background: white; padding: 40px; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);">
            <div class="report-header text-center" style="margin-bottom: 40px; border-bottom: 2px solid var(--primary-color); padding-bottom: 20px;">
                <div style="font-size: 12px; font-weight: 700; color: var(--primary-color); letter-spacing: 2px; margin-bottom: 10px;">FINANCIAL STATEMENT</div>
                <h1 style="font-size: 28px; color: #1e293b; font-weight: 800; margin: 0;">FINSIGHT PRIVATE LIMITED</h1>
                <h2 style="font-size: 18px; color: #64748b; font-weight: 600; margin: 10px 0;">Balance Sheet (Statement of Financial Position)</h2>
                <div style="display: flex; align-items: center; justify-content: center; gap: 10px; margin-top: 15px;">
                    <span style="padding: 4px 12px; background: #f1f5f9; border-radius: 20px; font-size: 13px; color: #475569;">Run Date: ${date}</span>
                    <span style="padding: 4px 12px; background: #f1f5f9; border-radius: 20px; font-size: 13px; color: #475569;">Currency: INR</span>
                </div>
            </div>

            <div class="report-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 40px; align-items: start;">
                <!-- Left Side: Assets -->
                <div class="report-card">
                    <div style="padding: 12px 20px; background: #1e293b; color: white; border-radius: 8px 8px 0 0; font-weight: 700; display: flex; justify-content: space-between;">
                        <span>ASSETS</span>
                        <span>(Dr)</span>
                    </div>
                    <table class="data-table" style="width: 100%; border-collapse: collapse;">
                        <tbody style="font-size: 14px;">
                            ${renderRows(assetGroups)}
                        </tbody>
                        <tfoot>
                            <tr style="background: #f8fafc; border-top: 2px solid #1e293b; font-weight: 800; font-size: 15px;">
                                <td style="padding: 15px 20px;">TOTAL ASSETS</td>
                                <td class="text-right" style="padding: 15px 20px; color: var(--primary-color);">${formatCurrency(totalAssets)}</td>
                            </tr>
                        </tfoot>
                    </table>
                </div>

                <!-- Right Side: Liabilities & Equity -->
                <div class="report-card">
                    <div style="padding: 12px 20px; background: #1e293b; color: white; border-radius: 8px 8px 0 0; font-weight: 700; display: flex; justify-content: space-between;">
                        <span>LIABILITIES & EQUITY</span>
                        <span>(Cr)</span>
                    </div>
                    <table class="data-table" style="width: 100%; border-collapse: collapse;">
                        <tbody style="font-size: 14px;">
                            <tr style="background: rgba(0,0,0,0.05);"><td colspan="2"><strong>LIABILITIES</strong></td></tr>
                            ${renderRows(liabGroups)}
                            <tr><td colspan="2" style="height: 10px;"></td></tr>
                            <tr style="background: rgba(0,0,0,0.05);"><td colspan="2"><strong>OWNER'S EQUITY</strong></td></tr>
                            ${renderRows(equiGroups)}
                        </tbody>
                        <tfoot>
                            <tr style="background: #f8fafc; border-top: 2px solid #1e293b; font-weight: 800; font-size: 15px;">
                                <td style="padding: 15px 20px;">TOTAL LIABILITIES & EQUITY</td>
                                <td class="text-right" style="padding: 15px 20px; color: var(--primary-color);">${formatCurrency(totalLiabilities + totalEquity)}</td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>

            ${Math.abs(totalAssets - (totalLiabilities + totalEquity)) > 0.01 ? `
                <div style="margin-top: 30px; padding: 15px; background: #fee2e2; border-radius: 8px; border-left: 5px solid #ef4444; color: #b91c1c; display: flex; align-items: center; gap: 15px;">
                    <i class="fas fa-exclamation-triangle" style="font-size: 20px;"></i>
                    <div>
                        <strong style="display: block;">Out of Balance!</strong>
                        The statement is out of balance by ${formatCurrency(Math.abs(totalAssets - (totalLiabilities + totalEquity)))}. Please review unposted vouchers.
                    </div>
                </div>
            ` : `
                <div style="margin-top: 30px; text-align: center; color: #10b981; font-size: 13px; font-weight: 600;">
                    <i class="fas fa-check-circle"></i> This statement is in balance and finalized.
                </div>
            `}
        </div>
    `;
}

function renderNewProfitLoss(accounts, date) {
    const income = accounts.filter(a => a.type === 'Income');
    const expense = accounts.filter(a => a.type === 'Expense');

    const totalIncome = income.reduce((s, a) => s + parseFloat(a.amount || 0), 0);
    const totalExpense = expense.reduce((s, a) => s + parseFloat(a.amount || 0), 0);
    const netProfit = totalIncome - totalExpense;

    const groupBySub = (accs) => {
        return accs.reduce((groups, a) => {
            const sub = a.sub_type || 'Operating';
            if (!groups[sub]) groups[sub] = { accounts: [], total: 0 };
            groups[sub].accounts.push(a);
            groups[sub].total += parseFloat(a.amount || 0);
            return groups;
        }, {});
    };

    const incomeGroups = groupBySub(income);
    const expenseGroups = groupBySub(expense);

    const renderSection = (title, groups, colorClass) => {
        let html = `<tr style="background: #f1f5f9;"><td colspan="2"><strong style="color: #475569;">${title}</strong></td></tr>`;
        for (const [name, group] of Object.entries(groups)) {
            html += `<tr><td style="padding-left: 20px; font-weight: 600; font-size: 13px; color: #64748b;">${name}</td><td class="text-right"></td></tr>`;
            group.accounts.forEach(a => {
                html += `<tr><td style="padding-left: 40px;">${a.name}</td><td class="text-right" style="color: ${colorClass}">${formatCurrency(Math.abs(a.amount))}</td></tr>`;
            });
            html += `<tr style="border-bottom: 1px dotted #e2e8f0;"><td class="text-right" style="font-size: 12px; color: #94a3b8;">Total ${name}</td><td class="text-right" style="font-weight: 600;">${formatCurrency(Math.abs(group.total))}</td></tr>`;
        }
        return html;
    };

    return `
        <div class="report-view animate-fadeIn" style="background: white; padding: 40px; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); max-width: 900px; margin: 0 auto;">
            <div class="report-header text-center" style="margin-bottom: 40px;">
                <h1 style="font-size: 28px; color: #1e293b; font-weight: 800; margin: 0;">FINSIGHT PRIVATE LIMITED</h1>
                <h2 style="font-size: 20px; color: #64748b; font-weight: 600;">Statement of Profit and Loss</h2>
                <p style="color: #94a3b8; font-size: 14px; margin-top: 5px;">For the Period: Year to Date (Ending ${date})</p>
            </div>

            <table class="report-table" style="width: 100%; border-collapse: collapse;">
                <thead>
                    <tr style="border-bottom: 2px solid #1e293b;">
                        <th style="text-align: left; padding: 12px;">Particulars</th>
                        <th style="text-align: right; padding: 12px;">Amount (INR)</th>
                    </tr>
                </thead>
                <tbody style="font-size: 14px;">
                    ${renderSection('REVENUE FROM OPERATIONS', incomeGroups, '#10b981')}
                    <tr style="background: #f8fafc; font-weight: 700; border-top: 1px solid #1e293b;">
                        <td style="padding: 12px 20px;">(A) TOTAL REVENUE</td>
                        <td class="text-right" style="padding: 12px 20px; color: #10b981;">${formatCurrency(totalIncome)}</td>
                    </tr>
                    <tr><td colspan="2" style="height: 20px;"></td></tr>
                    ${renderSection('OPERATING EXPENSES', expenseGroups, '#ef4444')}
                    <tr style="background: #f8fafc; font-weight: 700; border-top: 1px solid #1e293b;">
                        <td style="padding: 12px 20px;">(B) TOTAL EXPENSES</td>
                        <td class="text-right" style="padding: 12px 20px; color: #ef4444;">${formatCurrency(totalExpense)}</td>
                    </tr>
                </tbody>
                <tfoot>
                    <tr style="background: #1e293b; color: white; font-weight: 800; font-size: 18px;">
                        <td style="padding: 20px;">NET ${netProfit >= 0 ? 'PROFIT' : 'LOSS'} FOR THE PERIOD (A - B)</td>
                        <td class="text-right" style="padding: 20px; color: ${netProfit >= 0 ? '#4ade80' : '#f87171'};">${formatCurrency(netProfit)}</td>
                    </tr>
                </tfoot>
            </table>
            
            <div style="margin-top: 40px; font-size: 12px; color: #94a3b8; border-top: 1px solid #e2e8f0; padding-top: 20px;">
                <p>* This report is generated automatically based on posted and draft vouchers for the selected period.</p>
                <p>* Net profit is before tax considerations unless specific tax provisions are adjusted via journal vouchers.</p>
            </div>
        </div>
    `;
}

function renderNewTrialBalance(accounts, date) {
    let totalDebit = 0;
    let totalCredit = 0;

    const rows = accounts.map(acc => {
        const debit = parseFloat(acc.total_debit || 0);
        const credit = parseFloat(acc.total_credit || 0);
        totalDebit += debit;
        totalCredit += credit;

        return `
            <tr>
                <td style="padding: 10px 15px;">${acc.code}</td>
                <td style="padding: 10px 15px;">${acc.name}</td>
                <td class="text-right" style="padding: 10px 15px; color: #1e293b;">${debit > 0 ? formatCurrency(debit) : '-'}</td>
                <td class="text-right" style="padding: 10px 15px; color: #1e293b;">${credit > 0 ? formatCurrency(credit) : '-'}</td>
            </tr>
        `;
    }).join('');

    return `
        <div class="report-view animate-fadeIn" style="background: white; padding: 40px; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); max-width: 1000px; margin: 0 auto;">
            <div class="report-header text-center" style="margin-bottom: 30px;">
                <h1 style="font-size: 26px; color: #1e293b; font-weight: 800; margin: 0;">FINSIGHT PRIVATE LIMITED</h1>
                <h2 style="font-size: 20px; color: #64748b; font-weight: 600;">Trial Balance (Summary)</h2>
                <p style="color: #94a3b8;">As of ${date}</p>
            </div>
            <table class="data-table" style="width: 100%; border-collapse: collapse;">
                <thead>
                    <tr style="background: #1e293b; color: white;">
                        <th style="padding: 12px 15px; text-align: left;">Code</th>
                        <th style="padding: 12px 15px; text-align: left;">Account Name</th>
                        <th class="text-right" style="padding: 12px 15px;">Total Debit</th>
                        <th class="text-right" style="padding: 12px 15px;">Total Credit</th>
                    </tr>
                </thead>
                <tbody style="font-size: 14px;">
                    ${rows}
                </tbody>
                <tfoot>
                    <tr style="background: #f8fafc; font-weight: 800; border-top: 2px solid #1e293b; font-size: 16px;">
                        <td colspan="2" style="padding: 15px;">GRAND TOTAL</td>
                        <td class="text-right" style="padding: 15px; color: var(--primary-color);">${formatCurrency(totalDebit)}</td>
                        <td class="text-right" style="padding: 15px; color: var(--primary-color);">${formatCurrency(totalCredit)}</td>
                    </tr>
                </tfoot>
            </table>
            ${Math.abs(totalDebit - totalCredit) > 0.01 ? `
                <div style="margin-top: 20px; color: var(--danger-color); font-weight: 700; text-align: center;">
                    <i class="fas fa-exclamation-circle"></i> LEDGER IS OUT OF BALANCE BY ${formatCurrency(Math.abs(totalDebit - totalCredit))}
                </div>
            ` : ''}
        </div>
    `;
}

// Initialize admin dashboard
document.addEventListener('DOMContentLoaded', async () => {
    try {
        await initAdminDashboard();
    } catch (e) {
        console.error('Dashboard init failed:', e);
    }

    // Wire form handlers
    const addUserForm = document.getElementById('addUserForm'); if (addUserForm) addUserForm.addEventListener('submit', submitAddUserForm);
    const addVoucherForm = document.getElementById('addVoucherForm'); if (addVoucherForm) addVoucherForm.addEventListener('submit', submitAddVoucherForm);
    const addAccountForm = document.getElementById('addAccountForm'); if (addAccountForm) addAccountForm.addEventListener('submit', submitAddAccountForm);

    // Page-specific initializers
    if (document.getElementById('usersTableBody')) {
        loadUsers();
    }

    if (document.getElementById('accountsTableBody')) {
        loadAccountsWithType();
    }

    if (document.getElementById('vouchersTableBody')) {
        loadVouchers();
    }

    if (document.getElementById('auditTableBody')) {
        loadAuditTrail();
    }

    if (document.getElementById('report-container')) {
        // No default report; left for user action
    }

    // New logic for role-based settings visibility
    setupSettingsAccess();

    // Initialize Notifications
    initNotifications();
});

// ... [existing codes] ...

async function initNotifications() {
    console.log('=== Initializing Notifications ===');

    // Check if we're on a dashboard page
    const isDashboard = window.location.pathname.includes('dashboard.html') ||
        window.location.pathname.includes('accountant.html') ||
        (window.location.pathname.endsWith('/') && document.getElementById('stat-revenue'));

    // Hide notification bell on all pages except dashboards
    if (!isDashboard) {
        const bellBtn = document.getElementById('notificationBtn') || document.querySelector('.fa-bell')?.closest('button');
        if (bellBtn) bellBtn.style.display = 'none';
        return;
    }

    // Find the notification button
    const bellBtn = document.getElementById('notificationBtn');

    if (!bellBtn) {
        console.error('Notification button not found!');
        return;
    }

    console.log('Notification button found:', bellBtn);

    // DELEGATE NOTIFICATION TO DASHBOARD.JS
    // The modern dashboard.js handles the beautiful CSS and logic for the notification dropdown.


    // Insert toggle button if it doesn't exist
    const header = document.querySelector('.header');
    if (header) {
        let toggle = document.getElementById('sidebarToggle');
        if (!toggle) {
            toggle = document.createElement('button');
            toggle.id = 'sidebarToggle';
            toggle.className = 'header-toggle';
            toggle.innerHTML = '<i class="fas fa-bars"></i>';
            header.insertBefore(toggle, header.firstElementChild);

            // Add click listener immediately
            toggle.addEventListener('click', () => {
                const sb = document.querySelector('.sidebar');
                if (window.innerWidth <= 768) {
                    sb.classList.toggle('active');
                } else {
                    sb.classList.toggle('collapsed');
                }
            });
        }
    }

    // Update User Profile
    updateUserProfile(currentUser);
    console.log('Event listeners attached');

    // Initial load
    loadNotifications();

    // Poll every 30 seconds
    setInterval(loadNotifications, 30000);
}


// Simplified notification loading function
async function loadNotifications() {
    console.log('Loading notifications...');

    const list = document.getElementById('notificationList');
    if (!list) {
        console.error('Notification list element not found');
        return;
    }

    // Abort any previous ongoing fetch
    if (_notificationAbortController) {
        _notificationAbortController.abort();
        console.log('Aborting previous notification fetch.');
    }
    _notificationAbortController = new AbortController();
    const signal = _notificationAbortController.signal;

    try {
        // Simple fetch with abort controller
        const response = await fetch(`${API_URL}/notifications.php?action=list`, {
            method: 'GET',
            credentials: 'include',
            headers: {
                'Content-Type': 'application/json'
            },
            signal: signal // Pass the signal to the fetch request
        });

        console.log('Response status:', response.status);

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const data = await response.json();
        console.log('Data received:', data);

        if (data.success && data.data) {
            const notifications = data.data.notifications || [];
            const unreadCount = data.data.unread_count || 0;

            console.log(`Found ${notifications.length} notifications, ${unreadCount} unread`);

            // Update badge
            updateBadge(unreadCount);

            // Render notifications
            if (notifications.length === 0) {
                list.innerHTML = `
                    <div style="padding: 40px 20px; text-align: center; color: #94a3b8; font-size: 14px;">
                        <i class="fas fa-bell-slash" style="font-size: 32px; margin-bottom: 10px; opacity: 0.5;"></i>
                        <p style="margin: 0;">No notifications</p>
                    </div>
                `;
            } else {
                list.innerHTML = notifications.map(notif => {
                    const isUnread = notif.is_read == 0;
                    const bgColor = isUnread ? '#f0f9ff' : 'white';
                    const textColor = isUnread ? '#1e293b' : '#64748b';
                    const dotColor = getNotificationColor(notif.type);

                    return `
                        <div class="notification-item"
                             style="padding: 12px 15px; border-bottom: 1px solid #f1f5f9; background: ${bgColor}; cursor: pointer; transition: all 0.2s;"
                             onmouseover="this.style.background='#f8fafc'"
                             onmouseout="this.style.background='${bgColor}'"
                             onclick="handleNotificationClick(${notif.id}, ${notif.related_id || 'null'})">
                            <div style="display: flex; gap: 10px; align-items: start;">
                                <div style="width: 8px; height: 8px; background: ${dotColor}; border-radius: 50%; margin-top: 6px; flex-shrink: 0;"></div>
                                <div style="flex: 1;">
                                    <p style="margin: 0 0 5px 0; font-size: 13px; color: ${textColor}; line-height: 1.4; font-weight: ${isUnread ? '600' : '400'};">
                                        ${notif.message}
                                    </p>
                                    <span style="font-size: 11px; color: #94a3b8;">
                                        ${formatTimeAgo(notif.created_at)}
                                    </span>
                                </div>
                            </div>
                        </div>
                    `;
                }).join('');
            }
        } else {
            list.innerHTML = `
                <div style="padding: 30px 20px; text-align: center; color: #94a3b8; font-size: 13px;">
                    <i class="fas fa-exclamation-circle"></i> Unable to load notifications
                </div>
            `;
        }
    } catch (error) {
        console.error('Error loading notifications:', error);

        // Don't show error if it's just an abort
        if (error.name === 'AbortError') {
            console.log('Request was aborted, ignoring...');
            return;
        }

        list.innerHTML = `
            <div style="padding: 30px 20px; text-align: center;">
                <p style="color: #ef4444; font-size: 13px; margin: 0 0 10px 0;">
                    <i class="fas fa-exclamation-triangle"></i> Failed to load
                </p>
                <button onclick="loadNotifications()" style="padding: 6px 12px; background: #f1f5f9; border: 1px solid #e2e8f0; border-radius: 6px; cursor: pointer; font-size: 12px;">
                    Retry
                </button>
            </div>
        `;
    }
}

// Update notification badge
function updateBadge(count) {
    const badges = document.querySelectorAll('.notification-badge');
    badges.forEach(badge => {
        if (count > 0) {
            badge.textContent = count > 9 ? '9+' : count;
            badge.style.display = 'flex';
        } else {
            badge.style.display = 'none';
        }
    });
}

// Get notification color based on type
function getNotificationColor(type) {
    switch (type) {
        case 'success': return '#22c55e';
        case 'error': return '#ef4444';
        case 'warning': return '#f59e0b';
        default: return '#3b82f6';
    }
}

// Format time ago
function formatTimeAgo(dateString) {
    const date = new Date(dateString);
    const now = new Date();
    const seconds = Math.floor((now - date) / 1000);

    if (seconds < 60) return 'Just now';
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
    if (seconds < 604800) return `${Math.floor(seconds / 86400)}d ago`;
    return date.toLocaleDateString();
}

// Handle notification click
function handleNotificationClick(notifId, relatedId) {
    console.log('Notification clicked:', notifId, relatedId);

    // Mark as read
    fetch(`${API_URL}/notifications.php?action=mark_read`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: notifId })
    }).then(() => {
        loadNotifications();
    });

    // Navigate to related voucher if exists
    if (relatedId) {
        window.location.href = 'vouchers.html?id=' + relatedId;
    }
}

// Mark all as read
function markAllNotificationsRead() {
    console.log('Marking all as read...');

    fetch(`${API_URL}/notifications.php?action=mark_read`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(() => {
        loadNotifications();
    });
}

function renderNotifications() {
    console.log('renderNotifications called');
    // Update Badge
    const badges = document.querySelectorAll('.notification-badge');
    badges.forEach(b => {
        if (_notifState.unread > 0) {
            b.textContent = _notifState.unread > 9 ? '9+' : _notifState.unread;
            b.style.display = 'flex';
        } else {
            b.style.display = 'none';
        }
    });

    // Update List
    const list = document.getElementById('notificationList');
    if (!list) {
        console.warn('notificationList element not found!');
        return;
    }

    if (_notifState.list.length === 0) {
        console.log('No notifications, showing empty message');
        list.innerHTML = `<div style="padding: 30px; text-align: center; color: #999; font-size: 13px;">No notifications</div>`;
        return;
    }

    console.log('Rendering', _notifState.list.length, 'notifications');

    list.innerHTML = _notifState.list.map(n => `
        <div class="notification-item ${n.is_read == 0 ? 'unread' : ''}" 
             style="padding: 12px 15px; border-bottom: 1px solid #f1f1f1; background: ${n.is_read == 0 ? '#f0f9ff' : 'white'}; cursor: pointer; transition: background 0.2s;"
             onclick="handleNotificationClick('${n.id}', '${n.related_id}')">
            <div style="display: flex; gap: 10px;">
                <div style="width: 8px; height: 8px; background: ${getNotifColor(n.type)}; border-radius: 50%; margin-top: 6px; flex-shrink: 0;"></div>
                <div>
                    <p style="margin: 0 0 5px 0; font-size: 13px; color: ${n.is_read == 0 ? '#1e293b' : '#64748b'}; line-height: 1.4;">${n.message}</p>
                    <span style="font-size: 11px; color: #94a3b8;">${timeAgo(new Date(n.created_at))}</span>
                </div>
            </div>
        </div>
    `).join('');
}

function getNotifColor(type) {
    if (type === 'success') return '#22c55e';
    if (type === 'error') return '#ef4444';
    if (type === 'warning') return '#f59e0b';
    return '#3b82f6';
}

function timeAgo(date) {
    const seconds = Math.floor((new Date() - date) / 1000);
    if (seconds < 60) return 'Just now';
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return minutes + 'm ago';
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return hours + 'h ago';
    const days = Math.floor(hours / 24);
    return days + 'd ago';
}

// ============================================
// LOGOUT FUNCTIONALITY
// ============================================

function logout() {
    let modal = document.getElementById('logoutModal');

    // Dynamically create modal if it doesn't exist
    if (!modal) {
        const modalHtml = `
            <div id="logoutModal" class="modal">
                <div class="modal-content" style="max-width: 400px; padding: 40px; text-align: center; border-radius: 24px;">
                    <div style="width: 80px; height: 80px; background: #fee2e2; color: #ef4444; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 32px; margin: 0 auto 24px auto;">
                        <i class="fas fa-sign-out-alt"></i>
                    </div>
                    <h2 style="font-size: 24px; font-weight: 800; color: #1e293b; margin-bottom: 12px;">Log Out?</h2>
                    <p style="color: #64748b; margin-bottom: 32px; font-size: 15px; line-height: 1.6;">Are you sure you want to end your session? You will be redirected to the login page.</p>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <button onclick="closeModal('logoutModal')" class="btn" style="padding: 12px; border-radius: 12px; font-weight: 600; background: #f1f5f9; color: #475569; border: 1px solid transparent; cursor: pointer; transition: all 0.2s;">Cancel</button>
                        <button onclick="confirmLogout()" class="btn" style="padding: 12px; border-radius: 12px; font-weight: 600; background: #ef4444; color: white; border: 1px solid #ef4444; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);">Yes, Logout</button>
                    </div>
                </div>
            </div>
        `;
        document.body.insertAdjacentHTML('beforeend', modalHtml);
        modal = document.getElementById('logoutModal');
    }

    modal.style.display = 'flex';
    setTimeout(() => {
        modal.classList.add('active');
    }, 10);
}

function confirmLogout() {
    localStorage.removeItem('user');
    window.location.href = '../index.html';
}

async function markAllNotificationsRead() {
    try {
        await fetchWithTimeout(`${API_URL}/notifications.php?action=mark_read`, {
            method: 'POST',
            body: JSON.stringify({}),
            credentials: 'include'
        });
        fetchNotifications();
    } catch (e) { console.error(e); }
}

async function handleNotificationClick(nId, relateId) {
    // 1. Mark as read
    try {
        await fetchWithTimeout(`${API_URL}/notifications.php?action=mark_read`, {
            method: 'POST',
            body: JSON.stringify({ id: nId }),
            credentials: 'include'
        });
        fetchNotifications();
    } catch (e) { }

    // 2. Action based on related Id
    if (relateId && typeof viewVoucher === 'function') {
        const modal = document.getElementById('viewVoucherModal');
        // Close dropdown
        const d = document.getElementById('notificationDropdown');
        if (d) d.style.display = 'none';

        // Wait a bit
        setTimeout(() => {
            // If we are on vouchers page or dashboard
            viewVoucher(relateId);
        }, 100);
    }
}


// ============================================
// FINSIGHT UI ENGINE (Toasts & Confirmations)
// ============================================

const Finsight = {
    init: function () {
        this.createToastContainer();
        this.createConfirmModal();
    },

    createToastContainer: function () {
        if (!document.getElementById('finsight-toast-container')) {
            const container = document.createElement('div');
            container.id = 'finsight-toast-container';
            document.body.appendChild(container);
        }
    },

    createConfirmModal: function () {
        if (!document.getElementById('finsight-confirm-modal')) {
            const modal = document.createElement('div');
            modal.id = 'finsight-confirm-modal';
            modal.className = 'modal';
            modal.innerHTML = `
                <div class="modal-content" style="max-width: 450px; text-align: center; padding: 32px;">
                    <div class="confirm-icon-wrapper" id="confirmIcon" style="width: 64px; height: 64px; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center; border-radius: 50%; background: #fee2e2; color: #ef4444; font-size: 28px;">
                        <i class="fas fa-exclamation-triangle"></i>
                    </div>
                    <h3 class="confirm-title" id="confirmTitle" style="font-size: 20px; font-weight: 700; color: var(--text-main); margin-bottom: 8px;">Confirmation</h3>
                    <p class="confirm-message" id="confirmMessage" style="font-size: 15px; color: var(--text-muted); margin-bottom: 24px; line-height: 1.5;">Are you sure?</p>
                    <div class="confirm-actions" style="display: flex; justify-content: center; gap: 12px;">
                        <button class="btn btn-secondary" id="confirmCancelBtn" style="min-width: 100px;">Cancel</button>
                        <button class="btn btn-danger" id="confirmOkBtn" style="min-width: 100px;">Confirm</button>
                    </div>
                </div>
            `;
            document.body.appendChild(modal);
        }
    },

    toast: function (options) {
        const { title, message, type = 'info', duration = 3000 } = options;
        this.createToastContainer();

        const container = document.getElementById('finsight-toast-container');
        const toast = document.createElement('div');

        let iconClass = 'fa-info-circle';
        let borderColor = '#3b82f6';
        let iconColor = '#3b82f6';

        if (type === 'success') { iconClass = 'fa-check-circle'; borderColor = '#10b981'; iconColor = '#10b981'; }
        if (type === 'error') { iconClass = 'fa-times-circle'; borderColor = '#ef4444'; iconColor = '#ef4444'; }
        if (type === 'warning') { iconClass = 'fa-exclamation-triangle'; borderColor = '#f59e0b'; iconColor = '#f59e0b'; }

        toast.className = `finsight-toast ${type}`;
        toast.style.cssText = `
            pointer-events: auto;
            min-width: 300px;
            max-width: 400px;
            background: white;
            border-radius: 8px;
            padding: 16px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            border-left: 4px solid ${borderColor};
            display: flex;
            align-items: flex-start;
            gap: 12px;
            margin-bottom: 12px;
            animation: fadeIn 0.3s ease-out;
            opacity: 1;
            transform: translateX(0);
            transition: all 0.3s ease;
        `;

        // Dark mode manual check
        if (document.body.getAttribute('data-theme') === 'dark') {
            toast.style.background = '#1e293b';
            toast.style.color = '#f1f5f9';
        }

        toast.innerHTML = `
            <div class="finsight-toast-icon" style="font-size: 20px; color: ${iconColor}; padding-top: 2px;"><i class="fas ${iconClass}"></i></div>
            <div class="finsight-toast-content" style="flex: 1;">
                <div class="finsight-toast-title" style="font-weight: 700; font-size: 14px; margin-bottom: 2px; color: inherit;">${title || type.toUpperCase()}</div>
                <div class="finsight-toast-message" style="font-size: 13px; opacity: 0.8; line-height: 1.4;">${message}</div>
            </div>
            <button onclick="this.parentElement.remove()" style="background:none; border:none; color:inherit; cursor:pointer; font-size:16px; opacity:0.5;"><i class="fas fa-times"></i></button>
        `;

        container.appendChild(toast);

        if (duration > 0) {
            setTimeout(() => {
                toast.style.opacity = '0';
                toast.style.transform = 'translateX(100%)';
                setTimeout(() => toast.remove(), 300);
            }, duration);
        }
    },

    confirm: function (message, onConfirm, options = {}) {
        this.createConfirmModal();
        const modal = document.getElementById('finsight-confirm-modal');

        document.getElementById('confirmTitle').textContent = options.title || 'Confirmation';
        document.getElementById('confirmMessage').textContent = message;

        const okBtn = document.getElementById('confirmOkBtn');
        const cancelBtn = document.getElementById('confirmCancelBtn');

        okBtn.textContent = options.confirmText || 'Confirm';
        cancelBtn.textContent = (options.cancelText || 'Cancel');

        const newOk = okBtn.cloneNode(true);
        okBtn.parentNode.replaceChild(newOk, okBtn);
        const newCancel = cancelBtn.cloneNode(true);
        cancelBtn.parentNode.replaceChild(newCancel, cancelBtn);

        const icon = document.getElementById('confirmIcon');
        if (options.type === 'primary') {
            newOk.className = 'btn btn-primary';
            newOk.style.backgroundColor = '#10b981';
            icon.style.backgroundColor = '#dcfce7';
            icon.style.color = '#10b981';
            icon.innerHTML = '<i class="fas fa-check-circle"></i>';
        } else {
            newOk.className = 'btn btn-danger';
            newOk.style.backgroundColor = '#ef4444';
            icon.style.backgroundColor = '#fee2e2';
            icon.style.color = '#ef4444';
            icon.innerHTML = '<i class="fas fa-exclamation-triangle"></i>';
        }

        newOk.onclick = () => { if (onConfirm) onConfirm(); this.closeConfirm(); };
        newCancel.onclick = () => { this.closeConfirm(); };

        modal.classList.add('active');
        modal.style.display = 'flex';
    },

    closeConfirm: function () {
        const modal = document.getElementById('finsight-confirm-modal');
        if (modal) {
            modal.classList.remove('active');
            setTimeout(() => { modal.style.display = 'none'; }, 200);
        }
    }
};

document.addEventListener('DOMContentLoaded', () => { Finsight.init(); });

document.addEventListener('DOMContentLoaded', () => { initAdminDashboard(); });
