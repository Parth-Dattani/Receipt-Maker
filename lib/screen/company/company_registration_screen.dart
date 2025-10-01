import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';
import '../../widgets/widgets.dart';

import 'package:shimmer/shimmer.dart';


class CompanyRegistrationScreen extends GetView<CompanyController> {
  static const pageId = "/CompanyRegistrationScreen";

  const CompanyRegistrationScreen({super.key});

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  // Custom Dropdown Widget
  // Custom Dropdown Widget
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title:  Obx(()=> Text(controller.isEditMode.value ? "Edit Company" : "Company Registration",)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          // Add edit mode indicator or action if needed
          Obx(() => controller.isEditMode.value
              ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          )
              : Container(),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx((){
          if(controller.isLoading.value){
            return CompanyFormShimmer();
          }
          else{
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Company Info Section ---
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _sectionTitle("Company Info", Icons.business),
                            Obx(
                                  ()=> CustomTextFormField(
                                controller: controller.companyCodeController,
                                label: "Company Code *",
                                prefixIcon: Icons.qr_code,
                                isRequired: true,
                                readOnly: controller.isEditMode.value,
                              ),
                            ),
                            CustomTextFormField(
                              controller: controller.companyNameController,
                              label: "Company Name *",
                              prefixIcon: Icons.apartment,
                              isRequired: true,
                            ),
                            CustomTextFormField(
                              controller: controller.addressController,
                              label: "Address",
                              prefixIcon: Icons.location_on,
                            ),

                            // 📞 Phone Number Field
                            CustomTextFormField(
                              controller: controller.phoneController,  // <-- Create this controller in your controller class
                              label: "Phone Number *",
                              prefixIcon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              isRequired: true,
                            ),

                            // Add this in your CompanyRegistrationScreen, after phoneController field

// 📊 Invoice Starting Number Field
                            CustomTextFormField(
                              controller: controller.invoiceStartingNumberController,
                              label: "Invoice Starting Number",
                              prefixIcon: Icons.receipt_long,
                              keyboardType: TextInputType.number,
                              hintText: "Default: 1",
                            ),

                            const SizedBox(height: 5),

                            // Add helper text
                            Padding(
                              padding: const EdgeInsets.only(left: 16, bottom: 12),
                              child: Text(
                                "Set the starting number for invoices (e.g., 1000 will create INV1000, INV1001, etc.)",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            /// Country Dropdown
                            // Obx(() => _customDropdown(
                            //   label: "Country *",
                            //   prefixIcon: Icons.flag,
                            //   value: controller.selectedCountry.value.isEmpty
                            //       ? null
                            //       : controller.selectedCountry.value,
                            //   items: controller.countries.map((country) {
                            //     return DropdownMenuItem<String>(
                            //       value: country,
                            //       child: Text(country),
                            //     );
                            //   }).toList(),
                            //   onChanged: (value) {
                            //     controller.selectedCountry.value = value ?? '';
                            //     controller.selectedState.value = ''; // Reset state when country changes
                            //   },
                            //   isRequired: true,
                            //   hint: "Select Country",
                            // )),
        // Country Dropdown
                            Obx(() => _customDropdown(
                              label: "Country *",
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



                            // State Dropdown (only shows when country is selected)
                            Obx(() {
                              if (controller.selectedCountry.value.isNotEmpty) {
                                return _customDropdown(
                                  label: "State *",
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
                                const SizedBox(width: 10),
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
                            CustomTextFormField(
                              controller: controller.logoController,
                              label: "Logo",
                              prefixIcon: Icons.image,
                              hintText: "Upload company logo",
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- Business Info Section ---
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _sectionTitle("Business Info", Icons.pie_chart),
                            CustomTextFormField(
                              controller: controller.businessCategoryController,
                              label: "Business Category *",
                              prefixIcon: Icons.category,
                              isRequired: true,
                            ),
                            CustomTextFormField(
                              controller: controller.gstController,
                              label: "G.S.T. Number",
                              prefixIcon: Icons.confirmation_number,
                            ),
                            CustomTextFormField(
                              controller: controller.panController,
                              label: "PAN No",
                              prefixIcon: Icons.credit_card,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- Bank Info Section ---
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _sectionTitle("Bank Info", Icons.account_balance),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextFormField(
                                    controller: controller.bankNameController,
                                    label: "Bank Name",
                                    prefixIcon: Icons.account_balance_wallet,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CustomTextFormField(
                                    controller: controller.ifscController,
                                    label: "IFSC Code",
                                    prefixIcon: Icons.code,
                                  ),
                                ),
                              ],
                            ),
                            CustomTextFormField(
                              controller: controller.accountNumberController,
                              label: "Account Number",
                              prefixIcon: Icons.numbers,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- Authorisation Section ---
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _sectionTitle("Authorisation", Icons.edit_document),
                            CustomTextFormField(
                              controller: controller.authorisedSignatureController,
                              label: "Authorised Signature ",
                              prefixIcon: Icons.person,
                              //isRequired: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- Features Section with Challan Option ---
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _sectionTitle("Features", Icons.featured_play_list),
                            Row(
                              children: [
                                Icon(Icons.list_alt, color: Colors.green, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Enable Challan Feature",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                Obx(() => Checkbox(
                                  value: controller.isChallanEnabled.value,
                                  onChanged: (value) {
                                    controller.isChallanEnabled.value = value ?? false;
                                  },
                                  activeColor: Colors.teal,
                                )),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Allows creating and managing delivery challans",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- GST Section Option ---
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _sectionTitle("GST", Icons.receipt_long),
                            Obx(() => SwitchListTile(
                              value: controller.isGstEnabled.value,
                              onChanged: (value) {
                                controller.isGstEnabled.value = value;
                              },
                              activeColor: Colors.white,
                              activeTrackColor: Colors.teal,
                              inactiveThumbColor: Colors.grey,
                              title: const Text(
                                "Enable GST",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: const Text(
                                "Enable this if invoices should include GST calculation",
                                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                              secondary: const Icon(Icons.receipt_long, color: Colors.teal),
                            )),
                          ],
                        ),
                      ),
                    ),


                    const SizedBox(height: 25),

                    // --- Register Button ---
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 36, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        icon: Icon(controller.isEditMode.value
                            ? Icons.update : Icons.check_circle_outline),
                        label: Text(
                          controller.isEditMode.value
                              ? "Update Company" : "Register Company",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => controller.saveCompany(),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          }
        }),
      )
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Info Section Shimmer
            _buildSectionShimmer("Company Info", Icons.business),
            const SizedBox(height: 16),
            _buildTextFieldShimmer(),
            const SizedBox(height: 12),
            _buildTextFieldShimmer(),
            const SizedBox(height: 12),
            _buildTextFieldShimmer(),
            const SizedBox(height: 12),
            _buildDropdownShimmer(),
            const SizedBox(height: 12),
            _buildDropdownShimmer(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextFieldShimmer()),
                const SizedBox(width: 10),
                Expanded(child: _buildTextFieldShimmer()),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextFieldShimmer(),

            const SizedBox(height: 20),

            // Business Info Section Shimmer
            _buildSectionShimmer("Business Info", Icons.pie_chart),
            const SizedBox(height: 16),
            _buildTextFieldShimmer(),
            const SizedBox(height: 12),
            _buildTextFieldShimmer(),
            const SizedBox(height: 12),
            _buildTextFieldShimmer(),

            const SizedBox(height: 20),

            // Bank Info Section Shimmer
            _buildSectionShimmer("Bank Info", Icons.account_balance),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextFieldShimmer()),
                const SizedBox(width: 10),
                Expanded(child: _buildTextFieldShimmer()),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextFieldShimmer(),

            const SizedBox(height: 20),

            // Authorisation Section Shimmer
            _buildSectionShimmer("Authorisation", Icons.edit_document),
            const SizedBox(height: 16),
            _buildTextFieldShimmer(),

            const SizedBox(height: 20),

            // Features Section Shimmer
            _buildSectionShimmer("Features", Icons.featured_play_list),
            const SizedBox(height: 16),
            _buildCheckboxShimmer(),

            const SizedBox(height: 25),
            _buildButtonShimmer(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionShimmer(String title, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 22),
            const SizedBox(width: 8),
            Container(
              width: 120,
              height: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldShimmer() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildDropdownShimmer() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
    );
  }

  Widget _buildCheckboxShimmer() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.list_alt, color: Colors.grey, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 20,
                color: Colors.white,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonShimmer() {
    return Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}

// class CompanyRegistrationScreen extends GetView<CompanyController> {
//   static const pageId = "/CompanyRegistrationScreen";
//
//   const CompanyRegistrationScreen({super.key});
//
//   Widget _sectionTitle(String title, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.teal, size: 22),
//           const SizedBox(width: 8),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.teal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         title: const Text("Company Registration"),
//         centerTitle: true,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Colors.teal, Colors.tealAccent],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: controller.formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // --- Company Info Section ---
//               Card(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       _sectionTitle("Company Info", Icons.business),
//                       CustomTextFormField(
//                         controller: controller.companyCodeController,
//                         label: "Company Code *",
//                         prefixIcon: Icons.qr_code,
//                         isRequired: true,
//                       ),
//                       CustomTextFormField(
//                         controller: controller.companyNameController,
//                         label: "Company Name *",
//                         prefixIcon: Icons.apartment,
//                         isRequired: true,
//                       ),
//                       CustomTextFormField(
//                         controller: controller.addressController,
//                         label: "Address",
//                         prefixIcon: Icons.location_on,
//                       ),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: CustomTextFormField(
//                               controller: controller.cityController,
//                               label: "City *",
//                               prefixIcon: Icons.location_city,
//                               isRequired: true,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: CustomTextFormField(
//                               controller: controller.stateController,
//                               label: "State *",
//                               prefixIcon: Icons.map,
//                               isRequired: true,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           Expanded(
//                             child:
//                             CountryPickerDropdown(
//                               itemBuilder: (Country country) => Row(
//                                 children: [
//                                   CountryPickerUtils.getDefaultFlagImage(country),
//                                   SizedBox(width: 8),
//                                   Text("+${country.phoneCode}"),
//                                   SizedBox(width: 8),
//                                   Text(country.name),
//                                 ],
//                               ),
//                               onValuePicked: (Country country) {
//                                 print("${country.name}");
//                               },
//                             ),
//                             // CustomTextFormField(
//                             //   controller: controller.countryController,
//                             //   label: "Country *",
//                             //   prefixIcon: Icons.flag,
//                             //   isRequired: true,
//                             // ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: CustomTextFormField(
//                               controller: controller.pincodeController,
//                               label: "Pincode *",
//                               prefixIcon: Icons.pin,
//                               keyboardType: TextInputType.number,
//                               isRequired: true,
//                             ),
//                           ),
//                         ],
//                       ),
//                       CustomTextFormField(
//                         controller: controller.logoController,
//                         label: "Logo",
//                         prefixIcon: Icons.image,
//                         hintText: "Upload company logo",
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // --- Business Info Section ---
//               Card(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 elevation: 4,
//                 margin: const EdgeInsets.symmetric(vertical: 12),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       _sectionTitle("Business Info", Icons.pie_chart),
//                       CustomTextFormField(
//                         controller: controller.businessCategoryController,
//                         label: "Business Category *",
//                         prefixIcon: Icons.category,
//                         isRequired: true,
//                       ),
//                       CustomTextFormField(
//                         controller: controller.gstController,
//                         label: "G.S.T. Number",
//                         prefixIcon: Icons.confirmation_number,
//                       ),
//                       CustomTextFormField(
//                         controller: controller.panController,
//                         label: "PAN No",
//                         prefixIcon: Icons.credit_card,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // --- Bank Info Section ---
//               Card(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 elevation: 4,
//                 margin: const EdgeInsets.symmetric(vertical: 12),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       _sectionTitle("Bank Info", Icons.account_balance),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: CustomTextFormField(
//                               controller: controller.bankNameController,
//                               label: "Bank Name",
//                               prefixIcon: Icons.account_balance_wallet,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: CustomTextFormField(
//                               controller: controller.ifscController,
//                               label: "IFSC Code",
//                               prefixIcon: Icons.code,
//                             ),
//                           ),
//                         ],
//                       ),
//                       CustomTextFormField(
//                         controller: controller.accountNumberController,
//                         label: "Account Number",
//                         prefixIcon: Icons.numbers,
//                         keyboardType: TextInputType.number,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // --- Authorisation Section ---
//               Card(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       _sectionTitle("Authorisation", Icons.edit_document),
//                       CustomTextFormField(
//                         controller: controller.authorisedSignatureController,
//                         label: "Authorised Signature *",
//                         prefixIcon: Icons.person,
//                         isRequired: true,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // --- Features Section with Challan Option ---
//               Card(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 elevation: 4,
//                 margin: const EdgeInsets.symmetric(vertical: 12),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       _sectionTitle("Features", Icons.featured_play_list),
//                       Row(
//                         children: [
//                           Icon(Icons.list_alt, color: Colors.green, size: 24),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               "Enable Challan Feature",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.grey.shade700,
//                               ),
//                             ),
//                           ),
//                           Obx(() => Checkbox(
//                             value: controller.isChallanEnabled.value,
//                             onChanged: (value) {
//                               controller.isChallanEnabled.value = value ?? false;
//                             },
//                             activeColor: Colors.teal,
//                           )),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         "Allows creating and managing delivery challans",
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 25),
//
//               // --- Register Button ---
//               Center(
//                 child: ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 36, vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     elevation: 5,
//                   ),
//                   icon: const Icon(Icons.check_circle_outline),
//                   label: const Text(
//                     "Register Company",
//                     style: TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   onPressed: () => controller.registerCompany(),
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


