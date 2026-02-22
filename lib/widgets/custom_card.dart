import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String tenantName;
  final String tenantHouseNumber;
  final String billGeneratedDate;
  final String rent;
  final String waterBill;
  final String gasBill;
  final String cleaning;
  final String previousBalance;
  final String totalAmount;
  final String paidAmount;
  final String remainingBalance;
  final String paymentStatus;

  const CustomCard({
    super.key,
    required this.tenantName,
    required this.tenantHouseNumber,
    required this.billGeneratedDate,
    required this.rent,
    required this.waterBill,
    required this.gasBill,
    required this.cleaning,
    required this.previousBalance,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingBalance,
    required this.paymentStatus,
  });

  Color _getStatusColor() {
    switch (paymentStatus.toUpperCase()) {
      case 'PAID':
        return const Color(0xFF10B981);
      case 'PARTIAL':
        return const Color(0xFFF59E0B);
      case 'UNPAID':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusBackgroundColor() {
    switch (paymentStatus.toUpperCase()) {
      case 'PAID':
        return const Color(0xFFD1FAE5);
      case 'PARTIAL':
        return const Color(0xFFFEF3C7);
      case 'UNPAID':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenantName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'House $tenantHouseNumber',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusBackgroundColor(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            paymentStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _getStatusColor(),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Generated: $billGeneratedDate',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bill Details Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bill Breakdown',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBillItem('Rent', rent, Icons.home_rounded),
                    _buildBillItem('Water Bill', waterBill, Icons.water_drop_rounded),
                    _buildBillItem('Gas Bill', gasBill, Icons.local_fire_department_rounded),
                    _buildBillItem('Cleaning', cleaning, Icons.cleaning_services_rounded),
                    _buildBillItem('Previous Balance', previousBalance, Icons.history_rounded),

                    const SizedBox(height: 12),
                    Divider(
                      color: Colors.white.withOpacity(0.3),
                      thickness: 1,
                    ),
                    const SizedBox(height: 12),

                    // Total Amount
                    _buildTotalItem('Total Amount', totalAmount),
                    const SizedBox(height: 8),
                    _buildTotalItem('Paid Amount', paidAmount, isPaid: true),
                    const SizedBox(height: 16),

                    // Remaining Balance - Highlighted
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Remaining Balance',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Rs ${remainingBalance ?? '0'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillItem(String label, String amount, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            'Rs $amount',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem(String label, String amount, {bool isPaid = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.95),
          ),
        ),
        Text(
          'Rs $amount',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isPaid ? const Color(0xFF10B981) : Colors.white,
          ),
        ),
      ],
    );
  }
}