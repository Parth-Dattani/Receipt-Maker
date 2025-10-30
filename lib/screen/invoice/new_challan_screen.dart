import 'package:demo_prac_getx/constant/constant.dart';
import 'package:demo_prac_getx/utils/calculations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';
import '../../model/model.dart';


/// 2-10
class NewChallanScreen extends GetView<NewChallanController> {
  static const String pageId = '/NewChallanScreen';

  const NewChallanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 4,
        leading: IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor,)),
        backgroundColor: AppColors.tealColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: Obx(() => Text(
          controller.isEditMode.value ? 'edit_challan'.tr : 'new_challan'.tr,
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
              : const SizedBox.shrink()
          ),
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
                  ' *', // Required indicator
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
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<Map<String, dynamic>>(
                      value: controller.selectedCustomer.value,
                      isExpanded: true,
                      hint: Text('Select Customer'),
                      underline: SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Select Customer'),
                        ),
                        ...controller.customers.map((customer) {
                          return DropdownMenuItem(
                            value: customer,
                            child: Text((customer['name'] ?? 'Unknown Customer').toString().toUpperCase()),
                          );
                        }).toList(),
                      ],
                      onChanged: controller.selectCustomer,
                    ),
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
                // Obx(() => Text(
                //   'Total: ₹${AppUtil.formatCurrency(controller.totalAmount.value)}',
                //   style: TextStyle(
                //     fontWeight: FontWeight.bold,
                //     color: AppColors.tealColor,
                //   ),
                // )),
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
                                  if (controller.itemList.isNotEmpty)
                                    Builder(
                                      builder: (context) {
                                        // Try to find the item in the full list (including inactive)
                                        Item? currentItem;
                                        try {
                                          currentItem = controller.itemList.firstWhere(
                                                  (i) => i.itemId == item.itemId
                                          );
                                        } catch (e) {
                                          currentItem = null;
                                        }

                                        // Check if item exists but is inactive
                                        final isInactive = currentItem != null && !(currentItem.isActive ?? true);

                                        // ✅ If in EDIT MODE and item is inactive/deleted, show as read-only
                                        if (controller.isEditMode.value && (isInactive || currentItem == null) && item.description.isNotEmpty) {
                                          return Container(
                                            height: 40,
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(8),
                                              //color: Colors.grey.shade50, // Visual indicator it's read-only
                                            ),
                                            child: Text(
                                              item.description,
                                              style: TextStyle(
                                                fontSize: 14,
                                                //color: Colors.grey.shade700,
                                              ),
                                            ),
                                          );
                                        }

                                        // ✅ Get only ACTIVE items for dropdown
                                        final activeItems = controller.itemList
                                            .where((i) => i.isActive == true)
                                            .toList();

                                        Item? selectedItem;
                                        try {
                                          selectedItem = activeItems.firstWhere(
                                                  (element) => element.itemId == item.itemId
                                          );
                                        } catch (e) {
                                          selectedItem = null;
                                        }

                                        // Normal dropdown for active items
                                        return Container(
                                          height: 40,
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: DropdownButton<Item>(
                                            value: selectedItem,
                                            isExpanded: true,
                                            hint: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                              child: Text('Select Item', style: TextStyle(fontSize: 14)),
                                            ),
                                            underline: SizedBox(),
                                            icon: Padding(
                                              padding: EdgeInsets.only(right: 8),
                                              child: Icon(Icons.arrow_drop_down, size: 20),
                                            ),
                                            items: [
                                              DropdownMenuItem(
                                                value: null,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                                  child: Text('Select Item', style: TextStyle(fontSize: 14)),
                                                ),
                                              ),
                                              ...activeItems.map((item) {
                                                return DropdownMenuItem(
                                                  value: item,
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                                    child: Text(
                                                      ('${item.itemName}').toUpperCase(),
                                                      style: TextStyle(fontSize: 14),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                            onChanged: (selectedItem) {
                                              if (selectedItem != null) {
                                                controller.selectRemoteItemForIndex(index, selectedItem);
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  if (controller.itemList.isEmpty)
                                    TextFormField(
                                      initialValue: item.description,
                                      decoration: InputDecoration(
                                        labelText: 'Item Description',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
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
                                      controller: controller.getPriceController(index, initialValue: item.price),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                                        ),
                                      ),
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (value) {
                                        double? price = double.tryParse(value);
                                        if (price != null && price >= 0) {
                                          controller.updateItem(
                                            index,
                                            price: price,
                                            unit: item.unit,
                                            quantity: item.quantity,
                                          );
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
                                  Obx((){
                                    if(controller.isEditMode.value){
                                      return  Container(
                                        height: 40,
                                        child: TextFormField(
                                          key: ValueKey('qty_$index'), // remove item.quantity from key
                                          initialValue: item.quantity.toString(),
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                                            ),
                                          ),
                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                                          onChanged: (value) {
                                            double? qty = double.tryParse(value);
                                            if (qty == null || qty <= 0) return;

                                            if (item.unit?.toLowerCase() == "pcs") {
                                              if (qty % 1 != 0) {
                                                Get.snackbar(
                                                  "Invalid Qty",
                                                  "You can only enter whole numbers for PCS items.",
                                                  snackPosition: SnackPosition.BOTTOM,
                                                );
                                                return;
                                              }
                                            }

                                            controller.updateItem(
                                              index,
                                              quantity: qty,
                                              price: item.price,
                                              unit: item.unit,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                    else{
                                      return Container(
                                        height: 40,
                                        child: TextFormField(
                                          key: ValueKey('qty_$index'), // remove item.quantity from key
                                          //initialValue: item.quantity.toString(),
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide(color: AppColors.tealColor, width: 2),
                                            ),
                                          ),
                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                                          onChanged: (value) {
                                            double? qty = double.tryParse(value);
                                            if (qty == null || qty <= 0) return;

                                            if (item.unit?.toLowerCase() == "pcs") {
                                              if (qty % 1 != 0) {
                                                Get.snackbar(
                                                  "Invalid Qty",
                                                  "You can only enter whole numbers for PCS items.",
                                                  snackPosition: SnackPosition.BOTTOM,
                                                );
                                                return;
                                              }
                                            }

                                            controller.updateItem(
                                              index,
                                              quantity: qty,
                                              price: item.price,
                                              unit: item.unit,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  }),

                                ],
                              ),
                            ),
                            if (controller.challanItems.length > 1)
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
            Divider(),
            Text(
              "payment_status".tr,
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
              color: isTotal ?
              (controller.isEditMode.value ? Colors.orange.shade700 : Colors.green.shade700)
                  : Colors.black87,
            ),
          ),
          Text(
            '₹${AppUtil.formatCurrency(amount)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ?
              (controller.isEditMode.value ? Colors.orange.shade700 : Colors.green.shade700)
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
    return Obx(() => Row(
      children: [
        // Cancel button
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

        /// Main action button - different text for edit mode
        Expanded(
          flex: 4,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.saveChallan(isDraft: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealColor,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              controller.isEditMode.value ? 'Update Challan' : 'Create Challan',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    ));
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

