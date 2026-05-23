import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../constant/constant.dart';
import '../../controller/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  static const pageId = "/settings";
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor2,
      appBar: AppBar(
        title: const Text("Application Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.appTheame,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 📊 Financial Year Section
            _buildSettingCard(
              title: "Financial Settings",
              children: [
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.currentFY.value,
                  decoration: const InputDecoration(labelText: "Active Financial Year", prefixIcon: Icon(Icons.calendar_month_rounded)),
                  items: ["2026-27", "2027-28", "2028-29"].map((fy) =>
                      DropdownMenuItem(value: fy, child: Text(fy))).toList(),
                  onChanged: (val) => controller.changeFinancialYear(val!),
                )),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.startRecCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Next Receipt Number", prefixIcon: Icon(Icons.numbers_rounded)),
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
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.donationTypeCtrl,
                        decoration: const InputDecoration(
                          hintText: "Add new type (e.g. Building)",
                          prefixIcon: Icon(Icons.add_circle_outline),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_box_rounded, size: 30, color: Colors.green),
                      onPressed: () => controller.addDonationType(),
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
                        children: controller.donationTypes.map((type) => Chip(
                          label: Text(type),
                          deleteIcon: const Icon(Icons.cancel, size: 18),
                          onDeleted: () => controller.removeDonationType(type),
                        )).toList(),
                      )),
              ],
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appTheame,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => controller.saveSettings(),
                child: const Text("Save All Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.appTheame)),
          const Divider(height: 25),
          ...children,
        ],
      ),
    );
  }
}