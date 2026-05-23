import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../constant/constant.dart';
import '../../controller/receipt_controller.dart';

class NewReceiptScreen extends GetView<ReceiptController> {
  static const pageId = "/new-receipt";
  const NewReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 850),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Obx(() => Skeletonizer( // 🚀 અહીં Skeletonizer આખા ફોર્મ પર લાગી ગયું
                enabled: controller.isLoading.value,
                child: Column(
                  children: [
                    _headerBanner(screenWidth),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          children: [
                            _sectionCard(
                              title: 'Receipt Information',
                              icon: Icons.receipt_long_rounded,
                              children: [
                                _buildResponsiveRow(
                                  screenWidth,
                                  child1: _customField(
                                    controller: controller.recNoCtrl,
                                    label: 'Receipt No.',
                                    icon: Icons.numbers_rounded,
                                    keyboardType: TextInputType.number,
                                    readOnly: true,
                                  ),
                                  child2: _customField(
                                    controller: controller.dateCtrl,
                                    label: 'Date',
                                    icon: Icons.calendar_today_rounded,
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
                                _customField(
                                  controller: controller.donorNameCtrl,
                                  label: 'Full Name / Donor Name',
                                  icon: Icons.badge_rounded,
                                  required: true,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 16),
                                _buildResponsiveRow(
                                  screenWidth,
                                  child1: _customField(
                                    controller: controller.panNoCtrl,
                                    label: 'PAN No.',
                                    icon: Icons.credit_card_rounded,
                                    caps: TextCapitalization.characters,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  child2: _customField(
                                    controller: controller.mobileNoCtrl,
                                    label: 'Mobile No.',
                                    icon: Icons.phone_android_rounded,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,

                                    textInputAction: TextInputAction.next,
                                    validator: (v) {                                    // ← આ add કરો
                                      if (v == null || v.trim().isEmpty) return 'Mobile No. required';
                                      if (v.trim().length != 10) return '10 digits mobile no.';
                                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim()))
                                        return 'please enter valid  mobile no';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            _sectionCard(
                              title: 'Payment Details',
                              icon: Icons.account_balance_wallet_rounded,
                              children: [
                                _buildResponsiveRow(
                                  screenWidth,
                                  child1: _customField(
                                    controller: controller.amountCtrl,
                                    label: 'Amount (₹)',
                                    icon: Icons.currency_rupee_rounded,
                                    keyboardType: TextInputType.number,
                                    required: true,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  child2: _paymentTypeDropdown(),
                                ),
                                const SizedBox(height: 16),
                                _donationTypeDropdown(),
                                Obx(() {
                                  final pType = controller.selectedPaymentType.value;
                                  if (pType == 'Cheque' || pType == 'Bank Transfer' || pType == 'Online') {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: _buildResponsiveRow(
                                        screenWidth,
                                        child1: _customField(
                                          controller: controller.bankNameCtrl,
                                          label: 'Bank Name',
                                          icon: Icons.account_balance_rounded,
                                          required: pType == 'Cheque',
                                          textInputAction: TextInputAction.next,
                                        ),
                                        child2: _customField(
                                          controller: controller.chequeNoCtrl,
                                          label: pType == 'Cheque' ? 'Cheque No.' : 'Transaction Ref No.',
                                          icon: Icons.confirmation_number_rounded,
                                          required: pType == 'Cheque',
                                          textInputAction: TextInputAction.done,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                                const SizedBox(height: 16),
                                _customField(
                                  controller: controller.remarksCtrl,
                                  label: 'Remarks / Narration (Optional)',
                                  icon: Icons.notes_rounded,
                                  maxLines: 2,
                                  textInputAction: TextInputAction.done,
                                ),
                              ],
                            ),
                            const SizedBox(height: 35),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: _generateButton(),
                            ),
                            const SizedBox(height: 40),
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
      return Column(children: [child1, const SizedBox(height: 14), child2]);
    }
  }

  Widget _customField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    bool required = false,
    String? Function(String?)? validator,
    TextCapitalization caps = TextCapitalization.words,
    int maxLines = 1,
    int? maxLength,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      textCapitalization: caps,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      validator: validator ?? (required ? (v) => v!.isEmpty ? 'This field is required' : null : null),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.appTheame.withOpacity(0.7)),
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        counterText: '',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.appTheame, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    );
  }

  Widget _paymentTypeDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedPaymentType.value,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
      decoration: InputDecoration(
        labelText: 'Payment Mode',
        prefixIcon: Icon(Icons.account_balance_wallet_rounded, size: 18, color: AppColors.appTheame.withOpacity(0.7)),
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.appTheame, width: 1.5)),
      ),
      items: controller.paymentTypes
          .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: (v) => controller.selectedPaymentType.value = v!,
    ));
  }

  Widget _donationTypeDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedDonationType.value,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
      decoration: InputDecoration(
        labelText: 'Donation Type',
        prefixIcon: Icon(Icons.volunteer_activism_rounded, size: 18, color: AppColors.appTheame.withOpacity(0.7)),
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.appTheame, width: 1.5)),
      ),
      items: controller.donationTypes
          .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: (v) => controller.selectedDonationType.value = v!,
    ));
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
