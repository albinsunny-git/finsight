// Shared UI helpers
function toggleUserMenu() {
    const dropdown = document.getElementById('userDropdown');
    if (dropdown) dropdown.classList.toggle('active');
}

function toggleSearch() {
    const sb = document.getElementById('searchBar');
    if (sb) sb.style.display = sb.style.display === 'none' ? 'flex' : 'none';
}

function toggleNotifications() {
    const badges = document.querySelectorAll('.notification-badge, .notification-dot');
    badges.forEach(badge => {
        badge.style.display = 'none';
        badge.textContent = '';
    });
    alert('You have no new notifications.');
}

function logout() {
    localStorage.removeItem('user');
    localStorage.removeItem('remembered_email');
    window.location.href = '../index.html';
}

// Utility Functions
function formatDate(dateString) {
    if (!dateString) return '';
    return new Date(dateString).toLocaleDateString('en-IN', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}

function formatDateTime(dateString) {
    if (!dateString) return '';
    return new Date(dateString).toLocaleString('en-IN', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function formatCurrency(amount) {
    amount = Number(amount) || 0;
    return new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR'
    }).format(amount);
}

function closeModal(modalId) {
    const m = document.getElementById(modalId);
    if (m) m.classList.remove('active');
}

function showAddUserModal() {
    const m = document.getElementById('addUserModal');
    if (m) {
        // Reset form fields for creating new user
        const form = document.getElementById('addUserForm');
        if (form) {
            form.reset();
            document.getElementById('editingUserId').value = '';
        }
        m.classList.add('active');
    }
}

function showAddAccountModal() {
    const m = document.getElementById('addAccountModal');
    if (m) {
        const form = document.getElementById('addAccountForm');
        if (form) {
            form.reset();
            // Remove editing id if any
            const codeEl = document.getElementById('newAccountCode');
            if (codeEl && codeEl.dataset) codeEl.dataset.editingId = '';
        }
        m.classList.add('active');
    }
}

function togglePasswordField(id) {
    const el = document.getElementById(id);
    if (!el) return;
    if (el.type === 'password') el.type = 'text'; else el.type = 'password';
}

function performSearch() {
    const q = document.getElementById('searchInput')?.value || '';
    alert('Search for: ' + q + '\nSearch functionality not implemented yet.');
}

function toggleSidebar() {
    const sidebar = document.querySelector('.sidebar');
    if (sidebar) sidebar.classList.toggle('collapsed');
}

// Close dropdown on outside click
document.addEventListener('click', (e) => {
    if (!e.target.closest('.user-menu')) {
        const dropdown = document.getElementById('userDropdown');
        if (dropdown) dropdown.classList.remove('active');
    }
});