import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tenant_mgmt_sys/core/services/auth_service.dart';
import 'package:tenant_mgmt_sys/core/services/bills_service.dart';
import 'package:tenant_mgmt_sys/core/services/tenant_service.dart';
import 'package:tenant_mgmt_sys/core/utils/calculation.dart';
import 'package:tenant_mgmt_sys/screens/billing/update_bill.dart';
import 'package:tenant_mgmt_sys/screens/tenants/add_tenant_screen.dart';
import 'package:tenant_mgmt_sys/screens/tenants/tenant_joining_details.dart';

class TenantDetailsScreen extends StatefulWidget {
  final String landlordId;
  final String houseNo;

  const TenantDetailsScreen({
    required this.landlordId,
    required this.houseNo,
  });

  @override
  State<TenantDetailsScreen> createState() => _TenantDetailsScreenState();
}

class _TenantDetailsScreenState extends State<TenantDetailsScreen> {
  // Services
  BillService billService = BillService();
  TenantService tenantService = TenantService();
  AuthService authService = AuthService();
  Calculation calculation = Calculation();

  // Data
  Map<String, dynamic>? tenant;
  Map<String, dynamic>? bill;

  List<String> monthYearList = [];
  String selectedMonthYear = "";

  @override
  void initState() {
    super.initState();
    monthYearList = _generateMonthYearList();
    selectedMonthYear = monthYearList.first;
    loadTenantData();
    loadBill();
  }

  List<String> _generateMonthYearList() {
    List<String> months = [
      "January", "February", "March", "April",
      "May", "June", "July", "August",
      "September", "October", "November", "December",
    ];

    List<String> result = [];
    DateTime now = DateTime.now();

    for (int i = 0; i < 24; i++) {
      DateTime date = DateTime(now.year, now.month - i, 1);
      String monthYear = "${months[date.month - 1]} ${date.year}";
      result.add(monthYear);
    }

    return result;
  }

  Future<void> loadTenantData() async {
    final data = await tenantService.getTenant(
      widget.landlordId,
      widget.houseNo,
    );

    setState(() {
      tenant = data;
    });
  }

  Future<void> loadBill() async {
    final data = await billService.getBill(
      widget.landlordId,
      widget.houseNo,
      selectedMonthYear,
    );

    setState(() {
      bill = data;
    });
  }

  // Complete delete function
  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Tenant"),
        content: const Text(
          "Are you sure you want to delete this tenant?\n\n"
              "This will permanently delete:\n"
              "• Tenant information\n"
              "• All bills\n"
              "• Login credentials\n\n"
              "This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 1. Delete all bills
      await billService.deleteAllBillsForTenant(
        widget.landlordId,
        widget.houseNo,
      );

      // 2. Delete tenant's user document
      await authService.deleteTenantUser(
        widget.houseNo,
        widget.landlordId,
      );

      // 3. Delete tenant document
      await tenantService.deleteTenant(
        widget.landlordId,
        widget.houseNo,
      );

      if (!mounted) return;

      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tenant deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Go back

    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return Colors.green;
      case 'PARTIAL':
        return Colors.orange;
      case 'UNPAID':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tenant Details")),
      body: tenant == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tenant Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tenant![TenantService.t_name],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddTenantScreen(
                                    landlordId: widget.landlordId,
                                    isUpdate: true,
                                    tName: tenant![TenantService.t_name],
                                    tPhone: tenant![TenantService.t_phNo],
                                    tHouseNumber: tenant![TenantService.t_houseNo],
                                    tAdvance: tenant![TenantService.t_advance],
                                    tRent: tenant![TenantService.t_rent],
                                    tRAmount: tenant![TenantService.t_receivedAmount],
                                    tJDate: (tenant![TenantService.t_joiningDate] as Timestamp).toDate(),
                                  ),
                                ),
                              );
                              loadTenantData();
                            },
                            icon: const Icon(Icons.edit, color: Colors.blue),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: _handleDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("House: ${tenant![TenantService.t_houseNo]}"),
                      Text("Phone: ${tenant![TenantService.t_phNo]}"),
                      Text("Rent: Rs ${tenant![TenantService.t_rent]}"),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TenantJoiningDetails(
                                  landlordId: widget.landlordId,
                                  houseNo: widget.houseNo,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text("View Joining Details"),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Month Selection
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: "Select Month",
              border: OutlineInputBorder(),
            ),
            value: selectedMonthYear,
            items: monthYearList.map((month) {
              return DropdownMenuItem(value: month, child: Text(month));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMonthYear = value!;
              });
              loadBill();
            },
          ),
          const SizedBox(height: 16),

          // Bill Card
          if (bill != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Bill for $selectedMonthYear",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text(
                            bill![BillService.t_paymentStatus],
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _getStatusColor(
                            bill![BillService.t_paymentStatus],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    _buildBillRow("Rent", bill![BillService.t_rent]),
                    _buildBillRow("Water Bill", bill![BillService.t_waterBill]),
                    _buildBillRow("Gas Bill", bill![BillService.t_gasBill]),
                    _buildBillRow("Cleaning", bill![BillService.t_cleaningCharges]),
                    _buildBillRow("Previous Balance", bill![BillService.t_previousBalance]),

                    const Divider(),

                    _buildBillRow(
                      "Total Amount",
                      bill![BillService.t_totalAmount],
                      isBold: true,
                    ),
                    _buildBillRow(
                      "Paid Amount",
                      bill![BillService.t_paidAmount],
                      color: Colors.green,
                    ),
                    _buildBillRow(
                      "Remaining Balance",
                      (int.parse(bill![BillService.t_totalAmount]) -
                          int.parse(bill![BillService.t_paidAmount]))
                          .toString(),
                      isBold: true,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 16),

                    // Update Payment Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateBill(
                                widget.houseNo,
                                selectedMonthYear,
                                widget.landlordId,
                              ),
                            ),
                          );
                          loadBill();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(7),
                          child: Text("Update Payment"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text("No bill generated for $selectedMonthYear"),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBillRow(
      String label,
      String amount, {
        bool isBold = false,
        Color? color,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "Rs $amount",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}