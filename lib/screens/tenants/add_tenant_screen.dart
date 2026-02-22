import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenant_mgmt_sys/core/utils/date_format.dart';

import '../../providers/auth_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../widgets/textformfield.dart';

class AddTenantScreen extends StatefulWidget {
  String landlordId;
  String tName;
  String tPhone;
  String tHouseNumber;
  String tAdvance;
  String tRent;
  String tRAmount;
  DateTime? tJDate;
  bool isUpdate;

  AddTenantScreen({
    required this.landlordId,
    this.tName = "",
    this.tPhone = "",
    this.tHouseNumber = "",
    this.tAdvance = "",
    this.tRent = "",
    this.tRAmount = "",
    this.tJDate,
    this.isUpdate = false,
  });

  @override
  State<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends State<AddTenantScreen> {
  TextEditingController tNameController = TextEditingController();
  TextEditingController tPhoneController = TextEditingController();
  TextEditingController tHouseNumberController = TextEditingController();
  TextEditingController tAdvanceController = TextEditingController();
  TextEditingController tRentController = TextEditingController();
  TextEditingController tReceivedAmountController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  DateTime? pickedDate;

  @override
  void initState() {
    super.initState();
    tNameController.text = widget.tName;
    tPhoneController.text = widget.tPhone;
    tHouseNumberController.text = widget.tHouseNumber;
    tAdvanceController.text = widget.tAdvance;
    tRentController.text = widget.tRent;
    tReceivedAmountController.text = widget.tRAmount;
    pickedDate = widget.tJDate;
  }

  @override
  void dispose() {
    super.dispose();
    tNameController.dispose();
    tPhoneController.dispose();
    tHouseNumberController.dispose();
    tAdvanceController.dispose();
    tRentController.dispose();
    tReceivedAmountController.dispose();
  }

  Future<void> _handleSubmit() async {
    //Get providers
    final authProvider = context.read<AuthProvider>();
    final tenantProvider = context.read<TenantProvider>();

    try {
      if (widget.isUpdate) {
        //UPDATE TENANT using provider
        final success = await tenantProvider.updateTenant(
          landlordId: widget.landlordId,
          houseNumber: tHouseNumberController.text,
          name: tNameController.text,
          phoneNumber: tPhoneController.text,
          advance: tAdvanceController.text,
          rent: tRentController.text,
          receivedAmount: tReceivedAmountController.text,
          joiningDate: pickedDate,
        );

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tenant Updated Successfully"),
              backgroundColor: Color(0xFF1976D2),
            ),
          );
          Navigator.pop(context); // Close confirmation dialog
          Navigator.pop(context); // Go back to previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tenantProvider.errorMessage ?? "Update failed"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        //CREATE TENANT using provider
        final success = await tenantProvider.createTenant(
          landlordId: widget.landlordId,
          name: tNameController.text,
          phNo: tPhoneController.text,
          houseNo: tHouseNumberController.text,
          advance: tAdvanceController.text,
          rent: tRentController.text,
          receivedAmount: tReceivedAmountController.text,
          joiningDate: pickedDate ?? DateTime.now(),
        );

        if (!mounted) return;

        if (success) {
          //Create tenant login credentials
          final credentials = await authProvider.createTenantUser(
            tenantName: tNameController.text.trim(),
            houseNo: tHouseNumberController.text.trim(),
            landlordId: widget.landlordId,
          );

          if (!mounted) return;

          Navigator.pop(context); // Close confirmation dialog

          // Show credentials dialog
          if (credentials != null) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text("Tenant Created Successfully"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Share these login credentials with your tenant:",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.email, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SelectableText(
                                  credentials['email']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.lock, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SelectableText(
                                  credentials['password']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Important: Save these credentials. The tenant will need them to login.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close credentials dialog
                      Navigator.pop(context); // Go back to tenant list
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Tenant added but login creation failed"),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tenantProvider.errorMessage ?? "Failed to add tenant",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //Watch provider for loading state
    final tenantProvider = context.watch<TenantProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.isUpdate ? "Update Tenant" : "Add Tenant"),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // House Number Card
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
                              Icons.home,
                              color: Color(0xFF1976D2),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Property Details",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "House Number",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 8),
                      widget.isUpdate
                          ? CustomTextField(
                              controller: tHouseNumberController,
                              hintText: "Enter House Number",
                              readOnly: true,
                              prefixIcon: Icons.home_outlined,
                              fillColor: Colors.white,
                              keyboardType: TextInputType.text,
                              validator: (value) =>
                                  TextFieldValidators.required(
                                    value,
                                    fieldName: "House Number",
                                  ),
                            )
                          : CustomTextField(
                              controller: tHouseNumberController,
                              hintText: "Enter House Number",
                              prefixIcon: Icons.home_outlined,
                              fillColor: Colors.white,
                              keyboardType: TextInputType.text,
                              validator: (value) =>
                                  TextFieldValidators.required(
                                    value,
                                    fieldName: "House Number",
                                  ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Personal Information Card
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
                              Icons.person,
                              color: Color(0xFF2196F3),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Full Name",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: tNameController,
                        hintText: "Enter Name",
                        prefixIcon: Icons.person_outline,
                        fillColor: Colors.white,
                        keyboardType: TextInputType.text,
                        validator: (value) => TextFieldValidators.required(
                          value,
                          fieldName: "Full Name",
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Phone Number",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: tPhoneController,
                        hintText: "Enter Phone Number",
                        prefixIcon: Icons.phone_outlined,
                        fillColor: Colors.white,
                        keyboardType: TextInputType.number,
                        validator: TextFieldValidators.phone,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Financial Details Card
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
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.payments,
                              color: Color(0xFF4CAF50),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Financial Details",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Advance Amount",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: tAdvanceController,
                        hintText: "Enter Advance Amount",
                        prefixIcon: Icons.account_balance_wallet,
                        fillColor: Colors.white,
                        keyboardType: TextInputType.number,
                        validator: (value) => TextFieldValidators.numeric(
                          value,
                          fieldName: "Advance Amount",
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Rent Amount",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: tRentController,
                        hintText: "Enter Rent Amount",
                        prefixIcon: Icons.monetization_on,
                        fillColor: Colors.white,
                        keyboardType: TextInputType.number,
                        validator: (value) => TextFieldValidators.numeric(
                          value,
                          fieldName: "Rent Amount",
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Received Amount",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: tReceivedAmountController,
                        hintText: "Enter Received Amount",
                        prefixIcon: Icons.check_circle,
                        fillColor: Colors.white,
                        keyboardType: TextInputType.number,
                        validator: (value) => TextFieldValidators.numeric(
                          value,
                          fieldName: "Received Amount",
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Joining Date",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: pickedDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2050),
                            );
                            if (date != null) {
                              setState(() {
                                pickedDate = date;
                              });
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFBDBDBD)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Color(0xFF1976D2),
                          ),
                          label: Text(
                            pickedDate == null
                                ? "Pick Date"
                                : DateFormat.formatDate(pickedDate!),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              //Submit Button with loading state
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: tenantProvider.isLoading
                      ? null
                      : () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(
                                widget.isUpdate
                                    ? "Update tenant"
                                    : "Add Tenant",
                              ),
                              content: Text(
                                widget.isUpdate
                                    ? "Are you sure you want to update this tenant?"
                                    : "Are you sure you want to add this tenant?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("No"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _handleSubmit();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                  ),
                                  child: const Text("Yes"),
                                ),
                              ],
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: tenantProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.isUpdate ? "Update Tenant" : "Add Tenant",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
