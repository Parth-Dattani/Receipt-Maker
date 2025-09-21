import 'package:demo_prac_getx/controller/challan_details_controller.dart';
import 'package:get/get.dart';

class ChallanDetailsBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<ChallanDetailsController>(ChallanDetailsController(), permanent: false);
  }

}