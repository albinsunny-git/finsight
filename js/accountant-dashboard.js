// Accountant Dashboard JavaScript
const API_URL = window.location.pathname.includes('/pages/') ? '../api' : 'api';
let currentUser = null;
let voucherDetails = [];

document.addEventListener('DOMContentLoaded', async () => {
    await initializeAccountantDashboard();
});

async function initializeAccountantDashboard() {
    const user = localStorage.getItem('user');

    if (!user) {
        window.location.href = '../index.html';
        return;
    }

    currentUser = JSON.parse(user);

    if (currentUser.role !== 'accountant') {
        alert('Access denied. This page is for accountants only.');
        window.location.href = '../index.html';
        return;
    }

    document.getElementById('user-name').textContent = `${currentUser.first_name} ${currentUser.last_name}`;

    await loadDashboardStats();
    initializeCharts();

    // Set default date to today
    document.getElementById('voucherDate').valueAsDate = new Date();

    // Show dashboard section by default
    loadSection('dashboard');
}

async function loadDashboardStats() {
    try {
        const response = await fetch(`${API_URL}/vouchers.php?action=list`);
        const data = await response.json();

        if (data.success) {
            // Stats should reflect all vouchers visible to the accountant
            const allVouchers = data.data;
            const draft = allVouchers.filter(v => v.status === 'Draft').length;
            const posted = allVouchers.filter(v => v.status === 'Posted').length;
            const rejected = allVouchers.filter(v => v.status === 'Rejected').length;

            document.getElementById('stat-draft-vouchers').textContent = draft;
            document.getElementById('stat-posted-vouchers').textContent = posted;
            document.getElementById('stat-rejected-vouchers').textContent = rejected;
        }
    } catch (error) {
        console.error('Error loading stats:', error);
    }
}

function initializeCharts() {
    const ctx = document.getElementById('voucherActivityChart')?.getContext('2d');
    if (ctx) {
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                datasets: [{
                    label: 'Vouchers Created',
                    data: [8, 12, 15, 10, 18, 14],
                    backgroundColor: '#2563eb'
                }, {
                    label: 'Vouchers Posted',
                    data: [6, 10, 14, 9, 16, 12],
                    backgroundColor: '#10b981'
                }]
            },
            options: {
                responsive: true,
                plugins: { legend: { position: 'bottom' } }
            }
        });
    }
}

function loadSection(section) {
    document.querySelectorAll('.section-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nav-link').forEach(el => el.classList.remove('active'));

    const content = document.getElementById(`${section}-content`);
    if (content) {
        content.classList.add('active');
    }

    // Robustly add 'active' to the nav link matching the section (supports href or inline onclick)
    const activeLink = document.querySelector(`.nav-link[href$="#${section}"], .nav-link[onclick*="${section}"]`);
    if (activeLink) activeLink.classList.add('active');

    const titles = {
        'dashboard': 'Dashboard',
        'vouchers': 'Vouchers List',
        'new-voucher': 'Create Voucher',
        'reports': 'Financial Reports',
        'settings': 'Settings'
    };

    document.getElementById('page-title').textContent = titles[section] || 'Dashboard';

    if (section === 'vouchers') {
        loadVouchers();
    } else if (section === 'new-voucher') {
        // Ensure there's at least one voucher detail line when creating a new voucher
        if (document.getElementById('voucherDetailsBody').children.length === 0) addVoucherDetail();
    } else if (section === 'settings') {
        loadSettings();
    }

    // Close sidebar on mobile
    const sidebar = document.querySelector('.sidebar');
    if (window.innerWidth <= 768) {
        sidebar?.classList.remove('active');
    }
}

