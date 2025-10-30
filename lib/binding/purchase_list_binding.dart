import 'package:get/get.dart';

import '../controller/controller.dart';

class PurchaseListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<PurchaseListController>(PurchaseListController(), permanent: true);
  }
}