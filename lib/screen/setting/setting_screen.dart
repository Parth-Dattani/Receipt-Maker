import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  static const String pageId = '/SettingsScreen';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Obx(() => Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildCurrencySettings(),
                            SizedBox(height: 16),
                            _buildTaxSettings(),
                            SizedBox(height: 16),
                            _buildInvoiceSettings(),
                            SizedBox(height: 16),
                            _buildTemplateSettings(),
                            SizedBox(height: 16),
                            _buildLanguageSettings(),
                            SizedBox(height: 16),
                            _buildTermsSettings(),
                            SizedBox(height: 30),
                            _buildActionButtons(),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                      if (controller.isLoading.value)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Saving Settings...'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Configure your invoice preferences',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: controller.loadSettings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySettings() {
    return _buildSettingsCard(
      icon: Icons.attach_money,
      title: 'Currency Settings',
      children: [
        Text(
          'Currency Symbol',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.currencyOptions.map((currency) {
            bool isSelected = controller.currencySymbol.value == currency;
            return GestureDetector(
              onTap: () => controller.updateCurrency(currency),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF667eea) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Color(0xFF667eea) : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  currency,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildTaxSettings() {
    return _buildSettingsCard(
      icon: Icons.receipt_long,
      title: 'Tax Settings',
      children: [
        Obx(() => _buildSwitchTile(
          title: 'GST',
          subtitle: 'Enable GST calculations',
          value: controller.isGstEnabled.value,
          onChanged: controller.updateGstStatus,
        )),
        SizedBox(height: 8),
        Obx(() => _buildSwitchTile(
          title: 'PAN',
          subtitle: controller.isGstEnabled.value
              ? 'PAN is mandatory when GST is enabled'
              : 'Include PAN in invoices',
          value: controller.isPanEnabled.value,
          onChanged: controller.updatePanStatus,
          enabled: !controller.isGstEnabled.value,
        )),
        SizedBox(height: 8),
        Obx(() => _buildSwitchTile(
          title: 'Bank Details',
          subtitle: controller.isGstEnabled.value
              ? 'Bank details are mandatory when GST is enabled'
              : 'Include bank details in invoices',
          value: controller.isBankDetailEnabled.value,
          onChanged: controller.updateBankDetailStatus,
          enabled: !controller.isGstEnabled.value,
        )),
      ],
    );
  }

  Widget _buildInvoiceSettings() {
    return _buildSettingsCard(
      icon: Icons.description,
      title: 'Invoice Settings',
      children: [
        Text(
          'Bill Format',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        SizedBox(height: 12),
        Obx(() => Column(
          children: controller.billFormats.map((format) {
            int formatId = int.parse(format['id']!);
            bool isSelected = controller.selectedBillFormat.value == formatId;
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Radio<int>(
                  value: formatId,
                  groupValue: controller.selectedBillFormat.value,
                  onChanged: (value) => controller.updateBillFormat(value!),
                  activeColor: Color(0xFF667eea),
                ),
                title: Text(
                  format['name']!,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(format['description']!),
                tileColor: isSelected ? Color(0xFF667eea).withOpacity(0.1) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onTap: () => controller.updateBillFormat(formatId),
              ),
            );
          }).toList(),
        )),
        SizedBox(height: 16),
        Text(
          'Start Invoice Number',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller.startInvoiceController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'Enter starting invoice number',
            prefixIcon: Icon(Icons.numbers, color: Color(0xFF667eea)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          onFieldSubmitted: (value) => controller.updateStartInvoiceNumber(),
        ),
      ],
    );
  }

  Widget _buildTemplateSettings() {
    return _buildSettingsCard(
      icon: Icons.palette,
      title: 'Invoice Templates',
      children: [
        Text(
          'Choose Template',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        SizedBox(height: 12),
        Obx(() => GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: controller.invoiceTemplates.length,
          itemBuilder: (context, index) {
            final template = controller.invoiceTemplates[index];
            bool isSelected = controller.selectedTemplate.value == template['id'];

            return GestureDetector(
              onTap: () => controller.updateTemplate(template['id']),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Color(0xFF667eea) : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: template['color'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.description,
                        color: template['color'],
                        size: 30,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      template['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      template['description'],
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isSelected)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF667eea),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        )),
      ],
    );
  }

  Widget _buildLanguageSettings() {
    return _buildSettingsCard(
      icon: Icons.language,
      title: 'Language Settings',
      children: [
        Text(
          'Invoice Language',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedLanguage.value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            prefixIcon: Icon(Icons.translate, color: Color(0xFF667eea)),
          ),
          items: controller.languageOptions.map((language) {
            return DropdownMenuItem<String>(
              value: language,
              child: Text(language),
            );
          }).toList(),
          onChanged: (value) => controller.updateLanguage(value!),
        )),
      ],
    );
  }

  Widget _buildTermsSettings() {
    return _buildSettingsCard(
      icon: Icons.article,
      title: 'Terms & Conditions',
      children: [
        Text(
          'Default Terms & Conditions',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller.termsController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter default terms and conditions for invoices',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          onFieldSubmitted: (value) => controller.updateTermsAndConditions(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.save, size: 20),
            label: Text(
              'Save Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.resetSettings,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.refresh, size: 20),
            label: Text(
              'Reset to Default',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Color(0xFF667eea), size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: enabled ? Colors.grey.shade800 : Colors.grey.shade500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: Color(0xFF667eea),
          ),
        ],
      ),
    );
  }
}