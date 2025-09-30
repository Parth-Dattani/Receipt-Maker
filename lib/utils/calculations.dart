import '../constant/constant.dart';

double calculateItemAmount(double price, double gstPercent) {
  return AppConstants.withGST.value
      ? price + (price * gstPercent / 100)
      : price;
}
