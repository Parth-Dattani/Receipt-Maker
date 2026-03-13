import 'package:intl/intl.dart';

import '../constant/constant.dart';

class AppUtil {
  static double calculateItemAmount(double price, double gstPercent) {
    return AppConstants.withGST.value
        ? price + (price * gstPercent / 100)
        : price;
  }

  static String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString()
          .padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }


  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',   // Indian format (12,34,567.89)
      symbol: '',        // Remove ₹ symbol (since you already add text)
      decimalDigits: AppConstants.decimalPlaces,
    );
    return formatter.format(amount);
  }
}