import 'package:flutter/material.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:finsight_mobile/services/api_service.dart';

class AddVoucherScreen extends StatefulWidget {
  const AddVoucherScreen({super.key});

  @override
  State<AddVoucherScreen> createState() => _AddVoucherScreenState();
}

class _AddVoucherScreenState extends State<AddVoucherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _isInit = true;

  // Data
  List<dynamic> _accounts = [];
  List<dynamic> _voucherTypes = [];

  // Form Fields
  int? _selectedTypeId;
  int? _fromAccountId;
  int? _toAccountId;
  final _dateController = TextEditingController();
  final _narrationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Entries
  final List<Map<String, dynamic>> _entries = [];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _fetchData();
    // Add two initial rows
    _addEntryRow();
    _addEntryRow();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final accounts = await _apiService.getAccounts();
    final types = await _apiService.getVoucherTypes();

    if (mounted) {
      setState(() {
        _accounts = accounts;
        _voucherTypes = types;
        if (_voucherTypes.isNotEmpty) {
          _selectedTypeId = int.tryParse(_voucherTypes[0]['id'].toString());
        }
        _isLoading = false;
        _isInit = false;
      });
    }
  }

  void _addEntryRow() {
    setState(() {
      _entries.add({
        'account_id': null,
        'description': '',
        'debit': 0.0,
        'credit': 0.0,
        'ctrl_desc': TextEditingController(),
        'ctrl_dr': TextEditingController(text: ''),
        'ctrl_cr': TextEditingController(text: ''),
      });
    });
  }

  void _removeEntryRow(int index) {
    setState(() {
      _entries.removeAt(index);
    });
    _calculateTotals();
  }

  double _totalDebit = 0;
  double _totalCredit = 0;

  void _calculateTotals() {
    double dr = 0;
    double cr = 0;
    for (var entry in _entries) {
      dr += double.tryParse(entry['ctrl_dr'].text) ?? 0;
      cr += double.tryParse(entry['ctrl_cr'].text) ?? 0;
    }
    setState(() {
      _totalDebit = dr;
      _totalCredit = cr;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF168194),
              onPrimary: Colors.white,
              surface: Color(0xFF1C242F),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate Totals
    if ((_totalDebit - _totalCredit).abs() > 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Total Debit must equal Total Credit'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    if (_totalDebit == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Voucher amount cannot be zero'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    setState(() => _isLoading = true);

    // Prepare Data
    List<Map<String, dynamic>> details = [];
    for (var entry in _entries) {
      if (entry['account_id'] == null) continue;
      double dr = double.tryParse(entry['ctrl_dr'].text) ?? 0;
      double cr = double.tryParse(entry['ctrl_cr'].text) ?? 0;

      if (dr == 0 && cr == 0) continue;

      details.add({
        'account_id': entry['account_id'],
        'description': entry['ctrl_desc'].text,
        'debit': dr,
        'credit': cr,
      });
    }

    if (details.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one valid entry')));
      return;
    }

    final data = {
      'voucher_type_id': _selectedTypeId,
      'from_account_id': _fromAccountId,
      'to_account_id': _toAccountId,
      'voucher_date': _dateController.text,
      'narration': _narrationController.text,
      'status': 'Draft',
      'details': details,
    };

    final result = await _apiService.createVoucher(data);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voucher created successfully')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to create')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color;
    final bgColor = theme.scaffoldBackgroundColor;
    final inputColor = theme.brightness == Brightness.dark
        ? Colors.white10
        : Colors.grey.shade100;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final hintColor =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('New Voucher',
            style: GoogleFonts.plusJakartaSans(
                color: theme.appBarTheme.titleTextStyle?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.appBarTheme.iconTheme,
        actions: [
          const ThemeToggleButton(),
          if (!_isLoading)
            IconButton(
              icon: const Icon(LucideIcons.check),
              onPressed: _submit,
              tooltip: 'Save',
            )
        ],
      ),
      body: _isInit
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  initialValue: _selectedTypeId,
                                  dropdownColor: cardColor,
                                  style: GoogleFonts.plusJakartaSans(
                                      color: textColor),
                                  decoration: InputDecoration(
                                    labelText: 'Type',
                                    labelStyle: TextStyle(color: hintColor),
                                    filled: true,
                                    fillColor: inputColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none),
                                  ),
                                  items: _voucherTypes.map((t) {
                                    return DropdownMenuItem<int>(
                                      value: int.tryParse(t['id'].toString()),
                                      child: Text(t['name'],
                                          style: TextStyle(color: textColor)),
                                    );
                                  }).toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedTypeId = val),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDate(context),
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      controller: _dateController,
                                      style: TextStyle(color: textColor),
                                      decoration: InputDecoration(
                                        labelText: 'Date',
                                        labelStyle: TextStyle(color: hintColor),
                                        filled: true,
                                        fillColor: inputColor,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 12),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none),
                                        suffixIcon: Icon(LucideIcons.calendar,
                                            size: 16, color: hintColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  initialValue: _fromAccountId,
                                  dropdownColor: cardColor,
                                  style: GoogleFonts.plusJakartaSans(
                                      color: textColor),
                                  decoration: InputDecoration(
                                    labelText: 'From Account',
                                    labelStyle: TextStyle(color: hintColor),
                                    filled: true,
                                    fillColor: inputColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none),
                                  ),
                                  items: _accounts.map((acc) {
                                    return DropdownMenuItem<int>(
                                      value: int.tryParse(acc['id'].toString()),
                                      child: Text(acc['name'],
                                          style: TextStyle(color: textColor),
                                          overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (val) =>
                                      setState(() => _fromAccountId = val),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  initialValue: _toAccountId,
                                  dropdownColor: cardColor,
                                  style: GoogleFonts.plusJakartaSans(
                                      color: textColor),
                                  decoration: InputDecoration(
                                    labelText: 'To Account',
                                    labelStyle: TextStyle(color: hintColor),
                                    filled: true,
                                    fillColor: inputColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none),
                                  ),
                                  items: _accounts.map((acc) {
                                    return DropdownMenuItem<int>(
                                      value: int.tryParse(acc['id'].toString()),
                                      child: Text(acc['name'],
                                          style: TextStyle(color: textColor),
                                          overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (val) =>
                                      setState(() => _toAccountId = val),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _narrationController,
                            style: TextStyle(color: textColor),
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Narration',
                              labelStyle: TextStyle(color: hintColor),
                              filled: true,
                              fillColor: inputColor,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none),
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Narration is required'
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text('Entries',
                        style: GoogleFonts.plusJakartaSans(
                            color: theme.textTheme.titleLarge?.color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    // Entries List
                    ..._entries.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map<String, dynamic> data = entry.value;
                      return _buildEntryRow(idx, data, cardColor!, inputColor,
                          textColor, hintColor);
                    }),

                    // Add Button
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _addEntryRow,
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('Add Line'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primaryColor,
                        side: BorderSide(color: theme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Totals
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: (_totalDebit - _totalCredit).abs() < 0.01
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Debit',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: hintColor, fontSize: 12)),
                              Text('₹${_totalDebit.toStringAsFixed(2)}',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Total Credit',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: hintColor, fontSize: 12)),
                              Text('₹${_totalCredit.toStringAsFixed(2)}',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Save Voucher',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEntryRow(int index, Map<String, dynamic> data, Color cardColor,
      Color inputColor, Color textColor, Color hintColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: data['account_id'],
                  dropdownColor: cardColor,
                  isExpanded: true,
                  style: GoogleFonts.plusJakartaSans(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Account',
                    labelStyle: TextStyle(color: hintColor),
                    filled: true,
                    fillColor: inputColor,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                  items: _accounts.map((acc) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(acc['id'].toString()),
                      child: Text("${acc['code']} - ${acc['name']}",
                          style: TextStyle(color: textColor),
                          overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => data['account_id'] = val);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(LucideIcons.trash2,
                    color: Colors.redAccent, size: 20),
                onPressed: () => _removeEntryRow(index),
              )
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: data['ctrl_desc'],
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: hintColor),
              filled: true,
              fillColor: inputColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: data['ctrl_dr'],
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Debit',
                    labelStyle: const TextStyle(color: Colors.greenAccent),
                    filled: true,
                    fillColor: inputColor,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                  onChanged: (val) {
                    _calculateTotals();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: data['ctrl_cr'],
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Credit',
                    labelStyle:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                    filled: true,
                    fillColor: inputColor,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => _calculateTotals(),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
