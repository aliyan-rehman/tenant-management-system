import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Calculation {

  /// Calculate remaining balance given total and paid amounts
  int remainingBalance({
    required int totalAmount,
    required int paidAmount,
  }) {
    return totalAmount - paidAmount;
  }

  /// Determine payment status based on remaining balance
  // String paymentStatus({required int remainingBalance}) {
  //   if (remainingBalance <= 0) {
  //     return "PAID";
  //   } else {
  //     return "DUE";
  //   }
  // }

  String paymentStatus({
    required int totalAmount,
    required int paidAmount,
  }) {
    if (paidAmount <= 0) {
      return "UNPAID";

    }
    else if (paidAmount < totalAmount) {
      return "PARTIAL";
    }

    return "PAID";
  }

}
