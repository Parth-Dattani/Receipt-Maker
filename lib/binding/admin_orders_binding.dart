import 'package:get/get.dart';
import '../controller/controller.dart';
import '../screen/order/admin_orders_screen.dart';

class AdminOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminOrdersController>(
          () => AdminOrdersController(),
    );
  }
}