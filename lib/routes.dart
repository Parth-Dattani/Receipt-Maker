import 'package:demo_prac_getx/screen/payment/payment_details_screen.dart';
import 'package:demo_prac_getx/screen/screen.dart';
import 'package:demo_prac_getx/screen/setting/setting_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'binding/bindings.dart';

List<GetPage> appPages = [

  GetPage(
      name: SplashScreen.pageId,
      page: ()=> SplashScreen(),
      binding: SplashBinding()
  ),

  GetPage(
      name: HomeScreen.pageId,
      page: ()=> HomeScreen(),
      binding: HomeBinding()
  ),

  GetPage(
      name: ItemScreen.pageId,
      page: ()=> ItemScreen(),
      binding: ItemBinding()
  ),

  GetPage(
      name: AuthScreen.pageId,
      page: ()=> AuthScreen(),
      binding: AuthBinding()
  ),

  GetPage(
      name: CompanyRegistrationScreen.pageId,
      page: ()=> CompanyRegistrationScreen(),
      binding: CompanyBinding()
  ),

  GetPage(
      name: DashboardScreen.pageId,
      page: () => DashboardScreen(),
      binding: DashboardBinding()
  ),
  GetPage(
      name: CustomerRegistrationScreen.pageId,
      page: () => CustomerRegistrationScreen(),
      binding: CustomerRegistrationBinding()
  ),
  GetPage(
      name: PurchaseListScreen.pageId,
      page: () => PurchaseListScreen(),
      binding: PurchaseListBinding()
  ),
  GetPage(
      name: PurchaseDetailsScreen.pageId,
      page: () => PurchaseDetailsScreen(),
      binding: PurchaseDetailsBinding()
  ),

  GetPage(
      name: StockReportScreen.pageId,
      page: () => StockReportScreen(),
      binding: StockReportBinding()
  ),

  GetPage(
      name: SettingsScreen.pageId,
      page: () => SettingsScreen(),
      binding: SettingsBinding()
  ),

  GetPage(
      name: CompanySelectionScreen.pageId,
      page: () => CompanySelectionScreen(),
      binding: CompanySelectionBinding()
  ),

  GetPage(
      name: CustomerListScreen.pageId,
      page: () => CompanySelectionScreen(),
      binding: CompanySelectionBinding()
  ),

  GetPage(
      name: NewInvoiceScreen.pageId,
      page: () => NewInvoiceScreen(),
      binding: NewInvoiceBinding()
  ),

  GetPage(
      name: InvoiceListScreen.pageId,
      page: () => InvoiceListScreen(),
      binding: InvoiceListBinding()
  ),

  GetPage(
      name: InvoiceDetailsScreen.pageId,
      page: () => InvoiceDetailsScreen(),
      binding: InvoiceListBinding()
  ),

    GetPage(
    name: ChallanListScreen.pageId,
    page: () => ChallanListScreen(),
    binding: ChallanListBinding(),
    ),

  GetPage(
    name: ChallanDetailsScreen.pageId,
    page: () => ChallanDetailsScreen(),
    binding: ChallanDetailsBinding(),
  ),

  GetPage(
    name: QuotationListScreen.pageId,
    page: () =>  QuotationListScreen(),
    binding: QuotationListBinding(),
  ),

  GetPage(
    name: PaymentDetailsScreen.pageId,
    page: () =>  PaymentDetailsScreen(),
    binding: PaymentDetailsBinding(),
  ),

  GetPage(
    name: PurchaseEntryScreen.pageId,
    page: () =>  PurchaseEntryScreen(),
    binding: PurchaseEntryBinding(),
  ),
];