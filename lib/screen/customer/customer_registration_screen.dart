import 'package:demo_prac_getx/constant/app_colors.dart';
import 'package:demo_prac_getx/constant/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/controller.dart';
import 'package:flutter/services.dart';


class CustomerRegistrationScreen extends GetView<CustomerRegistrationController> {
  static const pageId = "/CustomerRegistrationScreen";

  const CustomerRegistrationScreen({super.key});

  // Theme Color (Purple)
  static final Color _themeColor = AppColors.tealColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background logic: Gradient for Mobile, White for Web (cleaner split view)
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check for Web Width
          if (constraints.maxWidth > 1000) {
            return _buildWebLayout(context);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  // ===========================================================================
  // 📱 MOBILE LAYOUT (Your Original Layout)
  // ===========================================================================
  Widget _buildMobileLayout(BuildContext context) {
    return Container(
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
            _buildCustomAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Obx(() => Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressIndicator(),
                      const SizedBox(height: 20),
                      _buildAnimatedHeader(context),
                      const SizedBox(height: 25),

                      _buildSectionCard(
                        title: "Personal Information",
                        icon: Icons.person,
                        isExpanded: controller.personalInfoExpanded.value,
                        onToggle: () => controller.togglePersonalInfo(),
                        children: _buildPersonalFields(),
                      ),
                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: "Business Information",
                        icon: Icons.business,
                        isExpanded: controller.businessInfoExpanded.value,
                        onToggle: () => controller.toggleBusinessInfo(),
                        children: _buildBusinessFields(),
                      ),
                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: "Contact Information",
                        icon: Icons.contact_phone,
                        isExpanded: controller.contactInfoExpanded.value,
                        onToggle: () => controller.toggleContactInfo(),
                        children: _buildContactFields(),
                      ),
                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: "Additional Notes",
                        icon: Icons.notes,
                        isExpanded: controller.notesExpanded.value,
                        onToggle: () => controller.toggleNotes(),
                        children: _buildNotesFields(),
                      ),

                      const SizedBox(height: 30),
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
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT (2-Column Grid)
  // ===========================================================================
  // Replace your _buildWebLayout method with this updated version

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // ✅ Full-width header (outside the constrained box)
          _buildMergedWebHeader(context),

          // Main content with width constraint
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        // ✅ TWO COLUMN LAYOUT
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT COLUMN - Personal + Notes
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    children: [
                                      _buildWebSectionCardOptimized(
                                        "Personal Information",
                                        Icons.person,
                                        _buildPersonalFieldsWeb(),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildWebSectionCardOptimized(
                                        "Additional Notes",
                                        Icons.subject,
                                        _buildNotesFields(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // RIGHT COLUMN - Business + Contact
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Column(
                                    children: [
                                      _buildWebSectionCardOptimized(
                                        "Business Information",
                                        Icons.business,
                                        _buildBusinessFieldsWeb(),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildWebSectionCardOptimized(
                                        "Contact Information",
                                        Icons.contact_phone,
                                        _buildContactFieldsWeb(),
                                      ),

                                      SizedBox(height: 40,),
                                      Center(
                                        child: Container(
                                          constraints: const BoxConstraints(maxWidth: 500),
                                          padding: const EdgeInsets.symmetric(horizontal: 32),
                                          child: _buildActionButtons(isWeb: true),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),


                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// ✅ NEW: Compact Merged Header (AppBar + Animated Header Combined)
  Widget _buildMergedWebHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.tealColor, AppColors.tealColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              // Back Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(width: 24),

              // Animated  Title (Compact)
              Expanded(
                child: Obx(() => Row(
                  children: [

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.isEditMode.value ? "Edit Customer" : "New Customer",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.isEditMode.value
                                ? "Update customer information"
                                : "Fill in the details to add a new customer",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
              ),

              // Help Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                  onPressed: _showHelpDialog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 🧩 FIELD LISTS (Shared Logic)
  // ===========================================================================

  List<Widget> _buildPersonalFields() {
    return [
      _buildTextField(controller.nameController, "Customer Name*", Icons.person_outline, isRequired: true),
      _buildTextField(controller.addressController, "Address*", Icons.home_outlined, isRequired: true, maxLines: 3),
      _buildSundryTypeRadio(),
      Row(
        children: [
          Expanded(
            child: Obx(() => _customDropdown(
              label: "Country *",
              prefixIcon: Icons.flag,
              value: controller.selectedCountry.value.isEmpty ? null : controller.selectedCountry.value,
              items: controller.countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                controller.selectedCountry.value = val ?? '';
                controller.selectedState.value = '';
              },
              isRequired: true,
              hint: "Select Country",
            )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => _customDropdown(
              label: "State *",
              prefixIcon: Icons.map,
              value: controller.selectedState.value.isEmpty ? null : controller.selectedState.value,
              items: controller.getStatesForCountry().map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: controller.selectedCountry.value.isEmpty ? null : (val) => controller.selectedState.value = val ?? '',
              isRequired: true,
              hint: "Select State",
            )),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(child: _buildTextField(controller.cityController, "City*", Icons.location_city_outlined, isRequired: true)),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTextField(
              controller.pincodeController,
              "Pincode*",
              Icons.pin_drop_outlined,
              keyboard: TextInputType.number,
              isRequired: true,
              inputFormatters: [LengthLimitingTextInputFormatter(6), FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    ];
  }


  List<Widget> _buildPersonalFieldsWeb() {
    return [
      // Row 1: Customer Name (Full Width)
      _buildTextField(
        controller.nameController,
        "Customer Name*",
        Icons.person_outline,
        isRequired: true,
      ),

      // Row 2: Address (Full Width, 3 lines)
      _buildTextField(
        controller.addressController,
        "Address*",
        Icons.home_outlined,
        isRequired: true,
        maxLines: 2,
      ),

      // Row 3: Debtors/Creditors Radio (Full Width)
      _buildSundryTypeRadio(),

      // Row 4: Country + State
      Row(
        children: [
          Expanded(
            child: Obx(() => _customDropdown(
              label: "Country *",
              prefixIcon: Icons.flag,
              value: controller.selectedCountry.value.isEmpty
                  ? null
                  : controller.selectedCountry.value,
              items: controller.countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                controller.selectedCountry.value = val ?? '';
                controller.selectedState.value = '';
              },
              isRequired: true,
              hint: "Select Country",
            )),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() => _customDropdown(
              label: "State *",
              prefixIcon: Icons.map,
              value: controller.selectedState.value.isEmpty
                  ? null
                  : controller.selectedState.value,
              items: controller
                  .getStatesForCountry()
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: controller.selectedCountry.value.isEmpty
                  ? null
                  : (val) => controller.selectedState.value = val ?? '',
              isRequired: true,
              hint: "Select State",
            )),
          ),
        ],
      ),

      // Row 5: City + Pincode
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
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              controller.pincodeController,
              "Pincode*",
              Icons.pin_drop_outlined,
              keyboard: TextInputType.number,
              isRequired: true,
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildBusinessFields() {
    return [
      _buildTextField(controller.gstController, "GST Number (Optional)", Icons.receipt_long_outlined, hint: "e.g., 12ABCDE1234F1Z5", inputFormatters: [LengthLimitingTextInputFormatter(15), UpperCaseTextFormatter()]),
      _buildTextField(controller.panController, "PAN Number (Optional)", Icons.badge_outlined, hint: "e.g., ABCDE1234F", inputFormatters: [LengthLimitingTextInputFormatter(10), UpperCaseTextFormatter()]),
      _buildTextField(controller.businessNameController, "Business Name (Optional)", Icons.store_outlined),
      _buildTextField(controller.businessTypeController, "Business Type (Optional)", Icons.category_outlined),
    ];
  }

  List<Widget> _buildBusinessFieldsWeb() {
    return [
      // Row 1: GST + PAN
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller.gstController,
              "GST Number (Optional)",
              Icons.receipt_long_outlined,
              hint: "e.g., 12ABCDE1234F1Z5",
              inputFormatters: [
                LengthLimitingTextInputFormatter(15),
                UpperCaseTextFormatter()
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              controller.panController,
              "PAN Number (Optional)",
              Icons.badge_outlined,
              hint: "e.g., ABCDE1234F",
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                UpperCaseTextFormatter()
              ],
            ),
          ),
        ],
      ),

      // Row 2: Business Name + Business Type
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller.businessNameController,
              "Business Name (Optional)",
              Icons.store_outlined,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              controller.businessTypeController,
              "Business Type (Optional)",
              Icons.category_outlined,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildContactFields() {
    return [
      _buildTextField(controller.mobile1Controller, "Primary Mobile*", Icons.phone_outlined, keyboard: TextInputType.phone, isRequired: true, inputFormatters: [LengthLimitingTextInputFormatter(10), FilteringTextInputFormatter.digitsOnly]),
      _buildTextField(controller.mobile2Controller, "Secondary Mobile (Optional)", Icons.phone_android_outlined, keyboard: TextInputType.phone, inputFormatters: [LengthLimitingTextInputFormatter(10), FilteringTextInputFormatter.digitsOnly]),
      _buildTextField(controller.emailController, "Email Address (Optional)", Icons.email_outlined, keyboard: TextInputType.emailAddress),
      _buildTextField(controller.websiteController, "Website (Optional)", Icons.language_outlined, keyboard: TextInputType.url),
    ];
  }

  List<Widget> _buildContactFieldsWeb() {
    return [
      // Row 1: Primary Mobile + Secondary Mobile
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller.mobile1Controller,
              "Primary Mobile*",
              Icons.phone_outlined,
              keyboard: TextInputType.phone,
              isRequired: true,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              controller.mobile2Controller,
              "Secondary Mobile (Optional)",
              Icons.phone_android_outlined,
              keyboard: TextInputType.phone,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
          ),
        ],
      ),

      // Row 2: Email + Website
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller.emailController,
              "Email Address (Optional)",
              Icons.email_outlined,
              keyboard: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              controller.websiteController,
              "Website (Optional)",
              Icons.language_outlined,
              keyboard: TextInputType.url,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildWebSectionCardOptimized(String title, IconData icon, List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _themeColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style:  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _themeColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNotesFields() {
    return [
      _buildTextField(controller.notesController, "Notes (Optional)", Icons.note_outlined, maxLines: 4, hint: "Any additional info..."),
    ];
  }


  // ===========================================================================
  // 🧩 WIDGET COMPONENTS
  // ===========================================================================

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context)),
          ),
          const Spacer(),
          Obx(() => Text(
            controller.isEditMode.value ? "Edit Customer" : "New Customer",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          )),
          const Spacer(),
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: const Icon(Icons.help_outline, color: Colors.white), onPressed: _showHelpDialog),
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
              Text("Progress", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500)),
              Text("${(controller.formProgress.value * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: controller.formProgress.value, backgroundColor: Colors.white.withOpacity(0.3), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 4),
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
                Icon(controller.isEditMode.value ? Icons.edit : Icons.person_add, color: _themeColor, size: 40), // Purple Icon
                const SizedBox(height: 12),
                Text(
                  controller.isEditMode.value ? "Update Customer Details" : "Register New Customer",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: _themeColor, fontWeight: FontWeight.bold), // Purple Text
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.isEditMode.value ? "Update details to modify info" : "Fill in the details to add a new customer",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            )),
          ),
        );
      },
    );
  }

  // Mobile Collapsible Section
  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children, required bool isExpanded, required VoidCallback onToggle}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.purple.shade50]),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF6A11CB).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(icon, color: const Color(0xFF6A11CB), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A11CB)))),
                    AnimatedRotation(turns: isExpanded ? 0.5 : 0, duration: const Duration(milliseconds: 300), child: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6A11CB))),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(),
              secondChild: Padding(padding: const EdgeInsets.all(16), child: Column(children: children)),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  // Web Fixed Section (No Collapse)
  Widget _buildWebSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _themeColor, size: 24),
                const SizedBox(width: 12),
                Text(title, style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _themeColor)),
              ],
            ),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboard = TextInputType.text, bool isRequired = false, int maxLines = 1, String? hint, List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          prefixIcon: Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF6A11CB).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color:  AppColors.tealColor, size: 20)),
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 2)),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) return "This field is required";
          return null;
        },
        onChanged: (value) => this.controller.updateProgress(),
      ),
    );
  }

  Widget _buildSundryTypeRadio() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200)),
        child: Obx(() => Row(
          children: [
            Expanded(child: _buildRadioOption(value: 'Debtors', label: 'Debtors', isSelected: controller.sundryType.value == 'Debtors', onChanged: (val) => controller.sundryType.value = val!)),
            const SizedBox(width: 15),
            Expanded(child: _buildRadioOption(value: 'Creditors', label: 'Creditors', isSelected: controller.sundryType.value == 'Creditors', onChanged: (val) => controller.sundryType.value = val!)),
          ],
        )),
      ),
    );
  }

  Widget _buildRadioOption({required String value, required String label, required bool isSelected, required Function(String?) onChanged}) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tealColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.tealColor: Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(value: value,
                groupValue: isSelected ? value : null,
                onChanged: onChanged,
                activeColor: AppColors.tealColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.tealColor : Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _customDropdown({required String label, required IconData prefixIcon, required List<DropdownMenuItem<String>> items, String? value, required void Function(String?)? onChanged, bool isRequired = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        isExpanded: true,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Container(margin:  EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.tealColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(prefixIcon, color: AppColors.tealColor, size: 20)),
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        validator: (value) => (isRequired && (value == null || value.isEmpty)) ? "Required" : null,
      ),
    );
  }

  Widget _buildActionButtons({bool isWeb = false}) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton.icon(
            onPressed: controller.isLoading.value ? null : controller.registerCustomer,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: isWeb ? _themeColor : Colors.white,
              foregroundColor: isWeb ? Colors.white : _themeColor,
              elevation: 8,
            ),
            icon: controller.isLoading.value ? const SizedBox() : Icon(controller.isEditMode.value ? Icons.update : Icons.person_add),
            label: Text(controller.isEditMode.value ? "Update Customer" : "Register Customer", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.clearForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: isWeb ? Colors.grey : Colors.white),
              foregroundColor: isWeb ? Colors.grey[800] : Colors.white,
            ),
            icon: const Icon(Icons.clear_outlined, size: 18),
            label: const Text("Clear All"),
          ),
        ),
      ],
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Help"),
        content: const Text("• Fields marked with * are required\n• GST format: 15 chars\n• PAN: 10 chars"),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text("Got it"))],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}


