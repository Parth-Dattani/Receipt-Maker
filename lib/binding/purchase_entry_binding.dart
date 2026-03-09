import 'package:GetYourInvoice/controller/controller.dart';
import 'package:get/get.dart';

class PurchaseEntryBinding extends Bindings{
  @override
  void dependencies() {
   Get.put<PurchaseEntryController>(PurchaseEntryController(), permanent: false);
  }
}