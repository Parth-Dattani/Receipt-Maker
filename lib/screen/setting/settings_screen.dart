import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../constant/constant.dart';
import '../../controller/settings_controller.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/web_app_sidebar.dart';

class SettingsScreen extends GetView<SettingsController> {
  static const pageId = "/settings";
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 900;

    if (isWeb) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Row(
          children: [
            const WebAppSidebar(selectedItem: SidebarItem.settings),
            Expanded(
              child: Column(
                children: [
                  _buildWebHeader(),
                  Expanded(child: _buildMainContent()),
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
        title: const Text("Application Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.appTheame,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildWebHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        children: [
          const Text("Application Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          CircleAvatar(
            backgroundColor: AppColors.appTheame.withValues(alpha: 0.1),
            radius: 18,
            child: Icon(Icons.settings_suggest_rounded, color: AppColors.appTheame, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 📊 Financial Year Section
              _buildSettingCard(
                title: "Financial Settings",
                children: [
                  _buildSettingsDropdown(
                    label: "Active Financial Year",
                    icon: Icons.calendar_month_rounded,
                    value: controller.currentFY.value,
                    items: ["2026-27", "2027-28", "2028-29"],
                    onChanged: (val) => controller.changeFinancialYear(val!),
                  ),
                  CustomTextFormField(
                    controller: controller.startRecCtrl,
                    label: "Next Receipt Number",
                    prefixIcon: Icons.numbers_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 📱 WhatsApp Sharing Section
              _buildSettingCard(
                title: "Sharing Preferences",
                children: [
                  Obx(() => SwitchListTile(
                    title: const Text("Direct WhatsApp Chat", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Open donor's chat directly before sharing PDF", style: TextStyle(fontSize: 11)),
                    value: AppConstants.isWhatsappDirectShare.value,
                    activeColor: AppColors.whatsappColor,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => controller.toggleDirectShare(val),
                  )),
                ],
              ),
              const SizedBox(height: 20),

              // 🎁 Donation Types Section
              _buildSettingCard(
                title: "Donation Types",
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          controller: controller.donationTypeCtrl,
                          label: "Add New Type",
                          hintText: "e.g. Building Fund",
                          prefixIcon: Icons.add_circle_outline,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, left: 12),
                        child: IconButton(
                          icon: const Icon(Icons.add_box_rounded, size: 36, color: Colors.green),
                          onPressed: () => controller.addDonationType(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(() => controller.isLoadingTypes.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.donationTypes.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text("No types added yet", style: TextStyle(color: Colors.grey)),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.donationTypes.map((type) => Chip(
                            label: Text(type, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.grey.shade100,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            deleteIcon: const Icon(Icons.cancel, size: 16),
                            onDeleted: () => controller.removeDonationType(type),
                          )).toList(),
                        )),
                ],
              ),

              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appTheame,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => controller.saveSettings(),
                  child: const Text("Save All Settings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.appTheame)),
          const Divider(height: 30, thickness: 0.8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsDropdown({required String label, required IconData icon, required String value, required List<String> items, required Function(String?) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 2),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.black87)),
          ),
          Obx(() => DropdownButtonFormField<String>(
            value: controller.currentFY.value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.appTheame.withValues(alpha: 0.5), width: 1.5)),
            ),
            items: items.map((fy) => DropdownMenuItem(value: fy, child: Text(fy))).toList(),
            onChanged: onChanged,
          )),
        ],
      ),
    );
  }
}