async function loadVouchers() {
    try {
        let url = `${API_URL}/vouchers.php?action=list`;
        const status = document.getElementById('voucherStatusFilter')?.value;
        if (status) url += `&status=${status}`;

        const response = await fetch(url);
        const data = await response.json();

        if (data.success) {
            // Show all vouchers returned by API
            const vouchers = data.data;
            const tbody = document.getElementById('vouchersTableBody');
            tbody.innerHTML = '';

            vouchers.forEach(v => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${v.voucher_number}</td>
                    <td>${v.voucher_type_name}</td>
                    <td>${formatDate(v.voucher_date)}</td>
                    <td>${formatCurrency(v.total_debit)}</td>
                    <td><span class="badge badge-${v.status.toLowerCase().replace(' ', '-')}">${v.status}</span></td>
                    <td>
                        <button onclick="viewVoucher(${v.id})" class="btn-action">View</button>
                        ${v.status === 'Draft' && v.created_by === currentUser.id ? `
                            <button onclick="requestApproval(${v.id})" class="btn-action warning">Request</button>
                            <button onclick="editVoucher(${v.id})" class="btn-action">Edit</button>
                            <button onclick="deleteVoucher(${v.id})" class="btn-action danger">Delete</button>
                        ` : ''}
                    </td>
                `;
                tbody.appendChild(row);
            });
        }
    } catch (error) {
        console.error('Error loading vouchers:', error);
    }
}

function addVoucherDetail() {
    const tbody = document.getElementById('voucherDetailsBody');
    const rowIndex = tbody.children.length;

    const row = document.createElement('tr');
    row.innerHTML = `
        <td>
            <select id="account_${rowIndex}" class="account-select" required onchange="calculateTotals()">
                <option value="">Select Account</option>
            </select>
        </td>
        <td><input type="number" id="debit_${rowIndex}" class="debit-input" step="0.01" min="0" onchange="calculateTotals()"></td>
        <td><input type="number" id="credit_${rowIndex}" class="credit-input" step="0.01" min="0" onchange="calculateTotals()"></td>
        <td><input type="text" id="desc_${rowIndex}" placeholder="Description"></td>
        <td><button type="button" onclick="removeVoucherDetail(${rowIndex})" class="btn-action danger">Remove</button></td>
    `;
    tbody.appendChild(row);

    // Load accounts for select
    loadAccountsForSelect(`account_${rowIndex}`);
}

async function loadAccountsForSelect(selectId) {
    try {
        const response = await fetch(`${API_URL}/accounts.php?action=list`);
        const data = await response.json();

        if (data.success) {
            const select = document.getElementById(selectId);
            data.data.forEach(account => {
                const option = document.createElement('option');
                option.value = account.id;
                option.textContent = `${account.code} - ${account.name}`;
                select.appendChild(option);
            });
            return data.data;
        }
        return [];
    } catch (error) {
        console.error('Error loading accounts:', error);
        return [];
    }
}

function removeVoucherDetail(rowIndex) {
    const tbody = document.getElementById('voucherDetailsBody');
    tbody.children[rowIndex].remove();
    calculateTotals();
}

function calculateTotals() {
    const tbody = document.getElementById('voucherDetailsBody');
    let totalDebit = 0;
    let totalCredit = 0;

    Array.from(tbody.children).forEach((row, index) => {
        const debit = parseFloat(document.getElementById(`debit_${index}`)?.value || 0);
        const credit = parseFloat(document.getElementById(`credit_${index}`)?.value || 0);
        totalDebit += debit;
        totalCredit += credit;
    });

    document.getElementById('totalDebit').textContent = formatCurrency(totalDebit);
    document.getElementById('totalCredit').textContent = formatCurrency(totalCredit);
    document.getElementById('totalDifference').textContent = formatCurrency(Math.abs(totalDebit - totalCredit));
}

document.getElementById('newVoucherForm')?.addEventListener('submit', async (e) => {
    e.preventDefault();

    if (Math.abs(parseFloat(document.getElementById('totalDebit').textContent) -
        parseFloat(document.getElementById('totalCredit').textContent)) > 0.01) {
        alert('Debit and Credit must be equal');
        return;
    }

    const tbody = document.getElementById('voucherDetailsBody');
    const details = [];

    Array.from(tbody.children).forEach((row, index) => {
        const accountId = document.getElementById(`account_${index}`).value;
        const debit = parseFloat(document.getElementById(`debit_${index}`).value || 0);
        const credit = parseFloat(document.getElementById(`credit_${index}`).value || 0);
        const description = document.getElementById(`desc_${index}`).value;

        if (accountId && (debit > 0 || credit > 0)) {
            details.push({ account_id: accountId, debit, credit, description });
        }
    });

    if (details.length === 0) {
        alert('Please add at least one voucher detail');
        return;
    }

    const voucherData = {
        voucher_type_id: document.getElementById('voucherType').value,
        voucher_date: document.getElementById('voucherDate').value,
        narration: document.getElementById('voucherNarration').value,
        details: details
    };

    try {
        const editingId = document.getElementById('editingVoucherId')?.value;
        const action = editingId ? 'update' : 'create';
        if (editingId) voucherData.voucher_id = editingId;

        const response = await fetch(`${API_URL}/vouchers.php?action=${action}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(voucherData)
        });

        const data = await response.json();
        if (data.success) {
            alert(editingId ? 'Voucher updated successfully' : `Voucher created successfully: ${data.data?.voucher_number || ''}`);
            resetForm();
            loadVouchers();
            loadSection('vouchers');
        } else {
            alert((data.message) ? `Error: ${data.message}` : 'Error saving voucher');
        }
    } catch (error) {
        console.error('Error saving voucher:', error);
        alert('Error saving voucher');
    }
});

