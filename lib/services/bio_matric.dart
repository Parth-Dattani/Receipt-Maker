import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if biometric is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  // Check if device is enrolled with biometrics
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Authenticate using biometrics (local_auth 3.x API)
  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool persistAcrossBackgrounding = true,
  }) async {
    try {
      bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            cancelButton: 'Cancel',
            signInHint: 'Verify identity',
          ),
        ],
        biometricOnly: true,
        persistAcrossBackgrounding: persistAcrossBackgrounding,
      );
      return isAuthenticated;
    } catch (e) {
      print('Error during authentication: $e');
      return false;
    }
  }

  // Stop authentication
  Future<void> stopAuthentication() async {
    await _localAuth.stopAuthentication();
  }
}