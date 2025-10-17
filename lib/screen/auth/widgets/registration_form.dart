import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/controller.dart';
import '../../../widgets/widgets.dart';

class RegistrationForm extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "For New Registration Contact your Authorised Person",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const Text(
                  "New Registration",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.regUsernameController,
                  decoration: InputDecoration(
                    labelText: "User Name *",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.regEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email ID *",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  ()=> TextFormField(
                    controller: controller.loginPasswordController,
                    obscureText: controller.isPasswordHidden.value,
                    decoration: InputDecoration(
                      labelText: "Password *",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.regMobile1Controller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Mobile No. 1 *",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.regMobile2Controller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Mobile No. 2 (Optional)",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => _customDropdown(
                  label: "Country ",
                  prefixIcon: Icons.flag,
                  value: controller.selectedCountry.value.isEmpty ? null : controller.selectedCountry.value,
                  items: controller.countries.map((country) {
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedCountry.value = value ?? '';
                    controller.selectedState.value = ''; // Reset state when country changes
                  },
                  isRequired: true,
                  hint: "Select Country",
                )),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.selectedCountry.value.isNotEmpty) {
                    return _customDropdown(
                      label: "State ",
                      prefixIcon: Icons.map,
                      value: controller.selectedState.value.isEmpty
                          ? null
                          : controller.selectedState.value,
                      items: controller.getStatesForCountry().map((state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Text(state),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.selectedState.value = value ?? '';
                      },
                      isRequired: true,
                      hint: "Select State",
                    );
                  } else {
                    return Container(); // Hide state dropdown when no country is selected
                  }
                }),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.regCityController,
                  decoration: InputDecoration(
                    labelText: "City *",
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
               // const SizedBox(height: 16),
                // TextFormField(
                //   controller: controller.regStateController,
                //   decoration: InputDecoration(
                //     labelText: "State *",
                //     prefixIcon: const Icon(Icons.map),
                //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                //   ),
                // ),
                // const SizedBox(height: 16),
                // TextFormField(
                //   controller: controller.regCountryController,
                //   decoration: InputDecoration(
                //     labelText: "Country *",
                //     prefixIcon: const Icon(Icons.public),
                //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                //   ),
                // ),
                const SizedBox(height: 30),
                Obx(() =>
                    CustomButton(
                      text: "Register",
                      backgroundColor: Colors.deepPurple,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.handleRegistration,
                    ),
                //     ElevatedButton(
                //   onPressed: controller.isLoading.value ? null : controller.handleRegistration,
                //   style: ElevatedButton.styleFrom(
                //     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                //     backgroundColor: Colors.pinkAccent,
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                //   ),
                //   child: controller.isLoading.value
                //       ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                //       : const Text("Register", style: TextStyle(fontSize: 18)),
                // )
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: controller.isLoading.value ? null : controller.authenticateWithMobile,
                  child: const Text("Authenticate via Mobile", style: TextStyle(color: Colors.deepPurple)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customDropdown({
    required String label,
    required IconData prefixIcon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    bool isRequired = false,
    String? hint,
  }) {
    // Check if the current value exists in the items list
    final bool valueExists = items.any((item) => item.value == value);

    // If value doesn't exist in items, use null to avoid the error
    final String? safeValue = valueExists ? value : null;

    return DropdownButtonFormField<String>(
      value: safeValue,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: isRequired
          ? (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      }
          : null,
      hint: hint != null ? Text(hint) : null,
      isExpanded: true,
    );
  }
}