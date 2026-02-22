import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_mgmt_sys/core/services/tenant_service.dart';
import 'package:tenant_mgmt_sys/core/services/bills_service.dart';
import 'package:tenant_mgmt_sys/core/utils/calculation.dart';
import 'package:tenant_mgmt_sys/core/utils/date_format.dart';
import 'package:tenant_mgmt_sys/widgets/custom_card.dart';

import '../../providers/bills_provider.dart';
import '../../providers/tenant_provider.dart';

class MonthlyBillingScreen extends StatefulWidget {
  String? houseNo;
  String? month;
  final String landlordId;

  MonthlyBillingScreen({
    this.houseNo,
    this.month,
    required this.landlordId,
  });

  @override
  State<MonthlyBillingScreen> createState() => _MonthlyBillingScreenState();
}

class _MonthlyBillingScreenState extends State<MonthlyBillingScreen> {
  TextEditingController waterBillController = TextEditingController();
  TextEditingController gasBillController = TextEditingController();
  TextEditingController cleaningChargesController = TextEditingController();

  List<String> monthYearList = [];
  String? selectedMonthYear;
  String? selectedHouseNo;
  Map<String, dynamic>? selectedTenant;

  Calculation calculation = Calculation();

  @override
  void initState() {
    super.initState();

    // Generate last 24 months
    monthYearList = _generateMonthYearList();

    // Set default to current month-year or passed value
    if (widget.month != null) {
      selectedMonthYear = widget.month!;
    } else {
      selectedMonthYear = monthYearList.first;
    }

    selectedHouseNo = widget.houseNo;

    // Load tenants using provider
    Future.microtask(() {
      final tenantProvider = context.read<TenantProvider>();
      tenantProvider.loadTenants(widget.landlordId).then((_) {
        if (tenantProvider.allTenants.isNotEmpty) {
          setState(() {
            selectedHouseNo = widget.houseNo ?? tenantProvider.allTenants.first[TenantService.t_houseNo];
            selectedTenant = tenantProvider.allTenants.firstWhere(
                  (tenant) => tenant[TenantService.t_houseNo] == selectedHouseNo,
              orElse: () => tenantProvider.allTenants.first,
            );
          });
          _loadBill();
        }
      });
    });
  }

  // Generate list of last 24 months with years
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

  // Load bill using provider
  Future<void> _loadBill() async {
    if (selectedHouseNo == null || selectedMonthYear == null) return;

    final billProvider = context.read<BillProvider>();
    await billProvider.loadBill(
      landlordId: widget.landlordId,
      houseNo: selectedHouseNo!,
      monthYear: selectedMonthYear!,
    );
  }

