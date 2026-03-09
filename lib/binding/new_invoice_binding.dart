import 'package:GetYourInvoice/controller/new_invoice_controller.dart';
import 'package:get/get.dart';

class NewInvoiceBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<NewInvoiceController>(NewInvoiceController(), permanent: true);
  }

}