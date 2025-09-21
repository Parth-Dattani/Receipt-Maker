
import 'package:demo_prac_getx/controller/challan_list_controller.dart';
import 'package:get/get.dart';

class ChallanListBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<ChallanListController>(ChallanListController(), permanent: true);
  }

}
