// Authentication JavaScript
const API_URL = 'http://localhost/finsight/backend/api/auth.php';

// Helper to determine redirect URL based on role
function resolveRedirectUrl(role) {
    if (role && role.toLowerCase() === 'accountant') {
        return 'pages/accountant.html';
    } else {
        return 'pages/dashboard.html';
    }
}

// Password Toggle Function
function togglePassword(fieldId) {
    const field = document.getElementById(fieldId);
    if (!field) return;
    const type = field.type === 'password' ? 'text' : 'password';
    field.type = type;
}

// Show Login Form (Legacy support if needed)
function showLogin(event) {
    if (event) event.preventDefault();
    document.querySelectorAll('.form-container').forEach(el => el.classList.remove('active'));
    document.getElementById('login-form')?.classList.add('active');
}

// Login Form Handler
document.getElementById('loginForm')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    clearErrors();

    const emailOrUsername = document.getElementById('email_or_username').value.trim();
    const password = document.getElementById('password').value;

    if (!emailOrUsername || !password) {
        showError('login_error', 'Email/username and password are required');
        return;
    }

    const submitBtn = e.target.querySelector('button[type="submit"]');
    if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.textContent = 'Signing In...';
    }

    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                action: 'login',
                email_or_username: emailOrUsername,
                password: password
            })
        });

        const data = await response.json();

        if (data.success) {
            // Store user data
            localStorage.setItem('user', JSON.stringify(data.data));

            // Redirect based on role
            const role = data.data.role ? data.data.role : 'user';
            window.location.href = resolveRedirectUrl(role);
        } else {
            showError('login_error', data.message || 'Login failed');
        }
    } catch (error) {
        showError('login_error', 'An error occurred. Please try again.');
        console.error('Login error:', error);
    } finally {
        if (submitBtn) {
            submitBtn.disabled = false;
            submitBtn.textContent = 'Sign In';
        }
    }
});

// Handle Google Sign In Response
async function handleGoogleSignIn(response) {
    const token = response.credential;

    try {
        const apiResponse = await fetch(API_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                action: 'google-callback',
                token: token
            })
        });

        const result = await apiResponse.json();

        if (result.success) {
            const payload = result.data || {};
            localStorage.setItem('user', JSON.stringify(payload.user || payload));
            if (payload.sessionToken) localStorage.setItem('sessionToken', payload.sessionToken);

            // Redirect based on role
            const role = (payload.user && payload.user.role) ? payload.user.role : (payload.role ? payload.role : 'user');
            window.location.href = resolveRedirectUrl(role);
        } else {
            console.error('Google sign-in API response:', result);
            showError('login_error', result.message || 'Google Sign In failed');
        }
    } catch (error) {
        console.error('Google Sign In Error:', error);
        showError('login_error', error.message || 'An error occurred during Google Sign In');
    }
}

// Helper Functions
function showError(elementId, message) {
    const element = document.getElementById(elementId);
    if (element) {
        element.textContent = message;
        element.style.display = 'block';
    }
}

function clearErrors() {
    const err = document.getElementById('login_error');
    if (err) {
        err.style.display = 'none';
        err.textContent = '';
    }
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    // Optional: Add logic here if needed
});