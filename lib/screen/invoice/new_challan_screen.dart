import 'package:demo_prac_getx/constant/constant.dart';
import 'package:demo_prac_getx/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';
import '../../model/model.dart';
import '../../widgets/widgets.dart';



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class NewChallanScreen extends GetView<NewChallanController> {
  static const String pageId = '/NewChallanScreen';

  const NewChallanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 4,
        foregroundColor: Colors.white,
        backgroundColor: AppColors.tealColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: Obx(() => Text(
          controller.isEditMode.value ? 'edit_challan'.tr : 'new_challan'.tr,
          style: const TextStyle(
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
            // RESPONSIVE LAYOUT BUILDER
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return _buildWebLayout(context);
                } else {
                  return _buildMobileLayout(context);
                }
              },
            ),

            // LOADING OVERLAY
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
                        controller.isEditMode.value ? 'updating...'.tr : 'loading...'.tr,
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

  // ===========================================================================
  // 📱 MOBILE LAYOUT (Single Column)
  // ===========================================================================
  Widget _buildMobileLayout(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChallanDetailsCard(),
            SizedBox(height: 16),
            _buildCustomerSection(),
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
    );
  }

  // ===========================================================================
  // 💻 WEB LAYOUT (Split View - 2 Parts)
  // ===========================================================================
  Widget _buildWebLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1200),
        child: Form(
          key: controller.formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN (Main Details) - Flex 7
              Expanded(
                flex: 7,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildChallanDetailsCard(),
                      SizedBox(height: 24),
                      _buildCustomerSection(),
                      SizedBox(height: 24),
                      _buildItemsSection(),
                    ],
                  ),
                ),
              ),

              // RIGHT COLUMN (Summary & Actions) - Flex 3
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.grey.shade300)),
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildCalculationsSection(),
                        SizedBox(height: 24),
                        _buildNotesSection(),
                        SizedBox(height: 32),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 🧩 SHARED WIDGETS
  // ===========================================================================

  Widget _buildEditModeActions() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.delete, color: Colors.white),
          onPressed: () => _showDeleteConfirmation(),
          tooltip: 'Delete Challan',
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildChallanDetailsCard() {
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
                Text(
                  'challan_details'.tr,
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
                    'edit_mode'.tr,
                    style: TextStyle(
                      color: AppColors.tealColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : SizedBox()
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.challanNumberController,
                    decoration: InputDecoration(
                      labelText: 'Challan Number',
                      prefixIcon: Icon(Icons.receipt_long, color: AppColors.tealColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                    controller: controller.challanDateController,
                    decoration: InputDecoration(
                      labelText: 'Challan Date',
                      prefixIcon: Icon(Icons.calendar_today, color: AppColors.tealColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                      ),
                    ),
                    readOnly: true,
                    onTap: controller.selectChallanDate,
                  ),
                ),
              ],
            ),
            Obx(() {
              if (controller.isEditMode.value && controller.originalChallanData != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12),
                    Divider(),
                    Text(
                      'Original Challan Information:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Date: ${controller.formatOriginalChallanDate()}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }
              return SizedBox();
            }),

            Obx(() {
              if (AppConstants.isDemo.value) {
                return Column(
                  children: [
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '🔒 Demo Mode: Challan dates limited to 1990-1992',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
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
                Text(
                  'customer_information'.tr,
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
                Obx(() => !controller.isEditMode.value ? IconButton(
                  onPressed: controller.toggleCustomerForm,
                  icon: Icon(
                    controller.showCustomerForm.value ? Icons.person : Icons.person_add,
                    color: AppColors.tealColor,
                  ),
                  tooltip: controller.showCustomerForm.value
                      ? 'Select from existing customers'
                      : 'Add new customer manually',
                ) : SizedBox()),
              ],
            ),
            SizedBox(height: 16),
            Obx(() {
              if (controller.isEditMode.value) {
                return _buildEditModeCustomerInfo();
              } else {
                if (controller.customers.isEmpty && !controller.showCustomerForm.value) {
                  return Column(
                    children: [
                      Text(
                        'No customers found. Please add a customer.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: controller.toggleCustomerForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tealColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Add New Customer'),
                      ),
                    ],
                  );
                } else if (!controller.showCustomerForm.value) {
                  // ✅ Use SearchableDropdown for customers
                  return SearchableDropdown<Map<String, dynamic>>(
                    value: controller.selectedCustomer.value,
                    items: controller.customers,
                    itemLabel: (customer) => (customer['name'] ?? 'Unknown Customer').toString().toUpperCase(),
                    hintText: 'Select Customer',
                    searchHintText: 'Search customers by name...',
                    itemBuilder: (customer) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (customer['name'] ?? 'Unknown').toString().toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (customer['mobile1'] != null && customer['mobile1'].toString().isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.phone, size: 12, color: Colors.grey.shade600),
                                SizedBox(width: 4),
                                Text(
                                  customer['mobile1'].toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    onChanged: (selectedCustomer) {
                      controller.selectCustomer(selectedCustomer);
                    },
                  );
                } else {
                  return _buildCustomerFormFields();
                }
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerFormFields() {
    return Column(
      children: [
        SizedBox(height: 12),
        Text(
          'add_new_customer'.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.tealColor,
          ),
        ),
        SizedBox(height: 12),
        TextFormField(
          controller: controller.customerNameController,
          decoration: InputDecoration(
            labelText: 'customer_name'.tr,
            prefixIcon: Icon(Icons.person, color: AppColors.tealColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.tealColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter customer name';
            }
            return null;
          },
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.customerMobileController,
                decoration: InputDecoration(
                  labelText: 'mobile_number'.tr,
                  prefixIcon: Icon(Icons.phone, color: AppColors.tealColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                controller: controller.customerEmailController,
                decoration: InputDecoration(
                  labelText: 'email'.tr,
                  prefixIcon: Icon(Icons.email, color: AppColors.tealColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
          controller: controller.customerAddressController,
          decoration: InputDecoration(
            labelText: 'address'.tr,
            prefixIcon: Icon(Icons.location_on, color: AppColors.tealColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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

  Widget _buildEditModeCustomerInfo() {
    return _buildCustomerFormFields();
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
                Text(
                  'challan_items'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealColor,
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 16),
            Obx(() {
              if (controller.isEditMode.value && controller.originalItemsCount > 0) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.tealColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.tealColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 16, color: AppColors.tealColor),
                      SizedBox(width: 8),
                      Text(
                        'Originally had ${controller.originalItemsCount} items',
                        style: TextStyle(
                          color: AppColors.tealColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox();
            }),
            SizedBox(height: 12),
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
                      'item_description'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.tealColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'price_inr'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.tealColor,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'quantity'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.tealColor,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Obx(() => Column(
              children: [
                if (controller.itemList.isEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange.shade700),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No items available. Please add items in your inventory first.',
                            style: TextStyle(color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),

                ...controller.challanItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  ChallanItem item = entry.value;

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
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade600,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '#${index + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                         'Item',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),

                                  if (controller.itemList.isNotEmpty)
                                    Builder(
                                      builder: (context) {
                                        Item? currentItem;
                                        try {
                                          currentItem = controller.itemList.firstWhere(
                                                  (i) => i.itemId == item.itemId
                                          );
                                        } catch (e) {
                                          currentItem = null;
                                        }

                                        final isInactive = currentItem != null && !(currentItem.isActive ?? true);

                                        if (controller.isEditMode.value && (isInactive || currentItem == null) && item.description.isNotEmpty) {
                                          return Container(
                                            height: 40,
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item.description,
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          );
                                        }

                                        final activeItems = controller.itemList.where((i) => i.isActive == true).toList();
                                        Item? selectedItem;
                                        try {
                                          selectedItem = activeItems.firstWhere((element) => element.itemId == item.itemId);
                                        } catch (e) {
                                          selectedItem = null;
                                        }

                                        // ✅ NEW: Use SearchableDropdown for items
                                        return SearchableDropdown<Item>(
                                          value: selectedItem,
                                          items: activeItems,
                                          itemLabel: (item) => item.itemName.toUpperCase(),
                                          hintText: 'Select Item',
                                          searchHintText: 'Search items by name...',
                                          itemBuilder: (item) {
                                            double currentStock = (item.currentStock ?? 0.0).toDouble();
                                            bool isOutOfStock = currentStock <= 0;

                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      item.itemName.toUpperCase(),
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 14,
                                                        color: isOutOfStock ? Colors.grey : Colors.black87,
                                                      ),
                                                    ),
                                                    if (isOutOfStock)
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red.shade50,
                                                          borderRadius: BorderRadius.circular(4),
                                                          border: Border.all(color: Colors.red.shade200),
                                                        ),
                                                        child: Text(
                                                          "NO STOCK",
                                                          style: TextStyle(fontSize: 9, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                if (item.price > 0)
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 4),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.currency_rupee, size: 12, color: isOutOfStock ? Colors.grey : Colors.green.shade600),
                                                        Text(
                                                          '${item.price.toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            color: isOutOfStock ? Colors.grey : Colors.green.shade600,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          'Stock: ${currentStock.toStringAsFixed(0)}',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: isOutOfStock ? Colors.red : Colors.grey.shade600,
                                                            fontWeight: isOutOfStock ? FontWeight.bold : FontWeight.normal,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                          onChanged: (selectedItem) {
                                            if (selectedItem != null) {
                                              controller.selectRemoteItemForIndex(index, selectedItem);
                                            }
                                          },
                                        );
                                      },
                                    ),

                                  if (controller.itemList.isEmpty)
                                    TextFormField(
                                      initialValue: item.description,
                                      decoration: InputDecoration(
                                        labelText: 'Item Description',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),

                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      ),
                                      onChanged: (value) {
                                        controller.updateItem(index, description: value);
                                      },
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),

                            if (controller.challanItems.length > 1)
                              Container(
                                  margin: EdgeInsets.only(top: 30),
                                child: IconButton(
                                  onPressed: () => controller.removeItem(index),
                                  icon: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.red.shade200),
                                      ),

                                      child: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 20)),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  tooltip: 'Remove Item',
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 12),

                       Row(
                         children: [
                           Expanded(
                             flex: 2,
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text('price'.tr, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                 SizedBox(height: 4),
                                 Container(
                                   height: 40,
                                   child: TextFormField(
                                     controller: controller.getPriceController(index, initialValue: item.price),
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
                                         controller.updateItem(index, price: price, unit: item.unit, quantity: item.quantity);
                                       }
                                     },
                                   ),
                                 ),
                               ],
                             ),
                           ),
                           Spacer(),
                           SizedBox(width: 12),
                           Expanded(
                             flex: 1,
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                     item.unit != null && item.unit!.isNotEmpty
                                         ? 'Qty (${item.unit})'
                                         : 'Qty',
                                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                 SizedBox(height: 4),
                                 // Obx((){
                                 //   if(controller.isEditMode.value){
                                 //     return  Container(
                                 //       height: 40,
                                 //       child: TextFormField(
                                 //         key: ValueKey('qty_$index'),
                                 //         initialValue: item.quantity.toString(),
                                 //         textAlign: TextAlign.center,
                                 //         decoration: InputDecoration(
                                 //           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                 //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                 //           focusedBorder: OutlineInputBorder(
                                 //             borderRadius: BorderRadius.circular(8),
                                 //             borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                                 //           ),
                                 //         ),
                                 //         keyboardType: TextInputType.numberWithOptions(decimal: true),
                                 //         onChanged: (value) {
                                 //           double? qty = double.tryParse(value);
                                 //           if (qty == null || qty <= 0) return;
                                 //
                                 //           if (item.unit?.toLowerCase() == "pcs") {
                                 //             if (qty % 1 != 0) {
                                 //               Get.snackbar("Invalid Qty", "You can only enter whole numbers for PCS items.", snackPosition: SnackPosition.BOTTOM);
                                 //               return;
                                 //             }
                                 //           }
                                 //           controller.updateItem(index, quantity: qty, price: item.price, unit: item.unit);
                                 //         },
                                 //       ),
                                 //     );
                                 //   }
                                 //   else{
                                 //     return Container(
                                 //       height: 40,
                                 //       child: TextFormField(
                                 //         key: ValueKey('qty_$index'),
                                 //         textAlign: TextAlign.center,
                                 //         decoration: InputDecoration(
                                 //           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                 //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                 //           focusedBorder: OutlineInputBorder(
                                 //             borderRadius: BorderRadius.circular(8),
                                 //             borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                                 //           ),
                                 //         ),
                                 //         keyboardType: TextInputType.numberWithOptions(decimal: true),
                                 //         onChanged: (value) {
                                 //           double? qty = double.tryParse(value);
                                 //           if (qty == null || qty <= 0) return;
                                 //
                                 //           if (item.unit?.toLowerCase() == "pcs") {
                                 //             if (qty % 1 != 0) {
                                 //               Get.snackbar("Invalid Qty", "You can only enter whole numbers for PCS items.", snackPosition: SnackPosition.BOTTOM);
                                 //               return;
                                 //             }
                                 //           }
                                 //           controller.updateItem(index, quantity: qty, price: item.price, unit: item.unit);
                                 //         },
                                 //       ),
                                 //     );
                                 //   }
                                 // }),
                                 // Replace the quantity field section in _buildItemsSection()

                                 // Replace the quantity field section in _buildItemsSection()

                                 Obx(() {
                                   // Get available stock for this item
                                   double? availableStock;

                                   if (item.itemId != null && item.itemId!.isNotEmpty) {
                                     final masterItem = controller.itemList.firstWhereOrNull(
                                             (e) => e.itemId == item.itemId
                                     );
                                     if (masterItem != null) {
                                       availableStock = (masterItem.currentStock ?? 0.0).toDouble();
                                     }
                                   }

                                   // EDIT MODE
                                   if (controller.isEditMode.value) {
                                     return Container(
                                       height: 40,
                                       child: TextFormField(
                                         key: ValueKey('qty_edit_$index'),
                                         controller: controller.getQuantityController(index, initialValue: item.quantity), // ✅ USE CONTROLLER
                                         textAlign: TextAlign.center,
                                         style: TextStyle(
                                           fontSize: 14,
                                           fontWeight: FontWeight.w500,
                                         ),
                                         decoration: InputDecoration(
                                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                           focusedBorder: OutlineInputBorder(
                                             borderRadius: BorderRadius.circular(8),
                                             borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                                           ),
                                           hintText: availableStock != null
                                               ? 'Stock: ${availableStock.toStringAsFixed(availableStock % 1 == 0 ? 0 : 2)}'
                                               : null,
                                           hintStyle: TextStyle(fontSize: 10, color: Colors.orange),
                                         ),
                                         keyboardType: TextInputType.numberWithOptions(decimal: true),
                                         inputFormatters: [
                                           FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                         ],
                                         onChanged: (value) {
                                           print("📝 Quantity changed (EDIT): $value for item $index");

                                           if (value.isEmpty) {
                                             controller.itemsWithStockViolation.remove(index);
                                             controller.violationMessages.remove(index);
                                             // Don't update item with empty value
                                             return;
                                           }

                                           double? qty = double.tryParse(value);

                                           if (qty == null || qty <= 0) {
                                             Get.snackbar(
                                               "Invalid Quantity",
                                               "Please enter a valid quantity greater than 0",
                                               snackPosition: SnackPosition.BOTTOM,
                                               backgroundColor: Colors.orange.shade700,
                                               colorText: Colors.white,
                                               duration: Duration(seconds: 2),
                                             );
                                             controller.itemsWithStockViolation.add(index);
                                             controller.violationMessages[index] = "Invalid quantity";

                                             // ✅ Revert to previous valid quantity
                                             Future.delayed(Duration(milliseconds: 100), () {
                                               final qtyController = controller.getQuantityController(index);
                                               qtyController.text = item.quantity.toString();
                                               qtyController.selection = TextSelection.fromPosition(
                                                 TextPosition(offset: qtyController.text.length),
                                               );
                                             });
                                             return;
                                           }

                                           // Check for whole numbers
                                           if (item.unit?.toLowerCase() == "pcs") {
                                             if (qty % 1 != 0) {
                                               Get.snackbar(
                                                 "Invalid Qty",
                                                 "You can only enter whole numbers for PCS items.",
                                                 snackPosition: SnackPosition.BOTTOM,
                                               );
                                               controller.itemsWithStockViolation.add(index);
                                               controller.violationMessages[index] = "Must be whole number";

                                               // ✅ Revert to previous valid quantity
                                               Future.delayed(Duration(milliseconds: 100), () {
                                                 final qtyController = controller.getQuantityController(index);
                                                 qtyController.text = item.quantity.toString();
                                                 qtyController.selection = TextSelection.fromPosition(
                                                   TextPosition(offset: qtyController.text.length),
                                                 );
                                               });
                                               return;
                                             }
                                           }

                                           // ✅ STOCK CHECK (EDIT MODE)
                                           print("🔍 Stock Check (EDIT) - Item $index - Available: $availableStock, Entered: $qty");

                                           if (availableStock != null && availableStock > 0) {
                                             if (qty > availableStock) {
                                               print("❌ STOCK EXCEEDED! Item $index");

                                               controller.itemsWithStockViolation.add(index);
                                               controller.violationMessages[index] =
                                               "${item.itemName}: Only ${availableStock.toStringAsFixed(availableStock % 1 == 0 ? 0 : 2)} ${item.unit ?? ''} available";

                                               Get.snackbar(
                                                 "❌ Stock Limit Exceeded",
                                                 "Only ${availableStock.toStringAsFixed(availableStock % 1 == 0 ? 0 : 2)} ${item.unit ?? ''} available.\nYou entered: $qty ${item.unit ?? ''}",
                                                 snackPosition: SnackPosition.TOP,
                                                 backgroundColor: Colors.red.shade700,
                                                 colorText: Colors.white,
                                                 duration: Duration(seconds: 3),
                                                 icon: Icon(Icons.warning_amber_rounded, color: Colors.white),
                                               );

                                               // ✅ Revert to maximum available stock
                                               Future.delayed(Duration(milliseconds: 100), () {
                                                 final qtyController = controller.getQuantityController(index);
                                                 String maxQty = availableStock! % 1 == 0
                                                     ? availableStock.toInt().toString()
                                                     : availableStock.toString();
                                                 qtyController.text = maxQty;
                                                 qtyController.selection = TextSelection.fromPosition(
                                                   TextPosition(offset: qtyController.text.length),
                                                 );
                                               });

                                               return; // ✅ STOP - DO NOT UPDATE
                                             } else {
                                               print("✅ Stock check passed (EDIT)");
                                               controller.itemsWithStockViolation.remove(index);
                                               controller.violationMessages.remove(index);
                                             }
                                           } else {
                                             controller.itemsWithStockViolation.remove(index);
                                             controller.violationMessages.remove(index);
                                           }

                                           // Update if validation passes
                                           controller.updateItem(index, quantity: qty, price: item.price, unit: item.unit);
                                         },
                                       ),
                                     );
                                   }

                                   // CREATE MODE
                                   else {
                                     return Container(
                                       height: 40,
                                       child: TextFormField(
                                         //key: ValueKey('qty_create_$index'),
                                         key: ValueKey('qty_create_${item.itemId}_$index}_${controller.challanItems.length}'),
                                         controller: controller.getQuantityController(index, initialValue: item.quantity), // ✅ USE CONTROLLER
                                         textAlign: TextAlign.center,
                                         style: TextStyle(
                                           fontSize: 14,
                                           fontWeight: FontWeight.w500,
                                         ),
                                         decoration: InputDecoration(
                                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                           focusedBorder: OutlineInputBorder(
                                             borderRadius: BorderRadius.circular(8),
                                             borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                                           ),
                                           hintText: availableStock != null
                                               ? 'Stocks: ${availableStock.toStringAsFixed(availableStock % 1 == 0 ? 0 : 2)}'
                                               : null,
                                           hintStyle: TextStyle(fontSize: 10, color: Colors.orange),
                                         ),
                                         keyboardType: TextInputType.numberWithOptions(decimal: true),
                                         inputFormatters: [
                                           FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                         ],
                                         onChanged: (value) {
                                           if (value.isEmpty) {
                                             controller.itemsWithStockViolation.remove(index);
                                             controller.violationMessages.remove(index);
                                             return;
                                           }

                                           double? qty = double.tryParse(value);

                                           if (qty == null || qty <= 0) {
                                             Get.snackbar(
                                               "Invalid Quantity",
                                               "Please enter a valid quantity greater than 0",
                                               snackPosition: SnackPosition.BOTTOM,
                                               backgroundColor: Colors.orange.shade700,
                                               colorText: Colors.white,
                                               duration: Duration(seconds: 2),
                                             );
                                             controller.itemsWithStockViolation.add(index);
                                             controller.violationMessages[index] = "Invalid quantity";
                                             return;
                                           }

                                           if (item.unit?.toLowerCase() == "pcs") {
                                             if (qty % 1 != 0) {
                                               Get.snackbar(
                                                 "Invalid Qty",
                                                 "You can only enter whole numbers for PCS items.",
                                                 snackPosition: SnackPosition.BOTTOM,
                                               );
                                               controller.itemsWithStockViolation.add(index);
                                               controller.violationMessages[index] = "Must be whole number";
                                               return;
                                             }
                                           }

                                           // Stock check
                                           if (availableStock != null && availableStock > 0) {
                                             if (qty > availableStock) {
                                               controller.itemsWithStockViolation.add(index);
                                               controller.violationMessages[index] =
                                               "${item.itemName}: Only ${availableStock.toStringAsFixed(availableStock % 1 == 0 ? 0 : 2)} ${item.unit ?? ''} available";

                                               Get.snackbar(
                                                 "❌ Stock Limit Exceeded",
                                                 "Only ${availableStock.toStringAsFixed(availableStock % 1 == 0 ? 0 : 2)} ${item.unit ?? ''} available.\nYou entered: $qty ${item.unit ?? ''}",
                                                 snackPosition: SnackPosition.TOP,
                                                 backgroundColor: Colors.red.shade700,
                                                 colorText: Colors.white,
                                                 duration: Duration(seconds: 4),
                                                 icon: Icon(Icons.warning_amber_rounded, color: Colors.white),
                                               );
                                               return;
                                             } else {
                                               controller.itemsWithStockViolation.remove(index);
                                               controller.violationMessages.remove(index);
                                             }
                                           } else {
                                             controller.itemsWithStockViolation.remove(index);
                                             controller.violationMessages.remove(index);
                                           }

                                           // Update if validation passes
                                           controller.updateItem(index, quantity: qty, price: item.price, unit: item.unit);
                                         },
                                       ),
                                     );
                                   }
                                 })
                               ],
                             ),
                           ),
                         ],
                       )
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
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.tealColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.tealColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Items:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.tealColor,
                        ),
                      ),
                      Text(
                        '${controller.challanItems.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.tealColor,
                        ),
                      ),
                    ],
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
            Text(
              'calculations'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.tealColor,
              ),
            ),
            SizedBox(height: 16),
            Obx(() => Column(
              children: [
                _buildTotalRow('Subtotal', controller.subtotal.value),
                if (AppConstants.withGST.value) ...[
                  _buildTotalRow('CGST', controller.gstAmount.value / 2),
                  _buildTotalRow('SGST', controller.gstAmount.value / 2),
                ],
                Divider(),
                _buildTotalRow('Total Amount', controller.totalAmount.value, isTotal: true),
              ],
            )),
            SizedBox(height: 20),
            // Divider(),
            // Text(
            //   "payment_status".tr,
            //   style: TextStyle(
            //     fontWeight: FontWeight.w500,
            //     color: Colors.grey.shade700,
            //   ),
            // ),
            // SizedBox(height: 8),
            // Row(
            //   children: [
            //     Expanded(
            //       child: Obx(() => Container(
            //         padding: EdgeInsets.symmetric(horizontal: 12),
            //         decoration: BoxDecoration(
            //           border: Border.all(color: Colors.grey.shade300),
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //         child: DropdownButton<String>(
            //           value: controller.paymentStatus.value,
            //           isExpanded: true,
            //           underline: SizedBox(),
            //           items: [
            //             DropdownMenuItem(value: 'Pending', child: Text('Pending')),
            //             DropdownMenuItem(value: 'Paid', child: Text('Paid')),
            //             DropdownMenuItem(value: 'Partial', child: Text('Partial')),
            //           ],
            //           onChanged: (value) {
            //             if (value != null) {
            //               controller.updatePaymentStatus(value);
            //             }
            //           },
            //         ),
            //       )),
            //     ),
            //   ],
            // ),
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
              color: isTotal ?
              (controller.isEditMode.value ? Colors.orange.shade700 : AppColors.tealColor)
                  : Colors.black87,
            ),
          ),
          Text(
            '₹${AppUtil.formatCurrency(amount)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ?
              (controller.isEditMode.value ? Colors.orange.shade700 : AppColors.tealColor)
                  : Colors.black87,
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
            Text(
              'additional_notes'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.tealColor,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: controller.notesController,
              decoration: InputDecoration(
                hintText: 'add_notes_hint'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // ✅ Warning banner for stock violations
        Obx(() {
          if (controller.hasAnyStockViolation) {
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade900, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '⚠️ Cannot Create Challan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // List all items with violations
                  ...controller.violationMessages.entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(left: 36, top: 4),
                      child: Row(
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }
          return SizedBox.shrink();
        }),

        // Buttons row
        Obx(() => Row(
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
                // ✅ Disable if loading OR stock violation
                onPressed: (controller.isLoading.value || controller.hasAnyStockViolation)
                    ? null
                    : () => controller.saveChallan(isDraft: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealColor,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: Text(
                  controller.isEditMode.value ? 'Update Challan' : 'Create Challan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (controller.isLoading.value || controller.hasAnyStockViolation)
                        ? Colors.grey.shade600
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        )),
      ],
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text('delete_challan'.tr),
        content: Text('delete_challan_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              //controller.deleteChallan();
            },
            child: Text(
              'delete'.tr,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}


/// 2mobile working
// class NewChallanScreen extends GetView<NewChallanController> {
//   static const String pageId = '/NewChallanScreen';
//
//   const NewChallanScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         elevation: 4,
//         leading: IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor,)),
//         backgroundColor: AppColors.tealColor,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//         ),
//         title: Obx(() => Text(
//           controller.isEditMode.value ? 'edit_challan'.tr : 'new_challan'.tr,
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//             fontSize: 20,
//           ),
//         )),
//         centerTitle: true,
//         actions: [
//           Obx(() => controller.isEditMode.value
//               ? _buildEditModeActions()
//               : const SizedBox.shrink()
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Form(
//               key: controller.formKey,
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildChallanDetailsCard(),
//                     SizedBox(height: 16),
//                     _buildCustomerSection(),
//                     SizedBox(height: 16),
//                     _buildItemsSection(),
//                     SizedBox(height: 16),
//                     _buildCalculationsSection(),
//                     SizedBox(height: 16),
//                     _buildNotesSection(),
//                     SizedBox(height: 32),
//                     _buildActionButtons(),
//                   ],
//                 ),
//               ),
//             ),
//             Obx(() => controller.isLoading.value
//                 ? Container(
//               color: Colors.black.withOpacity(0.3),
//               child: Center(
//                 child: Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black26,
//                         blurRadius: 10,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(AppColors.tealColor),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         controller.isEditMode.value ? 'updating...'.tr : 'loading...'.tr,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             )
//                 : SizedBox.shrink()),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEditModeActions() {
//     return Row(
//       children: [
//         IconButton(
//           icon: Icon(Icons.delete, color: Colors.white),
//           onPressed: () => _showDeleteConfirmation(),
//           tooltip: 'Delete Challan',
//         ),
//         SizedBox(width: 8),
//       ],
//     );
//   }
//
//   Widget _buildChallanDetailsCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'challan_details'.tr,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.tealColor,
//                   ),
//                 ),
//                 Spacer(),
//                 Obx(() => controller.isEditMode.value
//                     ? Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppColors.tealColor.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: AppColors.tealColor.withOpacity(0.3)),
//                   ),
//                   child: Text(
//                     'edit_mode'.tr,
//                     style: TextStyle(
//                       color: AppColors.tealColor,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 )
//                     : SizedBox()
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: controller.challanNumberController,
//                     decoration: InputDecoration(
//                       labelText: 'Challan Number',
//                       prefixIcon: Icon(Icons.receipt_long, color: AppColors.tealColor),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: AppColors.tealColor, width: 2),
//                       ),
//                     ),
//                     readOnly: true,
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: TextFormField(
//                     controller: controller.challanDateController,
//                     decoration: InputDecoration(
//                       labelText: 'Challan Date',
//                       prefixIcon: Icon(Icons.calendar_today, color: AppColors.tealColor),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: AppColors.tealColor, width: 2),
//                       ),
//                     ),
//                     readOnly: true,
//                     onTap: controller.selectChallanDate,
//                   ),
//                 ),
//               ],
//             ),
//             Obx(() {
//               if (controller.isEditMode.value && controller.originalChallanData != null) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 12),
//                     Divider(),
//                     Text(
//                       'Original Challan Information:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey.shade600,
//                         fontSize: 14,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Date: ${controller.formatOriginalChallanDate()}',
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 );
//               }
//               return SizedBox();
//             }),
//
//             Obx(() {
//               if (AppConstants.isDemo.value) {
//                 return Column(
//                   children: [
//                     SizedBox(height: 12),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.orange.shade300),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               '🔒 Demo Mode: Challan dates limited to 1990-1992',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.orange.shade800,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               }
//               return SizedBox.shrink();
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCustomerSection() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'customer_information'.tr,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.tealColor,
//                   ),
//                 ),
//                 Text(
//                   ' *', // Required indicator
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.red,
//                   ),
//                 ),
//                 Spacer(),
//                 Obx(() => !controller.isEditMode.value ? IconButton(
//                   onPressed: controller.toggleCustomerForm,
//                   icon: Icon(
//                     controller.showCustomerForm.value ? Icons.person : Icons.person_add,
//                     color: AppColors.tealColor,
//                   ),
//                   tooltip: controller.showCustomerForm.value
//                       ? 'Select from existing customers'
//                       : 'Add new customer manually',
//                 ) : SizedBox()),
//               ],
//             ),
//             SizedBox(height: 16),
//             Obx(() {
//               if (controller.isEditMode.value) {
//                 return _buildEditModeCustomerInfo();
//               } else {
//                 if (controller.customers.isEmpty && !controller.showCustomerForm.value) {
//                   return Column(
//                     children: [
//                       Text(
//                         'No customers found. Please add a customer.',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                       SizedBox(height: 12),
//                       ElevatedButton(
//                         onPressed: controller.toggleCustomerForm,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.tealColor,
//                           foregroundColor: Colors.white,
//                         ),
//                         child: Text('Add New Customer'),
//                       ),
//                     ],
//                   );
//                 } else if (!controller.showCustomerForm.value) {
//                   // ✅ NEW: Use SearchableDropdown for customers
//                   return SearchableDropdown<Map<String, dynamic>>(
//                     value: controller.selectedCustomer.value,
//                     items: controller.customers,
//                     itemLabel: (customer) => (customer['name'] ?? 'Unknown Customer').toString().toUpperCase(),
//                     hintText: 'Select Customer',
//                     searchHintText: 'Search customers by name...',
//                     itemBuilder: (customer) => Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           (customer['name'] ?? 'Unknown').toString().toUpperCase(),
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                           ),
//                         ),
//                         if (customer['mobile1'] != null && customer['mobile1'].toString().isNotEmpty)
//                           Padding(
//                             padding: EdgeInsets.only(top: 4),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.phone, size: 12, color: Colors.grey.shade600),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   customer['mobile1'].toString(),
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey.shade600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                     onChanged: (selectedCustomer) {
//                       controller.selectCustomer(selectedCustomer);
//                     },
//                   );
//                 } else {
//                   return _buildCustomerFormFields();
//                 }
//               }
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCustomerFormFields() {
//     return Column(
//       children: [
//         SizedBox(height: 12),
//         Text(
//           'add_new_customer'.tr,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: AppColors.tealColor,
//           ),
//         ),
//         SizedBox(height: 12),
//         TextFormField(
//           controller: controller.customerNameController,
//           decoration: InputDecoration(
//             labelText: 'customer_name'.tr,
//             prefixIcon: Icon(Icons.person, color: AppColors.tealColor),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.tealColor, width: 2),
//             ),
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter customer name';
//             }
//             return null;
//           },
//         ),
//         SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 controller: controller.customerMobileController,
//                 decoration: InputDecoration(
//                   labelText: 'mobile_number'.tr,
//                   prefixIcon: Icon(Icons.phone, color: AppColors.tealColor),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: AppColors.tealColor, width: 2),
//                   ),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: TextFormField(
//                 controller: controller.customerEmailController,
//                 decoration: InputDecoration(
//                   labelText: 'email'.tr,
//                   prefixIcon: Icon(Icons.email, color: AppColors.tealColor),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: AppColors.tealColor, width: 2),
//                   ),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12),
//         TextFormField(
//           controller: controller.customerAddressController,
//           decoration: InputDecoration(
//             labelText: 'address'.tr,
//             prefixIcon: Icon(Icons.location_on, color: AppColors.tealColor),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: AppColors.tealColor, width: 2),
//             ),
//           ),
//           maxLines: 2,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildEditModeCustomerInfo() {
//     return _buildCustomerFormFields();
//   }
//
//   Widget _buildItemsSection() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'challan_items'.tr,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.tealColor,
//                   ),
//                 ),
//                 Spacer(),
//                 // Obx(() => Text(
//                 //   'Total: ₹${AppUtil.formatCurrency(controller.totalAmount.value)}',
//                 //   style: TextStyle(
//                 //     fontWeight: FontWeight.bold,
//                 //     color: AppColors.tealColor,
//                 //   ),
//                 // )),
//               ],
//             ),
//             SizedBox(height: 16),
//             Obx(() {
//               if (controller.isEditMode.value && controller.originalItemsCount > 0) {
//                 return Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: AppColors.tealColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: AppColors.tealColor.withOpacity(0.3)),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.history, size: 16, color: AppColors.tealColor),
//                       SizedBox(width: 8),
//                       Text(
//                         'Originally had ${controller.originalItemsCount} items',
//                         style: TextStyle(
//                           color: AppColors.tealColor,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//               return SizedBox();
//             }),
//             SizedBox(height: 12),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: AppColors.tealColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 3,
//                     child: Text(
//                       'item_description'.tr,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.tealColor,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Text(
//                       'price_inr'.tr,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.tealColor,
//                       ),
//                       textAlign: TextAlign.start,
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Text(
//                       'quantity'.tr,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.tealColor,
//                       ),
//                       textAlign: TextAlign.start,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 12),
//             Obx(() => Column(
//               children: [
//                 if (controller.itemList.isEmpty)
//                   Container(
//                     padding: EdgeInsets.all(16),
//                     margin: EdgeInsets.only(bottom: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.orange.shade200),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.info, color: Colors.orange.shade700),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             'No items available. Please add items in your inventory first.',
//                             style: TextStyle(color: Colors.orange.shade800),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ...controller.challanItems.asMap().entries.map((entry) {
//                   int index = entry.key;
//                   ChallanItem item = entry.value;
//
//                   return Container(
//                     margin: EdgeInsets.only(bottom: 12),
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(color: Colors.grey.shade200),
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppColors.tealColor.withOpacity(0.1),
//                           blurRadius: 4,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               flex: 3,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Item ${index + 1}',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey.shade700,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                   SizedBox(height: 8),
//
//                                   // In _buildItemsSection(), replace the existing dropdown section with this:
//
//                                   if (controller.itemList.isNotEmpty)
//                                     Builder(
//                                       builder: (context) {
//                                         // Try to find the item in the full list (including inactive)
//                                         Item? currentItem;
//                                         try {
//                                           currentItem = controller.itemList.firstWhere(
//                                                   (i) => i.itemId == item.itemId
//                                           );
//                                         } catch (e) {
//                                           currentItem = null;
//                                         }
//
//                                         // Check if item exists but is inactive
//                                         final isInactive = currentItem != null && !(currentItem.isActive ?? true);
//
//                                         // ✅ If in EDIT MODE and item is inactive/deleted, show as read-only
//                                         if (controller.isEditMode.value && (isInactive || currentItem == null) && item.description.isNotEmpty) {
//                                           return Container(
//                                             height: 40,
//                                             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                                             decoration: BoxDecoration(
//                                               border: Border.all(color: Colors.grey.shade300),
//                                               borderRadius: BorderRadius.circular(8),
//                                             ),
//                                             child: Text(
//                                               item.description,
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                               ),
//                                             ),
//                                           );
//                                         }
//
//                                         // ✅ Get only ACTIVE items for dropdown
//                                         final activeItems = controller.itemList
//                                             .where((i) => i.isActive == true)
//                                             .toList();
//
//                                         Item? selectedItem;
//                                         try {
//                                           selectedItem = activeItems.firstWhere(
//                                                   (element) => element.itemId == item.itemId
//                                           );
//                                         } catch (e) {
//                                           selectedItem = null;
//                                         }
//
//                                         // ✅ NEW: Use SearchableDropdown for items
//                                         return SearchableDropdown<Item>(
//                                           value: selectedItem,
//                                           items: activeItems,
//                                           itemLabel: (item) => item.itemName.toUpperCase(),
//                                           hintText: 'Select Item',
//                                           searchHintText: 'Search items by name...',
//                                           itemBuilder: (item) => Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 item.itemName.toUpperCase(),
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.w600,
//                                                   fontSize: 14,
//                                                 ),
//                                               ),
//                                               if (item.price > 0)
//                                                 Padding(
//                                                   padding: EdgeInsets.only(top: 4),
//                                                   child: Row(
//                                                     children: [
//                                                       Icon(Icons.currency_rupee, size: 12, color: Colors.green.shade600),
//                                                       Text(
//                                                         '${item.price.toStringAsFixed(2)}',
//                                                         style: TextStyle(
//                                                           color: Colors.green.shade600,
//                                                           fontSize: 12,
//                                                           fontWeight: FontWeight.w500,
//                                                         ),
//                                                       ),
//                                                       if (item.unitOfMeasurement.isNotEmpty) ...[
//                                                         SizedBox(width: 8),
//                                                         Container(
//                                                           padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                                           decoration: BoxDecoration(
//                                                             color: Colors.blue.shade50,
//                                                             borderRadius: BorderRadius.circular(4),
//                                                             border: Border.all(color: Colors.blue.shade200),
//                                                           ),
//                                                           child: Text(
//                                                             item.unitOfMeasurement,
//                                                             style: TextStyle(
//                                                               fontSize: 10,
//                                                               color: Colors.blue.shade700,
//                                                               fontWeight: FontWeight.w600,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ],
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                           onChanged: (selectedItem) {
//                                             if (selectedItem != null) {
//                                               controller.selectRemoteItemForIndex(index, selectedItem);
//                                             }
//                                           },
//                                         );
//                                       },
//                                     ),
//
//                                   if (controller.itemList.isEmpty)
//                                     TextFormField(
//                                       initialValue: item.description,
//                                       decoration: InputDecoration(
//                                         labelText: 'Item Description',
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         focusedBorder: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(8),
//                                           borderSide: BorderSide(color: AppColors.tealColor, width: 2),
//                                         ),
//                                         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                                       ),
//                                       onChanged: (value) {
//                                         controller.updateItem(index, description: value);
//                                       },
//                                     ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(width: 12),
//                             Expanded(
//                               flex: 2,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Price',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey.shade600,
//                                     ),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Container(
//                                     height: 40,
//                                     child: TextFormField(
//                                       controller: controller.getPriceController(index, initialValue: item.price),
//                                       textAlign: TextAlign.center,
//                                       decoration: InputDecoration(
//                                         contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         focusedBorder: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(8),
//                                           borderSide: BorderSide(color: AppColors.tealColor, width: 2),
//                                         ),
//                                       ),
//                                       keyboardType: TextInputType.numberWithOptions(decimal: true),
//                                       onChanged: (value) {
//                                         double? price = double.tryParse(value);
//                                         if (price != null && price >= 0) {
//                                           controller.updateItem(
//                                             index,
//                                             price: price,
//                                             unit: item.unit,
//                                             quantity: item.quantity,
//                                           );
//                                         }
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(width: 12),
//                             Expanded(
//                               flex: 1,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Qty',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey.shade600,
//                                     ),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Obx((){
//                                     if(controller.isEditMode.value){
//                                       return  Container(
//                                         height: 40,
//                                         child: TextFormField(
//                                           key: ValueKey('qty_$index'), // remove item.quantity from key
//                                           initialValue: item.quantity.toString(),
//                                           textAlign: TextAlign.center,
//                                           decoration: InputDecoration(
//                                             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                                             border: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(8),
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(8),
//                                               borderSide: BorderSide(color: AppColors.tealColor, width: 2),
//                                             ),
//                                           ),
//                                           keyboardType: TextInputType.numberWithOptions(decimal: true),
//                                           onChanged: (value) {
//                                             double? qty = double.tryParse(value);
//                                             if (qty == null || qty <= 0) return;
//
//                                             if (item.unit?.toLowerCase() == "pcs") {
//                                               if (qty % 1 != 0) {
//                                                 Get.snackbar(
//                                                   "Invalid Qty",
//                                                   "You can only enter whole numbers for PCS items.",
//                                                   snackPosition: SnackPosition.BOTTOM,
//                                                 );
//                                                 return;
//                                               }
//                                             }
//
//                                             controller.updateItem(
//                                               index,
//                                               quantity: qty,
//                                               price: item.price,
//                                               unit: item.unit,
//                                             );
//                                           },
//                                         ),
//                                       );
//                                     }
//                                     else{
//                                       return Container(
//                                         height: 40,
//                                         child: TextFormField(
//                                           key: ValueKey('qty_$index'), // remove item.quantity from key
//                                           //initialValue: item.quantity.toString(),
//                                           textAlign: TextAlign.center,
//                                           decoration: InputDecoration(
//                                             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                                             border: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(8),
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderRadius: BorderRadius.circular(8),
//                                               borderSide: BorderSide(color: AppColors.tealColor, width: 2),
//                                             ),
//                                           ),
//                                           keyboardType: TextInputType.numberWithOptions(decimal: true),
//                                           onChanged: (value) {
//                                             double? qty = double.tryParse(value);
//                                             if (qty == null || qty <= 0) return;
//
//                                             if (item.unit?.toLowerCase() == "pcs") {
//                                               if (qty % 1 != 0) {
//                                                 Get.snackbar(
//                                                   "Invalid Qty",
//                                                   "You can only enter whole numbers for PCS items.",
//                                                   snackPosition: SnackPosition.BOTTOM,
//                                                 );
//                                                 return;
//                                               }
//                                             }
//
//                                             controller.updateItem(
//                                               index,
//                                               quantity: qty,
//                                               price: item.price,
//                                               unit: item.unit,
//                                             );
//                                           },
//                                         ),
//                                       );
//                                     }
//                                   }),
//
//                                 ],
//                               ),
//                             ),
//                             if (controller.challanItems.length > 1)
//                               SizedBox(
//                                 width: 20,
//                                 child: Padding(
//                                   padding: EdgeInsets.only(top: 20, left: 5),
//                                   child: IconButton(
//                                     onPressed: () => controller.removeItem(index),
//                                     icon: Icon(Icons.delete, color: Colors.red, size: 20),
//                                     padding: EdgeInsets.zero,
//                                     constraints: BoxConstraints(),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//                 SizedBox(height: 16),
//                 Container(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: controller.addNewItem,
//                     icon: Icon(Icons.add_circle_outline, size: 20),
//                     label: Text('Add Another Item'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.tealColor,
//                       foregroundColor: Colors.white,
//                       padding: EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: AppColors.tealColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: AppColors.tealColor.withOpacity(0.3)),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Total Items:',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.tealColor,
//                         ),
//                       ),
//                       Text(
//                         '${controller.challanItems.length}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.tealColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             )),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCalculationsSection() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'calculations'.tr,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.tealColor,
//               ),
//             ),
//             SizedBox(height: 16),
//             Obx(() => Column(
//               children: [
//                 _buildTotalRow('Subtotal', controller.subtotal.value),
//                 if (AppConstants.withGST.value) ...[
//                   _buildTotalRow('CGST', controller.gstAmount.value / 2),
//                   _buildTotalRow('SGST', controller.gstAmount.value / 2),
//                 ],
//                 Divider(),
//                 _buildTotalRow('Total Amount', controller.totalAmount.value, isTotal: true),
//               ],
//             )),
//             SizedBox(height: 20),
//             Divider(),
//             Text(
//               "payment_status".tr,
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//             SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: Obx(() => Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: DropdownButton<String>(
//                       value: controller.paymentStatus.value,
//                       isExpanded: true,
//                       underline: SizedBox(),
//                       items: [
//                         DropdownMenuItem(value: 'Pending', child: Text('Pending')),
//                         DropdownMenuItem(value: 'Paid', child: Text('Paid')),
//                         DropdownMenuItem(value: 'Partial', child: Text('Partial')),
//                       ],
//                       onChanged: (value) {
//                         if (value != null) {
//                           controller.updatePaymentStatus(value);
//                         }
//                       },
//                     ),
//                   )),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: isTotal ? 18 : 16,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               color: isTotal ?
//               (controller.isEditMode.value ? Colors.orange.shade700 : Colors.green.shade700)
//                   : Colors.black87,
//             ),
//           ),
//           Text(
//             '₹${AppUtil.formatCurrency(amount)}',
//             style: TextStyle(
//               fontSize: isTotal ? 18 : 16,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               color: isTotal ?
//               (controller.isEditMode.value ? Colors.orange.shade700 : Colors.green.shade700)
//                   : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNotesSection() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'additional_notes'.tr,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.tealColor,
//               ),
//             ),
//             SizedBox(height: 16),
//             TextFormField(
//               controller: controller.notesController,
//               decoration: InputDecoration(
//                 hintText: 'add_notes_hint'.tr,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               maxLines: 4,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Obx(() => Row(
//       children: [
//         // Cancel button
//         Expanded(
//           flex: 2,
//           child: OutlinedButton(
//             onPressed: controller.isLoading.value ? null : () => Get.back(),
//             style: OutlinedButton.styleFrom(
//               padding: EdgeInsets.symmetric(vertical: 12),
//             ),
//             child: Text('Cancel'),
//           ),
//         ),
//         SizedBox(width: 8),
//
//         /// Main action button - different text for edit mode
//         Expanded(
//           flex: 4,
//           child: ElevatedButton(
//             onPressed: controller.isLoading.value ? null : () => controller.saveChallan(isDraft: false),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.tealColor,
//               padding: EdgeInsets.symmetric(vertical: 12),
//             ),
//             child: Text(
//               controller.isEditMode.value ? 'Update Challan' : 'Create Challan',
//               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//           ),
//         ),
//       ],
//     ));
//   }
//
//   /// Show delete confirmation dialog
//   void _showDeleteConfirmation() {
//     Get.dialog(
//       AlertDialog(
//         title: Text('delete_challan'.tr),
//         content: Text('delete_challan_message'.tr),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text('cancel'.tr),
//           ),
//           TextButton(
//             onPressed: () {
//               Get.back();
//               //controller.deleteChallan();
//             },
//             child: Text(
//               'delete'.tr,
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

