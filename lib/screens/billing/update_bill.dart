import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tenant_mgmt_sys/core/utils/calculation.dart';
import 'package:tenant_mgmt_sys/core/services/bills_service.dart';
import '../../core/utils/date_format.dart';

class UpdateBill extends StatefulWidget {
  String houseNo;
  String billMonth;
  String landlordId;


  UpdateBill(this.houseNo, this.billMonth, this.landlordId);

  @override
  State<UpdateBill> createState() => _UpdateBillState();
}

class _UpdateBillState extends State<UpdateBill> {
  TextEditingController receivingAmountController = TextEditingController();

  BillService bs = BillService();
  Calculation calculation = Calculation();

  Map<String, dynamic>? bill;

  @override
  void initState() {
    super.initState();
    loadbill();
  }

  loadbill() async {
    final data = await bs.getBill(widget.landlordId, widget.houseNo, widget.billMonth);

    setState(() {
      bill = data;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return const Color(0xFF4CAF50);
      case 'PARTIAL':
        return const Color(0xFFFF9800);
      case 'UNPAID':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return const Color(0xFFE8F5E9);
      case 'PARTIAL':
        return const Color(0xFFFFF3E0);
      case 'UNPAID':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Update Bill"),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 4,
      ),
      body: bill == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Bill Details Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Builder(
                    builder: (context) {
                      int total =
                      int.parse(bill![BillService.t_totalAmount]);
                      int paid =
                      int.parse(bill![BillService.t_paidAmount]);

                      int remaining = calculation.remainingBalance(
                        totalAmount: total,
                        paidAmount: paid,
                      );

                      String paymentStatus = calculation.paymentStatus(totalAmount: total, paidAmount: paid);

                      return Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Tenant",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      bill![BillService.t_name],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                    _getStatusBgColor(paymentStatus),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    paymentStatus.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color:
                                      _getStatusColor(paymentStatus),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bill Items
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildBillRow(
                                  "Rent",
                                  bill![BillService.t_rent],
                                  Icons.home,
                                ),
                                const SizedBox(height: 12),
                                _buildBillRow(
                                  "Water Bill",
                                  bill![BillService.t_waterBill],
                                  Icons.water_drop,
                                ),
                                const SizedBox(height: 12),
                                _buildBillRow(
                                  "Gas Bill",
                                  bill![BillService.t_gasBill],
                                  Icons.local_fire_department,
                                ),
                                const SizedBox(height: 12),
                                _buildBillRow(
                                  "Cleaning",
                                  bill![BillService.t_cleaningCharges],
                                  Icons.cleaning_services,
                                ),
                                const SizedBox(height: 12),
                                _buildBillRow(
                                  "Previous Balance",
                                  bill![BillService.t_previousBalance],
                                  Icons.history,
                                ),
                                const SizedBox(height: 16),
                                Divider(
                                  color: Colors.white.withOpacity(0.3),
                                  thickness: 1,
                                ),
                                const SizedBox(height: 16),
                                _buildTotalRow(
                                  "Total",
                                  bill![BillService.t_totalAmount],
                                ),
                                const SizedBox(height: 12),
                                _buildTotalRow(
                                  "Paid",
                                  bill![BillService.t_paidAmount],
                                  isPaid: true,
                                ),
                                const SizedBox(height: 16),

                                // Remaining Balance
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                      Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.account_balance_wallet,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "Remaining Balance",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "Rs $remaining",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Payment Date
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Payment Date: ${DateFormat.formatDate(bill![BillService.t_paymentDate].toDate())}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Payment Input Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.payment,
                              color: Color(0xFF4CAF50),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Add Payment",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: receivingAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Receiving Amount",
                          hintText: "Enter amount",
                          prefixIcon: const Icon(
                            Icons.monetization_on,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF1976D2),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (receivingAmountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please enter amount'),
                          backgroundColor: const Color(0xFFF44336),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                      return;
                    }

                    //Get total for payment Status
                    int total =
                    int.parse(bill![BillService.t_totalAmount]);
                    // Get current paid from database
                    int currentPaid =
                    int.parse(bill![BillService.t_paidAmount]);
                    // Get new payment from input
                    int receivingAmount =
                    int.parse(receivingAmountController.text);
                    // ADD them (cumulative)
                    int newPaidAmount = currentPaid + receivingAmount;

                    String paymentStatus = calculation.paymentStatus(totalAmount: total, paidAmount: newPaidAmount);

                    bs.updateBill(
                      landlordId: widget.landlordId,
                      houseNo: widget.houseNo,
                      paidAmount: newPaidAmount.toString(),
                      billMonth: widget.billMonth,
                      paymentStatus: paymentStatus,
                      paymentDate: DateTime.now(),
                    );

                    receivingAmountController.clear();
                    loadbill();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Payment updated successfully!'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF4CAF50),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: const Text(
                    "Update Payment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String amount, IconData icon) {
    return Row(
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
              child: Icon(icon, size: 16, color: Colors.white70),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Text(
          "Rs $amount",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String amount, {bool isPaid = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Text(
          "Rs $amount",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPaid ? const Color(0xFF4CAF50) : Colors.white,
          ),
        ),
      ],
    );
  }
}