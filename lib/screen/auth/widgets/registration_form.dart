import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/controller.dart';
import '../../../widgets/widgets.dart';


class RegistrationForm extends GetView<AuthController> {
  final bool showFormFields;

  const RegistrationForm({super.key, required this.showFormFields});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50, // Very light teal
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.shade100),
            ),
            child: Text(
              "For New Registration Contact your Authorised Person",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.teal.shade800),
            ),
          ),
          const SizedBox(height: 20),

          if (showFormFields) _buildFormFields(),

          const SizedBox(height: 30),
          Obx(() => _buildPrimaryButton(
            text: "REGISTER",
            isLoading: controller.isLoading.value,
            onPressed: controller.handleRegistration,
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTealTextField(
          controller: controller.regUsernameController,
          label: "Full Name",
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTealTextField(
          controller: controller.regEmailController,
          label: "Email ID",
          icon: Icons.email_outlined,
          inputType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        Obx(() => _buildTealTextField(
          controller: controller.loginPasswordController,
          label: "Password",
          icon: Icons.lock_outline,
          isPassword: true,
          isPasswordHidden: controller.isPasswordHidden.value,
          onVisibilityToggle: controller.togglePasswordVisibility,
        )),
        const SizedBox(height: 16),
        _buildTealTextField(
          controller: controller.regMobile1Controller,
          label: "Mobile No. 1",
          icon: Icons.phone_android,
          inputType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTealTextField(
          controller: controller.regMobile2Controller,
          label: "Mobile No. 2 (Optional)",
          icon: Icons.phone_android,
          inputType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        Obx(() => _buildTealDropdown(
          label: "Country",
          icon: Icons.flag_outlined,
          value: controller.selectedCountry.value.isEmpty ? null : controller.selectedCountry.value,
          items: controller.countries,
          onChanged: (value) {
            controller.selectedCountry.value = value ?? '';
            controller.selectedState.value = '';
          },
        )),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.selectedCountry.value.isNotEmpty) {
            return _buildTealDropdown(
              label: "State",
              icon: Icons.map_outlined,
              value: controller.selectedState.value.isEmpty ? null : controller.selectedState.value,
              items: controller.getStatesForCountry(),
              onChanged: (value) => controller.selectedState.value = value ?? '',
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 16),
        _buildTealTextField(
          controller: controller.regCityController,
          label: "City",
          icon: Icons.location_city_outlined,
        ),
        const SizedBox(height: 20),
        Obx(() => CheckboxListTile(
          value: controller.isDemo.value,
          onChanged: (val) => controller.isDemo.value = val ?? false,
          title: Text("Demo Account", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
          subtitle: const Text("Check to create a test account"),
          activeColor: Colors.teal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        )),
      ],
    );
  }
}

// --- SHARED WIDGETS (TEAL STYLE) ---

Widget _buildTealTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType inputType = TextInputType.text,
  bool isPassword = false,
  bool isPasswordHidden = false,
  VoidCallback? onVisibilityToggle,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade50, // Very slight grey for input
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      obscureText: isPassword && isPasswordHidden,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.teal), // Teal Icon
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordHidden ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onVisibilityToggle,
        )
            : null,
        // No border until focused
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5), // Teal Border on Focus
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    ),
  );
}

Widget _buildTealDropdown({
  required String label,
  required IconData icon,
  required String? value,
  required List<String> items,
  required Function(String?) onChanged,
}) {
  final safeValue = items.contains(value) ? value : null;

  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
      ],
    ),
    child: DropdownButtonFormField<String>(
      value: safeValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.teal, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    ),
  );
}

Widget _buildPrimaryButton({
  required String text,
  required VoidCallback onPressed,
  bool isLoading = false,
}) {
  return SizedBox(
    height: 55,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal, // Main Teal Color
        foregroundColor: Colors.white,
        elevation: 5,
        shadowColor: Colors.teal.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: isLoading
          ? const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      )
          : Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    ),
  );
}
