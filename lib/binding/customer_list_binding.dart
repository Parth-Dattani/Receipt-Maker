import 'package:get/get.dart';

import '../controller/controller.dart';
import '../screen/screen.dart' hide CustomerListController;

class CustomerListBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CustomerListController>(CustomerListController(), permanent: false);
  }
}