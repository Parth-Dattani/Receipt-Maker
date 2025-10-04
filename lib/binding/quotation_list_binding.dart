import 'package:get/get.dart';
import '../controller/controller.dart';

class QuotationListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<QuotationListController>(QuotationListController(), permanent: true);
  }
}

