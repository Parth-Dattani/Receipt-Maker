import 'package:get/get.dart';

import '../controller/controller.dart';

class PurchaseDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<PurchaseDetailsController>(PurchaseDetailsController(), permanent: true);
  }
}