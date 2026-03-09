import 'package:GetYourInvoice/controller/controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(), permanent: false);
  }

}