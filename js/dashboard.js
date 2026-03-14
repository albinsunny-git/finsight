// Reliable API URL resolution
const BASE_PATH = window.location.pathname.includes('/finsight') ? '/finsight' : '';
const API_URL = `${BASE_PATH}/api`;
const DB_API_URL = API_URL;

// ============================================
// GLOBAL ALERT OVERRIDE
// ============================================
window.alert = function (message) {
    if (document.getElementById('customAlertModal')) return;

    // Detect message type roughly
    let type = 'info';
    let icon = 'fa-info-circle';
    let iconColor = 'var(--primary-color)';
    let iconBg = 'var(--primary-light)';
    let title = 'Notification';

    const msgLower = (message || '').toLowerCase();
    if (msgLower.includes('fail') || msgLower.includes('error') || msgLower.includes('required') || message.includes('❌')) {
        type = 'error';
        icon = 'fa-exclamation-triangle';
        iconColor = '#ef4444';
        iconBg = '#fee2e2';
        title = 'Wait a moment';
    } else if (msgLower.includes('success') || message.includes('✓')) {
        type = 'success';
        icon = 'fa-check-circle';
        iconColor = '#10b981';
        iconBg = '#d1fae5';
        title = 'Success!';
    } else if (msgLower.includes('warning') || msgLower.includes('careful')) {
        type = 'warning';
        icon = 'fa-exclamation-circle';
        iconColor = '#f59e0b';
        iconBg = '#fef3c7';
        title = 'Warning';
    }

    // Clean up Emojis from string if they exist to prevent double visual cues
    const cleanMessage = message.replace(/[❌✓]/g, '').trim();

    const alertHtml = `
        <div id="customAlertModal" class="modal active" style="z-index: 9999; backdrop-filter: blur(8px); background: rgba(15, 23, 42, 0.4);">
            <div class="modal-content" style="max-width: 420px; padding: 40px 30px; text-align: center; border-radius: 24px; animation: alertPopIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); border: 1px solid rgba(255,255,255,0.7);">
                
                <div style="width: 80px; height: 80px; background: ${iconBg}; color: ${iconColor}; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 34px; margin: 0 auto 24px auto; box-shadow: 0 8px 24px ${iconBg}; border: 4px solid white;">
                    <i class="fas ${icon}"></i>
                </div>
                
                <h3 style="margin: 0 0 12px 0; font-size: 1.4rem; font-weight: 800; color: var(--text-main); letter-spacing: -0.5px;">${title}</h3>
                
                <p style="color: var(--text-muted); font-size: 1.05rem; line-height: 1.6; margin: 0 0 30px 0;">${cleanMessage}</p>
                
                <button id="customAlertBtn" class="btn btn-primary" style="width: 100%; justify-content: center; padding: 14px; font-weight: 700; font-size: 1.05rem; border-radius: 14px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); transition: all 0.2s; background: ${iconColor}; border-color: ${iconColor};">
                    Okay, got it
                </button>
            </div>
            <style>
                @keyframes alertPopIn { 
                    0% { transform: scale(0.7) translateY(30px); opacity: 0; } 
                    60% { transform: scale(1.05) translateY(-5px); opacity: 1; }
                    100% { transform: scale(1) translateY(0); opacity: 1; } 
                }
            </style>
        </div>
    `;

    document.body.insertAdjacentHTML('beforeend', alertHtml);

    const btn = document.getElementById('customAlertBtn');
    if (btn) btn.focus();

    const closeModalLogic = () => {
        const modal = document.getElementById('customAlertModal');
        if (modal) {
            modal.style.animation = 'none';
            modal.style.opacity = '0';
            modal.style.transform = 'scale(0.95)';
            modal.style.transition = 'all 0.2s ease-out';
            setTimeout(() => modal.remove(), 200);
        }
    };

    if (btn) btn.addEventListener('click', closeModalLogic);
};

// ============================================
// GLOBAL SETTINGS APPLIER
// ============================================

