import 'package:flutter/material.dart';
import 'package:tenant_mgmt_sys/core/services/tenant_service.dart';

class TenantProvider extends ChangeNotifier {
  final TenantService _tenantService = TenantService();

  List<Map<String, dynamic>> _allTenants = [];
  Map<String, dynamic>? _selectedTenant;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Map<String, dynamic>> get allTenants => _allTenants;
  Map<String, dynamic>? get selectedTenant => _selectedTenant;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all tenants
  Future<void> loadTenants(String landlordId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allTenants = await _tenantService.readAllTenants(landlordId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get single tenant
  Future<void> getTenant(String landlordId, String houseNo) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedTenant = await _tenantService.getTenant(landlordId, houseNo);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create tenant
  Future<bool> createTenant({
    required String landlordId,
    required String name,
    required String phNo,
    required String houseNo,
    required String advance,
    required String rent,
    required String receivedAmount,
    required DateTime joiningDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // createTenant returns Future<void>
      await _tenantService.createTenant(
        landlordId: landlordId,
        name: name,
        phNo: phNo,
        houseNo: houseNo,
        advance: advance,
        rent: rent,
        receivedAmount: receivedAmount,
        joiningDate: joiningDate,
      );

      // Reload tenants after creating
      await loadTenants(landlordId);

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update tenant
  Future<bool> updateTenant({
    required String landlordId,
    required String houseNumber,
    required String name,
    required String phoneNumber,
    required String advance,
    required String rent,
    required String receivedAmount,
    DateTime? joiningDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // updateTenant returns Future<void>
      await _tenantService.updateTenant(
        landlordId: landlordId,
        houseNumber: houseNumber,
        name: name,
        phoneNumber: phoneNumber,
        advance: advance,
        rent: rent,
        receivedAmount: receivedAmount,
        joiningDate: joiningDate,
      );

      // Reload tenants after updating
      await loadTenants(landlordId);

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete tenant
  Future<bool> deleteTenant(String landlordId, String houseNo) async {
    _isLoading = true;
    notifyListeners();

    try {
      // deleteTenant returns Future<void>
      await _tenantService.deleteTenant(landlordId, houseNo);

      // Reload tenants after deleting
      await loadTenants(landlordId);

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Set selected tenant (for navigation)
  void setSelectedTenant(Map<String, dynamic> tenant) {
    _selectedTenant = tenant;
    notifyListeners();
  }

  // Clear selected tenant
  void clearSelectedTenant() {
    _selectedTenant = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}