import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_prac_getx/constant/app_colors.dart';
import 'package:demo_prac_getx/constant/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/item_controller.dart';
import '../controller/item_controller_old.dart';
import '../model/model.dart';
import '../utils/pdf_helper.dart';
import '../utils/shared_preferences_helper.dart';
import '../widgets/widgets.dart';
import 'package:shimmer/shimmer.dart';



class ItemScreen extends GetView<ItemController> {
  static const pageId = "/ItemScreen";

  const ItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: AppColors.tealColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: (){
            Get.back();
          },),
        ),
        title: const Text(
          "Items Management",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.showInactiveItems.value
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white,
            ),
            onPressed: controller.toggleShowInactive,
            tooltip: controller.showInactiveItems.value
                ? 'Hide Inactive Items'
                : 'Show Inactive Items',
          )),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoader();
          }
        
          final items = controller.filteredItemList;
        
          if (items.isEmpty) {
            return _buildEmptyState();
          }
        
          return _buildItemList(items);
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.tealColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Item",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        onPressed: () => _showAddItemDialog(context),
      ),
    );
  }

  /// 🔹 Stylish shimmer loader
  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🔹 Empty state with better illustration
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 100, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            controller.showInactiveItems.value
                ? "No items found"
                : "No active items found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Add your first item using the + button",
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 🔹 Item List Cards with modern look
  Widget _buildItemList(List<Item> items) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shadowColor: AppColors.tealColor.withOpacity(0.2),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ExpansionTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            backgroundColor:
            item.isActive ? Colors.white : Colors.red.shade50,
            leading: CircleAvatar(
              backgroundColor: item.isActive
                  ? AppColors.tealColor.withOpacity(0.15)
                  : Colors.red.shade100,
              child: Icon(Icons.inventory_2_outlined,
                  color: item.isActive
                      ? AppColors.tealColor
                      : Colors.red.shade600),
            ),
            title: Text(
              item.itemName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color:
                item.isActive ? Colors.black : Colors.grey.shade600,
                decoration: item.isActive
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text(
              "₹${item.price.toStringAsFixed(2)} / ${item.unitOfMeasurement}",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.tealColor,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.isActive)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete Item',
                    onPressed: () =>
                        _confirmItemStatusChange(context, item, restore: false),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.restore, color: Colors.green),
                    tooltip: 'Restore Item',
                    onPressed: () =>
                        _confirmItemStatusChange(context, item, restore: true),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Edit Item',
                  onPressed: () => _showEditItemDialog(context, item),
                ),
              ],
            ),
            children: [_buildItemDetails(item)],
          ),
        );
      },
    );
  }


  void _showAddItemDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final detailCtrl = TextEditingController();
    final gstCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String selectedUnit = controller.unitOptions.first;
    bool isActive = true;
    bool isUnlimitedStock = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        bool isAdding = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              insetPadding: EdgeInsets.all(20),
              child: Container(
                padding: EdgeInsets.all(24),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                  maxWidth: 500,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Add New Item",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.tealColor,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: AppColors.tealColor),
                              onPressed: isAdding ? null : () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Item Name
                        TextFormField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            labelText: "Item Name *",
                            hintText: "Enter item name",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            prefixIcon: Icon(Icons.label_outline, color: AppColors.tealColor),
                          ),
                          enabled: !isAdding,
                          validator: (value) => value?.trim().isEmpty ?? true ? "Item name is required" : null,
                        ),
                        SizedBox(height: 16),

                        // Price and Unit Row
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: priceCtrl,
                                decoration: InputDecoration(
                                  labelText: "Price *",
                                  hintText: "0.00",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  prefixIcon: Icon(Icons.currency_rupee_outlined, color: AppColors.tealColor),
                                ),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                enabled: !isAdding,
                                validator: (value) {
                                  final price = double.tryParse(value ?? '');
                                  if (price == null || price <= 0) return "Valid price required";
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedUnit,
                                decoration: InputDecoration(
                                  labelText: "Unit",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                items: controller.unitOptions.map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                                onChanged: isAdding ? null : (value) {
                                  setState(() => selectedUnit = value!);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // GST Percentage
                        SizedBox(height: 16),
                        Obx(() => AppConstants.withGST.value
                            ? Column(
                          children: [
                            SizedBox(height: 16),
                            TextFormField(
                              controller: gstCtrl,
                              decoration: InputDecoration(
                                labelText: "GST (%)",
                                hintText: "Enter GST percentage",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                prefixIcon: Icon(Icons.percent, color: AppColors.tealColor),
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                final gst = double.tryParse(value ?? '');
                                if (gst == null || gst < 0 || gst > 100) {
                                  return "Enter valid GST (0-100)";
                                }
                                return null;
                              },
                            ),
                          ],
                        )
                            : const SizedBox.shrink()),


                        // Stock Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isUnlimitedStock,
                                  onChanged: isAdding ? null : (value) {
                                    setState(() {
                                      isUnlimitedStock = value!;
                                      if (isUnlimitedStock) stockCtrl.clear();
                                    });
                                  },
                                ),
                                Text("Unlimited Stock", style: TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                            if (!isUnlimitedStock)
                              TextFormField(
                                controller: stockCtrl,
                                decoration: InputDecoration(
                                  labelText: "Current Stock *",
                                  hintText: "Enter stock quantity",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  prefixIcon: Icon(Icons.inventory_2_outlined, color: AppColors.tealColor),
                                ),
                                keyboardType: TextInputType.number,
                                enabled: !isAdding,
                                validator: (value) {
                                  if (isUnlimitedStock) return null;
                                  final stock = int.tryParse(value ?? '');
                                  if (stock == null || stock < 0) return "Valid stock required";
                                  return null;
                                },
                              ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Detail Requirements
                        TextFormField(
                          controller: detailCtrl,
                          decoration: InputDecoration(
                            labelText: "Detail Requirements",
                            hintText: "Enter additional details (optional)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            prefixIcon: Icon(Icons.notes_outlined, color: AppColors.tealColor),
                          ),
                          maxLines: 3,
                          enabled: !isAdding,
                        ),
                        SizedBox(height: 16),

                        // Status Toggle
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.toggle_on_outlined, color: AppColors.tealColor),
                              SizedBox(width: 8),
                              Text("Status:", style: TextStyle(fontWeight: FontWeight.w500)),
                              Spacer(),
                              Switch(
                                value: isActive,
                                onChanged: isAdding ? null : (value) {
                                  setState(() => isActive = value);
                                },
                                activeColor: AppColors.tealColor,
                              ),
                              Text(
                                isActive ? "Active" : "Inactive",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isActive ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: isAdding ? null : () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tealColor,
                                foregroundColor: AppColors.whiteColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                elevation: 3,
                              ),
                              onPressed: isAdding ? null : () async {
                                if (formKey.currentState!.validate()) {
                                  setState(() => isAdding = true);

                                  final name = nameCtrl.text.trim();
                                  final price = double.parse(priceCtrl.text);
                                  final gstPercent = double.parse(gstCtrl.text.isEmpty ? '0' : gstCtrl.text);
                                  final stock = isUnlimitedStock ? -1 : int.parse(stockCtrl.text);
                                  final detail = detailCtrl.text.trim();

                                  try {
                                    await controller.addNewItem(
                                      name: name,
                                      price: price,
                                      gstPercent: gstPercent,
                                      unitOfMeasurement: selectedUnit,
                                      currentStock: stock,
                                      detailRequirement: detail,
                                      isActive: isActive,
                                    );
                                    Navigator.pop(context);
                                  } catch (e) {
                                    setState(() => isAdding = false);
                                  }
                                }
                              },
                              child: isAdding
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
                                ),
                              )
                                  : Text(
                                "Add Item",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditItemDialog(BuildContext context, Item item) {
    final nameCtrl = TextEditingController(text: item.itemName);
    final priceCtrl = TextEditingController(text: item.price.toStringAsFixed(2));
    final gstCtrl = TextEditingController(text: item.gstPercent.toStringAsFixed(2));
    final stockCtrl = TextEditingController(
        text: item.currentStock == -1 ? '' : item.currentStock.toString()
    );
    final detailCtrl = TextEditingController(text: item.detailRequirement);
    final formKey = GlobalKey<FormState>();

    String selectedUnit = item.unitOfMeasurement;
    bool isActive = item.isActive;
    bool isUnlimitedStock = item.currentStock == -1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              insetPadding: EdgeInsets.all(20),
              child: Container(
                padding: EdgeInsets.all(24),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                  maxWidth: 500,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Edit Item",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.tealColor,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: AppColors.tealColor),
                              onPressed: isSaving ? null : () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Item Name
                        TextFormField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            labelText: "Item Name *",
                            hintText: "Enter item name",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            prefixIcon: Icon(Icons.label_outline, color: AppColors.tealColor),
                          ),
                          enabled: !isSaving,
                          validator: (value) => value?.trim().isEmpty ?? true ? "Item name is required" : null,
                        ),
                        SizedBox(height: 16),

                        // Price and Unit Row
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: priceCtrl,
                                decoration: InputDecoration(
                                  labelText: "Price *",
                                  hintText: "0.00",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  prefixIcon: Icon(Icons.currency_rupee_outlined, color: AppColors.tealColor),
                                ),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                enabled: !isSaving,
                                validator: (value) {
                                  final price = double.tryParse(value ?? '');
                                  if (price == null || price <= 0) return "Valid price required";
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedUnit,
                                decoration: InputDecoration(
                                  labelText: "Unit",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                items: controller.unitOptions.map((unit) {
                                  return DropdownMenuItem(value: unit, child: Text(unit));
                                }).toList(),
                                onChanged: isSaving ? null : (value) {
                                  setState(() => selectedUnit = value!);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // GST Percentage
                        SizedBox(height: 16),
                        Obx(() => AppConstants.withGST.value
                            ? TextFormField(
                          controller: gstCtrl,
                          decoration: InputDecoration(
                            labelText: "GST (%)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            prefixIcon: Icon(Icons.percent, color: AppColors.tealColor),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            final gst = double.tryParse(value ?? '');
                            if (gst == null || gst < 0 || gst > 100) {
                              return "Enter valid GST (0-100)";
                            }
                            return null;
                          },
                        )
                            : const SizedBox.shrink()),



                        // Stock Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isUnlimitedStock,
                                  onChanged: isSaving ? null : (value) {
                                    setState(() {
                                      isUnlimitedStock = value!;
                                      if (isUnlimitedStock) stockCtrl.clear();
                                    });
                                  },
                                ),
                                Text("Unlimited Stock", style: TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                            if (!isUnlimitedStock)
                              TextFormField(
                                controller: stockCtrl,
                                decoration: InputDecoration(
                                  labelText: "Current Stock *",
                                  hintText: "Enter stock quantity",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  prefixIcon: Icon(Icons.inventory_2_outlined, color: AppColors.tealColor),
                                ),
                                keyboardType: TextInputType.number,
                                enabled: !isSaving,
                                validator: (value) {
                                  if (isUnlimitedStock) return null;
                                  final stock = int.tryParse(value ?? '');
                                  if (stock == null || stock < 0) return "Valid stock required";
                                  return null;
                                },
                              ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Detail Requirements
                        TextFormField(
                          controller: detailCtrl,
                          decoration: InputDecoration(
                            labelText: "Detail Requirements",
                            hintText: "Enter additional details (optional)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            prefixIcon: Icon(Icons.notes_outlined, color: AppColors.tealColor),
                          ),
                          maxLines: 3,
                          //enabled: not isSaving,
                        ),
                        SizedBox(height: 16),

                        // Status Toggle
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.toggle_on_outlined, color: AppColors.tealColor),
                              SizedBox(width: 8),
                              Text("Status:", style: TextStyle(fontWeight: FontWeight.w500)),
                              Spacer(),
                              Switch(
                                value: isActive,
                                onChanged: isSaving ? null : (value) {
                                  setState(() => isActive = value);
                                },
                                activeColor: AppColors.tealColor,
                              ),
                              Text(
                                isActive ? "Active" : "Inactive",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isActive ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: isSaving ? null : () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tealColor,
                                foregroundColor: AppColors.whiteColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                elevation: 3,
                              ),
                              onPressed: isSaving ? null : () async {
                                if (formKey.currentState!.validate()) {
                                  setState(() => isSaving = true);

                                  final name = nameCtrl.text.trim();
                                  final price = double.parse(priceCtrl.text);
                                  final gstPercent = double.parse(gstCtrl.text.isEmpty ? '0' : gstCtrl.text);
                                  final stock = isUnlimitedStock ? -1 : int.parse(stockCtrl.text);
                                  final detail = detailCtrl.text.trim();

                                  try {
                                    await controller.editItem(
                                      itemId: item.itemId,
                                      newName: name,
                                      newPrice: price,
                                      gstPercent: gstPercent,
                                      unitOfMeasurement: selectedUnit,
                                      currentStock: stock,
                                      detailRequirement: detail,
                                      isActive: isActive,
                                    );
                                    Navigator.pop(context);
                                  } catch (e) {
                                    setState(() => isSaving = false);
                                  }
                                }
                              },
                              child: isSaving
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
                                ),
                              )
                                  : Text(
                                "Update Item",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildItemDetails(Item item) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailRow("Unit", item.unitOfMeasurement),
              ),
              Expanded(
                child: _buildDetailRow("Stock", item.currentStock == -1
                    ? "Unlimited"
                    : "${item.currentStock}"),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailRow("Price", "₹${item.price.toStringAsFixed(2)}"),
              ),
              Expanded(
                child: _buildDetailRow("Status", item.isActive ? "Active" : "Inactive"),
              ),
            ],
          ),
          SizedBox(height: 12),
          Obx(() => AppConstants.withGST.value
              ? Row(
            children: [
              Expanded(child: _buildDetailRow("GST", "${item.gstPercent.toStringAsFixed(2)} %")),
              Expanded(child: _buildDetailRow(
                  "Final Price",
                  "₹${(item.price + (item.price * item.gstPercent / 100)).toStringAsFixed(2)}")),
            ],
          )
              : Row(
            children: [
              Expanded(child: _buildDetailRow("Final Price", "₹${item.price.toStringAsFixed(2)}")),
            ],
          )),

          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailRow("ID", item.itemId.toString()),
              ),
            ],
          ),
          if (item.detailRequirement.isNotEmpty) ...[
            SizedBox(height: 12),
            _buildDetailRow("Details", item.detailRequirement),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Confirmation dialog modernized
  void _confirmItemStatusChange(BuildContext context, Item item,
      {required bool restore}) {
    final title = restore ? "Restore Item" : "Delete Item";
    final content = restore
        ? "Do you want to restore '${item.itemName}'?\n\nThis will mark it as active again."
        : "Do you want to delete '${item.itemName}'?\n\nThis will mark it as inactive.";
    final buttonText = restore ? "Restore" : "Delete";
    final buttonColor = restore ? Colors.green : Colors.red;
    final icon = restore ? Icons.restore : Icons.delete_forever;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: buttonColor),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: buttonColor)),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(icon, color: Colors.white),
            label: Text(buttonText),
            onPressed: () async {
              Navigator.pop(context);
              await controller.updateItemStatus(
                itemId: item.itemId,
                isActive: restore,
              );
            },
          ),
        ],
      ),
    );
  }
}