// Apply saved settings on every page load
function applyGlobalSettings() {
    // Appearance Settings
    const appearance = JSON.parse(localStorage.getItem('appearance_settings') || '{}');

    // Apply Theme
    const theme = appearance.theme || 'light';
    document.documentElement.setAttribute('data-theme', theme);

    // Apply Accent Color
    const accentColor = appearance.accentColor || '#ef4444';
    document.documentElement.style.setProperty('--primary-color', accentColor);
    document.documentElement.style.setProperty('--primary-hover', adjustColorBrightness(accentColor, -15));
    document.documentElement.style.setProperty('--primary-light', hexToRgba(accentColor, 0.1));

    // Apply Font Size
    const fontSize = appearance.fontSize || 14;
    document.documentElement.style.setProperty('--base-font-size', fontSize + 'px');

    // Apply Compact Mode
    if (appearance.compactMode) {
        document.body.classList.add('compact-mode');
    } else {
        document.body.classList.remove('compact-mode');
    }
}

// Helper: Adjust color brightness
function adjustColorBrightness(color, percent) {
    const num = parseInt(color.replace('#', ''), 16);
    const amt = Math.round(2.55 * percent);
    const R = Math.max(0, Math.min(255, (num >> 16) + amt));
    const G = Math.max(0, Math.min(255, (num >> 8 & 0x00FF) + amt));
    const B = Math.max(0, Math.min(255, (num & 0x0000FF) + amt));
    return '#' + (0x1000000 + R * 0x10000 + G * 0x100 + B).toString(16).slice(1);
}

