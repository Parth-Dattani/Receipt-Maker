// new_invoice_screen.dart
import 'package:demo_prac_getx/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_prac_getx/model/item_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/model.dart';



class NewInvoiceScreen extends GetView<NewInvoiceController> {
  static const String pageId = '/NewInvoiceScreen';

  const NewInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Invoice'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [

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
                    _buildChallanToInvoiceSection(),
                    // Invoice Details Section
                    _buildInvoiceDetailsCard(),
        
                    SizedBox(height: 16),
        
                    // Customer Section
                    _buildCustomerSection(),
        
                    SizedBox(height: 16),
        
                    // Items Section
                    _buildItemsSection(),
        
                    SizedBox(height: 16),
        
                    // Calculations Section
                    _buildCalculationsSection(),
        
                    SizedBox(height: 16),
        
                    // Notes Section
                    _buildNotesSection(),
        
                    SizedBox(height: 32),
        
                    // Action Buttons
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Loading...',
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

  Widget _buildInvoiceDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Type Selection - FIXED
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(width: 16),
                // Use Obx only where needed
                _buildDocumentTypeSelection(),
              ],
            ),
            SizedBox(height: 16),

            // Use Obx for the title that changes with document type
            Obx(() => Text(
              '${controller.invoiceType.value.name} Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            )),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Obx(() => TextFormField(
                    controller: controller.invoiceNumberController,
                    decoration: InputDecoration(
                      labelText: '${controller.invoiceType.value.name} Number',
                      prefixIcon: Icon(controller.invoiceType.value == InvoiceType.invoice
                          ? Icons.receipt
                          : Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    readOnly: true,
                  )),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: controller.dueDateController,
                    decoration: InputDecoration(
                      labelText: 'Invoice Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    readOnly: true,
                    onTap: controller.selectDueDate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Separate method for document type selection
  Widget _buildDocumentTypeSelection() {
    return Row(
      children: [
        _buildDocumentTypeChip(InvoiceType.invoice, Icons.receipt, Colors.blue),
        SizedBox(width: 8),
        _buildDocumentTypeChip(InvoiceType.quotation, Icons.description, Colors.orange),
      ],
    );
  }

  Widget _buildDocumentTypeChip(InvoiceType type, IconData icon, Color color) {
    return Obx(() {
      final isSelected = controller.invoiceType.value == type;
      return ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            SizedBox(width: 4),
            Text(type.name),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => controller.setInvoiceType(type),
        selectedColor: color,
        backgroundColor: color.withOpacity(0.1),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.bold,
        ),
      );
    });
  }


  Widget _buildCustomerSection() {
    return Obx((){
      // Hide customer section when creating from challan
      if (controller.createFromChallan.value && controller.selectedCustomerForInvoice.value.isNotEmpty) {
        return SizedBox.shrink();
      }
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
                  Text(
                    'Customer Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: controller.toggleCustomerForm,
                    icon: Icon(
                      controller.showCustomerForm.value
                          ? Icons.person
                          : Icons.person_add,
                      color: Colors.blue.shade700,
                    ),
                    tooltip: controller.showCustomerForm.value
                        ? 'Select from existing customers'
                        : 'Add new customer manually',
                  ),
                ],
              ),
              SizedBox(height: 16),
              Obx(() {
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
                        child: Text('Add New Customer'),
                      ),
                    ],
                  );
                } else if (!controller.showCustomerForm.value) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
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
                            child: Text(customer['name'] ?? 'Unknown Customer'),
                          );
                        }).toList(),
                      ],
                      onChanged: controller.selectCustomer,
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      SizedBox(height: 12),
                      Text(
                        'Add New Customer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: controller.customerNameController,
                        decoration: InputDecoration(
                          labelText: 'Customer Name *',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
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
                                labelText: 'Mobile Number',
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
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
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
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
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  );
                }
              }),
            ],
          ),
        ),
      );
    }

    );
  }

  Widget _buildItemsSection() {
    return Obx(() {
      final isFromChallan = controller.createFromChallan.value &&
          controller.selectedCustomerForInvoice.value.isNotEmpty;

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
                  Text(
                    'Invoice Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Spacer(),
                  if (isFromChallan)
                    Chip(
                      label: Text('From Challan', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.purple.shade700,
                    )
                  else
                    Obx(() => Text(
                      'Total: ₹${controller.totalAmount.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    )),
                ],
              ),
              SizedBox(height: 16),

              // Items list header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Item Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Price (₹)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Qty',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),

                    if (!isFromChallan) SizedBox(width: 40), // Space for delete button
                  ],
                ),
              ),
              SizedBox(height: 12),

              Obx(() => Column(
                children: [
                  // Display message if no items available
                  if (controller.itemList.isEmpty && !isFromChallan)
                    Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
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

                  /// Invoice items list
                  ...controller.invoiceItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    InvoiceItem item = entry.value;

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
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
                                    // Make item selection read-only when from challan
                                    if (isFromChallan)
                                      Column(mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.description,
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          if (item.challanId != null)
                                            Text(
                                              '${item.challanId}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                        ],
                                      )
                                    else if (controller.itemList.isNotEmpty)
                                      Container(
                                        height: 40,
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: DropdownButton<Item>(
                                          value: controller.itemList.firstWhereOrNull(
                                                  (element) => element.itemId == item.itemId
                                          ),
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
                                            ...controller.itemList.map((item) {
                                              return DropdownMenuItem(
                                                value: item,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                                  child: Text(
                                                    '${item.itemName}',
                                                    style: TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                          onChanged: isFromChallan ? null : (selectedItem) {
                                            if (selectedItem != null) {
                                              controller.selectRemoteItemForIndex(index, selectedItem);
                                            }
                                          },
                                        ),
                                      )
                                    else
                                      TextFormField(
                                        initialValue: item.description,
                                        decoration: InputDecoration(
                                          labelText: 'Item Description',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                        readOnly: isFromChallan,
                                        onChanged: isFromChallan ? null : (value) {
                                          controller.updateItem(index, description: value);
                                        },
                                      ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 6),
                              /// Price
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Price',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      height: 40,
                                      child: TextFormField(
                                        controller: controller.getPriceController(index, initialValue: item.rate),
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        readOnly: isFromChallan, // disable editing when from challan
                                        keyboardType: TextInputType.number, // ✅ number only
                                        onChanged: isFromChallan ? null : (value) {
                                          final price = int.tryParse(value); // ✅ integers only
                                          if (price != null && price >= 0) {
                                            controller.updateItem(index, rate: price.toDouble());
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 6),

                              // Quantity - make read-only when from challan
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
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        readOnly: isFromChallan,
                                        keyboardType: TextInputType.number,
                                        onChanged: isFromChallan ? null : (value) {
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


                              if (!isFromChallan && controller.invoiceItems.length > 1)
                                SizedBox(width: 20,
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



                  /// Add item button - hide when from challan
                  if (!isFromChallan) ...[
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.addNewItem,
                        icon: Icon(Icons.add_circle_outline, size: 20),
                        label: Text('Add Another Item'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Summary
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Items:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          '${controller.invoiceItems.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
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
    });
  }

  Widget _buildCalculationsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              'Calculations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 16),

            /// Tax + Discount in one row
            // Row(
            //   children: [
            //     /// Tax Rate (40%)
            //     Expanded(
            //       flex: 4, // 40%
            //       child: TextFormField(
            //         decoration: InputDecoration(
            //           labelText: 'Tax Rate (%)',
            //           prefixIcon: const Icon(Icons.percent, size: 18,),
            //           prefixIconConstraints: const BoxConstraints(
            //             minWidth: 30,  // shrink the space
            //             minHeight: 30,
            //           ),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //         ),
            //         keyboardType: const TextInputType.numberWithOptions(decimal: true),
            //         onChanged: (value) {
            //           final rate = double.tryParse(value);
            //           if (rate != null && rate >= 0) {
            //             controller.updateTaxRate(rate);
            //           }
            //         },
            //       ),
            //     ),
            //     const SizedBox(width: 6),
            //
            //     /// Discount (60%)
            //     Expanded(
            //       flex: 6, // 60%
            //       child: TextFormField(
            //         decoration: InputDecoration(
            //           labelText: 'Discount',
            //           //prefixIcon: const Icon(Icons.discount),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //           suffixIcon: Obx(
            //                 () => DropdownButton<String>(
            //               value: controller.discountType.value,
            //               underline: const SizedBox(),
            //               items: const [
            //                 DropdownMenuItem(value: 'amount', child: Text('₹')),
            //                 DropdownMenuItem(value: 'percentage', child: Text('%')),
            //               ],
            //               onChanged: (value) {
            //                 if (value != null) {
            //                   controller.updateDiscount(
            //                     controller.discountAmount.value,
            //                     value,
            //                   );
            //                 }
            //               },
            //             ),
            //           ),
            //         ),
            //         keyboardType: const TextInputType.numberWithOptions(decimal: true),
            //         onChanged: (value) {
            //           final discount = double.tryParse(value);
            //           if (discount != null && discount >= 0) {
            //             controller.updateDiscount(
            //               discount,
            //               controller.discountType.value,
            //             );
            //           }
            //         },
            //       ),
            //     ),
            //   ],
            // ),



            /// Totals Section
            Obx(
                  () => Column(
                children: [
                  _buildTotalRow('Subtotal', controller.subtotal.value),
                  if (controller.discountAmount.value > 0)
                    _buildTotalRow(
                      'Discount',
                      controller.discountType.value == 'percentage'
                          ? controller.subtotal.value *
                          (controller.discountAmount.value / 100)
                          : controller.discountAmount.value,
                      isDiscount: true,
                    ),
                  if (controller.taxRate.value > 0)
                    _buildTotalRow(
                      'Tax (${controller.taxRate.value}%)',
                      controller.taxAmount.value,
                    ),
                  _buildTotalRow('Gst', controller.gstAmount.value),
                  const Divider(),
                  _buildTotalRow(
                    'Total Amount',
                    controller.totalAmount.value,
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            /// Payment Status
            Text("Payment Staus"),
            Obx(
                  () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: controller.paymentStatus.value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
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
              ),
            ),

          ],
        ),
      ),
    );
  }


  Widget _buildTotalRow(String label, double amount, {bool isDiscount = false, bool isTotal = false}) {
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
              color: isTotal ? Colors.blue.shade700 : Colors.black87,
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}₹ ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : (isTotal ? Colors.blue.shade700 : Colors.black87),
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
              'Additional Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: controller.notesController,
              decoration: InputDecoration(
                hintText: 'Add any additional notes or terms...',
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

        /// Save Draft button
        // Expanded(
        //   flex: 3,
        //   child: ElevatedButton(
        //     onPressed: controller.isLoading.value ? null : () => controller.saveInvoice(isDraft: true),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.grey.shade600,
        //       padding: EdgeInsets.symmetric(vertical: 12),
        //     ),
        //     child: Text('Save Draft'),
        //   ),
        // ),
        // SizedBox(width: 8),

        /// Main action button
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.saveInvoice(isDraft: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.invoiceType.value == InvoiceType.invoice
                  ? Colors.blue.shade700
                  : Colors.orange.shade700,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Obx(() => Text(
              controller.invoiceType.value == InvoiceType.invoice
                  ? 'Create Invoice'
                  : 'Create Quotation',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.whiteColor),
            )),
          ),
        ),
      ],
    ));
  }

  /// In your _buildChallanToInvoiceSection method
  Widget _buildChallanToInvoiceSection() {
    return Obx(() {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox to toggle create from challan
              Row(
                children: [
                  Checkbox(
                    value: controller.createFromChallan.value,
                    onChanged: (value) {
                      controller.createFromChallan.value = value ?? false;
                      if (value == true) {
                        // Load challans when checkbox is checked
                        controller.loadChallansForInvoice();
                      } else {
                        // Clear selection when unchecked
                        controller.selectedCustomerForInvoice.value = '';
                        controller.selectedCustomerChallans.clear();
                      }
                    },
                  ),
                  Text(
                    'Create Invoice from Challans',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  Spacer(),
                  if (controller.createFromChallan.value)
                    IconButton(
                      onPressed: controller.loadChallansForInvoice,
                      icon: Icon(Icons.refresh),
                      color: Colors.purple.shade700,
                    ),
                ],
              ),

              // Show challan section only when checkbox is checked
              if (controller.createFromChallan.value) ...[
                SizedBox(height: 16),

                // Date Range Picker
                Text(
                  'Select Date Range:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.fromDateController,
                        decoration: InputDecoration(
                          labelText: 'From Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => controller.selectFromDate(Get.context!),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: controller.toDateController,
                        decoration: InputDecoration(
                          labelText: 'To Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => controller.selectToDate(Get.context!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                if (controller.allChallans.isEmpty)
                  ElevatedButton(
                    onPressed: controller.loadChallansForInvoice,
                    child: Text('Load Challans'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  Column(
                    children: [
                      // Customer dropdown
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: controller.selectedCustomerForInvoice.value.isEmpty
                              ? null
                              : controller.selectedCustomerForInvoice.value,
                          isExpanded: true,
                          hint: Text('Select Customer'),
                          underline: SizedBox(),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text('Select Customer'),
                            ),
                            ...controller.customerNames.map((customerName) {
                              final challanCount = controller.allChallans
                                  .where((challan) => challan.customerName == customerName)
                                  .length;

                              return DropdownMenuItem(
                                value: customerName,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customerName,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '$challanCount challan(s)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                          onChanged: controller.selectCustomerForInvoice,
                        ),
                      ),

                      // Selected customer challans info
                      if (controller.selectedCustomerForInvoice.value.isNotEmpty)
                        Column(
                          children: [
                            SizedBox(height: 16),
                            Text(
                              'Challans to be combined:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            ...controller.selectedCustomerChallans.map((challan) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.receipt, size: 20, color: Colors.blue),
                                title: Text(
                                  'Challan #${challan.challanId}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                subtitle: Text(
                                  DateFormat('MMM dd, yyyy').format(
                                      challan.challanDate ?? DateTime.now()
                                  ),
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              );
                            }).toList(),

                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Items:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${controller.invoiceItems.length}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      );
    });
  }
}