import 'package:flutter/material.dart';
import 'package:finsight_mobile/services/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _settings = {};
  bool _isLoading = false;

  Map<String, dynamic> get settings => _settings;
  bool get isLoading => _isLoading;

  String get companyName =>
      _settings['company_name'] ?? "FinSight Private Limited";
  String get companyTagline =>
      _settings['company_tagline'] ?? "Your Accurate Financial Partner";
  String get companyEmail => _settings['company_email'] ?? "";
  String get companyPhone => _settings['company_phone'] ?? "";
  String get companyAddress => _settings['company_address'] ?? "";

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _apiService.getCompanySettings();
      if (data.isNotEmpty) {
        _settings = data;
      }
    } catch (e) {
      print("Error loading settings in provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSettings(Map<String, dynamic> newSettings) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _apiService.updateCompanySettings(newSettings);
      if (success) {
        _settings = {..._settings, ...newSettings};
        return true;
      }
      return false;
    } catch (e) {
      print("Error updating settings in provider: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
