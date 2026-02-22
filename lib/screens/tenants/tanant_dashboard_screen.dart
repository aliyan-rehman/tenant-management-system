import 'package:flutter/material.dart';
import 'package:tenant_mgmt_sys/core/services/bills_service.dart';
import 'package:tenant_mgmt_sys/core/utils/calculation.dart';
import 'package:tenant_mgmt_sys/core/utils/date_format.dart';
import 'package:tenant_mgmt_sys/core/services/auth_service.dart';
import 'package:tenant_mgmt_sys/screens/auth/login_screen.dart';

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

  String selectedMonth = "";
  List<String> monthsList = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
  ];

  String? tenantName;

  @override
  void initState() {
    super.initState();
    selectedMonth = monthsList[DateTime.now().month - 1];
    loadUserInfo();
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
      MaterialPageRoute(builder: (context) => LoginScreen()),
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
        title: Text("My Bills"),
        backgroundColor: const Color(0xFF1976D2),
        automaticallyImplyLeading: false,  // Remove back button
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${tenantName ?? 'Loading...'}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text("House: ${widget.houseNo}"),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Month Selection
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Select Month",
              border: OutlineInputBorder(),
            ),
            value: selectedMonth,
            items: monthsList.map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text(month),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMonth = value!;
              });
            },
          ),
          SizedBox(height: 16),

          // Bill Display
          FutureBuilder<Map<String, dynamic>?>(
            future: billService.getBill(
              widget.landlordId,
              widget.houseNo,
              selectedMonth,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No bill for $selectedMonth'),
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
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Bill for $selectedMonth",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Chip(
                            label: Text(
                              paymentStatus,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: _getStatusColor(paymentStatus),
                          ),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 8),

                      _buildBillRow("Rent", bill[BillService.t_rent]),
                      _buildBillRow("Water Bill", bill[BillService.t_waterBill]),
                      _buildBillRow("Gas Bill", bill[BillService.t_gasBill]),
                      _buildBillRow("Cleaning", bill[BillService.t_cleaningCharges]),
                      _buildBillRow("Previous Balance", bill[BillService.t_previousBalance]),

                      Divider(),

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

                      SizedBox(height: 16),

                      // Info Box
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
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
      padding: EdgeInsets.symmetric(vertical: 4),
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