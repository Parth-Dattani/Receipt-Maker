import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/constant.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';



import 'package:flutter/material.dart';
import 'package:get/get.dart';


class PurchaseEntryScreen extends GetView<PurchaseEntryController> {
  static const String pageId = '/PurchaseEntryScreen';

  const PurchaseEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 4,
        automaticallyImplyLeading: true,
        foregroundColor: Colors.white,
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
            // ---------------------------------------------------------
            // 🔄 RESPONSIVE LAYOUT BUILDER
            // ---------------------------------------------------------
            LayoutBuilder(
              builder: (context, constraints) {
                // Check for Web/Desktop Width (Standard breakpoint 900)
                if (constraints.maxWidth > 900) {
                  return _buildWebLayout();
                } else {
                  return _buildMobileLayout();
                }
              },
            ),

            // ---------------------------------------------------------
            // ⏳ LOADING OVERLAY
            // ---------------------------------------------------------
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

  // ===========================================================================
  // 📱 MOBILE LAYOUT (Your Original Single Column)
  // ===========================================================================
  Widget _buildMobileLayout() {
    return Form(
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
            SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

// ✅ REPLACE YOUR _buildWebLayout() method with this:

  Widget _buildWebLayout() {
    return Form(
      key: controller.formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================
          // LEFT COLUMN (65% - Inputs)
          // ========================================
          Expanded(
            flex: 65,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPurchaseDetailsCard(),
                  SizedBox(height: 12),
                  _buildVendorSection(),
                  SizedBox(height: 12),
                  _buildItemsSection(),
                  SizedBox(height: 80), // Bottom padding for action buttons
                ],
              ),
            ),
          ),

          // ========================================
          // RIGHT COLUMN (35% - Summary & Actions)
          // ========================================
          Expanded(
            flex: 35,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // Scrollable summary section
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildCalculationsSection(),
                          SizedBox(height: 12),
                          _buildNotesSection(),
                        ],
                      ),
                    ),
                  ),

                  // Fixed action buttons at bottom
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: _buildActionButtons(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 🧩 WIDGETS (Reused in both layouts)
  // ===========================================================================

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
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.purchaseDateController,
                          decoration: InputDecoration(
                            labelText: 'Purchase Date',
                            prefixIcon: Icon(Icons.calendar_today, color: AppColors.tealColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          readOnly: true,
                          onTap: controller.selectPurchaseDate,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controller.paymentDueDateController,
                          decoration: InputDecoration(
                            labelText: 'Payment Due Date',
                            prefixIcon: Icon(Icons.event, color: AppColors.tealColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          readOnly: true,
                          onTap: controller.selectPaymentDueDate,
                        ),
                      ),
                    ],
                  ),
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
                                    '🔒 Demo Mode: Purchase dates limited to 1990-1992',
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
                    ? Row(
                  children: [
                    IconButton(
                      onPressed: controller.refreshVendors,
                      icon: Icon(Icons.refresh, color: AppColors.tealColor),
                      tooltip: 'Refresh vendors list',
                    ),
                    IconButton(
                      onPressed: controller.toggleVendorForm,
                      icon: Icon(
                        controller.showVendorForm.value
                            ? Icons.store
                            : Icons.add_business,
                        color: AppColors.tealColor,
                      ),
                      tooltip: controller.showVendorForm.value
                          ? 'Select from existing customers'
                          : 'Add new vendor manually',
                    ),
                  ],
                )
                    : SizedBox()),
              ],
            ),
            SizedBox(height: 16),
            Obx(() {
              if (controller.isEditMode.value) {
                return _buildVendorFormFields();
              } else {
                if (controller.isLoading.value && controller.customers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.tealColor),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Loading customers...',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.customers.isEmpty && !controller.showVendorForm.value) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 32,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No customers found',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: controller.toggleVendorForm,
                              icon: Icon(Icons.add_business, size: 18),
                              label: Text('Add Vendor'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tealColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: controller.refreshVendors,
                              icon: Icon(Icons.refresh, size: 18),
                              label: Text('Refresh'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.tealColor,
                                side: BorderSide(color: AppColors.tealColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else if (!controller.showVendorForm.value) {
                  return Column(
                    children: [
                      SearchableDropdown<Map<String, dynamic>>(
                        value: controller.selectedVendor.value,
                        items: controller.customers,
                        itemLabel: (vendor) => (vendor['name'] ?? 'Unknown Vendor').toString().toUpperCase(),
                        hintText: 'Select Vendor',
                        searchHintText: 'Search vendors...',
                        itemBuilder: (vendor) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (vendor['name'] ?? 'Unknown').toString().toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            if (vendor['mobile1'] != null && vendor['mobile1'].toString().isNotEmpty)
                              Text(vendor['mobile1'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                        onChanged: (selectedVendor) {
                          controller.selectVendor(selectedVendor);
                        },
                      ),
                    ],
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
          ),
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
                ),
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
                ),
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
                  'Purchase Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealColor,
                  ),
                ),
                Spacer(),
                Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.useItemMaster.value
                        ? AppColors.tealColor.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: controller.useItemMaster.value
                          ? AppColors.tealColor.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.useItemMaster.value
                            ? Icons.arrow_drop_down_circle
                            : Icons.edit,
                        size: 16,
                        color: controller.useItemMaster.value
                            ? AppColors.tealColor
                            : Colors.orange,
                      ),
                      SizedBox(width: 4),
                      Text(
                        controller.useItemMaster.value ? 'List' : 'Manual',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: controller.useItemMaster.value
                              ? AppColors.tealColor
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                )),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.swap_horiz, color: AppColors.tealColor),
                  onPressed: controller.toggleItemEntryMode,
                  tooltip: 'Toggle between dropdown and manual entry',
                ),
              ],
            ),
            SizedBox(height: 16),
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //   decoration: BoxDecoration(
            //     color: AppColors.tealColor.withOpacity(0.1),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Row(
            //     children: [
            //       Expanded(flex: 3, child: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor))),
            //       Expanded(flex: 1, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor))),
            //       Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.tealColor))),
            //       SizedBox(width: 30),
            //     ],
            //   ),
            // ),
            SizedBox(height: 12),
            Obx(() => Column(
              children: [
                ...controller.purchaseItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;

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
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade600,
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
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 30.0),
                              child: Text(
                                'Price',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ),

                          ],
                        ),
                        SizedBox(height: 8),
                        // Row 1: Item Name + Price + Qty
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (controller.useItemMaster.value)
                                    Builder(
                                      builder: (context) {
                                        final activeItems = controller.itemList
                                            .where((i) => i.isActive == true)
                                            .toList();
                                        Item? selectedItem;
                                        try {
                                          selectedItem = activeItems.firstWhere((element) => element.itemId == item.itemId);
                                        } catch (e) {
                                          selectedItem = null;
                                        }
                                        return SearchableDropdown<Item>(
                                          value: selectedItem,
                                          items: activeItems,
                                          itemLabel: (item) => item.itemName.toUpperCase(),
                                          hintText: 'Select Item',
                                          searchHintText: 'Search items...',
                                          itemBuilder: (item) => Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.itemName.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                            ],
                                          ),
                                          onChanged: (selectedItem) {
                                            if (selectedItem != null) {
                                              controller.selectItemForIndex(index, selectedItem);
                                            }
                                          },
                                        );
                                      },
                                    ),

                                  if (!controller.useItemMaster.value)
                                    SizedBox(
                                      height: 40,
                                      child: TextFormField(
                                        initialValue: item.itemName,
                                        decoration: InputDecoration(
                                          hintText: 'Enter item name',
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onChanged: (value) => controller.updateItem(index, itemName: value, itemId: ''),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 40,
                                child: TextFormField(
                                  ///no want Price every Time User manully enter not from Gettin gList
                                  controller: controller.getPriceController(index, initialValue: item.purchasePrice),
                                  //controller: controller.priceControllers,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'price',

                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                            ),

                            if (controller.purchaseItems.length > 1)
                              SizedBox(
                                width: 20,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 1, left: 5),
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
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Qty', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  SizedBox(height: 4),
                                  SizedBox(
                                    height: 40,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      initialValue: item.quantity > 0 ? item.quantity.toString() : '',
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (value) {
                                        double? qty = double.tryParse(value);
                                        if (qty != null && qty > 0) {
                                          controller.updateItem(index, quantity: qty);
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
                                  Text('GST %', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  SizedBox(height: 4),
                                  SizedBox(
                                    height: 40,
                                    child: DropdownButtonFormField<double>(
                                      value: item.gstRate,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      items: [0.0, 5.0, 12.0, 18.0].map((rate) {
                                        return DropdownMenuItem(value: rate, child: Text("${rate.toInt()}%"));
                                      }).toList(),
                                      onChanged: (value) => controller.updateItem(index, gstRate: value),
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
                                  Text('Unit', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  SizedBox(height: 4),
                                  SizedBox(
                                    height: 40,
                                    child: DropdownButtonFormField<String>(
                                      value: item.unit.isNotEmpty && controller.unitOptions.contains(item.unit) ? item.unit : controller.unitOptions.first,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      items: controller.unitOptions.map((unit) {
                                        return DropdownMenuItem(value: unit, child: Text(unit, style: TextStyle(fontSize: 12)));
                                      }).toList(),
                                      onChanged: (value) => controller.updateItem(index, unit: value),
                                    ),
                                  ),
                                ],
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                if (AppConstants.withGST.value)
                  _buildTotalRow('GST Amount', controller.gstAmount.value),
                Divider(),
                _buildTotalRow('Total Amount', controller.totalAmount.value, isTotal: true),
              ],
            )),
            SizedBox(height: 20),
            Divider(),
            Text("Payment Status", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
            SizedBox(height: 8),
            Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: controller.paymentStatus.value,
                isExpanded: true,
                underline: SizedBox(),
                items: ['Pending', 'Paid', 'Partial'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: (value) => controller.updatePaymentStatus(value!),
              ),
            )),
            Obx(() {
              if (controller.paymentStatus.value == 'Partial') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12),
                    Text("Paid Amount", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade700, fontSize: 14)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: controller.paidAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: "₹ ",
                        hintText: "Enter paid amount",
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (value) => controller.updatePaidAmount(value),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Paid:", style: TextStyle(fontWeight: FontWeight.w600)),
                              Text("₹${AppUtil.formatCurrency(controller.paidAmount.value)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Pending:", style: TextStyle(fontWeight: FontWeight.w600)),
                              Text("₹${AppUtil.formatCurrency(controller.pendingAmount.value)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                            ],
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

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.green.shade700 : Colors.black87)),
          Text('₹${AppUtil.formatCurrency(amount)}', style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.green.shade700 : Colors.black87)),
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


