
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';
import '../../utils/utils.dart';

class PurchaseEntryScreen extends GetView<PurchaseEntryController> {
  static const String pageId = '/PurchaseEntryScreen';

  const PurchaseEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 4,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
        ),
        backgroundColor: AppColors.tealColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: Obx(() => Text(
          controller.isEditMode.value ? 'Edit Purchase Entry' : 'New Purchase Entry',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        )),
        centerTitle: true,
        actions: [
          Obx(() => controller.isEditMode.value
              ? _buildEditModeActions()
              : const SizedBox.shrink()),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPurchaseDetailsCard(),
                    SizedBox(height: 16),
                    _buildVendorSection(),
                    SizedBox(height: 16),
                    _buildItemsSection(),
                    SizedBox(height: 16),
                    _buildCalculationsSection(),
                    SizedBox(height: 16),
                    _buildNotesSection(),
                    SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
            Obx(() => controller.isLoading.value
                ? Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.tealColor),
                      ),
                      SizedBox(height: 8),
                      Text(
                        controller.isEditMode.value ? 'Updating...' : 'Saving...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                : SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildEditModeActions() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.delete, color: Colors.white),
          onPressed: () => _showDeleteConfirmation(),
          tooltip: 'Delete Purchase',
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPurchaseDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: AppColors.tealColor),
                SizedBox(width: 8),
                Text(
                  'Purchase Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealColor,
                  ),
                ),
                Spacer(),
                Obx(() => controller.isEditMode.value
                    ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tealColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.tealColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Edit Mode',
                    style: TextStyle(
                      color: AppColors.tealColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : SizedBox()),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.purchaseNumberController,
                    decoration: InputDecoration(
                      labelText: 'Purchase Number',
                      prefixIcon: Icon(Icons.receipt_long, color: AppColors.tealColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                      ),
                    ),
                    readOnly: true,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: controller.purchaseDateController,
                    decoration: InputDecoration(
                      labelText: 'Purchase Date',
                      prefixIcon: Icon(Icons.calendar_today, color: AppColors.tealColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                      ),
                    ),
                    readOnly: true,
                    onTap: controller.selectPurchaseDate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: AppColors.tealColor),
                SizedBox(width: 8),
                Text(
                  'Vendor Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealColor,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Spacer(),
                Obx(() => !controller.isEditMode.value
                    ? IconButton(
                  onPressed: controller.toggleVendorForm,
                  icon: Icon(
                    controller.showVendorForm.value ? Icons.store : Icons.add_business,
                    color: AppColors.tealColor,
                  ),
                  tooltip: controller.showVendorForm.value
                      ? 'Select from existing customers'
                      : 'Add new vendor manually',
                )
                    : SizedBox()),
              ],
            ),
            SizedBox(height: 16),
            Obx(() {
              if (controller.isEditMode.value) {
                return _buildVendorFormFields();
              } else {
                if (controller.customers.isEmpty && !controller.showVendorForm.value) {
                  return Column(
                    children: [
                      Text(
                        'No customers found. Please add vendor details.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: controller.toggleVendorForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tealColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Add Vendor Details'),
                      ),
                    ],
                  );
                } else if (!controller.showVendorForm.value) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<Map<String, dynamic>>(
                      value: controller.selectedVendor.value,
                      isExpanded: true,
                      hint: Text('Select Customer as Vendor'),
                      underline: SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Select Customer'),
                        ),
                        ...controller.customers.map((customer) {
                          return DropdownMenuItem(
                            value: customer,
                            child: Text(customer['name'] ?? 'Unknown Customer'),
                          );
                        }).toList(),
                      ],
                      onChanged: controller.selectVendor,
                    ),
                  );
                } else {
                  return _buildVendorFormFields();
                }
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: controller.vendorNameController,
          decoration: InputDecoration(
            labelText: 'Vendor Name',
            prefixIcon: Icon(Icons.store, color: AppColors.tealColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.tealColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter vendor name';
            }
            return null;
          },
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.vendorMobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone, color: AppColors.tealColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller.vendorEmailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: AppColors.tealColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        TextFormField(
          controller: controller.vendorAddressController,
          decoration: InputDecoration(
            labelText: 'Address',
            prefixIcon: Icon(Icons.location_on, color: AppColors.tealColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.tealColor, width: 2),
            ),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, color: AppColors.tealColor),
                SizedBox(width: 8),
                Text(
                  'Purchase Items (Manual Entry)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.tealColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Item Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.tealColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Purchase Price',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.tealColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Quantity',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.tealColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                ],
              ),
            ),
            SizedBox(height: 12),
            Obx(() => Column(
              children: [
                ...controller.purchaseItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  PurchaseItem item = entry.value;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tealColor.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Item ${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    height: 40,
                                    child: TextFormField(
                                      initialValue: item.itemName,
                                      decoration: InputDecoration(
                                        hintText: 'Enter item name',
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        controller.updateItem(index, itemName: value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Price',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    height: 40,
                                    child: TextFormField(
                                      initialValue: item.purchasePrice.toStringAsFixed(2),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                                        ),
                                      ),
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (value) {
                                        double? price = double.tryParse(value);
                                        if (price != null && price >= 0) {
                                          controller.updateItem(index, purchasePrice: price);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Qty',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    height: 40,
                                    child: TextFormField(
                                      initialValue: item.quantity.toString(),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        int? qty = int.tryParse(value);
                                        if (qty != null && qty > 0) {
                                          controller.updateItem(index, quantity: qty);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (controller.purchaseItems.length > 1)
                              SizedBox(
                                width: 20,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20, left: 5),
                                  child: IconButton(
                                    onPressed: () => controller.removeItem(index),
                                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 40,
                          child: TextFormField(
                            initialValue: item.unit,
                            decoration: InputDecoration(
                              labelText: 'Unit (e.g., pcs, kg, ltr)',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                              ),
                            ),
                            onChanged: (value) {
                              controller.updateItem(index, unit: value);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.addNewItem,
                    icon: Icon(Icons.add_circle_outline, size: 20),
                    label: Text('Add Another Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tealColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: AppColors.tealColor),
                SizedBox(width: 8),
                Text(
                  'Purchase Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Obx(() => Column(
              children: [
                _buildTotalRow('Subtotal', controller.subtotal.value),
                if (AppConstants.withGST.value) ...[
                  _buildTotalRow('GST Amount', controller.gstAmount.value),
                ],
                Divider(),
                _buildTotalRow('Total Amount', controller.totalAmount.value, isTotal: true),
              ],
            )),
            SizedBox(height: 20),
            Divider(),
            Text(
              "Payment Status",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Obx(() => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: controller.paymentStatus.value,
                      isExpanded: true,
                      underline: SizedBox(),
                      items: [
                        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                        DropdownMenuItem(value: 'Partial', child: Text('Partial')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.updatePaymentStatus(value);
                        }
                      },
                    ),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green.shade700 : Colors.black87,
            ),
          ),
          Text(
            '₹${AppUtil.formatCurrency(amount)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: AppColors.tealColor),
                SizedBox(width: 8),
                Text(
                  'Additional Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: controller.notesController,
              decoration: InputDecoration(
                hintText: 'Add any notes about this purchase...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() => Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: controller.isLoading.value ? null : () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text('Cancel'),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.savePurchase(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealColor,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              controller.isEditMode.value ? 'Update Purchase' : 'Save Purchase',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    ));
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Purchase'),
        content: Text('Are you sure you want to delete this purchase entry?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // controller.deletePurchase();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}