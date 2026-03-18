import 'package:get/get.dart';
import '../controller/order_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    // fenix: true — controller deleted થાય તો automatically recreate
    Get.lazyPut<OrderController>(
          () => OrderController(),
      fenix: true,
    );
  }
}
