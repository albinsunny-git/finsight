import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:finsight_mobile/screens/login_screen.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:finsight_mobile/screens/settings/security_settings_screen.dart';
import 'package:finsight_mobile/screens/add_account_screen.dart';
import 'package:finsight_mobile/screens/add_voucher_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:finsight_mobile/providers/theme_provider.dart';
import 'package:finsight_mobile/screens/reports/reports_home_screen.dart';
import 'package:finsight_mobile/screens/user_management_screen.dart';
import 'package:finsight_mobile/screens/notifications_screen.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';
import 'package:finsight_mobile/screens/voucher_detail_screen.dart';
import 'package:finsight_mobile/screens/settings/company_settings_screen.dart';
import 'package:finsight_mobile/screens/edit_account_screen.dart';
import 'package:finsight_mobile/screens/settings/profile_edit_screen.dart';
import 'package:finsight_mobile/screens/manager/manager_dashboard_view.dart';
import 'package:finsight_mobile/screens/manager/manager_accounts_view.dart';
import 'package:finsight_mobile/screens/manager/manager_vouchers_view.dart';
import 'package:finsight_mobile/screens/manager/manager_reports_view.dart';
import 'package:finsight_mobile/screens/manager/manager_profile_view.dart';
import 'package:finsight_mobile/screens/manager/manager_team_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = 'User';
  String _userRole = 'Admin';
  String _email = '';
  String _phone = '';
  String _userId = '';
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  // Real Data State
  Map<String, dynamic> _dashboardData = {};
  List<dynamic> _users = [];
  List<dynamic> _vouchers = [];
  List<dynamic> _accounts = [];

  int _unreadNotifCount = 0;

  // Navigation State
  int _selectedIndex = 0;
  late PageController _pageController;

  // Define all possible pages with their internal IDs
  final List<Map<String, dynamic>> _allPages = [
    {'id': 'dashboard', 'label': 'DASHBOARD', 'icon': LucideIcons.layoutGrid},
    {'id': 'accounts', 'label': 'ACCOUNTS', 'icon': LucideIcons.landmark},
    {'id': 'vouchers', 'label': 'VOUCHERS', 'icon': LucideIcons.scroll},
    {'id': 'reports', 'label': 'REPORTS', 'icon': LucideIcons.trendingUp},
    {'id': 'users', 'label': 'TEAMS', 'icon': LucideIcons.users},
    {'id': 'profile', 'label': 'PROFILE', 'icon': LucideIcons.user},
  ];

  List<Map<String, dynamic>> _currentPages = [];
  String? _profileImagePath;
  String? _serverProfileImage;

  final Map<String, dynamic> _stats = {
    'revenue': 0.0,
    'expenses': 0.0,
    'net_profit': 0.0,
    'active_users': 0,
    'revenue_trend': '+0.0%',
    'expenses_trend': '+0.0%',
    'profit_trend': '+0.0%',
  };

  final TextEditingController _voucherSearchController =
      TextEditingController();
  final TextEditingController _accountSearchController =
      TextEditingController();
  final String _selectedVoucherStatus = "All";
  String _selectedVoucherType = "All Types";
  final String _selectedAccountType = "All Accounts";

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadUserData();
    _startPolling();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _voucherSearchController.dispose();
    _accountSearchController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) _loadUserData();
    });
  }


  void _navigateToPageIndex(int index) {
    if (!mounted) return;
    if ((_selectedIndex - index).abs() > 1) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToPage(String pageId) {
    int index = _currentPages.indexWhere((p) => p['id'] == pageId);
    if (index != -1) {
      _navigateToPageIndex(index);
    }
  }

  void _updateNavigationForRole(String role) {
    if (!mounted) return;
    final normalizedRole = role.trim().toLowerCase();

    setState(() {
      if (normalizedRole.contains('admin')) {
        _currentPages = _allPages;
      } else if (normalizedRole.contains('manager')) {
        _currentPages = _allPages.where((page) {
          return [
            'dashboard',
            'users',
            'accounts',
            'vouchers',
            'reports',
            'profile'
          ].contains(page['id']);
        }).toList();
      } else {
        _currentPages = _allPages.where((page) {
          return ['dashboard', 'vouchers', 'accounts', 'reports', 'profile']
              .contains(page['id']);
        }).toList();
      }
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');

    String role = 'Admin';
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      if (mounted) {
        setState(() {
          _userName = userData['first_name'] ?? 'User';
          _userRole = userData['role'] ?? 'Admin';
          _email = userData['email'] ?? '';
          _userId = userData['id']?.toString() ?? '';
          _phone = userData['phone'] ?? '';
          _serverProfileImage = userData['profile_image'];
          role = _userRole;
        });
      }
    }

    final imagePath = prefs.getString('profile_image_path_$_userId');
    if (mounted) {
      setState(() {
        _profileImagePath =
            (_serverProfileImage != null && _serverProfileImage!.isNotEmpty)
                ? _serverProfileImage
                : imagePath;
      });
    }

    final normalizedRole = role.trim().toLowerCase();
    _updateNavigationForRole(normalizedRole);

    try {
      final dashboardStats = await _apiService.getDashboardStats();
      final vouchersList = await _apiService.getVouchers();
      final accountsList = await _apiService.getAccounts();

      final pnlList = await _apiService.getProfitLoss();
      final notifs = await _apiService.getNotifications();
      List<dynamic> usersList = [];

      if (normalizedRole.contains('admin') || normalizedRole.contains('manager')) {
        usersList = await _apiService.getUsers();
      }

      if (mounted) {
        setState(() {
          _dashboardData = dashboardStats;
          _users = usersList;
          _vouchers = vouchersList;
          _accounts = accountsList;
          _unreadNotifCount = notifs['unread_count'] ?? 0;

          if (normalizedRole == 'admin') {
            _stats['active_users'] = _users
                .where((u) => u['is_active'] == 1 || u['is_active'] == true)
                .length;
          }

          // Calculate Dashboard Totals matching Web App Logic (YTD P&L)
          double totalIncome = 0.0;
          double totalExpense = 0.0;

          if (pnlList.isNotEmpty) {
            for (var item in pnlList) {
              String accType = item['type']?.toString() ?? '';
              double amount =
                  double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0;
              if (accType == 'Income') {
                totalIncome += amount.abs();
              } else if (accType == 'Expense') {
                totalExpense += amount.abs();
              }
            }
          } else {
            // Fallback to all-time account balances if P&L is empty
            for (var account in _accounts) {
              String accType = account['type']?.toString() ?? '';
              double balance =
                  double.tryParse(account['balance']?.toString() ?? '0') ?? 0.0;
              if (accType == 'Income') {
                totalIncome += balance.abs();
              } else if (accType == 'Expense') {
                totalExpense += balance.abs();
              }
            }
          }

          _stats['revenue'] = totalIncome;
          _stats['expenses'] = totalExpense;
          _stats['net_profit'] = totalIncome - totalExpense;

          // Compute Trends from analytics cash_flow if available
          if (_dashboardData.containsKey('analytics') &&
              _dashboardData['analytics'] != null &&
              _dashboardData['analytics'].containsKey('cash_flow')) {
            final cashFlow = _dashboardData['analytics']['cash_flow'];
            double prevIncome = 0, currIncome = 0;
            double prevExpense = 0, currExpense = 0;

            if (cashFlow['income'] != null &&
                (cashFlow['income'] as List).length >= 2) {
              int len = cashFlow['income'].length;
              currIncome = (cashFlow['income'][len - 1] as num).toDouble();
              prevIncome = (cashFlow['income'][len - 2] as num).toDouble();
            }
            if (cashFlow['expense'] != null &&
                (cashFlow['expense'] as List).length >= 2) {
              int len = cashFlow['expense'].length;
              currExpense = (cashFlow['expense'][len - 1] as num).toDouble();
              prevExpense = (cashFlow['expense'][len - 2] as num).toDouble();
            }

            double revChange = prevIncome == 0
                ? (currIncome > 0 ? 100 : 0)
                : ((currIncome - prevIncome) / prevIncome) * 100;
            double expChange = prevExpense == 0
                ? (currExpense > 0 ? 100 : 0)
                : ((currExpense - prevExpense) / prevExpense) * 100;
            double prevProfit = prevIncome - prevExpense;
            double currProfit = currIncome - currExpense;
            double profChange = prevProfit == 0
                ? (currProfit > 0 ? 100 : (currProfit < 0 ? -100 : 0))
                : ((currProfit - prevProfit) / prevProfit.abs()) * 100;

            _stats['revenue_trend'] = revChange >= 0
                ? '+${revChange.toStringAsFixed(1)}%'
                : '${revChange.toStringAsFixed(1)}%';
            _stats['expenses_trend'] = expChange >= 0
                ? '+${expChange.toStringAsFixed(1)}%'
                : '${expChange.toStringAsFixed(1)}%';
            _stats['profit_trend'] = profChange >= 0
                ? '+${profChange.toStringAsFixed(1)}%'
                : '${profChange.toStringAsFixed(1)}%';
          } else {
            _stats['revenue_trend'] = '+0.0%';
            _stats['expenses_trend'] = '+0.0%';
            _stats['profit_trend'] = '+0.0%';
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      print("Logout error: $e");
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (_isLoading) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor)),
      );
    }

    final normalizedRole = _userRole.trim().toLowerCase();
    final isManager = normalizedRole.contains('manager');

    Widget mainScaffold = Scaffold(
      backgroundColor: isManager ? const Color(0xFF0D0D17) : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return _buildDesktopLayout(constraints, isDark);
          } else {
            return _buildMobileLayout(isDark, themeProvider);
          }
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900
          ? _buildBottomNavigationBar(isDark)
          : null,
    );

    if (isManager) {
      return Theme(
        data: AppTheme.darkTheme,
        child: mainScaffold,
      );
    }

    return mainScaffold;
  }

  Widget _buildBottomNavigationBar(bool isDark) {
    final normalizedRole = _userRole.trim().toLowerCase();

    return Container(
      decoration: BoxDecoration(
        color: normalizedRole == 'manager' 
            ? const Color(0xFF0D0D17) 
            : (isDark ? const Color(0xFF1E293B) : Colors.white),
        border: Border(
            top: BorderSide(
                color: normalizedRole == 'manager' 
                    ? const Color(0xFF1F1F35) 
                    : Colors.grey.withOpacity(0.1), 
                width: 1)),
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _navigateToPageIndex,
        selectedItemColor: normalizedRole == 'manager'
            ? const Color(0xFFA855F7) // Amethyst Primary Light
            : const Color(0xFFFF6B00),
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
        items: _currentPages.map((page) {
          IconData iconData = page['icon'];
          String label = page['label'];
          
          // Match icons to mockup better
          if (page['id'] == 'dashboard') {
            iconData = LucideIcons.layoutGrid;
          }
          if (page['id'] == 'vouchers') {
            iconData = LucideIcons.arrowLeftRight;
          }
          if (page['id'] == 'reports') iconData = LucideIcons.barChart2;
          
          if (normalizedRole.contains('manager')) {
            if (page['id'] == 'users') {
              iconData = LucideIcons.users;
              label = 'TEAMS';
            }
            if (page['id'] == 'profile') {
              iconData = LucideIcons.user;
            }
          } else {
            if (page['id'] == 'profile' || page['id'] == 'settings') {
              iconData = LucideIcons.settings;
            }
          }

          return BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(iconData, size: 24),
            ),
            label: label,
          );
        }).toList(),
      ),
    );
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout(bool isDark, ThemeProvider themeProvider) {
    final normalizedRole = _userRole.trim().toLowerCase();
    String currentTab = _currentPages.isNotEmpty
        ? _currentPages[_selectedIndex]['id']
        : 'dashboard';

    // For Manager, we use a more integrated design where some pages have custom headers
    if (normalizedRole.contains('manager')) {
      return Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                if (_selectedIndex != index) {
                  setState(() => _selectedIndex = index);
                }
              },
              itemCount: _currentPages.length,
              itemBuilder: (context, index) {
                return _buildPageContent(index);
              },
            ),
          ),
        ],
      );
    }

    // Default Mobile Layout (Admin / Accountant / etc)
    Widget appBarContent;

    if (currentTab == 'dashboard') {
      appBarContent = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            color: Theme.of(context).cardTheme.color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (String result) {
              if (result == 'profile') {
                final profileIndex =
                    _currentPages.indexWhere((p) => p['id'] == 'profile');
                if (profileIndex != -1) {
                  _navigateToPageIndex(profileIndex);
                }
              } else if (result == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(LucideIcons.user,
                        size: 18,
                        color: isDark ? Colors.white : Colors.black87),
                    const SizedBox(width: 8),
                    Text('My Profile', style: GoogleFonts.plusJakartaSans()),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(LucideIcons.logOut,
                        size: 18, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text('Logout',
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 32,
                    height: 32,
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: const Color(0xFFFDE6D2),
                  backgroundImage: _profileImagePath != null &&
                          _profileImagePath!.isNotEmpty
                      ? (_profileImagePath!.startsWith('http') ||
                              _profileImagePath!.startsWith('uploads/'))
                          ? NetworkImage(_profileImagePath!.startsWith('http')
                                  ? _profileImagePath!
                                  : "${ApiService.baseUrl.replaceAll('/api', '')}/$_profileImagePath")
                              as ImageProvider
                          : FileImage(File(_profileImagePath!))
                      : null,
                  radius: 20,
                  child: _profileImagePath == null || _profileImagePath!.isEmpty
                      ? const Icon(LucideIcons.user, color: Colors.orange)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1D23),
                      ),
                    ),
                    Text(
                      _userRole.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsScreen()),
                  );
                  _loadUserData();
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isDark ? Colors.grey[900] : const Color(0xFFFFF2E6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.bell,
                          color: Color(0xFFFF6B00), size: 18),
                    ),
                    if (_unreadNotifCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _unreadNotifCount > 9
                                ? '9+'
                                : _unreadNotifCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _logout,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : const Color(0xFFFFF2E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout,
                      color: Color(0xFFFF6B00), size: 18),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (currentTab == 'accounts') {
      appBarContent = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Accounts',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ThemeToggleButton(),
              TextButton(
                onPressed: () {},
                child: Text('Edit',
                    style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              )
            ],
          ),
        ],
      );
    } else if (currentTab == 'vouchers') {
      appBarContent = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(LucideIcons.chevronLeft,
                color: Color(0xFF2563EB), size: 28),
            label: Text("Back",
                style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF2563EB), fontSize: 16)),
            onPressed: () => _navigateToPage('dashboard'),
          ),
          Text(
            'Voucher Ledger',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ThemeToggleButton(),
              IconButton(
                icon: const Icon(LucideIcons.search,
                    color: Color(0xFF2563EB), size: 24),
                onPressed: () {},
              )
            ],
          ),
        ],
      );
    } else if (currentTab == 'reports') {
      appBarContent = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(LucideIcons.arrowLeft,
                color: isDark ? Colors.white : Colors.black87),
            onPressed: () => _navigateToPage('dashboard'),
          ),
          Text(
            'Financial Reports',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemeToggleButton(),
            ],
          ),
        ],
      );
    } else if (currentTab == 'users') {
      appBarContent = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(LucideIcons.arrowLeft,
                color: isDark ? Colors.white : Colors.black87),
            onPressed: () => setState(() => _selectedIndex = 0),
          ),
          Text(
            'User Management',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ThemeToggleButton(),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(LucideIcons.moreVertical,
                    color: isDark ? Colors.white : Colors.black87),
                onPressed: () {},
              ),
            ],
          ),
        ],
      );
    } else if (currentTab == 'profile') {
      appBarContent = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(LucideIcons.arrowLeft,
                color: isDark ? Colors.white : Colors.black87),
            onPressed: () => _navigateToPage('dashboard'),
          ),
          Text(
            'Profile',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ThemeToggleButton(),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Save',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      appBarContent = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.barChart2,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FINSIGHT',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          letterSpacing: 1.5)),
                  Text(
                      _currentPages.isNotEmpty
                          ? _currentPages[_selectedIndex]['label']
                          : 'Dashboard',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(isDark ? Icons.light_mode : LucideIcons.moon),
                onPressed: () => themeProvider.toggleTheme(),
                style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).cardTheme.color,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8)),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _logout,
                style: IconButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8)),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        // App Bar
        Container(
          padding:
              const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: appBarContent,
        ),
        if (currentTab == 'dashboard' && !isDark)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.activity,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Finsight Dashboard",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1D23),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Real-time accounting overview",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        // Body Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                if (_selectedIndex != index) {
                  setState(() => _selectedIndex = index);
                }
              },
              itemCount: _currentPages.length,
              itemBuilder: (context, index) => _buildPageContent(index),
            ),
          ),
        ),
      ],
    );
  }

  // --- DESKTOP LAYOUT ---
  Widget _buildDesktopLayout(BoxConstraints constraints, bool isDark) {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 260,
          color: Theme.of(context).cardTheme.color,
          child: Column(
            children: [
              // Brand
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.barChart2,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'FINSIGHT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Menu
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _currentPages.length,
                  itemBuilder: (context, index) {
                    final page = _currentPages[index];
                    return _buildSidebarItem(
                        index, page['label'], page['icon']);
                  },
                ),
              ),
            ],
          ),
        ),

        // Main Content Area
        Expanded(
          child: Column(
            children: [
              // Header
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                color: Theme.of(context).cardTheme.color,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentPages[_selectedIndex]['label'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(children: [
                      IconButton(
                        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                        onPressed: () {
                          Provider.of<ThemeProvider>(context, listen: false)
                              .toggleTheme();
                        },
                      ),
                      const SizedBox(width: 8),
                      // ADD LOGOUT HERE
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.logout,
                              color: Colors.white, size: 20),
                        ),
                        onPressed: _logout,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Stack(children: [
                          const Icon(LucideIcons.bell),
                          if (_unreadNotifCount > 0)
                            Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle)))
                        ]),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsScreen()),
                          );
                          _loadUserData();
                        },
                      ),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        radius: 20.0,
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage: _profileImagePath != null &&
                                _profileImagePath!.isNotEmpty
                            ? (_profileImagePath!.startsWith('http') ||
                                    _profileImagePath!.startsWith('uploads/'))
                                ? NetworkImage(_profileImagePath!
                                            .startsWith('http')
                                        ? _profileImagePath!
                                        : "${ApiService.baseUrl.replaceAll('/api', '')}/$_profileImagePath")
                                    as ImageProvider
                                : FileImage(File(_profileImagePath!))
                            : null,
                        child: _profileImagePath == null ||
                                _profileImagePath!.isEmpty
                            ? Text(
                                _userName.isNotEmpty
                                    ? _userName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(color: Colors.white))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(_userName),
                    ]),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      if (_selectedIndex != index) {
                        setState(() => _selectedIndex = index);
                      }
                    },
                    itemCount: _currentPages.length,
                    itemBuilder: (context, index) => _buildPageContent(index),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? theme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isSelected ? Colors.white : theme.iconTheme.color, size: 20),
        title: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color:
                isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: () => _navigateToPageIndex(index),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPageContent(int index) {
    if (index >= _currentPages.length) return const SizedBox.shrink();
    final pageId = _currentPages[index]['id'];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final normalizedRole = _userRole.trim().toLowerCase();

    // Use manager-specific views if the role is manager
    if (normalizedRole.contains('manager')) {
      switch (pageId) {
        case 'dashboard':
          return ManagerDashboardView(
            userData: {
              'first_name': _userName,
              'role': _userRole,
              'email': _email,
              'phone': _phone,
              'id': _userId,
              'profileImage': _profileImagePath,
            },
            dashboardData: _dashboardData,
            vouchers: _vouchers,
            unreadNotificationsCount: _unreadNotifCount,
            isDark: isDark,
            totalIncome: _stats['revenue'] ?? 0.0,
            totalExpense: _stats['expenses'] ?? 0.0,
            onNavigate: _navigateToPage,
            userRole: _userRole,
            currentUserId: _userId,
          );
        case 'accounts':
          return ManagerAccountsView(
            accounts: _accounts,
            isDark: isDark,
            totalIncome: _stats['revenue'] ?? 0.0,
            totalExpense: _stats['expenses'] ?? 0.0,
            onNavigate: _navigateToPage,
            onRefresh: _loadUserData,
          );
        case 'vouchers':
          return ManagerVouchersView(
            vouchers: _vouchers,
            isDark: isDark,
            totalIncome: _stats['revenue'] ?? 0.0,
            totalExpense: _stats['expenses'] ?? 0.0,
            currentUserId: _userId,
            userRole: _userRole,
            onNavigate: _navigateToPage,
            onRefresh: _loadUserData,
          );
        case 'reports':
          return ManagerReportsView(
            dashboardData: _dashboardData,
            isDark: isDark,
            onNavigate: _navigateToPage,
            onRefresh: _loadUserData,
          );
        case 'profile':
          return ManagerProfileView(
            userData: {
              'first_name': _userName,
              'role': _userRole,
              'id': _userId,
              'email': _email,
              'phone': _phone,
            },
            vouchers: _vouchers,
            unreadNotificationsCount: _unreadNotifCount,
            profileImagePath: _profileImagePath,
            isDark: isDark,
            onLogout: _logout,
            onRefresh: _loadUserData,
            onNavigate: _navigateToPage,
          );
        case 'users':
          return ManagerTeamView(
            users: _users,
            isDark: isDark,
            onNavigate: _navigateToPage,
          );
      }
    }

    // Default views for other roles
    switch (pageId) {
      case 'dashboard':
        return _buildDashboardContent();
      case 'users':
        return _buildUsersContent();
      case 'accounts':
        return _buildAccountsContent();
      case 'vouchers':
        return _buildVouchersContent();
      case 'reports':
        return const ReportsHomeScreen();
      case 'profile':
        return _buildProfileContent();
      default:
        return const Center(child: Text("Page Not Found"));
    }
  }

  Widget _buildProfileContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Orange Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B00),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.chevronLeft,
                          color: Colors.white),
                      onPressed: () => _navigateToPage('dashboard'),
                    ),
                    Text(
                      "Profile",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const CompanySettingsScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.settings,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        image: _profileImagePath != null &&
                                _profileImagePath!.isNotEmpty
                            ? DecorationImage(
                                image: (_profileImagePath!.startsWith('http') ||
                                        _profileImagePath!
                                            .startsWith('uploads/'))
                                    ? NetworkImage(_profileImagePath!
                                                .startsWith('http')
                                            ? _profileImagePath!
                                            : "${ApiService.baseUrl.replaceAll('/api', '')}/$_profileImagePath")
                                        as ImageProvider
                                    : FileImage(File(_profileImagePath!)),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: NetworkImage(
                                    "https://i.pravatar.cc/150?img=12"),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            // Check Permissions
                            if (Platform.isAndroid) {
                              if (await Permission.photos.isDenied) {
                                await Permission.photos.request();
                              }
                              if (await Permission.storage.isDenied) {
                                await Permission.storage.request();
                              }
                            }

                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 1024,
                                maxHeight: 1024);

                            if (image != null) {
                              final croppedFile =
                                  await ImageCropper().cropImage(
                                sourcePath: image.path,
                                aspectRatio: const CropAspectRatio(
                                    ratioX: 1.0, ratioY: 1.0),
                                uiSettings: [
                                  AndroidUiSettings(
                                      toolbarTitle: 'Crop Profile Photo',
                                      toolbarColor: const Color(0xFFFF6B00),
                                      toolbarWidgetColor: Colors.white,
                                      initAspectRatio:
                                          CropAspectRatioPreset.square,
                                      lockAspectRatio: true),
                                  IOSUiSettings(
                                    title: 'Crop Profile Photo',
                                  ),
                                ],
                              );

                              if (croppedFile != null) {
                                if (mounted) setState(() => _isLoading = true);
                                final uploadedPath = await _apiService
                                    .uploadProfileImage(croppedFile.path);

                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                    _profileImagePath =
                                        uploadedPath ?? croppedFile.path;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(uploadedPath != null
                                            ? 'Profile picture updated successfully'
                                            : 'Photo cropped but upload failed')),
                                  );

                                  if (uploadedPath != null) {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final userDataString =
                                        prefs.getString('user_data');
                                    if (userDataString != null) {
                                      final userData =
                                          jsonDecode(userDataString);
                                      userData['profile_image'] = uploadedPath;
                                      await prefs.setString(
                                          'user_data', jsonEncode(userData));
                                    }
                                  } else {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString(
                                        'profile_image_path_$_userId',
                                        croppedFile.path);
                                  }
                                }
                              }
                            }
                          } catch (e) {
                            debugPrint("Error picking/cropping image: $e");
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error updating photo: $e'),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.edit2,
                              size: 14, color: Color(0xFFFF6B00)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _userName,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final userDataString = prefs.getString('user_data');
                        if (userDataString != null) {
                          final userData = jsonDecode(userDataString);
                          if (mounted) {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) =>
                                      ProfileEditScreen(userData: userData)),
                            );
                            if (updated == true) {
                              _loadUserData();
                            }
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.edit,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
                Text(
                  _email,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_userRole.toUpperCase()} ACCOUNT",
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFFF6B00),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Account Settings List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ACCOUNT SETTINGS",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(
                          LucideIcons.mail,
                          "Email",
                          _email.isNotEmpty ? _email : "user@finsight.com",
                          isDark),
                      _buildInfoTile(
                          LucideIcons.phone,
                          "Phone",
                          _phone.isNotEmpty ? _phone : "+91 9876543210",
                          isDark),
                      _buildInfoTile(
                          LucideIcons.briefcase,
                          "Employee ID",
                          "EMP-${_userId.isNotEmpty ? _userId : '4421'}",
                          isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "SECURITY & PREFERENCES",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const CompanySettingsScreen()),
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                          child: const Icon(LucideIcons.building,
                              color: Color(0xFF475569), size: 18),
                        ),
                        title: Text("Company Details",
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87)),
                        subtitle: Text("Manage organization info",
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, color: Colors.grey)),
                        trailing:
                            const Icon(LucideIcons.chevronRight, size: 16),
                      ),
                      const Divider(height: 1, indent: 60),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: Color(0xFFFFF2E6), shape: BoxShape.circle),
                          child: const Icon(LucideIcons.lock,
                              color: Color(0xFFFF6B00), size: 18),
                        ),
                        title: Text("Change Password",
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1D23))),
                        trailing: Icon(LucideIcons.chevronRight,
                            size: 16, color: Colors.grey[400]),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) =>
                                    const SecuritySettingsScreen())),
                      ),
                      Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: Color(0xFFFFF2E6), shape: BoxShape.circle),
                          child: const Icon(LucideIcons.fingerprint,
                              color: Color(0xFFFF6B00), size: 18),
                        ),
                        title: Text("Biometric Login",
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1D23))),
                        trailing: Switch(
                            value: true,
                            onChanged: (v) {},
                            activeThumbColor: const Color(0xFFFF6B00)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Logout Button
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.logOut,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        "Logout",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    "FINSIGHT ADMIN V2.5.0",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[400],
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionItem(
      String title,
      String subtitle,
      String amount,
      IconData icon,
      String typeLabel,
      Color amountColor,
      bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.1)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : const Color(0xFFF1F5F9),
                shape: BoxShape.circle),
            child: Icon(icon,
                color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark ? Colors.grey[500] : Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          )),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: amountColor)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(typeLabel,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        color: isDark ? Colors.grey[400] : Colors.grey[600])),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: theme.primaryColor),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
      ),
    );
  }

  // --- USERS PAGE ---
  Widget _buildDashboardContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double safeRevenue = 0.0;
    double safeExpense = 0.0;

    List<FlSpot> incomeSpots = [];
    List<FlSpot> profitSpots = [];

    if (_vouchers.isNotEmpty) {
      final validVouchers = _vouchers
          .where((v) => v['status'] != 'Rejected')
          .toList()
          .reversed
          .toList();
          
      if (validVouchers.isNotEmpty) {
        for (int i = 0; i < validVouchers.length; i++) {
          final v = validVouchers[i];
          final type = (v['voucher_type_name'] ?? '').toString().toLowerCase();
          double amt = double.tryParse(v['total_debit']?.toString() ?? '0') ?? 0.0;

          if (type == 'receipt') {
            safeRevenue += amt;
          } else if (type == 'payment') {
            safeExpense += amt;
          }

          incomeSpots.add(FlSpot(i.toDouble(), safeRevenue));
          profitSpots.add(FlSpot(i.toDouble(), safeRevenue - safeExpense));
        }
      }
    }

    if (incomeSpots.isEmpty) {
      incomeSpots = [const FlSpot(0, 0), const FlSpot(1, 0)];
      profitSpots = [const FlSpot(0, 0), const FlSpot(1, 0)];
    } else if (incomeSpots.length == 1) {
      incomeSpots.insert(0, const FlSpot(-1, 0));
      profitSpots.insert(0, const FlSpot(-1, 0));
    }

    String incomeTrendStr = "+0.0%";
    String profitTrendStr = "+0.0%";
    if (incomeSpots.length >= 2) {
      double currInc = incomeSpots.last.y;
      double prevInc = incomeSpots[incomeSpots.length - 2].y;
      double revChange = prevInc == 0 ? (currInc > 0 ? 100 : 0) : ((currInc - prevInc) / prevInc) * 100;
      incomeTrendStr = revChange >= 0 ? '+${revChange.toStringAsFixed(1)}%' : '${revChange.toStringAsFixed(1)}%';

      double currProf = profitSpots.last.y;
      double prevProf = profitSpots[profitSpots.length - 2].y;
      double profChange = prevProf == 0 ? (currProf > 0 ? 100 : (currProf < 0 ? -100 : 0)) : ((currProf - prevProf) / prevProf.abs()) * 100;
      profitTrendStr = profChange >= 0 ? '+${profChange.toStringAsFixed(1)}%' : '${profChange.toStringAsFixed(1)}%';
    }

    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line Chart 1: Cash Flow
            _buildPremiumChartCard(
              title: "CASH FLOW",
              amount: "₹${NumberFormat('#,##0.00').format(safeRevenue)}",
              percentage: incomeTrendStr,
              isPositive: !incomeTrendStr.contains('-'),
              spots: incomeSpots.length < 2
                  ? [const FlSpot(0, 0), const FlSpot(1, 1)]
                  : incomeSpots,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            // Line Chart 2: Profit Trend
            _buildPremiumChartCard(
              title: "PROFIT TREND",
              amount:
                  "${(safeRevenue - safeExpense) >= 0 ? '+' : ''}₹${NumberFormat('#,##0.00').format(safeRevenue - safeExpense)}",
              percentage: profitTrendStr,
              isPositive: !profitTrendStr.contains('-'),
              spots: profitSpots.length < 2
                  ? [const FlSpot(0, 0), const FlSpot(1, 0.5)]
                  : profitSpots,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            Text(
              "Financial Metrics",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1D23),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildMetricCard(
                  "New Voucher",
                  LucideIcons.scrollText,
                  const Color(0xFFFF6B00),
                  const Color(0xFFFFF2E6),
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const AddVoucherScreen())),
                  isDark,
                ),
                _buildMetricCard(
                  "Add Account",
                  LucideIcons.landmark,
                  const Color(0xFF16A34A),
                  const Color(0xFFDCFCE7),
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const AddAccountScreen())),
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Transactions",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87)),
                GestureDetector(
                  onTap: () => _navigateToPage('vouchers'), // Vouchers tab
                  child: Text("View All",
                      style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 12),
            if (_vouchers.isEmpty)
              _buildEmptyState("No Activity", "You have no transactions",
                  LucideIcons.history)
            else
              ..._vouchers.take(3).map((v) {
                final type = v['voucher_type_name']?.toString().toLowerCase() ??
                    'general';
                final amt =
                    double.tryParse(v['total_debit']?.toString() ?? '0') ?? 0;
                final isPayment = type == 'payment';
                final isReceipt = type == 'receipt';
                final sign = isPayment ? '-' : (isReceipt ? '+' : '');
                final color = isPayment
                    ? Colors.redAccent
                    : (isReceipt
                        ? Colors.greenAccent
                        : (isDark ? Colors.white : Colors.black87));
                return _buildRecentTransactionItem(
                    v['narration'] ?? 'Transaction',
                    "${v['voucher_date']} • ${v['account_name']}",
                    "$sign₹${amt.toStringAsFixed(2)}",
                    isPayment
                        ? LucideIcons.arrowUpRight
                        : (isReceipt
                            ? LucideIcons.arrowDownLeft
                            : LucideIcons.arrowRight),
                    type.toUpperCase(),
                    color,
                    isDark);
              }),
          ],
        ));
  }

  Widget _buildPremiumChartCard({
    required String title,
    required String amount,
    required String percentage,
    required bool isPositive,
    required List<FlSpot> spots,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFFE6FFFA)
                      : const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive
                          ? LucideIcons.trendingUp
                          : LucideIcons.trendingDown,
                      color: isPositive
                          ? const Color(0xFF38A169)
                          : const Color(0xFFE53E3E),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      percentage,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPositive
                            ? const Color(0xFF38A169)
                            : const Color(0xFFE53E3E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1D23),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'MON',
                          'TUE',
                          'WED',
                          'THU',
                          'FRI',
                          'SAT',
                          'SUN'
                        ];
                        if (value % 2 == 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFFFF6B00),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B00).withOpacity(0.1),
                          const Color(0xFFFF6B00).withOpacity(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, IconData icon, Color iconColor,
      Color iconBg, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isDark ? const Color(0xFF1E40AF).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1D23),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
      IconData icon, String label, String value, bool isDark) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
      subtitle: Text(value,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87)),
    );
  }

  Widget _buildUsersContent() {
    return UserManagementScreen(
      users: _users,
      onRefresh: _loadUserData,
      currentUserId: _userId,
    );
  }

  // --- VOUCHERS PAGE ---
  Widget _buildVouchersContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    List<dynamic> filteredVouchers = _vouchers.where((v) {
      final type = (v['voucher_type_name'] ?? '').toString().toLowerCase();
      final matchesType = _selectedVoucherType == 'All Types' ||
          (_selectedVoucherType == 'Payments' && type == 'payment') ||
          (_selectedVoucherType == 'Receipts' && type == 'receipt');

      final searchLower = _voucherSearchController.text.toLowerCase();
      final matchesSearch = (v['voucher_number'] ?? '')
              .toString()
              .toLowerCase()
              .contains(searchLower) ||
          (v['narration'] ?? '').toString().toLowerCase().contains(searchLower);

      return matchesType && matchesSearch;
    }).toList();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B00),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B00).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.fileText,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Vouchers",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.plusCircle,
                          color: Colors.white, size: 28),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddVoucherScreen()),
                        );
                        if (result == true) {
                          _loadUserData();
                        }
                      },
                      tooltip: 'New Voucher',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _voucherSearchController,
                    onChanged: (val) => setState(() {}),
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Search vouchers...",
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(LucideIcons.search,
                          color: Color(0xFFFF6B00)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Segmented Control
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          _buildSegmentButton("All", "All Types", isDark),
                          _buildSegmentButton("Payments", "Payments", isDark),
                          _buildSegmentButton("Receipts", "Receipts", isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFFF6B00)))
                    else if (filteredVouchers.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 48),
                            Icon(LucideIcons.fileX,
                                size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text("No Vouchers Found",
                                style: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey[400], fontSize: 16)),
                          ],
                        ),
                      )
                    else ...[
                      Text(
                        "RECENT TRANSACTIONS",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[500],
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ]),
                ),
              ),
              if (!_isLoading && filteredVouchers.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildMockupVoucherListItem(
                          filteredVouchers[index], isDark),
                      childCount: filteredVouchers.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentButton(String label, String value, bool isDark) {
    bool isSelected = _selectedVoucherType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedVoucherType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFFFF6B00))
                    : Colors.grey[500],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMockupVoucherListItem(Map<String, dynamic> v, bool isDark) {
    final type = (v['voucher_type_name'] ?? '').toString().toLowerCase();

    IconData icon = LucideIcons.fileText;
    if (type.contains('payment')) icon = LucideIcons.wallet;
    if (type.contains('receipt')) icon = LucideIcons.fileInput;

    double amt = double.tryParse(v['total_debit']?.toString() ?? '0') ??
        double.tryParse(v['total_credit']?.toString() ?? '0') ??
        0;

    String status =
        (v['status_name'] ?? v['status'] ?? 'PENDING').toString().toUpperCase();

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoucherDetailScreen(
              voucher: v,
              userRole: _userRole,
              currentUserId: _userId,
            ),
          ),
        );
        if (result == true) _loadUserData();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: const Border(
            left: BorderSide(color: Color(0xFFFF6B00), width: 6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2E6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: const Color(0xFFFF6B00), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${v['from_account'] ?? 'Unknown'} → ${v['to_account'] ?? 'Expense'}",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A1D23),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${v['voucher_number']} • 10:45 AM",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (status == "VERIFIED" ||
                              status == "POSTED" ||
                              status == "APPROVED")
                          ? const Color(0xFFE6FFFA)
                          : (status == "REJECTED"
                              ? const Color(0xFFFFF5F5)
                              : (status == "DRAFT" || status == "PENDING"
                                  ? Colors.grey.withOpacity(0.1)
                                  : const Color(0xFFFFF7E6))),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: (status == "VERIFIED" ||
                                status == "POSTED" ||
                                status == "APPROVED")
                            ? const Color(0xFF38A169)
                            : (status == "REJECTED"
                                ? const Color(0xFFE53E3E)
                                : const Color(0xFFD69E2E)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AMOUNT",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF6B00),
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    "${type.contains('payment') ? '-' : (type.contains('receipt') ? '+' : '')}₹${NumberFormat('#,##0.00').format(amt)}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: type.contains('payment')
                          ? const Color(0xFFE53E3E)
                          : (type.contains('receipt')
                              ? const Color(0xFF38A169)
                              : (isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1D23))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ACCOUNTS PAGE ---
  Widget _buildAccountsContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double totalNetWorth = 0;
    for (var a in _accounts) {
      totalNetWorth += (double.tryParse(a['balance']?.toString() ?? '0') ?? 0);
    }

    final filteredAccounts = _accounts.where((acc) {
      final name = (acc['name'] ?? '').toString().toLowerCase();
      final code = (acc['code'] ?? '').toString().toLowerCase();
      final search = _accountSearchController.text.toLowerCase();
      return name.contains(search) || code.contains(search);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (c) => const AddAccountScreen()));
          if (result == true) _loadUserData();
        },
        backgroundColor: const Color(0xFFFF6B00),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Finsight Accounts",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1D23),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Search Bar
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _accountSearchController,
                onChanged: (val) => setState(() {}),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Search accounts...",
                  hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
                  prefixIcon:
                      const Icon(LucideIcons.search, color: Color(0xFFFF6B00)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            // Total Net Worth Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B00), Color(0xFFFF8E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B00).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Net Worth",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${NumberFormat('#,##0.00').format(totalNetWorth)}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.trendingUp,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "+4.2%",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "vs last month",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "MY ACCOUNTS",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[500],
                    letterSpacing: 1,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "View All",
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFFF6B00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredAccounts.length,
              itemBuilder: (context, index) =>
                  _buildMockupAccountCard(filteredAccounts[index], isDark),
            ),
            const SizedBox(height: 32),
            Text(
              "CASH FLOW HISTORY",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.grey[500],
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: 10,
                  barGroups: [
                    _barData(0, 4),
                    _barData(1, 6),
                    _barData(2, 5),
                    _barData(3, 8),
                    _barData(4, 9),
                    _barData(5, 7),
                    _barData(6, 6),
                  ],
                  titlesData: const FlTitlesData(show: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: x == 4 ? const Color(0xFFFF6B00) : const Color(0xFFFFCCAC),
          width: 25,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildMockupAccountCard(Map<String, dynamic> acc, bool isDark) {
    double bal = double.tryParse(acc['balance']?.toString() ?? '0') ?? 0;
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditAccountScreen(account: acc),
          ),
        );
        if (result == true) _loadUserData();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2E6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(LucideIcons.landmark,
                  color: Color(0xFFFF6B00), size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    acc['name'] ?? "Operating Account",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1D23),
                    ),
                  ),
                  Text(
                    "**** ${acc['code'] ?? '8821'}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${NumberFormat('#,##0.00').format(bal)}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF6B00),
                  ),
                ),
                Row(
                  children: [
                    const Icon(LucideIcons.activity,
                        size: 10, color: Color(0xFF38A169)),
                    const SizedBox(width: 4),
                    Text(
                      "REAL-TIME",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF38A169),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
