import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tenant_mgmt_sys/core/services/tenant_service.dart';

class BillService {
  static const String c_landlords = "landlords"; //collection name of landlord
  static const String c_tenants = "tenants"; //Collection Name of Tenant

  static const String c_bills = "TenantBills"; //Collection Name

  static const String t_name = "TenantName";
  static const String t_rent = "rent";
  static const String t_waterBill = "waterBill";
  static const String t_gasBill = "gasBill";
  static const String t_cleaningCharges = "cleaningCharges";
  static const String t_previousBalance = "previousBalance";
  static const String t_totalAmount = "totalAmount";
  static const String t_paidAmount = "paidAmount";
  static const String t_paymentStatus = "paymentStatus";
  static const String t_paymentDate = "paymentDate";
  static const String t_billGeneratedDate = "billGeneratedDate";
  static const String t_remainingBalance = "remainingBalance";

  final _firestore = FirebaseFirestore.instance;

  // Get path to bills: landlords/{landlordId}/tenants/{houseNo}/bills
  String _getBillsPath(String landlordId, String houseNo) {
    return '$c_landlords/$landlordId/$c_tenants/$houseNo/$c_bills';
  }

  //ADD
  Future createBill({
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
    try {
      await _firestore
          .collection(_getBillsPath(landlordId, houseNo))
          .doc(billMonth.trim())
          .set({
            t_name: name.trim(),
            t_billGeneratedDate: Timestamp.fromDate(billGeneratedDate),
            t_rent: rent,
            t_waterBill: waterBill,
            t_gasBill: gasBill,
            t_cleaningCharges: cleaningCharges,
            t_previousBalance: previousBalance,
            t_totalAmount: totalAmount,
            t_paidAmount: paidAmount,
            t_paymentStatus: paymentStatus,
            t_paymentDate: Timestamp.fromDate(paymentDate),
            t_remainingBalance: remainingBalance,
          });

      print("Bill created for $billMonth");

      //ADD THIS: Cleanup old bills (keep only 24 months)
      await _cleanupOldBills(landlordId, houseNo);

    } catch (e) {
      print("Error: $e");
    }
  }

  // GET SPECIFIC BILL
  Future<Map<String, dynamic>?> getBill(
      String landlordId,
      String houseNo,
      String month) async {
    try {
      final doc = await _firestore
          .collection(_getBillsPath(landlordId, houseNo))
          .doc(month.trim())
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  //Update Bill (when payment is made)
  updateBill({
    required String landlordId,
    required String houseNo,
    required String billMonth,
    String? paidAmount,
    String? paymentStatus,
    DateTime? paymentDate,
    String? remainingBalance,
  }) {
    _firestore
        .collection(_getBillsPath(landlordId, houseNo))
        .doc(billMonth.trim())
        .update({
          t_paidAmount: paidAmount,
          t_paymentStatus: paymentStatus,
          t_paymentDate: Timestamp.fromDate(paymentDate!),
          t_remainingBalance: remainingBalance,
        });
  }

  // GET PREVIOUS BALANCE
  Future<int> getPreviousBalance(String landlordId,String houseNo, String currentMonth) async {
    try {
      final monthsOrder = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      ];

      final hasAnyBill = await _checkIfAnyBillExists(landlordId, houseNo);

      if (!hasAnyBill) {
        //No bills exist = FIRST BILL EVER
        //Advance balance used ONLY this one time!
        print("First bill ever - using advance balance");
        return await _getAdvanceBalance(landlordId, houseNo);
      }


      int currentYear = DateTime.now().year;
      int currentIndex = monthsOrder.indexOf(currentMonth);

      if (currentIndex <= 0) {

        int previousYear = currentYear - 1;
        String decemberWithYear = "December $previousYear";
        // It's January - look at December
        final decemberBill = await getBill(
          landlordId,
          houseNo,
          decemberWithYear,
        );

        if (decemberBill != null) {
          int total = int.tryParse(
              decemberBill[t_totalAmount] ?? '0') ?? 0;
          int paid = int.tryParse(
              decemberBill[t_paidAmount] ?? '0') ?? 0;
          return total - paid;
        }

        return 0;
      }

      String previousMonth = monthsOrder[currentIndex - 1];
      String previousMonthWithYear = "$previousMonth $currentYear";

      final previousBill = await getBill(
        landlordId,
        houseNo,
        previousMonthWithYear,
      );

      if (previousBill == null) return 0;

      int total = int.tryParse(
          previousBill[t_totalAmount] ?? '0') ?? 0;
      int paid = int.tryParse(
          previousBill[t_paidAmount] ?? '0') ?? 0;

      return total - paid;

    } catch (e) {
      print("Error getting previous balance: $e");
      return 0;
    }
  }

// CHECK IF ANY BILL EXISTS
// Used to detect if this is the very first bill
  Future<bool> _checkIfAnyBillExists(
      String landlordId,
      String houseNo,
      ) async {
    try {
      final snapshot = await _firestore
          .collection(_getBillsPath(landlordId, houseNo))
          .limit(1)  // Only need to find 1
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }


// GET ADVANCE BALANCE FROM TENANT DOCUMENT
  Future<int> _getAdvanceBalance(
      String landlordId,
      String houseNo,
      ) async {
    try {
      final tenantDoc = await _firestore
          .collection('$c_landlords/$landlordId/$c_tenants')
          .doc(houseNo)
          .get();

      if (!tenantDoc.exists) return 0;

      final data = tenantDoc.data();
      if (data == null) return 0;

      int advanceBalance =
          int.tryParse(data[TenantService.t_advanceBalance] ?? '0') ?? 0;

      print("Advance balance: $advanceBalance");
      print("TenantAdvanceBalance field: ${data[TenantService.t_advanceBalance]}");
      return advanceBalance;

    } catch (e) {
      print("Error getting advance balance: $e");
      return 0;
    }
  }

  // Get all bills for a tenant, sorted by date (oldest first)
  Future<List<Map<String, dynamic>>> getAllBillsSorted(
      String landlordId,
      String houseNo,
      ) async {
    try {
      final snapshot = await _firestore
          .collection(_getBillsPath(landlordId, houseNo))
          .get();

      if (snapshot.docs.isEmpty) return [];

      // Convert to list with month names
      List<Map<String, dynamic>> bills = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['_docId'] = doc.id;  // Store document ID for deletion
        return data;
      }).toList();

      // Sort by bill generated date (oldest first)
      bills.sort((a, b) {
        Timestamp aTime = a[t_billGeneratedDate] as Timestamp;
        Timestamp bTime = b[t_billGeneratedDate] as Timestamp;
        return aTime.compareTo(bTime);
      });

      return bills;
    } catch (e) {
      print("Error getting sorted bills: $e");
      return [];
    }
  }

  /// Delete oldest bills if more than 24 months exist
  Future<void> _cleanupOldBills(
      String landlordId,
      String houseNo,
      ) async {
    try {
      print("🧹 Checking for old bills to cleanup...");

      // Get all bills sorted by date
      final allBills = await getAllBillsSorted(landlordId, houseNo);

      int totalBills = allBills.length;
      print("Total bills: $totalBills");

      // If more than 24 bills, delete oldest ones
      if (totalBills > 24) {
        int billsToDelete = totalBills - 24;
        print("Deleting $billsToDelete old bills...");

        // Delete the oldest bills
        for (int i = 0; i < billsToDelete; i++) {
          String monthToDelete = allBills[i]['_docId'];

          await _firestore
              .collection(_getBillsPath(landlordId, houseNo))
              .doc(monthToDelete)
              .delete();

          print("Deleted bill: $monthToDelete");
        }

        print("Cleanup complete! Now keeping 24 months.");
      } else {
        print("No cleanup needed. Bills: $totalBills/24");
      }
    } catch (e) {
      print("Error during cleanup: $e");
    }
  }

  // Delete all bills for a tenant
  Future<bool> deleteAllBillsForTenant(String landlordId, String houseNo) async {
    try {
      print("Deleting all bills for tenant $houseNo...");

      // Get all bills
      final snapshot = await _firestore
          .collection(_getBillsPath(landlordId, houseNo))
          .get();

      // Delete each bill
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
        print("Deleted bill: ${doc.id}");
      }

      print("Deleted ${snapshot.docs.length} bills");
      return true;
    } catch (e) {
      print("Error deleting bills: $e");
      return false;
    }
  }

}
