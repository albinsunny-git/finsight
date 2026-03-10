import 'dart:io';

void main() {
  var file = File(
      r'c:\xampp\htdocs\finsight\mobile\lib\screens\dashboard_screen.dart');
  var content = file.readAsStringSync();

  // 1. Add fl_chart import if missing
  if (!content.contains('import \'package:fl_chart/fl_chart.dart\';')) {
    content = content.replaceFirst(
        'import \'package:lucide_icons/lucide_icons.dart\';',
        'import \'package:lucide_icons/lucide_icons.dart\';\nimport \'package:fl_chart/fl_chart.dart\';');
  }

  // 2. Reduce Dashboard white spaces & Shrink Quick Actions
  content = content.replaceAll(
      'const SizedBox(height: 24),', 'const SizedBox(height: 12),');
  content = content.replaceAll(
      'const SizedBox(height: 16),', 'const SizedBox(height: 8),');
  content =
      content.replaceAll('childAspectRatio: 1.5,', 'childAspectRatio: 2.2,');

  // 3. Insert Trend Graph before Quick Actions
  var quickActionsText = 'Text("Quick Actions",';
  var graphCode = '''
        Text("Financial Trends",
            style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 20,
              barGroups: [
                _makeGroupData(0, 15, 10, isDark),
                _makeGroupData(1, 12, 8, isDark),
                _makeGroupData(2, 18, 14, isDark),
                _makeGroupData(3, 11, 7, isDark),
                _makeGroupData(4, 16, 12, isDark),
              ],
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                      return Text(days[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey));
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 20),
''';
  content =
      content.replaceFirst(quickActionsText, graphCode + quickActionsText);

  // 4. Update Profile Page (Remove Recent Activity, Add Company Details)
  // Find "Recent Activity" or where it's built in Profile
  if (content.contains('// Recent Activity')) {
    var start = content.indexOf('// Recent Activity');
    var end = content.indexOf('const SizedBox(height: 100)', start);
    if (end != -1) {
      content = content.replaceRange(start, end, '');
    }
  }

  // Add Company Details tile after Security
  var securityEnd = content.indexOf('],', content.indexOf('// Security'));
  if (securityEnd != -1) {
    var companyTile = '''
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Organization",
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87)),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? theme.cardTheme.color : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.building, color: Colors.orange, size: 20),
                ),
                title: Text("Company Settings",
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text("Update business profile and details", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                trailing: const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
                onTap: () {
                   // Navigate to Company Settings
                },
              ),
            ),
          ),
''';
    content = content.replaceFirst(
        'const SizedBox(height: 32),', companyTile, content.lastIndexOf('],'));
  }

  // 5. Add Helper Method for BarChart
  if (!content.contains('BarChartGroupData _makeGroupData')) {
    content = content.replaceFirst('  Widget _buildBodyContent() {', '''
  BarChartGroupData _makeGroupData(int x, double y1, double y2, bool isDark) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(toY: y1, color: const Color(0xFF2563EB), width: 8, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: y2, color: isDark ? Colors.redAccent : Colors.red, width: 8, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }

  Widget _buildBodyContent() {''');
  }

  file.writeAsStringSync(content);
}
