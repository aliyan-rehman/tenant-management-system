import 'package:flutter/material.dart';
import 'package:tenant_mgmt_sys/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _landlordId;
  String? _userRole;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String? get landlordId => _landlordId;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _landlordId != null;

  // Initialize - check if user is logged in
  Future<void> initialize() async {
    try {
      _landlordId = _authService.getCurrentUserId();
      if (_landlordId != null) {
        final userData = await _authService.getCurrentUserData();
        _userRole = userData?['role'] as String?;
      }
      notifyListeners();
    } catch (e) {
      _landlordId = null;
      _userRole = null;
      notifyListeners();
    }
  }

  // Login - returns role ("landlord" or "tenant")
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // loginUser returns role string
      final role = await _authService.loginUser(
        email: email,
        password: password,
      );

      _landlordId = _authService.getCurrentUserId();
      _userRole = role;
      _isLoading = false;
      notifyListeners();

      return role;  // Return "landlord" or "tenant"

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // registerUser returns UserCredential
      await _authService.registerUser(
        name: name,
        email: email,
        password: password,
      );

      _landlordId = _authService.getCurrentUserId();
      _userRole = 'landlord';
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

  // Create tenant credentials
  Future<Map<String, dynamic>?> createTenantUser({
    required String tenantName,
    required String houseNo,
    required String landlordId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credentials = await _authService.createTenantUser(
        tenantName: tenantName,
        houseNo: houseNo,
        landlordId: landlordId,
      );

      _isLoading = false;
      notifyListeners();
      return credentials;  // Returns {'email': ..., 'password': ...}

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.signOut();
    _landlordId = null;
    _userRole = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}