// Helper: Convert hex to rgba
function hexToRgba(hex, alpha) {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

// ============================================
// UTILITY FUNCTIONS
// ============================================

// Utility: Format Currency (uses saved preferences)
function formatCurrency(amount) {
    const prefs = JSON.parse(localStorage.getItem('app_preferences') || '{}');
    const currency = prefs.currency || 'INR';

    const localeMap = {
        'INR': 'en-IN',
        'USD': 'en-US',
        'EUR': 'de-DE',
        'GBP': 'en-GB',
        'AED': 'ar-AE',
        'JPY': 'ja-JP'
    };

    return new Intl.NumberFormat(localeMap[currency] || 'en-IN', {
        style: 'currency',
        currency: currency,
        minimumFractionDigits: 2
    }).format(amount);
}

// Utility: Format Date (uses saved preferences)
function formatDate(dateStr) {
    if (!dateStr) return '';
    const prefs = JSON.parse(localStorage.getItem('app_preferences') || '{}');
    const format = prefs.dateFormat || 'DD/MM/YYYY';
    const date = new Date(dateStr);

    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const monthName = monthNames[date.getMonth()];

    switch (format) {
        case 'MM/DD/YYYY':
            return `${month}/${day}/${year}`;
        case 'YYYY-MM-DD':
            return `${year}-${month}-${day}`;
        case 'DD-MMM-YYYY':
            return `${day}-${monthName}-${year}`;
        default: // DD/MM/YYYY
            return `${day}/${month}/${year}`;
    }
}

// Utility: Get timezone offset for display
function getTimezone() {
    const prefs = JSON.parse(localStorage.getItem('app_preferences') || '{}');
    return prefs.timezone || 'Asia/Kolkata';
}

// Utility: Fetch with Timeout with Global Auth Error Handling
async function fetchWithTimeout(resource, options = {}) {
    const { timeout = 8000 } = options;
    const controller = new AbortController();
    const id = setTimeout(() => controller.abort(), timeout);

    const fetchOptions = {
        credentials: 'include',
        ...options,
        signal: controller.signal
    };

    try {
        const response = await fetch(resource, fetchOptions);
        clearTimeout(id);

        // Global check for 401 Unauthorized
        if (response.status === 401) {
            console.error('Session expired or unauthorized. Redirecting to login...');
            localStorage.removeItem('user');
            // Redirect to home/login
            const currentPath = window.location.pathname;
            const prefix = currentPath.includes('/pages/') ? '../' : '';
            window.location.href = prefix + 'index.html?error=session_expired';
        }

        return response;
    } catch (error) {
        clearTimeout(id);
        throw error;
    }
}

// ============================================
// MAIN INITIALIZATION
// ============================================

document.addEventListener('DOMContentLoaded', () => {
    // Apply global settings first (theme, colors, etc.)
    applyGlobalSettings();

    // Check Auth
    const userStr = localStorage.getItem('user');
    if (!userStr) {
        if (!window.location.pathname.includes('index.html') &&
            !window.location.pathname.includes('login.html') &&
            !window.location.pathname.includes('reset-password.html') &&
            !window.location.pathname.includes('forgot-password.html')) {
            window.location.href = '../index.html';
        }
    } else {
        const user = JSON.parse(userStr);
        updateUserProfile(user);
    }

    if (document.querySelector('canvas')) {
        initCharts();
    }

    // Auto-load stats if elements exist
    if (document.getElementById('stat-users')) {
        loadDashboardData();
    }

    // Initialize Notifications
    fetchNotifications();
    setInterval(fetchNotifications, 60000); // Poll every minute

    // Initialize Mobile Sidebar Toggle
    const mobileToggle = document.getElementById('mobileToggle');
    const sidebar = document.querySelector('.sidebar');
    
    // Create overlay if it doesn't exist
    let overlay = document.querySelector('.sidebar-overlay');
    if (!overlay) {
        overlay = document.createElement('div');
        overlay.className = 'sidebar-overlay';
        document.body.appendChild(overlay);
    }

    if (mobileToggle && sidebar) {
        mobileToggle.addEventListener('click', () => {
            sidebar.classList.toggle('active');
            overlay.classList.toggle('active');
        });

        overlay.addEventListener('click', () => {
            sidebar.classList.remove('active');
            overlay.classList.remove('active');
        });
        
        // Close sidebar when clicking links on mobile
        const sidebarLinks = sidebar.querySelectorAll('.nav-link');
        sidebarLinks.forEach(link => {
            link.addEventListener('click', () => {
                if (window.innerWidth <= 1024) {
                    sidebar.classList.remove('active');
                    overlay.classList.remove('active');
                }
            });
        });
    }

    // Add notification click listener
    document.addEventListener('click', (e) => {
        const bellBtn = e.target.closest('.btn-icon');
        if (bellBtn && bellBtn.querySelector('.fa-bell')) {
            toggleNotifications(bellBtn);
        } else if (!e.target.closest('.notification-dropdown')) {
            // Close if clicked outside
            const dd = document.querySelector('.notification-dropdown');
            if (dd) dd.classList.remove('active');
        }
    });
});

async function fetchNotifications() {
    try {
        // If we are on dashboard, we might already have this from combined load
        const res = await fetchWithTimeout(`${DB_API_URL}/notifications.php?action=list`, { credentials: 'include' });
        const data = await res.json();
        if (data.success) {
            updateNotificationUI(data.data.notifications, data.data.unread_count);
        }
    } catch (e) {
        console.warn('Notification fetch failed', e);
    }
}

function updateNotificationUI(notifications, unreadCount) {
    const badge = document.querySelector('.notification-badge');
    if (badge) {
        if (unreadCount > 0) {
            badge.textContent = unreadCount;
            badge.style.display = 'block';
        } else {
            badge.style.display = 'none';
        }
    }

    // Update Dropdown Content if it exists
    const list = document.querySelector('.notification-list');
    if (list) {
        if (notifications.length === 0) {
            list.innerHTML = '<div style="padding:20px; text-align:center; color:var(--text-muted);">No new notifications</div>';
            return;
        }

        list.innerHTML = notifications.map(n => `
            <div class="notification-item ${n.is_read == 0 ? 'unread' : ''}" onclick="markAsRead(${n.id})">
                <div class="notification-icon">
                    <i class="fas ${getNotificationIcon(n.type)}"></i>
                </div>
                <div class="notification-content">
                    <div class="notification-text">${n.message}</div>
                    <div class="notification-time">${formatTimeAgo(n.created_at)}</div>
                </div>
            </div>
        `).join('');
    }
}

function getNotificationIcon(type) {
    switch (type) {
        case 'success': return 'fa-check-circle';
        case 'error': return 'fa-exclamation-circle';
        case 'warning': return 'fa-exclamation-triangle';
        default: return 'fa-info-circle';
    }
}

function formatTimeAgo(dateString) {
    const date = new Date(dateString);
    const now = new Date();
    const seconds = Math.floor((now - date) / 1000);

    if (seconds < 60) return 'Just now';
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes}m ago`;
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `${hours}h ago`;
    return formatDate(dateString);
}


function toggleNotifications(btn) {
    let dd = document.querySelector('.notification-dropdown');

    // Create dropdown if doesn't exist
    if (!dd) {
        const ddHtml = `
            <div class="notification-dropdown">
                <div class="notification-header">
                    <span>Notifications</span>
                    <button onclick="markAsRead()" style="background:none; border:none; color:var(--primary-color); cursor:pointer; font-size:12px;">Mark all read</button>
                </div>
                <div class="notification-list">
                    <div style="padding:20px; text-align:center;">Loading...</div>
                </div>
            </div>
        `;
        // Insert after button parent (header-actions) or body
        const container = document.querySelector('.header-actions');
        if (container) {
            container.style.position = 'relative';
            container.insertAdjacentHTML('beforeend', ddHtml);
            dd = container.querySelector('.notification-dropdown');
        }

        // Refresh data
        fetchNotifications();
    }

    dd.classList.toggle('active');
}

async function markAsRead(id = null) {
    try {
        await fetch(`${DB_API_URL}/notifications.php?action=mark_read`, {
            method: 'POST',
            body: JSON.stringify({ id: id }),
            credentials: 'include'
        });
        fetchNotifications(); // Refresh
    } catch (e) {
        console.error(e);
    }
}

// Update user profile display across all pages (header + sidebar)
function updateUserProfile(user) {
    // Header elements
    const nameEls = document.querySelectorAll('.user-name, #userName, #headerName');
    const roleEls = document.querySelectorAll('.user-role, #userRole');
    const avatarEls = document.querySelectorAll('.user-avatar, #userAvatar, #headerAvatar');

    // Sidebar elements
    const sidebarNameEls = document.querySelectorAll('.sidebar-user-name, #sidebarUserName');
    const sidebarRoleEls = document.querySelectorAll('.sidebar-user-role, #sidebarUserRole');
    const sidebarAvatarEls = document.querySelectorAll('.sidebar-user-avatar, #sidebarUserAvatar');

    const fullName = `${user.first_name} ${user.last_name}`;
    const roleText = user.role ? user.role.charAt(0).toUpperCase() + user.role.slice(1) : 'User';

    // Update header user info
    nameEls.forEach(el => el.textContent = fullName);
    roleEls.forEach(el => el.textContent = roleText);

    // Update sidebar user info
    sidebarNameEls.forEach(el => el.textContent = fullName);
    sidebarRoleEls.forEach(el => el.textContent = roleText);

    // Load profile photo if exists
    const profilePhoto = localStorage.getItem('profile_photo');

    // Update header avatars
    avatarEls.forEach(el => {
        if (profilePhoto) {
            el.innerHTML = `<img src="${profilePhoto}" alt="Profile" style="width: 100%; height: 100%; border-radius: 50%; object-fit: cover; display: block;">`;
        } else {
            el.textContent = (user.first_name || 'U').charAt(0).toUpperCase();
            el.innerHTML = el.textContent;
        }
    });

    // Update sidebar avatars
    sidebarAvatarEls.forEach(el => {
        if (profilePhoto) {
            el.innerHTML = `<img src="${profilePhoto}" alt="Profile" style="width: 100%; height: 100%; border-radius: 50%; object-fit: cover; display: block;">`;
        } else {
            el.textContent = (user.first_name || 'U').charAt(0).toUpperCase();
            el.innerHTML = el.textContent;
        }
    });
}

// Logout with Modal
// Logout with Dynamic Modal
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
                    <h2 style="font-size: 24px; font-weight: 800; color: var(--text-main); margin-bottom: 12px;">Log Out?</h2>
                    <p style="color: var(--text-muted); margin-bottom: 32px; font-size: 15px; line-height: 1.6;">Are you sure you want to end your session? You will be redirected to the login page.</p>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <button onclick="closeModal('logoutModal')" class="btn" style="padding: 12px; border-radius: 12px; font-weight: 600; background: var(--bg-body); color: var(--text-main); border: 1px solid transparent; cursor: pointer; transition: all 0.2s;">Cancel</button>
                        <button onclick="confirmLogout()" class="btn" style="padding: 12px; border-radius: 12px; font-weight: 600; background: #ef4444; color: white; border: 1px solid #ef4444; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);">Yes, Logout</button>
                    </div>
                </div>
            </div>
        `;
        document.body.insertAdjacentHTML('beforeend', modalHtml);
        modal = document.getElementById('logoutModal');
    }

    // Activate the modal
    setTimeout(() => {
        modal.classList.add('active');
    }, 10);
}