  // Handle bill generation
  Future<void> _handleGenerateBill() async {
    if (selectedTenant == null || selectedHouseNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a tenant"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final billProvider = context.read<BillProvider>();

    int rent = int.tryParse(selectedTenant![TenantService.t_rent].toString()) ?? 0;
    int waterBill = int.tryParse(waterBillController.text) ?? 0;
    int gasBill = int.tryParse(gasBillController.text) ?? 0;
    int cleaningCharges = int.tryParse(cleaningChargesController.text) ?? 0;

    // Extract month and year from "February 2026"
    List<String> parts = selectedMonthYear!.split(' ');
    String month = parts[0]; // "February"

    // Get previous balance using provider
    int previousBalance = await billProvider.getPreviousBalance(
      landlordId: widget.landlordId,
      houseNo: selectedHouseNo!,
      currentMonth: month,
    );

    int totalAmount = rent + waterBill + gasBill + cleaningCharges + previousBalance;
    int remainingBalance = totalAmount;

    // Create bill using provider
    final success = await billProvider.createBill(
      landlordId: widget.landlordId,
      name: selectedTenant![TenantService.t_name],
      billGeneratedDate: DateTime.now(),
      houseNo: selectedHouseNo!,
      billMonth: selectedMonthYear!,
      rent: rent.toString(),
      waterBill: waterBill.toString(),
      gasBill: gasBill.toString(),
      cleaningCharges: cleaningCharges.toString(),
      previousBalance: previousBalance.toString(),
      totalAmount: totalAmount.toString(),
      paidAmount: "0",
      paymentStatus: "UNPAID",
      paymentDate: DateTime.now(),
      remainingBalance: remainingBalance.toString(),
    );

    if (!mounted) return;

    if (success) {
      // Clear inputs
      waterBillController.clear();
      gasBillController.clear();
      cleaningChargesController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bill generated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(billProvider.errorMessage ?? "Failed to generate bill"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    waterBillController.dispose();
    gasBillController.dispose();
    cleaningChargesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final tenantProvider = context.watch<TenantProvider>();
    final billProvider = context.watch<BillProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Monthly Billing"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        elevation: 4,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: const Icon(Icons.receipt_long, color: Colors.white),
          ),
        ],
      ),
      body: tenantProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tenant Selection Card
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
                            color: const Color(0xFF1976D2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF1976D2),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Tenant Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Select House Number",
                        prefixIcon: const Icon(Icons.home, size: 20),
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
                      value: selectedHouseNo,
                      items: tenantProvider.allTenants.map((tenant) {
                        String houseNo = tenant[TenantService.t_houseNo];
                        String tenantName = tenant[TenantService.t_name];
                        return DropdownMenuItem(
                          value: houseNo,
                          child: Text("$houseNo - $tenantName"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedHouseNo = value;
                          selectedTenant = tenantProvider.allTenants.firstWhere(
                                (tenant) => tenant[TenantService.t_houseNo] == value,
                          );
                        });
                        _loadBill();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Month Selection Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Select Month & Year",
                        prefixIcon: const Icon(Icons.calendar_month, size: 20),
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
                      value: selectedMonthYear,
                      items: monthYearList
                          .map(
                            (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMonthYear = value.toString();
                        });
                        _loadBill();
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Electricity Units Card (Optional - commented out as not functional)
            // You can enable this when you implement the functionality

            // Utility Bills Card
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
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.receipt,
                            color: Color(0xFF2196F3),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Utility Bills",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: waterBillController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Water Bill",
                              prefixIcon: const Icon(Icons.water_drop, size: 18),
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: gasBillController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Gas Bill",
                              prefixIcon: const Icon(Icons.local_fire_department, size: 18),
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: cleaningChargesController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Cleaning",
                              prefixIcon: const Icon(Icons.cleaning_services, size: 18),
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Generate Bill Button with loading state
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: billProvider.isLoading ? null : _handleGenerateBill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: billProvider.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.add_circle_outline, size: 20),
                label: Text(
                  billProvider.isLoading ? "Generating..." : "Generate Bill",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bill Preview
            if (selectedTenant != null)
              billProvider.currentBill != null
                  ? Builder(
                builder: (context) {
                  final bill = billProvider.currentBill!;
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

                  return CustomCard(
                    tenantName: selectedTenant![TenantService.t_name],
                    tenantHouseNumber: selectedHouseNo!,
                    billGeneratedDate: DateFormat.formatDate(
                      bill[BillService.t_billGeneratedDate].toDate(),
                    ),
                    rent: selectedTenant![TenantService.t_rent].toString(),
                    waterBill: bill[BillService.t_waterBill].toString(),
                    gasBill: bill[BillService.t_gasBill].toString(),
                    cleaning: bill[BillService.t_cleaningCharges].toString(),
                    previousBalance: bill[BillService.t_previousBalance].toString(),
                    totalAmount: bill[BillService.t_totalAmount].toString(),
                    paidAmount: bill[BillService.t_paidAmount].toString(),
                    remainingBalance: remaining.toString(),
                    paymentStatus: paymentStatus,
                  );
                },
              )
                  : Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                        Text(
                          'No bill generated for $selectedMonthYear',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No tenant selected',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}