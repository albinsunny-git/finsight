import 'dart:io';

void main() {
  var file = File(
      r'c:\xampp\htdocs\finsight\mobile\lib\screens\reports\reports_home_screen.dart');
  var content = file.readAsStringSync();

  // 1. Remove Aged Payables
  content = content.replaceFirst('''      {
        'title': 'Aged Payables',
        'subtitle': 'Bills to be paid and their aging',
        'icon': LucideIcons.arrowUpRightSquare,
        'color': isDark ? Colors.indigoAccent : Colors.indigo,
        'route': (context) => const AnalyticsScreen(),
      },''', '');

  // 2. Add State for Date Range
  content = content.replaceFirst(
      'class _ReportsHomeScreenState extends State<ReportsHomeScreen> {',
      '''class _ReportsHomeScreenState extends State<ReportsHomeScreen> {
  DateTimeRange? _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  String _getRangeText() {
    if (_selectedDateRange == null) return "Select Date Range";
    final start = _selectedDateRange!.start;
    final end = _selectedDateRange!.end;
    return "\${start.day} \${_getMonthName(start.month)} - \${end.day} \${_getMonthName(end.month)} \${end.year}";
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF2563EB),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }
''');

  // 3. Replace _buildDateRangeSelector with a functional one
  var calStart = content.indexOf('Widget _buildDateRangeSelector');
  var calEnd = content.indexOf('  Widget _buildCalDay', calStart);
  if (calStart != -1 && calEnd != -1) {
    var newSelector =
        '''  Widget _buildDateRangeSelector(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.calendar, color: Color(0xFF2563EB), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Report Period", style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(_getRangeText(), style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
''';
    content = content.replaceRange(calStart, calEnd, newSelector);
  }

  file.writeAsStringSync(content);
}
