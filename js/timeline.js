async function switchView(view) {
    const listBtn = document.getElementById('btnViewList');
    const timelineBtn = document.getElementById('btnViewTimeline');
    const listContainer = document.getElementById('listViewContainer');
    const timelineContainer = document.getElementById('timelineViewContainer');

    if (view === 'list') {
        listBtn.classList.add('active');
        listBtn.style.background = 'white';
        listBtn.style.color = 'var(--primary-color)';
        listBtn.style.boxShadow = '0 2px 4px rgba(0,0,0,0.1)';

        timelineBtn.classList.remove('active');
        timelineBtn.style.background = 'transparent';
        timelineBtn.style.color = 'var(--text-muted)';
        timelineBtn.style.boxShadow = 'none';

        listContainer.style.display = 'block';
        timelineContainer.style.display = 'none';

        loadVouchers(); // Reload list to be safe
    } else {
        timelineBtn.classList.add('active');
        timelineBtn.style.background = 'white';
        timelineBtn.style.color = 'var(--primary-color)';
        timelineBtn.style.boxShadow = '0 2px 4px rgba(0,0,0,0.1)';

        listBtn.classList.remove('active');
        listBtn.style.background = 'transparent';
        listBtn.style.color = 'var(--text-muted)';
        listBtn.style.boxShadow = 'none';

        listContainer.style.display = 'none';
        timelineContainer.style.display = 'block';

        loadTimeline();
    }
}

async function loadTimeline() {
    const container = document.getElementById('timelineContent');
    container.innerHTML = '<div style="text-align: center; padding: 40px;"><i class="fas fa-circle-notch fa-spin"></i> Loading timeline...</div>';

    try {
        const response = await fetchWithTimeout(`${API_URL}/vouchers.php?action=timeline`, { credentials: 'include' });
        const data = await response.json();

        if (data.success) {
            if (data.data.length === 0) {
                container.innerHTML = `
                    <div style="text-align: center; padding: 40px; color: var(--text-muted);">
                        <i class="fas fa-history" style="font-size: 32px; margin-bottom: 10px; opacity: 0.5;"></i>
                        <p>No transactions found in the timeline.</p>
                    </div>
                `;
                return;
            }
            renderTimeline(data.data);
        } else {
            container.innerHTML = `<div style="text-align: center; color: var(--danger-color);">Failed to load timeline: ${data.message}</div>`;
        }
    } catch (error) {
        console.error('Timeline error:', error);
        container.innerHTML = `<div style="text-align: center; color: var(--danger-color);">Error loading timeline. Please try again.</div>`;
    }
}

function renderTimeline(days) {
    const container = document.getElementById('timelineContent');
    container.innerHTML = '';

    const timelineWrapper = document.createElement('div');
    timelineWrapper.style.position = 'relative';
    timelineWrapper.style.paddingLeft = '30px';
    timelineWrapper.style.borderLeft = '2px solid var(--border-color)';
    timelineWrapper.style.marginLeft = '20px';

    days.forEach(day => {
        const dayDiv = document.createElement('div');
        dayDiv.style.marginBottom = '30px';
        dayDiv.style.position = 'relative';

        // Date Header
        const dateHeader = document.createElement('div');
        dateHeader.style.cssText = `
            position: absolute;
            left: -39px;
            top: 0;
            background: var(--bg-body);
            border: 2px solid var(--border-color);
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            color: var(--text-muted);
            white-space: nowrap;
        `;
        dateHeader.textContent = day.formatted_date;
        dayDiv.appendChild(dateHeader);

        // Vouchers for the day
        const vouchersList = document.createElement('div');
        vouchersList.style.marginTop = '10px';

        day.vouchers.forEach(v => {
            const card = document.createElement('div');
            card.style.cssText = `
                background: var(--bg-card);
                border: 1px solid var(--border-color);
                border-radius: 12px;
                padding: 15px;
                margin-bottom: 12px;
                box-shadow: var(--shadow-sm);
                transition: transform 0.2s;
                cursor: pointer;
            `;
            card.onmouseover = () => card.style.transform = 'translateY(-2px)';
            card.onmouseout = () => card.style.transform = 'translateY(0)';
            card.onclick = () => viewVoucher(v.id);

            const statusColor = v.status === 'Posted' ? 'var(--success-color)' : (v.status === 'Rejected' ? 'var(--danger-color)' : 'var(--warning-color)');
            const statusBg = v.status === 'Posted' ? 'var(--bg-success-light, #dcfce7)' : (v.status === 'Rejected' ? 'var(--bg-danger-light, #fee2e2)' : 'var(--bg-warning-light, #fef3c7)');

            card.innerHTML = `
                <div style="display: flex; justify-content: space-between; align-items: start;">
                    <div>
                        <div style="font-weight: 700; font-size: 15px; color: var(--text-main); margin-bottom: 4px;">
                            ${v.voucher_type_name} <span style="font-weight: 400; color: var(--text-muted); font-size: 13px;">#${v.voucher_number}</span>
                        </div>
                        <div style="font-size: 13px; color: var(--text-muted); line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                            ${v.narration || 'No description'}
                        </div>
                    </div>
                    <div style="text-align: right;">
                        <div style="font-weight: 700; font-size: 15px; color: var(--text-main);">
                            ${formatCurrency(v.total_debit)}
                        </div>
                        <span style="display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; background: ${statusBg}; color: ${statusColor}; margin-top: 4px;">
                            ${v.status}
                        </span>
                    </div>
                </div>
                <div style="margin-top: 10px; padding-top: 10px; border-top: 1px dashed var(--border-color); display: flex; justify-content: space-between; align-items: center; font-size: 12px; color: var(--text-muted);">
                    <div><i class="fas fa-user-circle"></i> ${v.first_name} ${v.last_name}</div>
                    <div style="color: var(--primary-color); font-weight: 600;">Tap to view details <i class="fas fa-chevron-right"></i></div>
                </div>
            `;

            vouchersList.appendChild(card);
        });

        dayDiv.appendChild(vouchersList);
        timelineWrapper.appendChild(dayDiv);
    });

    container.appendChild(timelineWrapper);
}