function confirmLogout() {
    localStorage.removeItem('user');
    window.location.href = '../index.html';
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('active');
    }
}

// Global Confirm with Dynamic Modal (like logout)
window.customConfirm = function (message, onConfirm, onCancel, options = {}) {
    let modal = document.getElementById('globalConfirmModal');

    if (!modal) {
        const modalHtml = `
            <div id="globalConfirmModal" class="modal">
                <div class="modal-content" style="max-width: 400px; padding: 40px; text-align: center; border-radius: 24px;">
                    <div style="width: 80px; height: 80px; background: #fee2e2; color: #ef4444; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 32px; margin: 0 auto 24px auto;">
                        <i id="globalConfirmIcon" class="fas fa-question-circle"></i>
                    </div>
                    <h2 id="globalConfirmTitle" style="font-size: 24px; font-weight: 800; color: var(--text-main); margin-bottom: 12px;">Confirm Action</h2>
                    <p id="globalConfirmMessage" style="color: var(--text-muted); margin-bottom: 32px; font-size: 15px; line-height: 1.6;"></p>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <button id="globalConfirmCancelBtn" class="btn" style="padding: 12px; border-radius: 12px; font-weight: 600; background: var(--bg-body); color: var(--text-main); border: 1px solid transparent; cursor: pointer; transition: all 0.2s;">Cancel</button>
                        <button id="globalConfirmOkBtn" class="btn" style="padding: 12px; border-radius: 12px; font-weight: 600; background: #ef4444; color: white; border: 1px solid #ef4444; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);">Yes</button>
                    </div>
                </div>
            </div>
        `;
        document.body.insertAdjacentHTML('beforeend', modalHtml);
        modal = document.getElementById('globalConfirmModal');
    }

    document.getElementById('globalConfirmMessage').textContent = message;
    if (options.title) document.getElementById('globalConfirmTitle').textContent = options.title;
    if (options.icon) document.getElementById('globalConfirmIcon').className = options.icon;
    if (options.confirmText) document.getElementById('globalConfirmOkBtn').textContent = options.confirmText;
    if (options.cancelText) document.getElementById('globalConfirmCancelBtn').textContent = options.cancelText;

    const okBtn = document.getElementById('globalConfirmOkBtn');
    const cancelBtn = document.getElementById('globalConfirmCancelBtn');

    // Remove old listeners by cloning
    const newOk = okBtn.cloneNode(true);
    okBtn.parentNode.replaceChild(newOk, okBtn);
    const newCancel = cancelBtn.cloneNode(true);
    cancelBtn.parentNode.replaceChild(newCancel, cancelBtn);

    newCancel.addEventListener('click', () => {
        closeModal('globalConfirmModal');
        if (onCancel) onCancel();
    });

    newOk.addEventListener('click', () => {
        closeModal('globalConfirmModal');
        if (onConfirm) onConfirm();
    });

    setTimeout(() => {
        modal.classList.add('active');
    }, 10);
};

