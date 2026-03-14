// Dynamic API_URL to support different ports (80, 8080, etc.)
const API_URL = typeof DB_API_URL !== 'undefined' ? DB_API_URL : (window.location.pathname.includes('/pages/') ? '../api' : 'api');

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
    if (currentUser.role === 'admin') loadAdminStats();
    if (currentUser.role === 'accountant') loadAccountantStats(); // We'll add this
}

function renderSidebar(role) {
    const nav = document.querySelector('.sidebar-nav');
    if (!nav) return;

    const currentPage = window.location.pathname.split('/').pop();

    let items = [];
    if (role === 'admin' || role === 'manager') {
        items = [
            { icon: 'fa-home', text: 'Home', href: '../index.html' },
            { icon: 'fa-columns', text: 'Dashboard', href: 'dashboard.html' },
            { icon: 'fa-users', text: 'Users', href: 'users.html' },
            { icon: 'fa-sitemap', text: 'Accounts', href: 'accounts.html' },
            { icon: 'fa-receipt', text: 'Vouchers', href: 'vouchers.html' },
            { icon: 'fa-chart-pie', text: 'Reports', href: 'reports.html' },
            { icon: 'fa-cog', text: 'Settings', href: 'settings.html' }
        ];
    } else if (role === 'accountant') {
        items = [
            // No Home link required by user spec ("only need... dashboard, accounts...")
            { icon: 'fa-columns', text: 'Dashboard', href: 'accountant.html' },
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
    // Basic placeholder stats for accountant
    const v = getMockVouchers();
    const draft = v.filter(x => x.status === 'Draft').length;
    const posted = v.filter(x => x.status === 'Posted').length;
    const rejected = v.filter(x => x.status === 'Rejected').length;

    if (document.getElementById('stat-draft-vouchers')) document.getElementById('stat-draft-vouchers').textContent = draft;
    if (document.getElementById('stat-posted-vouchers')) document.getElementById('stat-posted-vouchers').textContent = posted;
    if (document.getElementById('stat-rejected-vouchers')) document.getElementById('stat-rejected-vouchers').textContent = rejected;
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
            fetchWithTimeout(`${API_URL}/reports.php?action=profit-loss`, { timeout: 3000, credentials: 'include' })
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
        if (confirm(`Are you sure you want to ${action} ${userName}?`)) {
            // Optimistically set it to the new state
            checkbox.checked = isActivating;

            if (isActivating) {
                activateUserAPI(userId);
            } else {
                deactivateUserAPI(userId);
            }
        }
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
    Finsight.confirm(
        `Are you sure you want to delete account "${accountName}"? This action cannot be undone.`,
        () => deleteAccount(accountId),
        { title: 'Delete Account', confirmText: 'Delete', type: 'danger' }
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
            alert('✓ Account deleted successfully!');
            loadAccountsWithType();
            return;
        } else {
            if (data.message && data.message.toLowerCase().includes('existing transactions')) {
                if (confirm('❌ Delete failed: Account has existing transactions.\n\nWould you like to DEACTIVATE this account instead?')) {
                    deactivateAccountAPI(accountId);
                }
            } else {
                alert('❌ Delete failed: ' + (data.message || 'Unknown error'));
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
        if (confirm(`Are you sure you want to ${action} account "${accountName}"?`)) {
            checkbox.checked = isActivating; // Optimistically set
            if (isActivating) {
                activateAccountAPI(accountId);
            } else {
                deactivateAccountAPI(accountId);
            }
        }
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
    if (confirm(`Are you sure you want to PERMANENTLY DELETE user ${userName}? This action cannot be undone.`)) {
        deleteUserAPI(userId);
    }
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

    // Handle data structure: could be array or object with transactions
    let entries = [];
    let openingBalance = 0;

    if (Array.isArray(data)) {
        entries = data;
    } else if (data && typeof data === 'object') {
        entries = data.transactions || [];
        openingBalance = parseFloat(data.opening_balance) || 0;
    }

    // Update Opening Balance
    const obEl = document.getElementById('ledgerOpeningBalance');
    if (obEl) obEl.textContent = formatCurrency(openingBalance);

    if (!entries || entries.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="text-center">No transactions found</td></tr>';
        // Zero out totals but keep OB
        if (document.getElementById('ledgerTotalDebit')) document.getElementById('ledgerTotalDebit').textContent = formatCurrency(0);
        if (document.getElementById('ledgerTotalCredit')) document.getElementById('ledgerTotalCredit').textContent = formatCurrency(0);
        return;
    }

    let runningBalance = openingBalance;
    let totalDebit = 0;
    let totalCredit = 0;

    entries.forEach(entry => {
        const date = entry.date || entry.voucher_date || entry.created_at;
        const desc = entry.description || entry.narration || entry.particulars || '-';
        const vNo = entry.voucher_number || entry.id || '-';
        const debit = parseFloat(entry.debit) || 0;
        const credit = parseFloat(entry.credit) || 0;

        runningBalance += (debit - credit);
        totalDebit += debit;
        totalCredit += credit;

        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${formatDate(date)}</td>
            <td>${vNo}</td>
            <td>${desc}</td>
            <td class="text-right">${debit > 0 ? formatCurrency(debit) : '-'}</td>
            <td class="text-right">${credit > 0 ? formatCurrency(credit) : '-'}</td>
            <td class="text-right" style="color: ${runningBalance >= 0 ? 'var(--secondary-color)' : 'var(--primary-color)'}">
                <strong>${formatCurrency(Math.abs(runningBalance))} ${runningBalance >= 0 ? 'Dr' : 'Cr'}</strong>
            </td>
        `;
        tbody.appendChild(row);
    });

    // Update Totals
    if (document.getElementById('ledgerTotalDebit')) document.getElementById('ledgerTotalDebit').textContent = formatCurrency(totalDebit);
    if (document.getElementById('ledgerTotalCredit')) document.getElementById('ledgerTotalCredit').textContent = formatCurrency(totalCredit);
    if (document.getElementById('ledgerFooterDebit')) document.getElementById('ledgerFooterDebit').textContent = formatCurrency(totalDebit);
    if (document.getElementById('ledgerFooterCredit')) document.getElementById('ledgerFooterCredit').textContent = formatCurrency(totalCredit);
    if (document.getElementById('ledgerClosingBalance')) document.getElementById('ledgerClosingBalance').textContent = formatCurrency(Math.abs(runningBalance)) + (runningBalance >= 0 ? ' Dr' : ' Cr');
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
    const selects = document.querySelectorAll('.account-select');
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
        const accountSelect = row.querySelector('.account-select');
        const debitInput = row.querySelector('.debit-amount');
        const creditInput = row.querySelector('.credit-amount');

        if (accountSelect && accountSelect.value) {
            const debit = parseFloat(debitInput.value) || 0;
            const credit = parseFloat(creditInput.value) || 0;
            if (debit > 0 || credit > 0) {
                entries.push({
                    account_id: accountSelect.value,
                    account_name: accountSelect.options[accountSelect.selectedIndex].text,
                    debit: debit,
                    credit: credit
                });
                totalDebit += debit;
                totalCredit += credit;
            }
        }
    });

    if (entries.length < 2) {
        alert('At least two entries are required for a valid voucher.');
        return;
    }

    if (Math.abs(totalDebit - totalCredit) > 0.01) {
        alert('Voucher is not balanced. Total Debit must equal Total Credit.');
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
        const res = await fetchWithTimeout(`${API_URL}/vouchers.php?action=post`, {
            method: 'POST',
            body: JSON.stringify({ voucher_id: id }),
            credentials: 'include'
        });
        const data = await res.json();
        if (data.success) {
            alert('✓ Voucher Posted Successfully!');
            closeModal('viewVoucherModal');
            loadVouchers();
        } else {
            alert('❌ Approval Failed: ' + data.message);
        }
    } catch (e) {
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
        const res = await fetchWithTimeout(`${API_URL}/vouchers.php?action=reject`, {
            method: 'POST',
            body: JSON.stringify({ voucher_id: id, reason: reason }),
            credentials: 'include'
        });
        const data = await res.json();
        if (data.success) {
            alert('✓ Voucher Rejected. Accountant has been notified.');
            closeModal('viewVoucherModal'); // Close the view modal too
            loadVouchers();
        } else {
            alert('❌ Rejection Failed: ' + data.message);
        }
    } catch (e) {
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

// --- Dynamic Reporting Logic ---
async function generateDynamicReport(type) {
    const container = document.getElementById('report-container');
    if (!container) return;

    container.innerHTML = '<div class="text-center"><i class="fas fa-spinner fa-spin"></i> Generating report...</div>';

    // Fetch data
    let accounts = [];
    try {
        const res = await fetchWithTimeout(`${API_URL}/accounts.php?action=list`, { timeout: 3000, credentials: 'include' });
        const data = await res.json();
        if (data.success) accounts = data.data;
    } catch (err) {
        console.warn('API fail, using mock accounts for report');
        accounts = getMockAccounts();
    }

    if (!accounts || accounts.length === 0) {
        container.innerHTML = '<div class="text-center">No account data found to generate report.</div>';
        return;
    }

    const today = new Date().toLocaleDateString('en-IN', { year: 'numeric', month: 'long', day: 'numeric' });
    let content = '';

    if (type === 'trial-balance') {
        let totalDebit = 0;
        let totalCredit = 0;

        const rows = accounts.map(acc => {
            const balance = parseFloat(acc.balance) || 0;
            // Simplified: Assets/Expenses are Debit, Liabilities/Equity/Income are Credit for TB
            const isDebitSide = (acc.type === 'Asset' || acc.type === 'Expense');
            if (isDebitSide) totalDebit += balance;
            else totalCredit += balance;

            return `
                <tr>
                    <td>${acc.code} - ${acc.name}</td>
                    <td class="text-right">${isDebitSide ? formatCurrency(balance) : '-'}</td>
                    <td class="text-right">${!isDebitSide ? formatCurrency(balance) : '-'}</td>
                </tr>
            `;
        }).join('');

        content = `
            <div class="report-view animate-fadeIn">
                <div class="report-header text-center" style="margin-bottom: 30px;">
                    <h2 style="font-size: 24px; color: var(--text-main);">Trial Balance</h2>
                    <p class="text-muted">As of ${today}</p>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Account Name</th>
                            <th class="text-right">Debit</th>
                            <th class="text-right">Credit</th>
                        </tr>
                    </thead>
                    <tbody>${rows}</tbody>
                    <tfoot>
                        <tr style="background: var(--bg-body); font-weight: 800; border-top: 2px solid var(--text-main);">
                            <td>TOTAL</td>
                            <td class="text-right" style="color: var(--primary-color);">${formatCurrency(totalDebit)}</td>
                            <td class="text-right" style="color: var(--primary-color);">${formatCurrency(totalCredit)}</td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        `;
    } else if (type === 'profit-loss') {
        const income = accounts.filter(a => a.type === 'Income');
        const expense = accounts.filter(a => a.type === 'Expense');

        const totalIncome = income.reduce((sum, a) => sum + (parseFloat(a.balance) || 0), 0);
        const totalExpense = expense.reduce((sum, a) => sum + (parseFloat(a.balance) || 0), 0);
        const netProfit = totalIncome - totalExpense;

        content = `
            <div class="report-view animate-fadeIn">
                <div class="report-header text-center" style="margin-bottom: 30px;">
                    <h2 style="font-size: 24px; color: var(--text-main);">Profit & Loss Account</h2>
                    <p class="text-muted">For the period ending ${today}</p>
                </div>
                <div style="max-width: 800px; margin: 0 auto;">
                    <table class="data-table">
                        <thead><tr><th>Particulars</th><th class="text-right">Amount</th></tr></thead>
                        <tbody>
                            <tr style="background: #f8fafc;"><td colspan="2"><strong>Incomes</strong></td></tr>
                            ${income.map(a => `<tr><td>${a.name}</td><td class="text-right" style="color: var(--secondary-color);">+ ${formatCurrency(Math.abs(a.balance))}</td></tr>`).join('')}
                            <tr style="background: var(--primary-light); font-weight: 700;"><td>Total Income</td><td class="text-right">${formatCurrency(totalIncome)}</td></tr>
                            
                            <tr style="background: #f8fafc; margin-top: 20px;"><td colspan="2"><strong>Expenses</strong></td></tr>
                            ${expense.map(a => `<tr><td>${a.name}</td><td class="text-right" style="color: var(--danger-color);">- ${formatCurrency(Math.abs(a.balance))}</td></tr>`).join('')}
                            <tr style="background: var(--primary-light); font-weight: 700;"><td>Total Expenses</td><td class="text-right">${formatCurrency(totalExpense)}</td></tr>
                            
                            <tr style="background: var(--bg-body); font-weight: 800; border-top: 2px solid ${netProfit >= 0 ? 'var(--secondary-color)' : 'var(--danger-color)'};">
                                <td style="font-size: 18px;">NET ${netProfit >= 0 ? 'PROFIT' : 'LOSS'}</td>
                                <td class="text-right" style="font-size: 18px; color: ${netProfit >= 0 ? 'var(--secondary-color)' : 'var(--danger-color)'}">${formatCurrency(netProfit)}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        `;
    } else if (type === 'balance-sheet') {
        const assets = accounts.filter(a => a.type === 'Asset');
        const liabilities = accounts.filter(a => a.type === 'Liability');
        const equity = accounts.filter(a => a.type === 'Equity');

        // Calculate Net Profit for Balance Sheet integration
        const totalIncome = accounts.filter(a => a.type === 'Income').reduce((sum, a) => sum + (parseFloat(a.balance) || 0), 0);
        const totalExpense = accounts.filter(a => a.type === 'Expense').reduce((sum, a) => sum + (parseFloat(a.balance) || 0), 0);
        const netProfit = totalIncome - totalExpense;

        const totalAssets = assets.reduce((sum, a) => sum + (parseFloat(a.balance) || 0), 0);
        const totalLiabEqui = liabilities.reduce((sum, a) => sum + (parseFloat(a.balance) || 0), 0) +
            equity.reduce((sum, a) => sum + (parseFloat(a.balance) || 0), 0) +
            netProfit;

        content = `
            <div class="report-view animate-fadeIn">
                <div class="report-header text-center" style="margin-bottom: 30px;">
                    <h2 style="font-size: 24px; color: var(--text-main);">Balance Sheet</h2>
                    <p class="text-muted">As of ${today}</p>
                </div>
                
                <div class="charts-grid" style="grid-template-columns: 1fr 1fr; gap: 32px; align-items: start;">
                    <div class="report-section">
                        <div style="padding: 10px; background: var(--primary-color); color: white; border-radius: 8px 8px 0 0; font-weight: 700;">ASSETS</div>
                        <table class="data-table">
                            <tbody>
                                ${assets.map(a => `<tr><td>${a.name}</td><td class="text-right">${formatCurrency(a.balance)}</td></tr>`).join('')}
                                <tr style="background: var(--bg-body); font-weight: 800;"><td>TOTAL ASSETS</td><td class="text-right">${formatCurrency(totalAssets)}</td></tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="report-section">
                        <div style="padding: 10px; background: var(--secondary-color); color: white; border-radius: 8px 8px 0 0; font-weight: 700;">LIABILITIES & EQUITY</div>
                        <table class="data-table">
                            <tbody>
                                <tr style="background: #f8fafc;"><td colspan="2"><strong>Liabilities</strong></td></tr>
                                ${liabilities.map(a => `<tr><td>${a.name}</td><td class="text-right">${formatCurrency(a.balance)}</td></tr>`).join('')}
                                
                                <tr style="background: #f8fafc;"><td colspan="2"><strong>Equity</strong></td></tr>
                                ${equity.map(a => `<tr><td>${a.name}</td><td class="text-right">${formatCurrency(a.balance)}</td></tr>`).join('')}
                                <tr><td>Retained Earnings (Net Profit)</td><td class="text-right">${formatCurrency(netProfit)}</td></tr>
                                
                                <tr style="background: var(--bg-body); font-weight: 800;"><td>TOTAL LIABILITIES & EQUITY</td><td class="text-right">${formatCurrency(totalLiabEqui)}</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                ${Math.abs(totalAssets - totalLiabEqui) > 1 ? `<div style="margin-top:20px; color: var(--danger-color); text-align:center;"><i class="fas fa-exclamation-triangle"></i> Balance sheet out of balance by ${formatCurrency(Math.abs(totalAssets - totalLiabEqui))}</div>` : ''}
            </div>
        `;
    }

    container.innerHTML = content;
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
    // Try to find header actions
    const headerActions = document.querySelector('.header-actions');
    let bellBtn = document.getElementById('notificationBtn');

    if (!bellBtn && headerActions) {
        // Try to find specific button with bell icon
        const icons = headerActions.querySelectorAll('.btn-icon, button');
        icons.forEach(btn => {
            if (btn.querySelector('.fa-bell')) bellBtn = btn;
        });
    }

    if (!bellBtn) {
        // Fallback: search entire document for any button with fa-bell
        // This handles cases where header structure might be slightly different
        const bells = document.querySelectorAll('.fa-bell');
        for (let i = 0; i < bells.length; i++) {
            const btn = bells[i].closest('button');
            if (btn) {
                bellBtn = btn;
                break;
            }
        }
    }

    if (!bellBtn) {
        // Aggressive Fallback
        const icon = document.querySelector('.fa-bell');
        if (icon) bellBtn = icon.closest('button');
    }

    if (!bellBtn) {
        console.warn('Notification bell button not found');
        return;
    }

    // Clear any existing listeners to be safe (cloning)
    const newBtn = bellBtn.cloneNode(true);
    bellBtn.parentNode.replaceChild(newBtn, bellBtn);
    bellBtn = newBtn;
    bellBtn.id = 'notificationBtn'; // Force ID

    console.log('Notification button initialized successfully:', bellBtn);

    // Ensure badge element exists
    let badge = bellBtn.querySelector('.notification-badge');
    if (!badge) {
        badge = document.createElement('span');
        badge.className = 'notification-badge';
        bellBtn.appendChild(badge);
    }

    // Create Dropdown
    let dropdown = document.getElementById('notificationDropdown');
    if (!dropdown) {
        dropdown = document.createElement('div');
        dropdown.id = 'notificationDropdown';
        dropdown.style.cssText = `
            position: absolute;
            top: 70px;
            right: 100px;
            width: 350px;
            background: white;
            border: 1px solid #e1e4e8;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            display: none;
            z-index: 9999;
            overflow: hidden;
            animation: fadeIn 0.1s ease;
        `;

        // ... inside initNotifications ...
        dropdown.innerHTML = `
            <div style="padding: 15px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; background: #f8fafc;">
                <h4 style="margin: 0; font-size: 14px; color: #333; font-weight: 600;">Notifications</h4>
                <button onclick="markAllNotificationsRead()" style="border: none; background: none; color: #2563eb; font-size: 12px; cursor: pointer; font-weight: 500;">Mark all read</button>
            </div>
            <div id="notificationList" style="max-height: 400px; overflow-y: auto; background: white; min-height: 100px;">
                <div style="padding: 20px; text-align: center; color: #64748b; font-size: 13px;">
                    <i class="fas fa-sync fa-spin"></i> Loading Notifications...
                </div>
            </div>
        `;

        // ...
        document.body.appendChild(dropdown);
    }

    // Toggle Dropdown (FIX: Added missing click handler)
    bellBtn.onclick = (e) => {
        e.preventDefault();
        e.stopPropagation(); // Prevent conflict with dashboard.js

        const rect = bellBtn.getBoundingClientRect();
        dropdown.style.top = (rect.bottom + 10) + 'px';
        dropdown.style.right = (window.innerWidth - rect.right) + 'px';

        if (dropdown.style.display === 'block') {
            dropdown.style.display = 'none';
        } else {
            dropdown.style.display = 'block';
            // Refresh on open
            fetchNotifications();
        }
    };

    // Close on click outside
    document.addEventListener('click', (e) => {
        if (!dropdown.contains(e.target) && !bellBtn.contains(e.target)) {
            dropdown.style.display = 'none';
        }
    });

    // Start Polling with initial visual Loading if needed
    fetchNotifications();
    setInterval(fetchNotifications, 15000);
}

async function fetchNotifications() {
    try {
        // Use window.fetchWithTimeout explicitly if needed, or rely on the polyfill availability
        const res = await fetchWithTimeout(`${API_URL}/notifications.php?action=list`, { credentials: 'include' });

        if (!res.ok) throw new Error(`HTTP Error ${res.status}`);

        const data = await res.json();

        if (data.success) {
            _notifState.list = data.data.notifications || [];
            _notifState.unread = data.data.unread_count || 0;
            renderNotifications();
        } else {
            console.warn('API returned success=false for notifications');
            // Check if lists are actually empty/errored
            const list = document.getElementById('notificationList');
            if (list && _notifState.list.length === 0) {
                list.innerHTML = `<div style="padding: 20px; text-align: center; color: #64748b; font-size: 13px;">No notifications found</div>`;
            }
        }
    } catch (e) {
        console.error('Fetch notifications failed:', e);
        console.log('Attempted URL:', `${API_URL}/notifications.php?action=list`);
        // If fail, show error in list if empty
        const list = document.getElementById('notificationList');
        if (list && _notifState.list.length === 0) {
            list.innerHTML = `
                <div style="padding: 20px; text-align: center; color: #ef4444; font-size: 13px;">
                    <i class="fas fa-exclamation-circle"></i> Failed to load<br>
                    <button onclick="fetchNotifications()" style="margin-top:10px; padding:5px 10px; cursor:pointer; background:#fff; border:1px solid #ddd; border-radius:4px;">Retry</button>
                </div>`;
        }
    }
}

function renderNotifications() {
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
    if (!list) return;

    if (_notifState.list.length === 0) {
        list.innerHTML = `<div style="padding: 30px; text-align: center; color: #999; font-size: 13px;">No notifications</div>`;
        return;
    }

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
    return Math.floor(hours / 24) + 'd ago';
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

