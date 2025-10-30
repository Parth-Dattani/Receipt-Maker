import 'package:demo_prac_getx/controller/controller.dart';
import 'package:get/get.dart';

class StockReportBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<StockReportController>(StockReportController(), permanent: false);
  }
}