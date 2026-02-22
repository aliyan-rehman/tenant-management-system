import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_mgmt_sys/core/services/tenant_service.dart';
import 'package:tenant_mgmt_sys/core/services/bills_service.dart';
import 'package:tenant_mgmt_sys/core/utils/calculation.dart';
import 'package:tenant_mgmt_sys/core/utils/date_format.dart';
import 'package:tenant_mgmt_sys/screens/tenants/tenant_details.dart';
import 'package:tenant_mgmt_sys/screens/auth/login_screen.dart';
import 'package:tenant_mgmt_sys/screens/tenants/add_tenant_screen.dart';
import 'package:tenant_mgmt_sys/screens/billing/monthly_billing_screen.dart';

import '../../providers/auth_provider.dart';
import '../../providers/tenant_provider.dart';

class AllTenants extends StatefulWidget {
  const AllTenants({super.key});

  @override
  State<AllTenants> createState() => _AllTenantsState();
}

class _AllTenantsState extends State<AllTenants> {
  List<String> monthYearList = [];
  String selectedMonthYear = "";

  BillService bs = BillService();
  Calculation calculation = Calculation();

  @override
  void initState() {
    super.initState();

    monthYearList = _generateMonthYearList();
    selectedMonthYear = monthYearList.first;

    //Load tenants using provider
    Future.microtask(() {
      final authProvider = context.read<AuthProvider>();
      final tenantProvider = context.read<TenantProvider>();

      if (authProvider.landlordId != null) {
        tenantProvider.loadTenants(authProvider.landlordId!);
      }
    });
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

  Future<void> _logout() async {
    //Use AuthProvider for logout
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    //Watch providers for reactive updates
    final authProvider = context.watch<AuthProvider>();
    final tenantProvider = context.watch<TenantProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("All Tenants"),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 4,
        leading: IconButton(
          onPressed: () {
            // Reload using provider
            if (authProvider.landlordId != null) {
              tenantProvider.loadTenants(authProvider.landlordId!);
            }
          },
          icon: const Icon(Icons.refresh),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
                tooltip: "Logout",
              ),
              Container(
                margin: const EdgeInsets.only(right: 12),
                child: const Icon(Icons.people, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
      body: tenantProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tenantProvider.allTenants.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tenants added yet',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button to add a tenant',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
        itemCount: tenantProvider.allTenants.length,
        itemBuilder: (context, index) {
          final tenant = tenantProvider.allTenants[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TenantDetailsScreen(
                      houseNo: tenant[TenantService.t_houseNo],
                      landlordId: authProvider.landlordId!,
                    ),
                  ),
                );

                // Auto-reload after navigation
                if (authProvider.landlordId != null) {
                  tenantProvider.loadTenants(authProvider.landlordId!);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF1976D2),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                tenant[TenantService.t_name],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2196F3)
                                          .withOpacity(0.1),
                                      borderRadius:
                                      BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.home,
                                          size: 14,
                                          color: Color(0xFF2196F3),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          tenant[TenantService
                                              .t_houseNo],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                            FontWeight.w500,
                                            color: Color(0xFF2196F3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFFBDBDBD),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade200, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons.calendar_today,
                            label: "Joining Date",
                            value: DateFormat.formatDate(
                              tenant[TenantService.t_joiningDate]
                                  .toDate(),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade200,
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons.payments,
                            label: "Rent",
                            value:
                            "Rs ${tenant[TenantService.t_rent]}",
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade200,
                        ),
                        Expanded(
                          child: FutureBuilder<Map<String, dynamic>?>(
                            future: bs.getBill(
                              authProvider.landlordId!,
                              tenant[TenantService.t_houseNo],
                              selectedMonthYear,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildInfoItem(
                                  icon: Icons.check_circle,
                                  label: "Status",
                                  value: "...",
                                  valueColor:
                                  const Color(0xFF757575),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data == null) {
                                return _buildInfoItem(
                                  icon: Icons.info_outline,
                                  label: "Status",
                                  value: "No Bill",
                                  valueColor:
                                  const Color(0xFF757575),
                                );
                              }

                              final bill = snapshot.data!;
                              int total = int.parse(
                                  bill[BillService.t_totalAmount]);
                              int paid = int.parse(
                                  bill[BillService.t_paidAmount]);

                              String paymentStatus =
                              calculation.paymentStatus(
                                totalAmount: total,
                                paidAmount: paid,
                              );

                              Color statusColor;
                              switch (paymentStatus.toUpperCase()) {
                                case 'PAID':
                                  statusColor =
                                  const Color(0xFF4CAF50);
                                  break;
                                case 'PARTIAL':
                                  statusColor =
                                  const Color(0xFFFF9800);
                                  break;
                                case 'UNPAID':
                                  statusColor =
                                  const Color(0xFFF44336);
                                  break;
                                default:
                                  statusColor =
                                  const Color(0xFF757575);
                              }

                              return _buildInfoItem(
                                icon: Icons.check_circle,
                                label: "Status",
                                value: paymentStatus,
                                valueColor: statusColor,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () async {
              // Check if tenants exist
              if (tenantProvider.allTenants.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No tenants added yet!")),
                );
                return;
              }

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MonthlyBillingScreen(
                    houseNo: tenantProvider.allTenants.first[TenantService.t_houseNo],
                    month: selectedMonthYear,
                    landlordId: authProvider.landlordId!,
                  ),
                ),
              );

              // Auto-reload
              if (authProvider.landlordId != null) {
                tenantProvider.loadTenants(authProvider.landlordId!);
              }
            },
            backgroundColor: const Color(0xFF1976D2),
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            label: const Text(
              "Generate Bills",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            elevation: 4,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTenantScreen(
                    landlordId: authProvider.landlordId!,
                  ),
                ),
              );

              // Auto-reload
              if (authProvider.landlordId != null) {
                tenantProvider.loadTenants(authProvider.landlordId!);
              }
            },
            backgroundColor: const Color(0xFF4CAF50),
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text(
              "Add Tenant",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            elevation: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF757575)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF212121),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}