// Async wrapper for Global Confirm
window.customConfirmAsync = function (message, options = {}) {
    return new Promise((resolve) => {
        window.customConfirm(message, () => resolve(true), () => resolve(false), options);
    });
};

// --- Optimised Combined Dashboard Loader ---
async function loadDashboardData() {
    const tbody = document.getElementById('recentTransactionsBody');
    
    try {
        // 1. Initial Mock UI Update (Zero Latency)
        const mockUsers = JSON.parse(localStorage.getItem('mock_users') || '[]');
        const mockAccounts = JSON.parse(localStorage.getItem('mock_accounts') || '[]');
        updateStatsUI(mockUsers.length, mockAccounts);

        // 2. Fetch Combined Data (1 API call instead of 4)
        const res = await fetchWithTimeout(`${DB_API_URL}/dashboard.php`);
        const data = await res.json();

        if (data.success) {
            const d = data.data;
            
            // Update Stats
            updateStatsUI(d.user_count, [], d); // Pass the raw data object for combined fields

            // Update Recent Transactions
            if (tbody) {
                renderVoucherTable(tbody, d.recent_vouchers);
            }

            // Update Notification Badge (if already loaded)
            updateNotificationUI([], d.unread_notifications);
        }

    } catch (e) {
        console.warn("Unified Dashboard Refresh Failed:", e);
        // Fallback to separate loaders if needed or show offline message
        if (tbody) tbody.innerHTML = '<tr><td colspan="5" class="text-center">Using locally cached data</td></tr>';
    }
}

