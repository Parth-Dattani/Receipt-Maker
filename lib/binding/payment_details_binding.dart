import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../controller/controller.dart';

class PaymentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentDetailsController>(() => PaymentDetailsController());
  }
}