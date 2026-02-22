import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tenant_mgmt_sys/core/services/tenant_service.dart';
import 'package:tenant_mgmt_sys/core/utils/date_format.dart';

class TenantJoiningDetails extends StatefulWidget {
  final String landlordId;
  final String houseNo;

  const TenantJoiningDetails({required this.landlordId, required this.houseNo});

  @override
  State<TenantJoiningDetails> createState() => _TenantJoiningDetailsState();
}

class _TenantJoiningDetailsState extends State<TenantJoiningDetails> {
  TenantService tenantService = TenantService();
  Map<String, dynamic>? tenant;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTenantData();
  }

  Future<void> loadTenantData() async {
    final data = await tenantService.getTenant(
      widget.landlordId,
      widget.houseNo,
    );

    setState(() {
      tenant = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Joining Details"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tenant == null
          ? const Center(child: Text("Tenant not found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tenant Info Header Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tenant![TenantService.t_name],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "House: ${tenant![TenantService.t_houseNo]}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      "Joining Date: ${DateFormat.formatDate((tenant![TenantService.t_joiningDate] as Timestamp).toDate())}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
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
                  ),
                  const SizedBox(height: 24),

                  // Financial Details Section
                  _buildSectionTitle("Financial Details at Joining"),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildFinancialRow(
                            label: "Monthly Rent",
                            value: "Rs ${tenant![TenantService.t_rent]}",
                            icon: Icons.home,
                            color: const Color(0xFF4CAF50),
                          ),
                          const Divider(height: 24),
                          _buildFinancialRow(
                            label: "Advance Amount",
                            value: "Rs ${tenant![TenantService.t_advance]}",
                            icon: Icons.account_balance_wallet,
                            color: const Color(0xFF2196F3),
                          ),
                          const Divider(height: 24),
                          _buildFinancialRow(
                            label: "Amount Received",
                            value:
                                "Rs ${tenant![TenantService.t_receivedAmount]}",
                            icon: Icons.payments,
                            color: const Color(0xFFFF9800),
                          ),
                          const Divider(height: 24),
                          _buildFinancialRow(
                            label: "Pending Amount",
                            value: "Rs ${_calculatePending()}",
                            icon: Icons.pending_actions,
                            color: const Color(0xFFF44336),
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Information Section
                  _buildSectionTitle("Contact Information"),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.phone, color: Colors.blue, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Phone Number",
                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${tenant![TenantService.t_phNo]}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ],
                      )
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1976D2).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF1976D2),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "This information reflects the tenant's details at the time of joining.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF212121),
      ),
    );
  }

  Widget _buildFinancialRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                color: const Color(0xFF212121),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? color : const Color(0xFF212121),
          ),
        ),
      ],
    );
  }

  String _calculatePending() {
    int advance =
        int.tryParse(tenant![TenantService.t_advance].toString()) ?? 0;
    int received =
        int.tryParse(tenant![TenantService.t_receivedAmount].toString()) ?? 0;
    int pending = advance - received;
    return pending.toString();
  }
}
