import 'package:flutter/material.dart';
import 'package:tenant_mgmt_sys/core/services/bills_service.dart';

class BillProvider extends ChangeNotifier {
  final BillService _billService = BillService();

  Map<String, dynamic>? _currentBill;
  List<Map<String, dynamic>> _allBills = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic>? get currentBill => _currentBill;
  List<Map<String, dynamic>> get allBills => _allBills;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get bill
  Future<void> loadBill({
    required String landlordId,
    required String houseNo,
    required String monthYear,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentBill = await _billService.getBill(
        landlordId,
        houseNo,
        monthYear,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get all bills sorted
  Future<void> loadAllBills({
    required String landlordId,
    required String houseNo,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allBills = await _billService.getAllBillsSorted(
        landlordId,
        houseNo,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create bill
  Future<bool> createBill({
    required String landlordId,
    required String name,
    required String houseNo,
    required String billMonth,
    required String rent,
    required String waterBill,
    required String gasBill,
    required String cleaningCharges,
    required String previousBalance,
    required String totalAmount,
    required String paidAmount,
    required String paymentStatus,
    required DateTime paymentDate,
    required DateTime billGeneratedDate,
    required String remainingBalance,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // createBill returns Future<void>
      await _billService.createBill(
        landlordId: landlordId,
        name: name,
        houseNo: houseNo,
        billMonth: billMonth,
        rent: rent,
        waterBill: waterBill,
        gasBill: gasBill,
        cleaningCharges: cleaningCharges,
        previousBalance: previousBalance,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        paymentStatus: paymentStatus,
        paymentDate: paymentDate,
        billGeneratedDate: billGeneratedDate,
        remainingBalance: remainingBalance,
      );

      // Reload the bill after creating
      await loadBill(
        landlordId: landlordId,
        houseNo: houseNo,
        monthYear: billMonth,
      );

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

  // Update bill (payment)
  Future<bool> updateBill({
    required String landlordId,
    required String houseNo,
    required String billMonth,
    required String paidAmount,
    required String paymentStatus,
    required DateTime paymentDate,
    required String remainingBalance,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // updateBill returns void (not Future)
      _billService.updateBill(
        landlordId: landlordId,
        houseNo: houseNo,
        billMonth: billMonth,
        paidAmount: paidAmount,
        paymentStatus: paymentStatus,
        paymentDate: paymentDate,
        remainingBalance: remainingBalance,
      );

      // Reload the bill after updating
      await loadBill(
        landlordId: landlordId,
        houseNo: houseNo,
        monthYear: billMonth,
      );

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

  // Get previous balance
  Future<int> getPreviousBalance({
    required String landlordId,
    required String houseNo,
    required String currentMonth,
  }) async {
    try {
      return await _billService.getPreviousBalance(
        landlordId,
        houseNo,
        currentMonth,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return 0;
    }
  }

  // Clear current bill
  void clearCurrentBill() {
    _currentBill = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}