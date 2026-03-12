import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TemplatePreviewScreen extends StatelessWidget {
  final int templateId;

  const TemplatePreviewScreen({Key? key, required this.templateId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final template = _getTemplateData(templateId);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Template Preview - ${template['name']}'),
        backgroundColor: template['primaryColor'],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _downloadTemplate(),
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareTemplate(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: _buildInvoicePreview(template),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _useThisTemplate(),
        backgroundColor: template['primaryColor'],
        label: Text('Use This Template'),
        icon: Icon(Icons.check),
      ),
    );
  }

  Map<String, dynamic> _getTemplateData(int templateId) {
    final templates = {
      1: {
        'name': 'Classic Blue',
        'primaryColor': Colors.blue.shade700,
        'secondaryColor': Colors.blue.shade50,
        'accentColor': Colors.blue.shade200,
        'headerStyle': 'classic',
      },
      2: {
        'name': 'Modern Green',
        'primaryColor': Colors.green.shade600,
        'secondaryColor': Colors.green.shade50,
        'accentColor': Colors.green.shade200,
        'headerStyle': 'modern',
      },
      3: {
        'name': 'Corporate Gray',
        'primaryColor': Colors.grey.shade700,
        'secondaryColor': Colors.grey.shade50,
        'accentColor': Colors.grey.shade300,
        'headerStyle': 'corporate',
      },
      4: {
        'name': 'Elegant Purple',
        'primaryColor': Colors.purple.shade700,
        'secondaryColor': Colors.purple.shade50,
        'accentColor': Colors.purple.shade200,
        'headerStyle': 'elegant',
      },
    };

    return templates[templateId] ?? templates[1]!;
  }

  Widget _buildInvoicePreview(Map<String, dynamic> template) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(template),
          SizedBox(height: 32),
          _buildBillingInfo(template),
          SizedBox(height: 24),
          _buildInvoiceDetails(template),
          SizedBox(height: 24),
          _buildItemsTable(template),
          SizedBox(height: 24),
          _buildTotalSection(template),
          SizedBox(height: 24),
          _buildFooter(template),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> template) {
    switch (template['headerStyle']) {
      case 'modern':
        return _buildModernHeader(template);
      case 'corporate':
        return _buildCorporateHeader(template);
      case 'elegant':
        return _buildElegantHeader(template);
      default:
        return _buildClassicHeader(template);
    }
  }

  Widget _buildClassicHeader(Map<String, dynamic> template) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: template['primaryColor'],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR COMPANY NAME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '123 Business Street\nCity, State 12345\nPhone: (555) 123-4567\nEmail: info@company.com',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'INVOICE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#INV-001',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(Map<String, dynamic> template) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: template['primaryColor'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.business, color: Colors.white, size: 30),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR COMPANY NAME',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Professional Services',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: template['secondaryColor'],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: template['primaryColor']),
              ),
              child: Text(
                'INVOICE',
                style: TextStyle(
                  color: template['primaryColor'],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Divider(color: template['accentColor'], thickness: 2),
      ],
    );
  }

  Widget _buildCorporateHeader(Map<String, dynamic> template) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR COMPANY NAME',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: template['primaryColor'],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '123 Business Street, City, State 12345',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'Tel: (555) 123-4567 | Email: info@company.com',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'INVOICE',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: template['primaryColor'],
                  ),
                ),
                Text(
                  'INV-001',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          height: 1,
          color: template['primaryColor'],
        ),
      ],
    );
  }

  Widget _buildElegantHeader(Map<String, dynamic> template) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [template['primaryColor'], template['primaryColor'].withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'YOUR COMPANY NAME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '123 Business Street\nCity, State 12345\n(555) 123-4567',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [template['primaryColor'].withOpacity(0.1), template['secondaryColor']],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'INVOICE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: template['primaryColor'],
                        ),
                      ),
                      Text(
                        '#001',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          color: template['primaryColor'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingInfo(Map<String, dynamic> template) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bill To:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: template['primaryColor'],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: template['secondaryColor'],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('ABC Corporation'),
                    Text('456 Client Avenue'),
                    Text('City, State 67890'),
                    Text('john@abccorp.com'),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoice Details:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: template['primaryColor'],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              _buildDetailRow('Invoice Date:', 'Aug 26, 2025'),
              _buildDetailRow('Due Date:', 'Sep 25, 2025'),
              _buildDetailRow('Payment Terms:', '30 Days'),
              _buildDetailRow('Currency:', '₹ INR'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails(Map<String, dynamic> template) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: template['secondaryColor'],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: template['accentColor']),
      ),
      child: Row(
        children: [
          Icon(Icons.description, color: template['primaryColor'], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: template['primaryColor'],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Web Development Services for Q3 2025',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(Map<String, dynamic> template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoice Items',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: template['primaryColor'],
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: template['accentColor']),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: template['primaryColor'],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('Description', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('Qty', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    Expanded(flex: 2, child: Text('Rate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                    Expanded(flex: 2, child: Text('Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                  ],
                ),
              ),
              // Items
              _buildTableRow(['Frontend Development', '40', '₹1,500', '₹60,000'], false, template),
              _buildTableRow(['Backend Integration', '20', '₹2,000', '₹40,000'], true, template),
              _buildTableRow(['UI/UX Design', '15', '₹1,200', '₹18,000'], false, template),
              _buildTableRow(['Testing & QA', '10', '₹1,000', '₹10,000'], true, template),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableRow(List<String> items, bool isAlternate, Map<String, dynamic> template) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isAlternate ? template['secondaryColor'] : Colors.white,
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(items[0], style: TextStyle(fontSize: 12))),
          Expanded(flex: 1, child: Text(items[1], style: TextStyle(fontSize: 12), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(items[2], style: TextStyle(fontSize: 12), textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text(items[3], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildTotalSection(Map<String, dynamic> template) {
    return Row(
      children: [
        Expanded(child: Container()), // Spacer
        Container(
          width: 280,
          child: Column(
            children: [
              _buildTotalRow('Subtotal:', '₹1,28,000', false, template),
              _buildTotalRow('GST (18%):', '₹23,040', false, template),
              Divider(color: template['accentColor']),
              _buildTotalRow('Total Amount:', '₹1,51,040', true, template),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String amount, bool isBold, Map<String, dynamic> template) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? template['primaryColor'] : Colors.grey.shade700,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? template['primaryColor'] : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(Map<String, dynamic> template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: template['secondaryColor'],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: template['primaryColor'],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Payment due within 30 days. Late payments may incur additional charges. All work is subject to our standard terms and conditions.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _downloadTemplate() {
    Get.snackbar(
      'Download',
      'Template download feature will be implemented',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _shareTemplate() {
    Get.snackbar(
      'Share',
      'Template sharing feature will be implemented',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _useThisTemplate() {
    Get.defaultDialog(
      title: 'Confirm Selection',
      middleText: 'Do you want to use this template for your invoices?',
      textConfirm: 'Yes, Use This',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // Close dialog
        Get.back(); // Go back to settings
        Get.snackbar(
          'Success',
          'Template selected successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
    );
  }
}