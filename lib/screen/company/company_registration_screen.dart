import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:GetYourInvoice/constant/constant.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

import '../../controller/controller.dart';
import '../../utils/shared_preferences_helper.dart';
import '../../widgets/widgets.dart';
import '../../widgets/web_screen_wrapper.dart';

import 'package:shimmer/shimmer.dart';

import '../auth/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';



class CompanyRegistrationScreen extends GetView<CompanyController> {
  static const pageId = "/CompanyRegistrationScreen";

  const CompanyRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return CompanyFormShimmer();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildWebLayout(context);
              } else {
                return _buildMobileLayout(context);
              }
            },
          );
        }),
      ),
    );
    if (kIsWeb) return webScreenWrapper(currentRoute: pageId, child: content);
    return content;
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.tealColor,
      title: Obx(() => Text(
        controller.isEditMode.value ? "Edit Company" : "Company Registration",
        style: const TextStyle(color: Colors.white),
      )),
      centerTitle: true,
      elevation: 0,
      foregroundColor: Colors.white,
      actions: [
        Obx(() {
          if (!controller.isEditMode.value) {
            return IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: () => _showLogoutDialog(context),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // ===========================================================================
  // 📱 MOBILE LAYOUT
  // ===========================================================================
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            _buildCompanyInfoCard(),
            const SizedBox(height: 12),
            _buildBusinessInfoCard(),
            const SizedBox(height: 12),
            _buildBankInfoCard(),
            const SizedBox(height: 12),
            _buildAuthorisationCard(),
            const SizedBox(height: 12),
            _buildFeaturesCard(),
            const SizedBox(height: 12),
            _buildGstCard(),
            const SizedBox(height: 30),
            _buildRegisterButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT (Split View with Optimized Rows)
  // ===========================================================================
  Widget _buildWebLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                // ✅ TWO COLUMN ROW
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT COLUMN: Company Info & Bank Info
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildCompanyInfoCardWeb(),
                              const SizedBox(height: 16),
                              _buildBusinessInfoCardWeb(),

                            ],
                          ),
                        ),
                      ),

                      // RIGHT COLUMN: Business, Auth, Features
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildBankInfoCardWeb(),
                              const SizedBox(height: 16),
                              _buildAuthorisationCard(),
                              const SizedBox(height: 16),
                              _buildFeaturesCard(),
                              const SizedBox(height: 16),
                              _buildGstCard(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ✅ CENTERED BUTTON AT BOTTOM (NORMAL FLOW)
                const SizedBox(height: 30),
                _buildRegisterButton(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 🧩 WEB-SPECIFIC CARD LAYOUTS (Optimized with Rows)
  // ===========================================================================

  Widget _buildCompanyInfoCardWeb() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, left: 16,bottom: 16, right: 16),
        child: Column(
          children: [
            _sectionTitle("Company Info", Icons.business),
            _buildLogoPickerSection(),
            const SizedBox(height: 12),
            // Row 1: Company Code + Company Name
            Row(
              children: [
                Expanded(
                  child: Obx(() => CustomTextFormField(
                    controller: controller.companyCodeController,
                    label: "Company Code *",
                    prefixIcon: Icons.qr_code,
                    isRequired: true,
                    readOnly: controller.isEditMode.value,
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => CustomTextFormField(
                    controller: controller.companyNameController,
                    label: "Company Name *",
                    prefixIcon: Icons.apartment,
                    isRequired: true,
                    readOnly: controller.isEditMode.value,
                  )),
                ),
              ],
            ),

            // Row 2: Address (Full Width)
            CustomTextFormField(
              controller: controller.addressController,
              label: "Address",
              maxLines: 3,
              minLines: 2,
              prefixIcon: Icons.location_on,
            ),

            // Row 3: Phone + Invoice Starting Number
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: controller.phoneController,
                    label: "Phone Number *",
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextFormField(
                    controller: controller.invoiceStartingNumberController,
                    label: "Invoice Starting Number",
                    prefixIcon: Icons.receipt_long,
                    keyboardType: TextInputType.number,
                    hintText: "Default: 1",
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 12),
              child: Text(
                "Set the starting number for invoices (e.g., 1000 will create INV1000, INV1001, etc.)",
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: 12),

            // Row 4: Country + State
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
                  child: Obx(() {
                    if (controller.selectedCountry.value.isNotEmpty) {
                      return _customDropdown(
                        label: "State *",
                        prefixIcon: Icons.map,
                        value: controller.selectedState.value.isEmpty ? null : controller.selectedState.value,
                        items: controller.getStatesForCountry().map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => controller.selectedState.value = val ?? '',
                        isRequired: true,
                        hint: "Select State",
                      );
                    }
                    return Container();
                  }),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Row 5: City + Pincode
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: controller.cityController,
                    label: "City *",
                    prefixIcon: Icons.location_city,
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextFormField(
                    controller: controller.pincodeController,
                    label: "Pincode *",
                    prefixIcon: Icons.pin,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessInfoCardWeb() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, left: 16,bottom: 16, right: 16),
        child: Column(
          children: [
            _sectionTitle("Business Info", Icons.pie_chart),
            const SizedBox(height: 16),

            // Row 1: Business Type + Business Category
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.isEditMode.value) {
                      return CustomTextFormField(
                        controller: TextEditingController(text: controller.selectedBusinessType.value),
                        label: "Business Type *",
                        prefixIcon: Icons.business_center,
                        readOnly: true,
                      );
                    } else {
                      return _customDropdown(
                        label: "Business Type *",
                        prefixIcon: Icons.business_center,
                        value: controller.selectedBusinessType.value.isEmpty ? null : controller.selectedBusinessType.value,
                        items: controller.businessTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                        onChanged: (val) => controller.selectedBusinessType.value = val ?? '',
                        isRequired: true,
                        hint: "Select Business Type",
                      );
                    }
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextFormField(
                    controller: controller.businessCategoryController,
                    label: "Business Category *",
                    prefixIcon: Icons.category,
                    isRequired: true,
                  ),
                ),
              ],
            ),

            // Row 2: GST Number + PAN Number
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: controller.gstController,
                    label: "G.S.T. Number",
                    prefixIcon: Icons.confirmation_number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextFormField(
                    controller: controller.panController,
                    label: "PAN No",
                    prefixIcon: Icons.credit_card,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Due Date Switch
            Obx(() => SwitchListTile(
              value: controller.isDueDateEnabled.value,
              onChanged: (value) {
                controller.isDueDateEnabled.value = value;
                if (!value) {
                  controller.dueDateDaysController.clear();
                }
              },
              activeColor: Colors.white,
              activeTrackColor: AppColors.tealColor,
              inactiveThumbColor: Colors.grey,
              title: const Text(
                "Enable Due Date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                "Set payment due date in days from invoice date",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              secondary: Icon(Icons.calendar_today, color: AppColors.tealColor),
            )),

            // Due Date Days Field
            Obx(() {
              if (controller.isDueDateEnabled.value) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CustomTextFormField(
                    controller: controller.dueDateDaysController,
                    label: "Due Date (Days) *",
                    prefixIcon: Icons.event_available,
                    keyboardType: TextInputType.number,
                    hintText: "e.g., 30",
                    isRequired: true,
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoCardWeb() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, left: 16,bottom: 16, right: 16),
        child: Column(
          children: [
            _sectionTitle("Bank Info", Icons.account_balance),

            // Row 1: Bank Name + IFSC Code
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: controller.bankNameController,
                    label: "Bank Name",
                    prefixIcon: Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextFormField(
                    controller: controller.ifscController,
                    label: "IFSC Code",
                    prefixIcon: Icons.code,
                  ),
                ),
              ],
            ),

            // Row 2: Account Number + UPI ID
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: controller.accountNumberController,
                    label: "Account Number",
                    prefixIcon: Icons.numbers,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextFormField(
                    controller: controller.upiController,
                    label: "UPI ID",
                    prefixIcon: Icons.paypal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 🧩 MOBILE CARD LAYOUTS (Original - Unchanged)
  // ===========================================================================

  Widget _buildCompanyInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle("Company Info", Icons.business),
            _buildLogoPickerSection(),
            const SizedBox(height: 12),
            Obx(() => CustomTextFormField(
              controller: controller.companyCodeController,
              label: "Company Code *",
              prefixIcon: Icons.qr_code,
              isRequired: true,
              readOnly: controller.isEditMode.value,
            )),
            Obx(() => CustomTextFormField(
              controller: controller.companyNameController,
              label: "Company Name *",
              prefixIcon: Icons.apartment,
              isRequired: true,
              readOnly: controller.isEditMode.value,
            )),
            CustomTextFormField(
              controller: controller.addressController,
              label: "Address",
              minLines: 2,
              maxLines: 3,
              prefixIcon: Icons.location_on,
            ),
            CustomTextFormField(
              controller: controller.phoneController,
              label: "Phone Number *",
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              isRequired: true,
            ),
            CustomTextFormField(
              controller: controller.invoiceStartingNumberController,
              label: "Invoice Starting Number",
              prefixIcon: Icons.receipt_long,
              keyboardType: TextInputType.number,
              hintText: "Default: 1",
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 12),
              child: Text(
                "Set the starting number for invoices (e.g., 1000 will create INV1000, INV1001, etc.)",
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => _customDropdown(
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
            const SizedBox(height: 16),
            Obx(() {
              if (controller.selectedCountry.value.isNotEmpty) {
                return _customDropdown(
                  label: "State *",
                  prefixIcon: Icons.map,
                  value: controller.selectedState.value.isEmpty ? null : controller.selectedState.value,
                  items: controller.getStatesForCountry().map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => controller.selectedState.value = val ?? '',
                  isRequired: true,
                  hint: "Select State",
                );
              }
              return Container();
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: CustomTextFormField(controller: controller.cityController, label: "City *", prefixIcon: Icons.location_city, isRequired: true)),
                const SizedBox(width: 10),
                Expanded(child: CustomTextFormField(controller: controller.pincodeController, label: "Pincode *", prefixIcon: Icons.pin, keyboardType: TextInputType.number, isRequired: true)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle("Business Info", Icons.pie_chart),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isEditMode.value) {
                return CustomTextFormField(
                  controller: TextEditingController(text: controller.selectedBusinessType.value),
                  label: "Business Type *",
                  prefixIcon: Icons.business_center,
                  readOnly: true,
                );
              } else {
                return _customDropdown(
                  label: "Business Type *",
                  prefixIcon: Icons.business_center,
                  value: controller.selectedBusinessType.value.isEmpty ? null : controller.selectedBusinessType.value,
                  items: controller.businessTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (val) => controller.selectedBusinessType.value = val ?? '',
                  isRequired: true,
                  hint: "Select Business Type",
                );
              }
            }),
            CustomTextFormField(controller: controller.businessCategoryController, label: "Business Category *", prefixIcon: Icons.category, isRequired: true),
            CustomTextFormField(controller: controller.gstController, label: "G.S.T. Number", prefixIcon: Icons.confirmation_number),
            CustomTextFormField(controller: controller.panController, label: "PAN No", prefixIcon: Icons.credit_card),

            const SizedBox(height: 16),
            Obx(() => SwitchListTile(
              value: controller.isDueDateEnabled.value,
              onChanged: (value) {
                controller.isDueDateEnabled.value = value;
                if (!value) {
                  controller.dueDateDaysController.clear();
                }
              },
              activeColor: Colors.white,
              activeTrackColor: AppColors.tealColor,
              inactiveThumbColor: Colors.grey,
              title: const Text(
                "Enable Due Date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                "Set payment due date in days from invoice date",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              secondary: Icon(Icons.calendar_today, color: AppColors.tealColor),
            )),
            Obx(() {
              if (controller.isDueDateEnabled.value) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CustomTextFormField(
                    controller: controller.dueDateDaysController,
                    label: "Due Date (Days) *",
                    prefixIcon: Icons.event_available,
                    keyboardType: TextInputType.number,
                    hintText: "e.g., 30",
                    isRequired: true,
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle("Bank Info", Icons.account_balance),
            Row(
              children: [
                Expanded(child: CustomTextFormField(controller: controller.bankNameController, label: "Bank Name", prefixIcon: Icons.account_balance_wallet)),
                const SizedBox(width: 10),
                Expanded(child: CustomTextFormField(controller: controller.ifscController, label: "IFSC Code", prefixIcon: Icons.code)),
              ],
            ),
            CustomTextFormField(controller: controller.accountNumberController, label: "Account Number", prefixIcon: Icons.numbers, keyboardType: TextInputType.number),
            CustomTextFormField(
              controller: controller.upiController,
              label: "UPI ID",
              prefixIcon: Icons.paypal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorisationCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, left: 16,bottom: 16, right: 16),
        child: Column(
          children: [
            _sectionTitle("Authorisation", Icons.edit_document),
            CustomTextFormField(controller: controller.authorisedSignatureController, label: "Authorised Signature", prefixIcon: Icons.person),

            const SizedBox(height: 16),

            Obx(() => SwitchListTile(
              value: controller.isExtraNotesEnabled.value,
              onChanged: (value) {
                controller.isExtraNotesEnabled.value = value;
                if (!value) {
                  controller.extraNote1Controller.clear();
                  controller.extraNote2Controller.clear();
                  controller.extraNote3Controller.clear();
                }
              },
              activeColor: Colors.white,
              activeTrackColor: AppColors.tealColor,
              inactiveThumbColor: Colors.grey,
              title: const Text(
                "Enable Extra Notes",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                "Add up to 3 custom notes to display on invoices",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              secondary: Icon(Icons.note_add, color: AppColors.tealColor),
            )),

            Obx(() {
              if (controller.isExtraNotesEnabled.value) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: controller.extraNote1Controller,
                      label: "Note 1",
                      prefixIcon: Icons.notes,
                      hintText: "e.g., Terms & Conditions",
                    ),
                    const SizedBox(height: 8),
                    CustomTextFormField(
                      controller: controller.extraNote2Controller,
                      label: "Note 2",
                      prefixIcon: Icons.notes,
                      hintText: "e.g., Payment Terms",
                    ),
                    const SizedBox(height: 8),
                    CustomTextFormField(
                      controller: controller.extraNote3Controller,
                      label: "Note 3",
                      prefixIcon: Icons.notes,
                      hintText: "e.g., Delivery Instructions",
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        "* At least one note is required when Extra Notes is enabled",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, left: 16,bottom: 16, right: 16),
        child: Column(
          children: [
            _sectionTitle("Features", Icons.featured_play_list),
            Row(
              children: [
                Icon(Icons.list_alt, color: AppColors.tealColor, size: 24),
                const SizedBox(width: 12),
                const Expanded(child: Text("Enable Challan Feature", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                Obx(() => Checkbox(
                  value: controller.isChallanEnabled.value,
                  onChanged: (val) => controller.isChallanEnabled.value = val ?? false,
                  activeColor: AppColors.tealColor,
                )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.receipt, color: AppColors.tealColor, size: 24),
                const SizedBox(width: 12),
                const Expanded(child: Text("Enable CashMemo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                Obx(() => Checkbox(
                  value: controller.isCashMemoEnabled.value,
                  onChanged: (val) => controller.isCashMemoEnabled.value = val ?? false,
                  activeColor: AppColors.tealColor,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGstCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, left: 16,bottom: 16, right: 16),
        child: Column(
          children: [
            _sectionTitle("GST", Icons.receipt_long),
            Obx(() => SwitchListTile(
              value: controller.isGstEnabled.value,
              onChanged: controller.isEditMode.value ? null : (val) => controller.isGstEnabled.value = val,
              activeColor: Colors.white,
              activeTrackColor: AppColors.tealColor,
              title: const Text("Enable GST", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              subtitle: const Text("Enable this if invoices should include GST calculation", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              secondary: Icon(Icons.receipt_long, color: AppColors.tealColor),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tealColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 5,
        ),
        icon: Obx(() => Icon(controller.isEditMode.value ? Icons.update : Icons.check_circle_outline)),
        label: Obx(() => Text(
          controller.isEditMode.value ? "Update Company" : "Register Company",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        )),
        onPressed: () => controller.saveCompany(),
      ),
    );
  }

  // ===========================================================================
  // 🛠️ HELPERS & DIALOGS
  // ===========================================================================

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.tealColor, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tealColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text("Company Logo (URL or pick image)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        // Row 1: Image preview full row
        Obx(() {
          final url = controller.logoPreviewUrl.value ?? controller.logoController.text.trim();
          return Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tealColor.withOpacity(0.5)),
            ),
            clipBehavior: Clip.antiAlias,
            child: url.isEmpty
                ? Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey.shade500)
                : _buildLogoPreview(url),
          );
        }),
        const SizedBox(height: 12),
        // Next line: Logo URL text field (full width)
        CustomTextFormField(
          controller: controller.logoController,
          label: "Logo URL",
          hintText: "https://example.com/logo.png",
          prefixIcon: Icons.link,
          validator: (value) {
            final t = value?.trim() ?? '';
            if (t.isEmpty) return null;
            if (t.startsWith('data:')) return null; // base64 from image picker
            if (!t.startsWith('http://') && !t.startsWith('https://')) {
              return 'Enter a valid URL (e.g. https://example.com/logo.png)';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        // Next line: Row with Pick image and Clear logo (wraps on narrow screens)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => controller.pickLogoImage(),
              icon: const Icon(Icons.image, size: 18),
              label: const Text("Pick image"),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.tealColor),
            ),
            OutlinedButton.icon(
              onPressed: () => controller.clearLogo(),
              icon: const Icon(Icons.clear, size: 18),
              label: const Text("Clear logo"),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade700),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoPreview(String url) {
    if (url.startsWith('data:')) {
      try {
        final base64 = url.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
        final bytes = base64Decode(base64);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return Icon(Icons.broken_image, size: 40, color: Colors.grey.shade500);
      }
    }
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: 40, color: Colors.grey.shade500));
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
    final bool valueExists = items.any((item) => item.value == value);
    final String? safeValue = valueExists ? value : null;

    return DropdownButtonFormField<String>(
      value: safeValue,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(prefixIcon, color: AppColors.tealColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.tealColor, width: 2),
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: isRequired
          ? (val) => (val == null || val.isEmpty) ? 'Please select $label' : null
          : null,
      hint: hint != null ? Text(hint) : null,
      isExpanded: true,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 10), Text('Logout')]),
        content: const Text('Are you sure you want to logout?', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              Get.back();
              await FirebaseAuth.instance.signOut();
              // await sharedPreferencesHelper.clearPrefData(); // Ensure this service exists
              Get.offAllNamed(AuthScreen.pageId);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class CompanyFormShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _shimmerCard(height: 140),
            const SizedBox(height: 12),
            _shimmerCard(height: 120),
            const SizedBox(height: 12),
            _shimmerCard(height: 160),
            const SizedBox(height: 12),
            _shimmerCard(height: 100),
            const SizedBox(height: 12),
            _shimmerCard(height: 80),
            const SizedBox(height: 12),
            _shimmerCard(height: 60),
            const SizedBox(height: 30),
            _shimmerCard(height: 48),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _shimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}





