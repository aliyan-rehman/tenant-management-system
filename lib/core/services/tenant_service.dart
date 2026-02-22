import 'package:cloud_firestore/cloud_firestore.dart';

class TenantService {
  static const String c_landlords = "landlords"; //collection name of landlord

  static const String c_tenants = "tenants"; //Collection Name

  static const String t_name = "TenantName";
  static const String t_phNo = "TenantPhoneNo";
  static const String t_houseNo = "TenantHouseNo";
  static const String t_advance = "TenantAdvance";
  static const String t_advanceBalance = "TenantAdvanceBalance";
  static const String t_rent = "TenantRent";
  static const String t_receivedAmount = "TenantReceivedAmount";
  static const String t_joiningDate = "TenantJoiningDate";

  final _firestore = FirebaseFirestore.instance;

  // Get path to landlord's tenants
  String _getTenantsPath(String landlordId) {
    return '$c_landlords/$landlordId/$c_tenants';
  }

  //ADD
  Future createTenant({
    required String landlordId,
    required String name,
    required String phNo,
    required String houseNo,
    required String advance,
    required String rent,
    required String receivedAmount,
    required DateTime joiningDate,
  }) async {
    try {

      //Calculate how much tenant still owes from advance
      int advanceAmount = int.tryParse(advance) ?? 0;
      int rentAmount = int.tryParse(rent) ?? 0;
      int totalAmount = rentAmount + advanceAmount;

      int received = int.tryParse(receivedAmount) ?? 0;
      int advanceBalance = totalAmount - received ;

      await _firestore
          .collection(_getTenantsPath(landlordId))
          .doc(houseNo.trim())
          .set({
            t_name: name.trim(),
            t_phNo: phNo.trim(),
            t_houseNo: houseNo.trim(),
            t_advance: advance,
            t_rent: rent,
            t_receivedAmount: receivedAmount,
            t_advanceBalance: advanceBalance.toString(),
            t_joiningDate: Timestamp.fromDate(joiningDate),
          });
    } catch (e) {
      print(e);
    }
  }

  // READ ALL TENANTS
  Future<List<Map<String, dynamic>>> readAllTenants(String landlordId) async {
    final snapshot = await _firestore
        .collection(_getTenantsPath(landlordId))
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // READ SINGLE TENANT
  Future<Map<String, dynamic>?> getTenant(
    String landlordId,
    String houseNo,
  ) async {
    final doc = await _firestore
        .collection(_getTenantsPath(landlordId))
        .doc(houseNo)
        .get();

    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // UPDATE TENANT
  Future<void> updateTenant({
    required String landlordId,
    required String houseNumber,
    required String name,
    required String phoneNumber,
    required String advance,
    required String rent,
    required String receivedAmount,
    DateTime? joiningDate,
  }) async {

    int advanceAmount = int.tryParse(advance) ?? 0;
    int received = int.tryParse(receivedAmount) ?? 0;
    int advanceBalance = advanceAmount - received;

    final data = {
      t_name: name,
      t_phNo: phoneNumber,
      t_advance: advance,
      t_rent: rent,
      t_receivedAmount: receivedAmount,
      t_advanceBalance: advanceBalance.toString(),
      t_joiningDate: Timestamp.fromDate(joiningDate!),
    };

    await _firestore
        .collection(_getTenantsPath(landlordId))
        .doc(houseNumber)
        .update(data);
  }

  // DELETE TENANT
  Future<void> deleteTenant(String landlordId, String houseNo) async {
    await _firestore
        .collection(_getTenantsPath(landlordId))
        .doc(houseNo)
        .delete();
  }
}

//Calculate Balance Amount

//----------------Basic-----------------
//READ
// read() async {
//   try {
//     final data = await _firestore.collection(c_Name).get();
//     data.docs.forEach((element) {
//       print(element.data());
//     });
//   } catch (e) {
//     print(e);
//   }
// }
//
// //UPDATE
// update(String name, String tenantId, bool value) async {
//   try {
//     await _firestore.collection(c_Name).doc(d_Id).update({
//       t_name: name,
//       t_phNo: tenantId,
//       t_advance: value,
//     });
//   } catch (e) {
//     print(e);
//   }
// }
//
// //DELETE
// delete() async {
//   try {
//     await _firestore.collection(c_Name).doc(d_Id).delete();
//   } catch (e) {
//     print(e);
//   }
// }