function updateStatsUI(userCount, accounts, combinedData = null) {
    const elUsers = document.getElementById('stat-users');
    const elRev = document.getElementById('stat-revenue');
    const elProf = document.getElementById('stat-profit');
    const elExp = document.getElementById('stat-expenses');

    if (elUsers) elUsers.textContent = userCount;

    let revenue, expenses, profit;

    if (combinedData) {
        revenue = combinedData.revenue;
        expenses = combinedData.expenses;
        profit = combinedData.profit;
    } else {
        revenue = accounts.filter(a => a.type === 'Income').reduce((s, a) => s + (parseFloat(a.balance) || 0), 0);
        expenses = accounts.filter(a => a.type === 'Expense').reduce((s, a) => s + (parseFloat(a.balance) || 0), 0);
        profit = revenue - expenses;
    }

    if (elRev) elRev.textContent = formatCurrency(revenue);
    if (elExp) elExp.textContent = formatCurrency(expenses);
    if (elProf) {
        elProf.textContent = formatCurrency(profit);
        elProf.style.color = profit >= 0 ? 'var(--secondary-color)' : 'var(--danger-color)';
    }
}

function renderVoucherTable(tbody, vouchers) {
    if (!vouchers || vouchers.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="text-center">No recent transactions</td></tr>';
        return;
    }

    tbody.innerHTML = '';
    vouchers.forEach(v => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${v.voucher_number || v.id}</td>
            <td>${new Date(v.voucher_date).toLocaleDateString('en-IN')}</td>
            <td>${v.voucher_type_name} - ${v.first_name || 'User'}</td>
            <td>${formatCurrency(v.total_debit || 0)}</td>
            <td><span class="badge badge-${(v.status || 'draft').toLowerCase()}">${v.status || 'Draft'}</span></td>
            <td><button class="btn btn-sm btn-sm-secondary" onclick="viewVoucher('${v.id}')"><i class="fas fa-eye"></i></button></td>
        `;
        tbody.appendChild(row);
    });
}

function initCharts() {
    // Finance Overview Chart
    const ctxFinance = document.getElementById('financeChart');
    if (ctxFinance) {
        new Chart(ctxFinance, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                datasets: [{
                    label: 'Revenue',
                    data: [12000, 19000, 3000, 5000, 20000, 30000],
                    borderColor: '#10b981',
                    tension: 0.4
                }, {
                    label: 'Expenses',
                    data: [8000, 15000, 5000, 4000, 15000, 22000],
                    borderColor: '#ef4444',
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false
            }
        });
    }

    // Expense Breakdown Chart
    const ctxExpense = document.getElementById('expenseChart');
    if (ctxExpense) {
        new Chart(ctxExpense, {
            type: 'doughnut',
            data: {
                labels: ['Salaries', 'Rent', 'Utilities', 'Supplies'],
                datasets: [{
                    data: [50, 25, 15, 10],
                    backgroundColor: ['#3b82f6', '#f59e0b', '#10b981', '#ef4444']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false
            }
        });
    }
}

// --- Reports Functions (Reports Page) ---
function loadReport(type) {
    const container = document.getElementById('report-container');
    if (!container) return;

    let content = '';
    const today = new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });

    if (type === 'balance-sheet') {
        content = `
            <div class="report-view animate-fadeIn">
                <div class="report-header" style="text-align:center; margin-bottom:32px;">
                    <h2 style="font-size: 24px; color: var(--text-main); margin-bottom: 8px;">Statement of Financial Position</h2>
                    <p style="color: var(--text-muted);">As of ${today}</p>
                </div>
                
                <div class="charts-grid" style="grid-template-columns: 1fr 1fr; gap: 32px;">
                    <div class="report-section">
                        <div class="section-title" style="padding: 12px 0; border-bottom: 2px solid var(--primary-color); margin-bottom: 16px;">
                            <h3 style="font-size: 18px; color: var(--primary-color);"><i class="fas fa-wallet"></i> Assets</h3>
                        </div>
                        <table class="data-table">
                            <tbody>
                                <tr><td>Cash & Equivalents</td><td style="text-align:right;">$125,500.00</td></tr>
                                <tr><td>Accounts Receivable</td><td style="text-align:right;">$45,200.00</td></tr>
                                <tr><td>Inventory</td><td style="text-align:right;">$32,000.00</td></tr>
                                <tr><td>Fixed Assets</td><td style="text-align:right;">$250,000.00</td></tr>
                                <tr style="background: var(--bg-body); font-weight: 700;">
                                    <td>Total Assets</td><td style="text-align:right;">$452,700.00</td></tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="report-section">
                        <div class="section-title" style="padding: 12px 0; border-bottom: 2px solid var(--secondary-color); margin-bottom: 16px;">
                            <h3 style="font-size: 18px; color: var(--secondary-color);"><i class="fas fa-hand-holding-usd"></i> Liabilities & Equity</h3>
                        </div>
                        <table class="data-table">
                            <tbody>
                                <tr style="background:#f9fafb;"><td colspan="2"><strong>Liabilities</strong></td></tr>
                                <tr><td>Accounts Payable</td><td style="text-align:right;">$28,500.00</td></tr>
                                <tr><td>Taxes Payable</td><td style="text-align:right;">$12,700.00</td></tr>
                                <tr style="background:#f9fafb;"><td colspan="2"><strong>Equity</strong></td></tr>
                                <tr><td>Retained Earnings</td><td style="text-align:right;">$111,500.00</td></tr>
                                <tr><td>Share Capital</td><td style="text-align:right;">$300,000.00</td></tr>
                                <tr style="background: var(--bg-body); font-weight: 700;">
                                    <td>Total Liabilities & Equity</td><td style="text-align:right;">$452,700.00</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    } else if (type === 'profit-loss') {
        content = `
            <div class="report-view animate-fadeIn">
                <div class="report-header" style="text-align:center; margin-bottom:32px;">
                    <h2 style="font-size: 24px; color: var(--text-main); margin-bottom: 8px;">Profit & Loss Statement</h2>
                    <p style="color: var(--text-muted);">For the period ending ${today}</p>
                </div>
                <div class="table-container" style="max-width: 800px; margin: 0 auto; padding: 24px;">
                    <table class="data-table">
                        <thead>
                            <tr><th>Description</th><th style="text-align:right;">Amount</th></tr>
                        </thead>
                        <tbody>
                            <tr style="background:#f9fafb;"><td colspan="2"><strong>Operating Revenue</strong></td></tr>
                            <tr><td>Sales Income</td><td style="text-align:right; color: var(--secondary-color);">+$245,000.00</td></tr>
                            <tr><td>Service Revenue</td><td style="text-align:right; color: var(--secondary-color);">+$12,000.00</td></tr>
                            <tr style="background: var(--primary-light); font-weight: 700;">
                                <td>Gross Revenue</td><td style="text-align:right;">$257,000.00</td></tr>
                            
                            <tr style="background:#f9fafb;"><td colspan="2"><strong>Operating Expenses</strong></td></tr>
                            <tr><td>Cost of Sales</td><td style="text-align:right; color: var(--primary-color);">-$120,000.00</td></tr>
                            <tr><td>Salaries & Wages</td><td style="text-align:right; color: var(--primary-color);">-$45,000.00</td></tr>
                            <tr><td>Rent & Utilities</td><td style="text-align:right; color: var(--primary-color);">-$8,500.00</td></tr>
                            <tr style="background: var(--bg-body); font-weight: 700; border-top: 2px solid var(--border-color);">
                                <td style="font-size: 18px;">Net Profit</td>
                                <td style="text-align:right; font-size: 18px; color: var(--secondary-color);">$83,500.00</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        `;
    } else if (type === 'trial-balance') {
        content = `
            <div class="report-view animate-fadeIn">
                <div class="report-header" style="text-align:center; margin-bottom:32px;">
                    <h2 style="font-size: 24px; color: var(--text-main); margin-bottom: 8px;">Trial Balance Summary</h2>
                    <p style="color: var(--text-muted);">Status as of ${today}</p>
                </div>
                <div class="table-container" style="max-width: 900px; margin: 0 auto;">
                    <table class="data-table">
                        <thead>
                            <tr><th>Account Name</th><th style="text-align:right;">Debit</th><th style="text-align:right;">Credit</th></tr>
                        </thead>
                        <tbody>
                            <tr><td>Petty Cash</td><td style="text-align:right;">$2,500.00</td><td style="text-align:right;">-</td></tr>
                            <tr><td>Main Bank Account</td><td style="text-align:right;">$123,000.00</td><td style="text-align:right;">-</td></tr>
                            <tr><td>Inventory Stock</td><td style="text-align:right;">$32,000.00</td><td style="text-align:right;">-</td></tr>
                            <tr><td>Customer Receivables</td><td style="text-align:right;">$45,200.00</td><td style="text-align:right;">-</td></tr>
                            <tr><td>Vendor Payables</td><td style="text-align:right;">-</td><td style="text-align:right;">$28,500.00</td></tr>
                            <tr><td>Tax Liability</td><td style="text-align:right;">-</td><td style="text-align:right;">$12,700.00</td></tr>
                            <tr><td>Revenue Account</td><td style="text-align:right;">-</td><td style="text-align:right;">$257,000.00</td></tr>
                            <tr><td>Expense Account</td><td style="text-align:right;">$95,500.00</td><td style="text-align:right;">-</td></tr>
                            <tr style="background: var(--bg-body); font-weight: 800; border-top: 2px solid var(--text-main);">
                                <td>TOTAL SUMMARY</td>
                                <td style="text-align:right; color:var(--primary-color);">$298,200.00</td>
                                <td style="text-align:right; color:var(--primary-color);">$298,200.00</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        `;
    }

    container.innerHTML = content;
}

// --- User Management (Users Page) ---
// This relies on admin-dashboard.js logic, but we can verify if we need wrappers
// ...
