import 'package:GetYourInvoice/screen/screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'binding/bindings.dart';

List<GetPage> appPages = [
  GetPage(
    name: SplashScreen.pageId,
    page: () => const SplashScreen(),
    binding: SplashBinding(),
  ),
  GetPage(
    name: LoginScreen.pageId,
    page: () => const LoginScreen(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: RegisterScreen.pageId,
    page: () => const RegisterScreen(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: DashboardScreen.pageId,
    page: () => const DashboardScreen(),
    binding: DashboardBinding(),
  ),
  GetPage(
    name: HistoryScreen.pageId,
    page: () => const HistoryScreen(),
    binding: ReceiptBinding(),
  ),
  GetPage(
    name: NewReceiptScreen.pageId,
    page: () => const NewReceiptScreen(),
    binding: ReceiptBinding(),
  ),
  GetPage(
    name: ReceiptPreviewScreen.pageId,
    page: () => const ReceiptPreviewScreen(),
    binding: ReceiptBinding(),
  ),
  GetPage(name: SettingsScreen.pageId, page: () => const SettingsScreen(), binding: SettingsBinding()), // 👈 આ લાઇન તપાસો
];
