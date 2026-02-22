import 'package:flutter/material.dart';
import 'package:tenant_mgmt_sys/core/services/bills_service.dart';
import 'package:tenant_mgmt_sys/core/utils/calculation.dart';
import 'package:tenant_mgmt_sys/core/services/auth_service.dart';
import 'package:tenant_mgmt_sys/screens/auth/login_screen.dart';
import 'package:tenant_mgmt_sys/screens/tenants/tenant_joining_details.dart';

class TenantDashboard extends StatefulWidget {
  final String landlordId;
  final String houseNo;

  const TenantDashboard({
    required this.landlordId,
    required this.houseNo,
  });

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  BillService billService = BillService();
  Calculation calculation = Calculation();
  AuthService authService = AuthService();

  List<String> monthYearList = [];
  String selectedMonthYear = "";

  String? tenantName;

  @override
  void initState() {
    super.initState();
    monthYearList = _generateMonthYearList();
    selectedMonthYear = monthYearList.first;
    loadUserInfo();
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

  Future<void> loadUserInfo() async {
    final userData = await authService.getCurrentUserData();
    setState(() {
      tenantName = userData?['name'] ?? "Tenant";
    });
  }

  Future<void> logout() async {
    await authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
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
      appBar: AppBar(
        title: const Text("My Bills"),
        backgroundColor: const Color(0xFF1976D2),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${tenantName ?? 'Loading...'}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("House: ${widget.houseNo}"),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1976D2),
                        side: const BorderSide(color: Color(0xFF1976D2)),
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
            ),
          ),
          const SizedBox(height: 16),

          // Month Selection
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: "Select Month & Year",
              border: OutlineInputBorder(),
            ),
            value: selectedMonthYear,
            items: monthYearList.map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text(month),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMonthYear = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Bill Display
          FutureBuilder<Map<String, dynamic>?>(
            future: billService.getBill(
              widget.landlordId,
              widget.houseNo,
              selectedMonthYear,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text('No bill for $selectedMonthYear'),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final bill = snapshot.data!;
              int total = int.parse(bill[BillService.t_totalAmount]);
              int paid = int.parse(bill[BillService.t_paidAmount]);
              int remaining = calculation.remainingBalance(
                totalAmount: total,
                paidAmount: paid,
              );
              String paymentStatus = calculation.paymentStatus(
                totalAmount: total,
                paidAmount: paid,
              );

              return Card(
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
                              paymentStatus,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: _getStatusColor(paymentStatus),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),

                      _buildBillRow("Rent", bill[BillService.t_rent]),
                      _buildBillRow("Water Bill", bill[BillService.t_waterBill]),
                      _buildBillRow("Gas Bill", bill[BillService.t_gasBill]),
                      _buildBillRow("Cleaning", bill[BillService.t_cleaningCharges]),
                      _buildBillRow("Previous Balance", bill[BillService.t_previousBalance]),

                      const Divider(),

                      _buildBillRow(
                        "Total Amount",
                        bill[BillService.t_totalAmount],
                        isBold: true,
                      ),
                      _buildBillRow(
                        "Paid Amount",
                        bill[BillService.t_paidAmount],
                        color: Colors.green,
                      ),
                      _buildBillRow(
                        "Remaining Balance",
                        remaining.toString(),
                        isBold: true,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 16),

                      // Info Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "To make a payment, please contact your landlord",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String amount,
      {bool isBold = false, Color? color}) {
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