function submitVoucher() {
    alert('Voucher has been submitted for posting');
    // Would submit to manager for approval
}

function viewVoucher(voucherId) {
    // Fetch voucher details and show modal
    (async () => {
        try {
            const resp = await fetch(`${API_URL}/vouchers.php?action=get&id=${voucherId}`);
            const data = await resp.json();
            if (!data.success) {
                alert('Failed to load voucher');
                return;
            }

            const v = data.data;
            document.getElementById('modalVoucherNumber').textContent = v.voucher_number + ' — ' + v.voucher_type_name;

            // Build modal body
            const body = document.getElementById('modalBody');
            body.innerHTML = `
                <p><strong>Date:</strong> ${formatDate(v.voucher_date)}</p>
                <p><strong>Narration:</strong> ${v.narration || ''}</p>
                <h4 style="margin-top:12px;">Details</h4>
                <table style="width:100%; border-collapse: collapse;">
                    <thead>
                        <tr style="border-bottom:1px solid #e5e7eb;"><th>Account</th><th>Debit</th><th>Credit</th><th>Description</th></tr>
                    </thead>
                    <tbody>
                        ${v.details.map(d => `<tr><td>${d.code} - ${d.name}</td><td>${formatCurrency(d.debit)}</td><td>${formatCurrency(d.credit)}</td><td>${d.description || ''}</td></tr>`).join('')}
                    </tbody>
                </table>
            `;

            // Build modal footer actions
            const footer = document.getElementById('modalFooter');
            footer.innerHTML = '';

            // Current user actions
            if ((currentUser.role === 'manager' || currentUser.role === 'admin') && v.status === 'Draft') {
                const postBtn = document.createElement('button');
                postBtn.className = 'btn btn-primary';
                postBtn.textContent = 'Post Voucher';
                postBtn.onclick = async () => {
                    if (!confirm('Are you sure to post this voucher?')) return;
                    const r = await fetch(`${API_URL}/vouchers.php?action=post`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ voucher_id: v.id }) });
                    const j = await r.json();
                    if (j.success) { alert('Voucher posted'); closeVoucherModal(); loadVouchers(); } else alert(j.message || 'Failed to post');
                };
                footer.appendChild(postBtn);

                const rejectBtn = document.createElement('button');
                rejectBtn.className = 'btn';
                rejectBtn.style.background = '#ef4444'; rejectBtn.style.color = 'white';
                rejectBtn.textContent = 'Reject';
                rejectBtn.onclick = async () => {
                    const reason = prompt('Enter rejection reason:');
                    if (!reason) return;
                    const r = await fetch(`${API_URL}/vouchers.php?action=reject`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ voucher_id: v.id, reason }) });
                    const j = await r.json();
                    if (j.success) { alert('Voucher rejected'); closeVoucherModal(); loadVouchers(); } else alert(j.message || 'Failed to reject');
                };
                footer.appendChild(rejectBtn);
            }

            if (v.created_by === currentUser.id && v.status === 'Draft') {
                const editBtn = document.createElement('button');
                editBtn.className = 'btn';
                editBtn.textContent = 'Edit';
                editBtn.onclick = () => { closeVoucherModal(); editVoucher(v.id); };
                footer.appendChild(editBtn);

                const delBtn = document.createElement('button');
                delBtn.className = 'btn';
                delBtn.style.background = '#ef4444'; delBtn.style.color = 'white';
                delBtn.textContent = 'Delete';
                delBtn.onclick = async () => {
                    if (!confirm('Delete this voucher?')) return;
                    const r = await fetch(`${API_URL}/vouchers.php?action=delete`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ voucher_id: v.id }) });
                    const j = await r.json();
                    if (j.success) { alert('Voucher deleted'); closeVoucherModal(); loadVouchers(); } else alert(j.message || 'Failed to delete');
                };
                footer.appendChild(delBtn);
            }

            const closeBtn = document.createElement('button');
            closeBtn.className = 'btn';
            closeBtn.textContent = 'Close';
            closeBtn.onclick = () => closeVoucherModal();
            footer.appendChild(closeBtn);

            // Show modal
            document.getElementById('voucherModal').style.display = 'flex';

        } catch (err) {
            console.error('Error fetching voucher:', err);
            alert('Failed to load voucher');
        }
    })();
}

