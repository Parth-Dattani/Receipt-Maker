import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';




// Enhanced Customer Registration Screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomerRegistrationScreen extends GetView<CustomerRegistrationController> {
  static const pageId = "/CustomerRegistrationScreen";

  const CustomerRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A11CB),
              Colors.teal,
              Colors.tealAccent,
              Color(0xFF2575FC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildCustomAppBar(context),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Obx(() => Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Indicator
                        _buildProgressIndicator(),

                        const SizedBox(height: 20),

                        // Header with Animation
                        _buildAnimatedHeader(context),

                        const SizedBox(height: 25),

                        /// Personal Info Section
                        _buildSectionCard(
                          title: "Personal Information",
                          icon: Icons.person,
                          isExpanded: controller.personalInfoExpanded.value,
                          onToggle: () => controller.togglePersonalInfo(),
                          children: [
                            _buildTextField(
                              controller.nameController,
                              "Customer Name*",
                              Icons.person_outline,
                              isRequired: true,
                            ),
                            _buildTextField(
                              controller.addressController,
                              "Address*",
                              Icons.home_outlined,
                              isRequired: true,
                              maxLines: 3,
                            ),
                            Row(
                              children: [
                                // Country Dropdown
                                Expanded(
                                  child: Obx(() => _customDropdown(
                                    label: "Country *",
                                    prefixIcon: Icons.flag,
                                    value: controller.selectedCountry.value.isEmpty
                                        ? null
                                        : controller.selectedCountry.value,
                                    items: controller.countries.map((country) {
                                      return DropdownMenuItem<String>(
                                        value: country,
                                        child: Text(country),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      controller.selectedCountry.value = value ?? '';
                                      controller.selectedState.value = '';
                                    },
                                    isRequired: true,
                                    hint: "Select Country",
                                  )),
                                ),
                                const SizedBox(width: 12),

                                // State Dropdown
                                Expanded(
                                  child: Obx(() => _customDropdown(
                                    label: "State *",
                                    prefixIcon: Icons.map,
                                    value: controller.selectedState.value.isEmpty
                                        ? null
                                        : controller.selectedState.value,
                                    items: controller
                                        .getStatesForCountry()
                                        .map((state) => DropdownMenuItem<String>(
                                      value: state,
                                      child: Text(state),
                                    ))
                                        .toList(),
                                    onChanged: controller.selectedCountry.value.isEmpty
                                        ? null
                                        : (value) => controller.selectedState.value = value ?? '',
                                    isRequired: true,
                                    hint: "Select State",
                                  )),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller.cityController,
                                    "City*",
                                    Icons.location_city_outlined,
                                    isRequired: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller.pincodeController,
                                    "Pincode*",
                                    Icons.pin_drop_outlined,
                                    keyboard: TextInputType.number,
                                    isRequired: true,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(6),
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Business Info Section
                        _buildSectionCard(
                          title: "Business Information",
                          icon: Icons.business,
                          isExpanded: controller.businessInfoExpanded.value,
                          onToggle: () => controller.toggleBusinessInfo(),
                          children: [
                            _buildTextField(
                              controller.gstController,
                              "GST Number (Optional)",
                              Icons.receipt_long_outlined,
                              hint: "e.g., 12ABCDE1234F1Z5",
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(15),
                                UpperCaseTextFormatter(),
                              ],
                            ),
                            _buildTextField(
                              controller.panController,
                              "PAN Number (Optional)",
                              Icons.badge_outlined,
                              hint: "e.g., ABCDE1234F",
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                UpperCaseTextFormatter(),
                              ],
                            ),
                            _buildTextField(
                              controller.businessNameController,
                              "Business Name (Optional)",
                              Icons.store_outlined,
                            ),
                            _buildTextField(
                              controller.businessTypeController,
                              "Business Type (Optional)",
                              Icons.category_outlined,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Contact Info Section
                        _buildSectionCard(
                          title: "Contact Information",
                          icon: Icons.contact_phone,
                          isExpanded: controller.contactInfoExpanded.value,
                          onToggle: () => controller.toggleContactInfo(),
                          children: [
                            _buildTextField(
                              controller.mobile1Controller,
                              "Primary Mobile*",
                              Icons.phone_outlined,
                              keyboard: TextInputType.phone,
                              isRequired: true,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            _buildTextField(
                              controller.mobile2Controller,
                              "Secondary Mobile (Optional)",
                              Icons.phone_android_outlined,
                              keyboard: TextInputType.phone,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            _buildTextField(
                              controller.emailController,
                              "Email Address (Optional)",
                              Icons.email_outlined,
                              keyboard: TextInputType.emailAddress,
                            ),
                            _buildTextField(
                              controller.websiteController,
                              "Website (Optional)",
                              Icons.language_outlined,
                              keyboard: TextInputType.url,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Additional Notes Section
                        _buildSectionCard(
                          title: "Additional Notes",
                          icon: Icons.notes,
                          isExpanded: controller.notesExpanded.value,
                          onToggle: () => controller.toggleNotes(),
                          children: [
                            _buildTextField(
                              controller.notesController,
                              "Notes (Optional)",
                              Icons.note_outlined,
                              maxLines: 4,
                              hint: "Any additional information about the customer...",
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Action Buttons
                        _buildActionButtons(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          const Spacer(),
          Obx(() => Text(
            controller.isEditMode.value ? "Edit Customer" : "New Customer",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          )),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () => _showHelpDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${(controller.formProgress.value * 100).toInt()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: controller.formProgress.value,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Obx(() => Column(
              children: [
                Icon(
                  controller.isEditMode.value ? Icons.edit : Icons.person_add,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  controller.isEditMode.value
                      ? "Update Customer Details"
                      : "Register New Customer",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.isEditMode.value
                      ? "Update the details to modify customer information"
                      : "Fill in the details to add a new customer to your database",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            )),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50,
                      Colors.purple.shade50,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A11CB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: const Color(0xFF6A11CB), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A11CB),
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF6A11CB),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            AnimatedCrossFade(
              firstChild: const SizedBox(),
              secondChild: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: children),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboard = TextInputType.text,
        bool isRequired = false,
        int maxLines = 1,
        String? hint,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6A11CB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6A11CB), size: 20),
          ),
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return "This field is required";
          }
          if (label.toLowerCase().contains('email') && value != null && value.isNotEmpty) {
            if (!GetUtils.isEmail(value)) {
              return "Enter a valid email address";
            }
          }
          return null;
        },
        onChanged: (value) => this.controller.updateProgress(),
      ),
    );
  }

  Widget _customDropdown({
    required String label,
    required IconData prefixIcon,
    required List<DropdownMenuItem<String>> items,
    String? value,
    required void Function(String?)? onChanged,
    bool isRequired = false,
    String? hint,
    String section = "",
  }) {
    final isDisabled = onChanged == null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        isExpanded: true,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6A11CB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              prefixIcon,
              color: isDisabled ? Colors.grey : const Color(0xFF6A11CB),
              size: 20,
            ),
          ),
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: isDisabled ? Colors.grey.shade200 : Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            if (section == "personal") controller.personalInfoExpanded.value = true;
            return "This field is required";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Action Button
        SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.registerCustomer,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6A11CB),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.3),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  controller.isEditMode.value ? Icons.update : Icons.person_add,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  controller.isEditMode.value
                      ? "Update Customer"
                      : "Register Customer",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )),
          )),
        ),

        const SizedBox(height: 12),

        // Secondary Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.clearForm,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: Colors.white),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.clear_outlined, size: 18),
                label: const Text("Clear All"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF6A11CB)),
            SizedBox(width: 8),
            Text("Help"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• Fields marked with * are required"),
            Text("• GST format: 15 characters (e.g., 12ABCDE1234F1Z5)"),
            Text("• PAN format: 10 characters (e.g., ABCDE1234F)"),
            Text("• Mobile numbers should be 10 digits"),
            Text("• Tap on section headers to expand/collapse"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }
}

// Custom Input Formatter
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}


