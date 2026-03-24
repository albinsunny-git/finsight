import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';

class ApiService {
  // Custom URL can be set via the Settings dialog on the login screen
  // for local development. Otherwise, the production Render URL is used.
  static String? _customBaseUrl;

  static void setCustomUrl(String url) {
    _customBaseUrl = url;
  }

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      if (_customBaseUrl!.endsWith('/')) {
        return '${_customBaseUrl!}api';
      }
      return '$_customBaseUrl/api';
    }
    
    // Always use the production Render URL.
    // For local development, use the Settings icon on the login screen
    // to set a custom URL (e.g., http://10.0.2.2/finsight for emulator).
    return 'https://finsight-1-a1ov.onrender.com/api';
  }

  // Helper to store session cookie
  Future<void> _saveSession(http.Response response) async {
    String? rawCookie;
    // Handle case-insensitivity of headers
    response.headers.forEach((key, value) {
      if (key.toLowerCase() == 'set-cookie') {
        rawCookie = value;
      }
    });

    if (rawCookie != null) {
      int index = rawCookie!.indexOf(';');
      String cookie =
          (index == -1) ? rawCookie! : rawCookie!.substring(0, index);
      // We store any cookie, but mainly PHPSESSID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_cookie', cookie);
      print("Saved Session Cookie: $cookie");
    } else {
      print("Warning: No Set-Cookie header found in login response.");
    }
  }

  Future<Map<String, String>> _getHeaders() => getHeaders();

  // Helper to get headers with session cookie and Firebase Token
  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('session_cookie');

    // Get Firebase Token if available
    String? token;
    try {
      token = await FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (e) {
      print("Error getting Firebase token: $e");
    }

    return {
      'Content-Type': 'application/json',
      'Connection': 'close',
      if (cookie != null) 'Cookie': cookie,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String url) async {
    final headers = await getHeaders();
    return await http
        .get(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 60));
  }

  Future<Map<String, dynamic>> login(
      String emailOrUsername, String password) async {
    final url = Uri.parse('${ApiService.baseUrl}/auth.php?action=login');
    print("Attempting login to: $url");

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email_or_username': emailOrUsername,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print("Login Response Status: ${response.statusCode}");
      print("Login Response Body: ${response.body}");

      // Capture session cookie
      await _saveSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Save user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(data['data']));
          return {'success': true, 'data': data['data']};
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed'
          };
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message':
                errorData['message'] ?? 'Server error: ${response.statusCode}'
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Server error: ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      print("Login Exception: $e");
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // --- Google Login ---
  Future<Map<String, dynamic>> googleLogin(String token) async {
    final url =
        Uri.parse('${ApiService.baseUrl}/auth.php?action=google-callback');

    try {
      print("Sending Google Token to backend: $url");
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}),
          )
          .timeout(const Duration(seconds: 60));

      print("Google Login Response: ${response.statusCode} - ${response.body}");
      await _saveSession(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(data['data']));
          return {'success': true, 'data': data['data']};
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Google Login failed'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      print("Google Login Exception: $e");
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // --- Fetch Dashboard Stats ---
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final headers = await _getHeaders();

      // Fetch Summary (Assets, Liab, Equity)
      final summaryRes = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/reports.php?type=summary'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      // Fetch Analytics (Cash Flow, Top Expenses)
      final analyticsRes = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/reports.php?type=analytics'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      // Fetch Recent Transactions
      final historyRes = await http
          .get(
            Uri.parse(
                '${ApiService.baseUrl}/reports.php?type=transaction-history'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      Map<String, dynamic> result = {};

      if (summaryRes.statusCode == 200) {
        final data = jsonDecode(summaryRes.body);
        if (data['success']) result['summary'] = data['data'];
      }

      if (analyticsRes.statusCode == 200) {
        final data = jsonDecode(analyticsRes.body);
        if (data['success']) result['analytics'] = data['data'];
      }

      if (historyRes.statusCode == 200) {
        final data = jsonDecode(historyRes.body);
        if (data['success']) result['history'] = data['data'];
      }

      return result;
    } catch (e) {
      print('Error fetching stats: $e');
      return {};
    }
  }

  // --- Fetch Users ---
  Future<List<dynamic>> getUsers() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/users.php?action=list'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      print('GetUsers Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // --- Fetch Vouchers ---
  Future<List<dynamic>> getVouchers() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/vouchers.php?action=list'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching vouchers: $e');
      return [];
    }
  }

  // --- Fetch Voucher Details ---
  Future<Map<String, dynamic>> getVoucherDetails(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/vouchers.php?action=get&id=$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'] ?? {};
        }
      }
      return {};
    } catch (e) {
      print('Error fetching voucher details: $e');
      return {};
    }
  }

  // --- Fetch Accounts ---
  Future<List<dynamic>> getAccounts() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/accounts.php?action=list'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching accounts: $e');
      return [];
    }
  }

  // --- Create Voucher ---
  Future<Map<String, dynamic>> createVoucher(
      Map<String, dynamic> voucherData) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/vouchers.php?action=create'),
            headers: headers,
            body: jsonEncode(voucherData),
          )
          .timeout(const Duration(seconds: 60));

      print('CreateVoucher: ${response.statusCode} - ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        try {
          final err = jsonDecode(response.body);
          return {
            'success': false,
            'message': err['message'] ?? 'Error ${response.statusCode}'
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Server Error ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      print("CreateVoucher Exception: $e");
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }

  // --- Create Account ---
  Future<Map<String, dynamic>> createAccount(
      Map<String, dynamic> accountData) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/accounts.php?action=create'),
            headers: headers,
            body: jsonEncode(accountData),
          )
          .timeout(const Duration(seconds: 60));

      print('CreateAccount: ${response.statusCode} - ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        try {
          final err = jsonDecode(response.body);
          return {
            'success': false,
            'message': err['message'] ?? 'Error ${response.statusCode}'
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Server Error ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }

  // --- Update Account ---
  Future<Map<String, dynamic>> updateAccount(
      Map<String, dynamic> accountData) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/accounts.php?action=update'),
            headers: headers,
            body: jsonEncode(accountData),
          )
          .timeout(const Duration(seconds: 60));

      print('UpdateAccount: ${response.statusCode} - ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        try {
          final err = jsonDecode(response.body);
          return {
            'success': false,
            'message': err['message'] ?? 'Error ${response.statusCode}'
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Server Error ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }

  // --- Delete Account ---
  Future<Map<String, dynamic>> deleteAccount(int accountId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/accounts.php?action=delete'),
            headers: headers,
            body: jsonEncode({'id': accountId}),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }

  // --- Get Voucher Types ---
  Future<List<dynamic>> getVoucherTypes() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/vouchers.php?action=types'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching voucher types: $e');
      return [];
    }
  }

  // --- Create User ---
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/users.php?action=create'),
            headers: headers,
            body: jsonEncode(userData),
          )
          .timeout(const Duration(seconds: 60));

      print('CreateUser: ${response.statusCode} - ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        try {
          final err = jsonDecode(response.body);
          return {
            'success': false,
            'message': err['message'] ?? 'Error ${response.statusCode}'
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Server Error ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    try {
      final headers = await _getHeaders();

      // Map 'id' to 'user_id' for backend compatibility
      final Map<String, dynamic> body = Map.from(userData);
      if (body.containsKey('id')) {
        body['user_id'] = body['id'];
        body.remove('id');
      }

      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/users.php?action=update'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        try {
          final err = jsonDecode(response.body);
          return {
            'success': false,
            'message': err['message'] ?? 'Error ${response.statusCode}'
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Server Error ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/users.php?action=delete'),
            headers: headers,
            body: jsonEncode({'user_id': userId}),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }

  // --- Request Approval ---
  Future<Map<String, dynamic>> requestApproval(int voucherId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(
                '${ApiService.baseUrl}/vouchers.php?action=request_approval'),
            headers: headers,
            body: jsonEncode({'voucher_id': voucherId}),
          )
          .timeout(const Duration(seconds: 60));

      print('RequestApproval: ${response.statusCode} - ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Status ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }

  // --- Approve Voucher ---
  Future<Map<String, dynamic>> approveVoucher(int voucherId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/vouchers.php?action=post'),
            headers: headers,
            body: jsonEncode({'voucher_id': voucherId}),
          )
          .timeout(const Duration(seconds: 60));

      print('ApproveVoucher: ${response.statusCode} - ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Status ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }

  // --- Reject Voucher ---
  Future<Map<String, dynamic>> rejectVoucher(
      int voucherId, String reason) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/vouchers.php?action=reject'),
            headers: headers,
            body: jsonEncode({'voucher_id': voucherId, 'reason': reason}),
          )
          .timeout(const Duration(seconds: 60));

      print('RejectVoucher: ${response.statusCode} - ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Status ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }

  // --- Get Financial Insights ---
  Future<Map<String, dynamic>> getInsights() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/insights.php?action=monthly'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data;
        }
      }
      return {'success': false, 'message': 'Failed to load insights'};
    } catch (e) {
      print('Error fetching insights: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  // --- Get Timeline Data ---
  Future<List<dynamic>> getTimeline() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/vouchers.php?action=timeline'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching timeline: $e');
      return [];
    }
  }

  // --- Reports & Analytics ---

  Future<List<dynamic>> getBalanceSheet({String? asOnDate}) async {
    try {
      final headers = await _getHeaders();
      String url = '${ApiService.baseUrl}/reports.php?type=balance-sheet';
      if (asOnDate != null) url += '&as_on_date=$asOnDate';

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) return data['data'];
      }
      return [];
    } catch (e) {
      print('Error fetching Balance Sheet: $e');
      return [];
    }
  }

  Future<List<dynamic>> getProfitLoss(
      {String? fromDate, String? toDate}) async {
    try {
      final headers = await _getHeaders();
      String url = '${ApiService.baseUrl}/reports.php?type=profit-loss';
      if (fromDate != null) url += '&from_date=$fromDate';
      if (toDate != null) url += '&to_date=$toDate';

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) return data['data'];
      }
      return [];
    } catch (e) {
      print('Error fetching P&L: $e');
      return [];
    }
  }

  Future<List<dynamic>> getTrialBalance({String? asOnDate}) async {
    try {
      final headers = await _getHeaders();
      String url = '${ApiService.baseUrl}/reports.php?type=trial-balance';
      if (asOnDate != null) url += '&as_on_date=$asOnDate';

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) return data['data'];
      }
      return [];
    } catch (e) {
      print('Error fetching Trial Balance: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/reports.php?type=analytics'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) return data['data'];
      }
      return {};
    } catch (e) {
      print('Error fetching Analytics: $e');
      return {};
    }
  }

  Future<List<dynamic>> getCashFlow({String? fromDate, String? toDate}) async {
    try {
      final headers = await _getHeaders();
      String url = '${ApiService.baseUrl}/reports.php?type=cash-flow';
      if (fromDate != null) url += '&from_date=$fromDate';
      if (toDate != null) url += '&to_date=$toDate';

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) return data['data'];
      }
      return [];
    } catch (e) {
      print('Error fetching Cash Flow: $e');
      return [];
    }
  }

  // --- Settings ---

  Future<Map<String, dynamic>> getCompanySettings() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/settings.php'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) return data['data'];
      }
      return {};
    } catch (e) {
      print('Error fetching settings: $e');
      return {};
    }
  }

  Future<bool> updateCompanySettings(Map<String, dynamic> settings) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/settings.php'),
            headers: headers,
            body: jsonEncode(settings),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error updating settings: $e');
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/users.php?action=update-profile'),
        headers: headers,
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      return false;
    }
  }

  Future<String?> uploadProfileImage(String filePath) async {
    try {
      final headers = await _getHeaders();
      // MultipartRequest logic
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              '${ApiService.baseUrl}/users.php?action=upload-profile-image'));

      request.headers.addAll(headers);
      request.files
          .add(await http.MultipartFile.fromPath('profile_image', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data']['profile_image']; // Returns the relative path
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile image: $e');
      }
      return null;
    }
  }

  // ---- Notifications API ----

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/notifications.php?action=list'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'] ?? {'notifications': [], 'unread_count': 0};
        }
      }
      return {'notifications': [], 'unread_count': 0};
    } catch (e) {
      print('Error fetching notifications: $e');
      return {'notifications': [], 'unread_count': 0};
    }
  }

  Future<bool> markNotificationAsRead({int? id}) async {
    try {
      final headers = await _getHeaders();
      final body = id != null ? jsonEncode({'id': id}) : jsonEncode({});
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/notifications.php?action=mark-read'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> clearNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/notifications.php?action=clear'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error clearing notifications: $e');
      return false;
    }
  }
  Future<List<dynamic>> getAuditLogs() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/audit.php?action=list'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching audit logs: $e');
      return [];
    }
  }
}