function editVoucher(voucherId) {
    (async () => {
        try {
            const resp = await fetch(`${API_URL}/vouchers.php?action=get&id=${voucherId}`);
            const data = await resp.json();
            if (!data.success) return alert('Failed to load voucher for editing');

            const v = data.data;
            // Switch to create form
            loadSection('new-voucher');

            // Populate header
            document.getElementById('editingVoucherId').value = v.id;
            document.getElementById('voucherType').value = v.voucher_type_id;
            document.getElementById('voucherDate').value = v.voucher_date;
            document.getElementById('voucherNarration').value = v.narration || '';

            // Clear existing lines
            document.getElementById('voucherDetailsBody').innerHTML = '';

            // Add rows and set values
            for (let i = 0; i < v.details.length; i++) {
                addVoucherDetail();
                const selectId = `account_${i}`;
                await loadAccountsForSelect(selectId);
                document.getElementById(selectId).value = v.details[i].account_id;
                document.getElementById(`debit_${i}`).value = v.details[i].debit;
                document.getElementById(`credit_${i}`).value = v.details[i].credit;
                document.getElementById(`desc_${i}`).value = v.details[i].description || '';
            }

            calculateTotals();
        } catch (err) {
            console.error('Error editing voucher:', err);
            alert('Failed to load voucher for editing');
        }
    })();
}

function deleteVoucher(voucherId) {
    (async () => {
        if (!confirm('Are you sure you want to delete this voucher?')) return;
        try {
            const r = await fetch(`${API_URL}/vouchers.php?action=delete`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ voucher_id: voucherId }) });
            const j = await r.json();
            if (j.success) { alert('Voucher deleted'); loadVouchers(); } else alert(j.message || 'Failed to delete');
        } catch (err) {
            console.error('Error deleting voucher:', err);
            alert('Failed to delete voucher');
        }
    })();
}

async function requestApproval(id) {
    if (!confirm('Send this voucher for Admin approval?')) return;
    try {
        const response = await fetch(`${API_URL}/vouchers.php?action=request_approval`, {
            method: 'POST',
            body: JSON.stringify({ voucher_id: id })
        });
        const data = await response.json();
        if (data.success) {
            alert('Request sent successfully!');
            loadVouchers();
        } else {
            alert('Failed: ' + data.message);
        }
    } catch (e) {
        console.error(e);
        alert('Error sending request');
    }
}

function closeVoucherModal() {
    document.getElementById('voucherModal').style.display = 'none';
    document.getElementById('modalBody').innerHTML = '';
    document.getElementById('modalFooter').innerHTML = '';
}

async function loadSettings() {
    document.getElementById('settingsFullName').value = `${currentUser.first_name} ${currentUser.last_name}`;
    document.getElementById('settingsEmail').value = currentUser.email;
}

function editProfile() {
    alert('Edit profile feature coming soon');
}

function loadReport(reportType) {
    alert('Load ' + reportType + ' report');
}

function toggleUserMenu() {
    document.getElementById('userDropdown').classList.toggle('active');
}

function toggleNotifications() {
    alert('Notifications feature coming soon');
}

// Sidebar toggle (kept here so accountant page works independently)
function toggleSidebar() {
    document.querySelector('.sidebar')?.classList.toggle('collapsed');
}

function resetForm() {
    document.getElementById('newVoucherForm').reset();
    document.getElementById('voucherDetailsBody').innerHTML = '';
    document.getElementById('voucherDate').valueAsDate = new Date();
    calculateTotals();
}

function logout() {
    localStorage.removeItem('user');
    window.location.href = '../index.html';
}

function formatDate(dateString) {
    return new Date(dateString).toLocaleDateString('en-IN', {
        year: 'numeric', month: 'short', day: 'numeric'
    });
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('en-IN', {
        style: 'currency', currency: 'INR'
    }).format(Math.abs(amount) || 0);
}

// Add badge styles to stylesheet
const style = document.createElement('style');
style.textContent = `
    .badge {
        display: inline-block;
        padding: 4px 8px;
        border-radius: 4px;
        font-size: 12px;
        font-weight: 600;
    }
    
    .badge-draft {
        background: #fef3c7;
        color: #b45309;
    }
    
    .badge-posted {
        background: #d1fae5;
        color: #065f46;
    }
    
    .badge-rejected {
        background: #fee2e2;
        color: #991b1b;
    }

    .badge-pending-approval {
        background: #fff7ed;
        color: #c2410c;
    }
    
    .btn-action {
        padding: 4px 8px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 12px;
        background: #2563eb;
        color: white;
        margin-right: 4px;
    }
    
    .btn-action:hover {
        background: #1d4ed8;
    }
    
    .btn-action.danger {
        background: #ef4444;
    }
    
    .btn-action.danger:hover {
        background: #dc2626;
    }
    
    .btn-action.warning {
        background: #f59e0b;
    }
    
    .btn-action.warning:hover {
        background: #d97706;
    }
    
    .btn-secondary {
        background: #6b7280;
        color: white;
    }
    
    .btn-secondary:hover {
        background: #4b5563;
    }
`;
document.head.appendChild(style);
