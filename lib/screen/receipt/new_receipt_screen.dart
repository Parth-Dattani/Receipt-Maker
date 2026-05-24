import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../constant/constant.dart';
import '../../controller/receipt_controller.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/web_app_sidebar.dart';

class NewReceiptScreen extends GetView<ReceiptController> {
  static const pageId = "/new-receipt";
  const NewReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 900;

    if (isWeb) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Row(
          children: [
            const WebAppSidebar(selectedItem: SidebarItem.newReceipt),
            Expanded(
              child: Column(
                children: [
                  _buildWebHeader(),
                  Expanded(child: _buildMainContent(context, screenWidth)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.whiteColor2,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.appTheame,
        foregroundColor: Colors.white,
        title: Obx(() => Text(
            controller.isEditMode.value ? 'Update Receipt' : 'Generate Receipt',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        )),
        centerTitle: screenWidth < 600 ? false : true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.resetForm,
            tooltip: 'Reset Form',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildMainContent(context, screenWidth),
    );
  }

  Widget _buildWebHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        children: [
          Obx(() => Text(
              controller.isEditMode.value ? 'Update Receipt' : 'Generate New Receipt',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          )),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
            onPressed: controller.resetForm,
            tooltip: "Reset Form",
          ),
          const SizedBox(width: 16),
          const VerticalDivider(width: 1, indent: 20, endIndent: 20),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: AppColors.appTheame.withValues(alpha: 0.1),
            radius: 18,
            child: Icon(Icons.add_box_rounded, color: AppColors.appTheame, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, double screenWidth) {
    bool isWeb = screenWidth > 900;
    return SafeArea(
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isWeb ? 1000 : 850),
          child: SingleChildScrollView(
            padding: isWeb ? const EdgeInsets.symmetric(vertical: 32) : EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            child: Obx(() => Skeletonizer(
              enabled: controller.isLoading.value,
              child: Column(
                children: [
                  if (!isWeb) _headerBanner(screenWidth),
                  if (isWeb) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline_rounded, size: 28, color: AppColors.appTheame),
                          const SizedBox(width: 14),
                          Text(
                            controller.isEditMode.value ? 'Update Receipt Details' : 'Create New Collection Receipt',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          // Top Sections Row for Web
                          if (isWeb)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: _sectionCard(
                                    title: 'Receipt Info',
                                    icon: Icons.receipt_long_rounded,
                                    children: [
                                      CustomTextFormField(
                                        controller: controller.recNoCtrl,
                                        label: 'Receipt No.',
                                        prefixIcon: Icons.numbers_rounded,
                                        readOnly: true,
                                      ),
                                      CustomTextFormField(
                                        controller: controller.dateCtrl,
                                        label: 'Date',
                                        prefixIcon: Icons.calendar_today_rounded,
                                        readOnly: true,
                                        onTap: () => controller.pickDate(context),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 2,
                                  child: _sectionCard(
                                    title: 'Donor Details',
                                    icon: Icons.person_rounded,
                                    children: [
                                      CustomTextFormField(
                                        controller: controller.donorNameCtrl,
                                        label: 'Full Name / Donor Name',
                                        prefixIcon: Icons.badge_rounded,
                                        isRequired: true,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextFormField(
                                              controller: controller.panNoCtrl,
                                              label: 'PAN No.',
                                              prefixIcon: Icons.credit_card_rounded,
                                              textCapitalization: TextCapitalization.characters,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: CustomTextFormField(
                                              controller: controller.mobileNoCtrl,
                                              label: 'Mobile No.',
                                              prefixIcon: Icons.phone_android_rounded,
                                              keyboardType: TextInputType.phone,
                                              maxLength: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _sectionCard(
                              title: 'Receipt Information',
                              icon: Icons.receipt_long_rounded,
                              children: [
                                _buildResponsiveRow(
                                  screenWidth,
                                  child1: CustomTextFormField(
                                    controller: controller.recNoCtrl,
                                    label: 'Receipt No.',
                                    prefixIcon: Icons.numbers_rounded,
                                    keyboardType: TextInputType.number,
                                    readOnly: true,
                                  ),
                                  child2: CustomTextFormField(
                                    controller: controller.dateCtrl,
                                    label: 'Date',
                                    prefixIcon: Icons.calendar_today_rounded,
                                    readOnly: true,
                                    onTap: () => controller.pickDate(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _sectionCard(
                              title: 'Donor Details',
                              icon: Icons.person_rounded,
                              children: [
                                CustomTextFormField(
                                  controller: controller.donorNameCtrl,
                                  label: 'Full Name / Donor Name',
                                  prefixIcon: Icons.badge_rounded,
                                  isRequired: true,
                                ),
                                _buildResponsiveRow(
                                  screenWidth,
                                  child1: CustomTextFormField(
                                    controller: controller.panNoCtrl,
                                    label: 'PAN No.',
                                    prefixIcon: Icons.credit_card_rounded,
                                    textCapitalization: TextCapitalization.characters,
                                  ),
                                  child2: CustomTextFormField(
                                    controller: controller.mobileNoCtrl,
                                    label: 'Mobile No.',
                                    prefixIcon: Icons.phone_android_rounded,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 20),

                          _sectionCard(
                            title: 'Payment & Collection Details',
                            icon: Icons.account_balance_wallet_rounded,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextFormField(
                                      controller: controller.amountCtrl,
                                      label: 'Amount (₹)',
                                      prefixIcon: Icons.currency_rupee_rounded,
                                      keyboardType: TextInputType.number,
                                      isRequired: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(child: _paymentTypeDropdown()),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(child: _donationTypeDropdown()),
                                  if (isWeb) const Spacer(),
                                ],
                              ),
                              Obx(() {
                                final pType = controller.selectedPaymentType.value;
                                if (pType == 'Cheque' || pType == 'Bank Transfer' || pType == 'Online') {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: CustomTextFormField(
                                            controller: controller.bankNameCtrl,
                                            label: 'Bank Name',
                                            prefixIcon: Icons.account_balance_rounded,
                                            isRequired: pType == 'Cheque',
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: CustomTextFormField(
                                            controller: controller.chequeNoCtrl,
                                            label: pType == 'Cheque' ? 'Cheque No.' : 'Transaction Ref No.',
                                            prefixIcon: Icons.confirmation_number_rounded,
                                            isRequired: pType == 'Cheque',
                                            textInputAction: TextInputAction.done,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                              CustomTextFormField(
                                controller: controller.remarksCtrl,
                                label: 'Remarks / Narration (Optional)',
                                prefixIcon: Icons.notes_rounded,
                                maxLines: 2,
                                textInputAction: TextInputAction.done,
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: _generateButton(),
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }

  Widget _headerBanner(double width) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 15, 20, width > 600 ? 40 : 30),
      decoration: BoxDecoration(
        color: AppColors.appTheame,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.trustName,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: width > 600 ? 20 : 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: const Text('Section 80G Registered Trust', style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.appTheame.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: AppColors.appTheame, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            ],
          ),
          const Divider(height: 25, thickness: 0.8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(double width, {required Widget child1, required Widget child2}) {
    if (width > 550) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: child1), const SizedBox(width: 16), Expanded(child: child2)]);
    } else {
      return Column(children: [child1, child2]);
    }
  }

  Widget _paymentTypeDropdown() {
    return Obx(() {
      final uniqueTypes = controller.paymentTypes.toSet().toList();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 6, left: 2),
              child: Text("Payment Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.black87)),
            ),
            DropdownButtonFormField<String>(
              value: controller.selectedPaymentType.value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_balance_wallet_rounded, size: 18, color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.appTheame.withValues(alpha: 0.5), width: 1.5)),
              ),
              items: uniqueTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14))))
                  .toList(),
              onChanged: (v) => controller.selectedPaymentType.value = v!,
            ),
          ],
        ),
      );
    });
  }

  Widget _donationTypeDropdown() {
    return Obx(() {
      final uniqueTypes = controller.donationTypes.toSet().toList();
      if (uniqueTypes.isNotEmpty && !uniqueTypes.contains(controller.selectedDonationType.value)) {
        controller.selectedDonationType.value = uniqueTypes.first;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 6, left: 2),
              child: Text("Donation Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.black87)),
            ),
            DropdownButtonFormField<String>(
              value: controller.selectedDonationType.value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.volunteer_activism_rounded, size: 18, color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.appTheame.withValues(alpha: 0.5), width: 1.5)),
              ),
              items: uniqueTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14))))
                  .toList(),
              onChanged: (v) => controller.selectedDonationType.value = v!,
            ),
          ],
        ),
      );
    });
  }

  Widget _generateButton() {
    return Obx(() => Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: AppColors.appTheame.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))]),
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.generateReceipt,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.appTheame, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
        child: controller.isLoading.value
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(controller.isEditMode.value ? Icons.save_rounded : Icons.picture_as_pdf_rounded, size: 20),
            const SizedBox(width: 10),
            Text(controller.isEditMode.value ? 'Save & Update Receipt' : 'Generate & Preview', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ));
  }
}
