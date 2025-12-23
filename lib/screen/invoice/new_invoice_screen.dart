import 'package:demo_prac_getx/constant/constant.dart';
import 'package:demo_prac_getx/utils/calculations.dart';
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
import '../../widgets/widgets.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';


class NewInvoiceScreen extends GetView<NewInvoiceController> {
  static const String pageId = '/NewInvoiceScreen';

  const NewInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isEditMode.value
              ? 'edit_invoice'.tr
              : controller.invoiceType.value == InvoiceType.invoice
              ? 'new_invoice'.tr
              : 'new_quotation'.tr,
        )),
        backgroundColor: controller.isEditMode.value
            ? Colors.orange.shade700
            : AppColors.tealColor,
        foregroundColor: Colors.white,
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
            // ✅ UPDATED: Used LayoutBuilder for Responsive Web UI
            LayoutBuilder(
              builder: (context, constraints) {
                // Check if width is greater than 900 (Web/Tablet landscape)
                bool isWeb = constraints.maxWidth > 900;

                return Form(
                  key: controller.formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isWeb ? 24 : 16),
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 1400), // Max width for large monitors
                        child: isWeb
                            ? _buildWebLayout()
                            : _buildMobileLayout(),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Loading Overlay
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                            controller.isEditMode.value
                                ? Colors.orange.shade700
                                : Colors.blue.shade700
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        controller.isEditMode.value ? 'Updating...' : 'Loading...',
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

  // ✅ MOBILE LAYOUT (Your original vertical stack)
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          if (!controller.isEditMode.value && !controller.isFromQuotation.value) {
            return Column(
              children: [
                _buildChallanToInvoiceSection(),
                SizedBox(height: 16),
              ],
            );
          }
          return SizedBox.shrink();
        }),
        _buildInvoiceDetailsCard(),
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
    );
  }

  // ✅ WEB LAYOUT (Two Column Structure)
  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT COLUMN (Main Data) - Takes 70% width
        Expanded(
          flex: 7,
          child: Column(
            children: [
              Obx(() {
                if (!controller.isEditMode.value && !controller.isFromQuotation.value) {
                  return Column(
                    children: [
                      _buildChallanToInvoiceSection(),
                      SizedBox(height: 16),
                    ],
                  );
                }
                return SizedBox.shrink();
              }),

              // Place Invoice Details and Customer details side-by-side on Web
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInvoiceDetailsCard()),
                  SizedBox(width: 16),
                  Expanded(child: _buildCustomerSection()),
                ],
              ),
              SizedBox(height: 16),

              _buildItemsSection(),
            ],
          ),
        ),

        SizedBox(width: 24), // Spacing between columns

        // RIGHT COLUMN (Summary & Actions) - Takes 30% width
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildCalculationsSection(),
              SizedBox(height: 16),
              _buildNotesSection(),
              SizedBox(height: 24),
              _buildActionButtons(), // Action buttons on the right side
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ALL EXISTING WIDGET METHODS REMAIN UNCHANGED BELOW
  // ---------------------------------------------------------------------------

  Widget _buildEditModeActions() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.delete, color: Colors.white),
          onPressed: () => _showDeleteConfirmation(),
          tooltip: 'Delete Invoice',
        ),
        SizedBox(width: 8),
      ],
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
            Row(
              children: [
                Obx(() => Text(
                  controller.isEditMode.value ? 'invoice_details'.tr : '${controller.invoiceType.value.name} Details'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: controller.isEditMode.value
                        ? Colors.orange.shade700
                        : AppColors.tealColor,
                  ),
                )),
                Spacer(),
                Obx(() => controller.isEditMode.value
                    ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    'edit_mode'.tr,
                    style: TextStyle(
                      color: Colors.orange.shade800,
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

            Obx(() {
              if (!controller.isEditMode.value && !controller.createFromChallan.value && !controller.isFromQuotation.value) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'invoice_type'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tealColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildDocumentTypeSelection(),
                    SizedBox(height: 16),
                  ],
                );
              }
              return SizedBox();
            }),

            // Invoice Number
            Obx(() => TextFormField(
              controller: controller.invoiceNumberController,
              decoration: InputDecoration(
                labelText: controller.isEditMode.value
                    ? 'Invoice Number'
                    : '${controller.invoiceType.value.name} Number',
                prefixIcon: Icon(Icons.receipt_long),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              readOnly: true,
              style: TextStyle(
                color: controller.isEditMode.value ? Colors.grey.shade600 : Colors.black87,
              ),
            )),

            SizedBox(height: 16),

            /// Invoice Date and Payment Due Date in Row
            // Row(
            //   children: [
            //     Expanded(
            //       child: Obx(() => TextFormField(
            //         controller: controller.invoiceDateController,
            //         decoration: InputDecoration(
            //           labelText: '${controller.invoiceType.value.name} Date',
            //           prefixIcon: Icon(Icons.calendar_today, size: 20),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            //         ),
            //         readOnly: true,
            //         onTap: controller.selectInvoiceDate,
            //         style: TextStyle(fontSize: 14),
            //       )),
            //     ),
            //
            //     SizedBox(width: 12),
            //
            //     Expanded(
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Obx(() => TextFormField(
            //             controller: controller.paymentDueDateController,
            //             decoration: InputDecoration(
            //               labelText: controller.invoiceType.value == InvoiceType.invoice
            //                   ? 'Due Date'
            //                   : 'Valid Until',
            //               prefixIcon: Icon(Icons.event_available, size: 20),
            //               border: OutlineInputBorder(
            //                 borderRadius: BorderRadius.circular(8),
            //               ),
            //               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            //             ),
            //             readOnly: true,
            //             onTap: controller.selectPaymentDueDate,
            //             style: TextStyle(fontSize: 14),
            //           )),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),

            Obx(() {
              final showDueDate = AppConstants.isDueDateEnabled.value;

              if (showDueDate) {
                // Show both Invoice Date and Due Date side by side
                return Row(
                  children: [
                    Expanded(
                      child: Obx(() => TextFormField(
                        controller: controller.invoiceDateController,
                        decoration: InputDecoration(
                          labelText: '${controller.invoiceType.value.name} Date',
                          prefixIcon: const Icon(Icons.calendar_today, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                        readOnly: true,
                        onTap: controller.selectInvoiceDate,
                        style: const TextStyle(fontSize: 14),
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => TextFormField(
                        controller: controller.paymentDueDateController,
                        decoration: InputDecoration(
                          labelText: controller.invoiceType.value == InvoiceType.invoice
                              ? 'Due Date'
                              : 'Valid Until',
                          prefixIcon: const Icon(Icons.event_available, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                        readOnly: true,
                        onTap: controller.selectPaymentDueDate,
                        style: const TextStyle(fontSize: 14),
                      )),
                    ),
                  ],
                );
              } else {
                // Show only Invoice Date (full width)
                return Obx(() => TextFormField(
                  controller: controller.invoiceDateController,
                  decoration: InputDecoration(
                    labelText: '${controller.invoiceType.value.name} Date',
                    prefixIcon: const Icon(Icons.calendar_today, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                  readOnly: true,
                  onTap: controller.selectInvoiceDate,
                  style: const TextStyle(fontSize: 14),
                ));
              }
            }),


            // Days until due info
            Obx(() {
              // Only show message if due date is enabled
              if (!AppConstants.isDueDateEnabled.value) {
                return const SizedBox.shrink();
              }

              if (!controller.isEditMode.value && !controller.isFromQuotation.value) {
                final daysUntilDue = controller.paymentDueDate.value.difference(controller.invoiceDate.value).inDays;

                if (controller.invoiceType.value == InvoiceType.invoice) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 14, color: Colors.blue.shade700),
                          SizedBox(width: 6),
                          Text(
                            'Payment due in $daysUntilDue days',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                else {
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 14, color: Colors.orange.shade700),
                          SizedBox(width: 6),
                          Text(
                            'Quotation valid for $daysUntilDue days',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
              return SizedBox.shrink();
            }),

            Obx(() {
              if (controller.isEditMode.value &&
                  controller.originalInvoiceData != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Divider(),
                    Text(
                      'original_invoice_information:'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${controller.formatOriginalInvoiceDate()}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
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
                              '🔒 Demo Mode: Invoice dates limited to 1990-1992',
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
                    SizedBox(height: 12),
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
    return Obx(() {
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
                    'customer_information'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: controller.isEditMode.value
                          ? Colors.orange.shade700
                          : AppColors.tealColor,
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
                      controller.showCustomerForm.value
                          ? Icons.person
                          : Icons.person_add,
                      color: controller.isEditMode.value
                          ? Colors.orange.shade700
                          : AppColors.tealColor,
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
                }
                else {
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
                          child: Text('add_new_customer'.tr),
                        ),
                      ],
                    );
                  } else if (!controller.showCustomerForm.value) {
                    return SearchableDropdown<Map<String, dynamic>>(
                      value: controller.selectedCustomerId.value.isEmpty
                          ? null
                          : controller.customers.firstWhereOrNull(
                              (c) => c['customerId']?.toString() == controller.selectedCustomerId.value
                      ),
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
                        if (selectedCustomer == null) {
                          controller.selectCustomer(null);
                        } else {
                          controller.selectCustomer(selectedCustomer);
                        }
                      },
                    );
                  } else {
                    return _buildNewCustomerForm();
                  }
                }
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEditModeCustomerInfo() {
    return Column(
      children: [
        _buildNewCustomerForm(),
      ],
    );
  }

  Widget _buildNewCustomerForm() {
    return Column(
      children: [
        if (!controller.isEditMode.value) ...[
          SizedBox(height: 12),
          Text(
            'add_new_customer'.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          SizedBox(height: 12),
        ],
        TextFormField(
          controller: controller.customerNameController,
          decoration: InputDecoration(
            labelText: 'customer_name'.tr,
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
                  labelText: 'mobile_number'.tr,
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
                  labelText: 'email'.tr,
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
            labelText: 'address'.tr,
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

  Widget _buildItemsSection() {
    return Obx(() {
      final isFromChallan = controller.createFromChallan.value &&
          controller.selectedCustomerForInvoice.value.isNotEmpty;

      final businessType = AppConstants.businessType?.toLowerCase() ?? '';

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
                    'invoice_items'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: controller.isEditMode.value
                          ? Colors.orange.shade700
                          : AppColors.tealColor,
                    ),
                  ),
                  Spacer(),
                  if (isFromChallan)
                    Chip(
                      label: Text('from_challan'.tr, style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.purple.shade700,
                    )
                ],
              ),
              SizedBox(height: 16),

              Obx(() {
                if (controller.isEditMode.value && controller.originalItemsCount > 0) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history, size: 16, color: Colors.orange.shade700),
                        SizedBox(width: 8),
                        Text(
                          'Originally had ${controller.originalItemsCount} items',
                          style: TextStyle(
                            color: Colors.orange.shade800,
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

              Obx(() => Column(
                children: [
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
                              'no_items_available'.tr,
                              style: TextStyle(color: Colors.orange.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ...controller.invoiceItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    InvoiceItem item = entry.value;

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Selector + Description
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
                                          businessType == 'trading' ? 'Item' : 'Service',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),

                                    // Item Dropdown/TextField
                                    if (controller.itemList.isNotEmpty)
                                      Builder(
                                        builder: (context) {
                                          final isFromChallan = controller.createFromChallan.value &&
                                              controller.selectedCustomerForInvoice.value.isNotEmpty;

                                          Item? currentItem;
                                          try {
                                            currentItem = controller.itemList.firstWhere(
                                                    (i) => i.itemId == item.itemId
                                            );
                                          } catch (e) {
                                            currentItem = null;
                                          }

                                          final isInactive = currentItem != null && !(currentItem.isActive ?? true);

                                          // Show read-only field for inactive items from challan
                                          if (isFromChallan /*&& (isInactive || currentItem == null) && item.itemName.isNotEmpty*/) {
                                            return Container(
                                              height: 40,
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey.shade300),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.itemName,
                                                      style: TextStyle(fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          final activeItems = controller.itemList.where((i) => i.isActive ?? true).toList();
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
                                                      if (isOutOfStock && businessType != 'service')
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
                                                          if (businessType != 'service')
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
                                        readOnly: (controller.createFromChallan.value && controller.selectedCustomerForInvoice.value.isNotEmpty),
                                        initialValue: item.description,
                                        decoration: InputDecoration(
                                          labelText: 'Item Description',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          filled: (controller.createFromChallan.value && controller.selectedCustomerForInvoice.value.isNotEmpty),
                                          fillColor: (controller.createFromChallan.value && controller.selectedCustomerForInvoice.value.isNotEmpty)
                                              ? Colors.grey.shade200
                                              : null,
                                        ),
                                        onChanged: (value) {
                                          if (controller.createFromChallan.value && controller.selectedCustomerForInvoice.value.isNotEmpty) return;
                                          controller.updateItem(index, description: value);
                                        },
                                      ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 12),

                              if (businessType == 'service' || businessType == 'client')
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.description_outlined, size: 14, color: Colors.blue.shade600),
                                          SizedBox(width: 6),
                                          Text(
                                            'Service Details',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade600,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        key: ValueKey('desc_${item.itemId}_$index'),
                                        initialValue: item.descriptionController == null ? (item.description ?? '') : null,
                                        controller: item.descriptionController,
                                        decoration: InputDecoration(
                                          labelText: 'Service Description',
                                          labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
                                          ),
                                          filled: true,
                                          fillColor: Colors.blue.shade50.withOpacity(0.3),
                                          alignLabelWithHint: true,
                                          hintText: item.itemName.isEmpty
                                              ? 'Select an item first'
                                              : 'Add detailed description',
                                          hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        ),
                                        maxLines: 3,
                                        minLines: 1,
                                        style: TextStyle(fontSize: 13),
                                        onChanged: (value) {
                                          controller.updateItemDescription(index, value);
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                              if (!isFromChallan && controller.invoiceItems.length > 1)
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
                                      child: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 20),
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    tooltip: 'Remove Item',
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(height: 12),

                          // Price and Quantity
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'price'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      height: 40,
                                      child: TextFormField(
                                        controller: controller.getPriceController(index, initialValue: item.rate),
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          filled: isFromChallan,
                                          fillColor: isFromChallan ? Colors.grey.shade200 : null,
                                        ),
                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                        onChanged: (value) {
                                          if (isFromChallan) return;
                                          double? price = double.tryParse(value);
                                          if (price != null && price >= 0) {
                                            controller.updateItem(index, rate: price);
                                          }
                                        },
                                        readOnly: isFromChallan,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Spacer(),

                              // if (businessType != 'client') ...[
                              //   SizedBox(width: 12),
                              //   Expanded(
                              //     flex: 2,
                              //     child: Column(
                              //       crossAxisAlignment: CrossAxisAlignment.start,
                              //       children: [
                              //         Text(
                              //           item.unit != null && item.unit!.isNotEmpty
                              //               ? 'Qty (${item.unit})'
                              //               :'Qty',
                              //           style: TextStyle(
                              //             fontSize: 12,
                              //             color: Colors.grey.shade600,
                              //           ),
                              //         ),
                              //
                              //         SizedBox(height: 4),
                              //         Obx(() {
                              //           if (controller.isEditMode.value) {
                              //             return Container(
                              //               height: 40,
                              //               child: TextFormField(
                              //                 key: ValueKey('qty_edit_${item.itemId}_$index'),
                              //                 controller: controller.getQuantityController(index, initialValue: item.quantity),
                              //                 textAlign: TextAlign.center,
                              //                 decoration: InputDecoration(
                              //                   contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              //                   border: OutlineInputBorder(
                              //                     borderRadius: BorderRadius.circular(6),
                              //                   ),
                              //                   suffixText: item.unit,
                              //                   suffixStyle: TextStyle(fontSize: 10, color: Colors.grey),
                              //                 ),
                              //                 keyboardType: TextInputType.numberWithOptions(decimal: true),
                              //                 onChanged: (value) {
                              //                   double? qty = double.tryParse(value);
                              //                   if (qty == null || qty <= 0) return;
                              //
                              //                   if (item.unit?.toLowerCase() == "pcs" || item.unit?.toLowerCase() == "box") {
                              //                     if (qty % 1 != 0) {
                              //                       Get.snackbar(
                              //                         "Invalid Qty",
                              //                         "You can only enter whole numbers for PCS items.",
                              //                         snackPosition: SnackPosition.BOTTOM,
                              //                       );
                              //                       return;
                              //                     }
                              //                   }
                              //
                              //                   controller.updateItem(
                              //                     index,
                              //                     quantity: qty,
                              //                     rate: item.rate,
                              //                     unit: item.unit,
                              //                   );
                              //                 },
                              //               ),
                              //             );
                              //           }
                              //           else {
                              //             final showQuantity = (controller.createFromChallan.value &&
                              //                 controller.selectedCustomerForInvoice.value.isNotEmpty) ||
                              //                 controller.isFromQuotation.value;
                              //
                              //             return Container(
                              //               height: 40,
                              //               child: TextFormField(
                              //                 key: ValueKey('qty_create_$index'),
                              //                 initialValue: showQuantity ? item.quantity.toString() : null,
                              //                 textAlign: TextAlign.center,
                              //                 decoration: InputDecoration(
                              //                   contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              //                   border: OutlineInputBorder(
                              //                     borderRadius: BorderRadius.circular(6),
                              //                   ),
                              //                 ),
                              //                 keyboardType: TextInputType.numberWithOptions(decimal: true),
                              //                 onChanged: (value) {
                              //                   double? qty = double.tryParse(value);
                              //                   if (qty == null || qty <= 0) return;
                              //
                              //                   if (item.unit?.toLowerCase() == "pcs") {
                              //                     if (qty % 1 != 0) {
                              //                       Get.snackbar(
                              //                         "Invalid Qty",
                              //                         "You can only enter whole numbers for PCS items.",
                              //                         snackPosition: SnackPosition.BOTTOM,
                              //                       );
                              //                       return;
                              //                     }
                              //                   }
                              //
                              //                   controller.updateItem(
                              //                     index,
                              //                     quantity: qty,
                              //                     rate: item.rate,
                              //                     unit: item.unit,
                              //                   );
                              //                 },
                              //               ),
                              //             );
                              //           }
                              //         }),
                              //
                              //       ],
                              //     ),
                              //   ),
                              // ],
                              if (businessType != 'client') ...[
                                SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.unit != null && item.unit!.isNotEmpty
                                            ? 'Qty (${item.unit})'
                                            : 'Qty',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Obx(() {
                                        // Get available stock for this item
                                        double? availableStock;
                                        bool isProductBusiness = businessType != 'service' && businessType != 'client';

                                        if (isProductBusiness && item.itemId != null && item.itemId!.isNotEmpty) {
                                          final masterItem = controller.itemList.firstWhereOrNull(
                                                  (e) => e.itemId == item.itemId
                                          );
                                          if (masterItem != null) {
                                            availableStock = (masterItem.currentStock ?? 0.0).toDouble();
                                            // DEBUG: Print stock info
                                            print("🔍 Item: ${item.itemName}, ItemID: ${item.itemId}");
                                            print("📦 Available Stock: $availableStock ${item.unit}");
                                          } else {
                                            print("❌ Master item not found for ItemID: ${item.itemId}");
                                          }
                                        } else {
                                          print("ℹ️ Stock check skipped - Business: $businessType, ItemID: ${item.itemId}");
                                        }

                                        // ==========================================================
                                        // 1. EDIT MODE SECTION
                                        // ==========================================================
                                        if (controller.isEditMode.value) {
                                          return Container(
                                            height: 40,
                                            child: TextFormField(
                                              key: ValueKey('qty_edit_${item.itemId}_$index'),
                                              controller: controller.getQuantityController(index, initialValue: item.quantity,),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 8,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                suffixText: item.unit,
                                                suffixStyle: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                ),
                                                // Show available stock hint
                                                hintText: availableStock != null
                                                    ? 'stocks: ${availableStock.toStringAsFixed(availableStock % 1 == 0 ? 0 : 2)}'
                                                    : null,
                                                hintStyle: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                              ],
                                              onChanged: (value) {
                                                print("📝 Quantity input changed: $value");

                                                if (value.isEmpty) {
                                                  // Allow clearing the field
                                                  controller.itemsWithStockViolation.remove(index);
                                                  controller.violationMessages.remove(index);
                                                  return;
                                                }

                                                double? qty = double.tryParse(value);
                                                print("🔢 Parsed quantity: $qty");


                                                // Validate quantity
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

                                                // Check for whole numbers for PCS/BOX units
                                                if (item.unit?.toLowerCase() == "pcs" ||
                                                    item.unit?.toLowerCase() == "box") {
                                                  if (qty % 1 != 0) {
                                                    Get.snackbar(
                                                      "Invalid Quantity",
                                                      "You can only enter whole numbers for ${item.unit} items.",
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      backgroundColor: Colors.orange.shade700,
                                                      colorText: Colors.white,
                                                      duration: Duration(seconds: 2),
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

                                                // ✅ STOCK CHECK LOGIC (EDIT MODE)
                                                print("🔍 Stock Check - Available: $availableStock, Entered: $qty");

                                                if (availableStock != null && availableStock > 0) {
                                                  if (qty > availableStock) {
                                                    print("❌ STOCK EXCEEDED! Available: $availableStock, Entered: $qty");

                                                    controller.itemsWithStockViolation.add(index);
                                                    controller.violationMessages[index] =
                                                    "${item.itemName}: Only ${availableStock.toStringAsFixed(availableStock % 1 == 0 ? 0 : 2)} ${item.unit ?? ''} available";

                                                    Get.snackbar(
                                                      "❌ Stock Limit Exceeded",
                                                      "Only ${availableStock.toStringAsFixed(availableStock % 1 == 0 ? 0 : 2)} ${item.unit ?? ''} available in stock.\nYou entered: $qty ${item.unit ?? ''}",
                                                      snackPosition: SnackPosition.TOP,
                                                      backgroundColor: Colors.red.shade700,
                                                      colorText: Colors.white,
                                                      duration: Duration(seconds: 3),
                                                      margin: EdgeInsets.all(10),
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
                                                    return; // IMPORTANT: Exit here to prevent update
                                                  } else {
                                                    print("✅ Stock check passed - Quantity within limit");
                                                    controller.itemsWithStockViolation.remove(index);
                                                    controller.violationMessages.remove(index);
                                                  }
                                                } else {
                                                  print("⚠️ Stock check skipped - availableStock is null or zero");
                                                  controller.itemsWithStockViolation.remove(index);
                                                  controller.violationMessages.remove(index);
                                                }

                                                // Update if validation passes
                                                print("✅ Updating item with quantity: $qty");
                                                controller.updateItem(
                                                  index,
                                                  quantity: qty,
                                                  rate: item.rate,
                                                  unit: item.unit,
                                                );
                                              },
                                            ),
                                          );
                                        }


                                        // CREATE MODE SECTION
                                        else {
                                          final showQuantity = (controller.createFromChallan.value &&
                                              controller.selectedCustomerForInvoice.value.isNotEmpty) ||
                                              controller.isFromQuotation.value;

                                          return Container(
                                            height: 40,
                                            child: TextFormField(
                                              key: ValueKey('qty_create_$index'),
                                              //key: ValueKey('qty_create_${item.itemId}_$index}_${controller.invoiceItems.length}'),
                                              //initialValue: showQuantity ? item.quantity.toString() : null,
                                              //controller: controller.getQuantityController(index),
                                              controller: controller.getQuantityController(index, initialValue: showQuantity ? item.quantity : null,), // ✅ USE CONTROLLER
                                              readOnly: isFromChallan,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 8,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                suffixText: item.unit,
                                                suffixStyle: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                ),
                                                hintText: availableStock != null
                                                    ? 'Stock: ${availableStock.toStringAsFixed(availableStock % 1 == 0 ? 0 : 2)}'
                                                    : null,
                                                hintStyle: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.orange,
                                                ),
                                                filled: isFromChallan,
                                                fillColor: isFromChallan ? Colors.grey.shade200 : null,
                                              ),
                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                              ],
                                              onChanged: (value) {
                                                if (isFromChallan) return;
                                                print("📝 Quantity input changed: $value for item index: $index");

                                                if (value.isEmpty) {
                                                  // ✅ Clear violation for this specific item
                                                  controller.itemsWithStockViolation.remove(index);
                                                  controller.violationMessages.remove(index);
                                                  return;
                                                }

                                                double? qty = double.tryParse(value);
                                                print("🔢 Parsed quantity: $qty");

                                                // Validate quantity
                                                if (qty == null || qty <= 0) {
                                                  Get.snackbar(
                                                    "Invalid Quantity",
                                                    "Please enter a valid quantity greater than 0",
                                                    snackPosition: SnackPosition.BOTTOM,
                                                    backgroundColor: Colors.orange.shade700,
                                                    colorText: Colors.white,
                                                    duration: Duration(seconds: 2),
                                                  );
                                                  // ✅ Mark THIS item as having violation
                                                  controller.itemsWithStockViolation.add(index);
                                                  controller.violationMessages[index] = "Invalid quantity";
                                                  return;
                                                }

                                                // Check for whole numbers for PCS units
                                                if (item.unit?.toLowerCase() == "pcs" || item.unit?.toLowerCase() == "box") {
                                                  if (qty % 1 != 0) {
                                                    Get.snackbar(
                                                      "Invalid Quantity",
                                                      "You can only enter whole numbers for ${item.unit} items.",
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      backgroundColor: Colors.orange.shade700,
                                                      colorText: Colors.white,
                                                      duration: Duration(seconds: 2),
                                                    );
                                                    // ✅ Mark THIS item as having violation
                                                    controller.itemsWithStockViolation.add(index);
                                                    controller.violationMessages[index] = "Must be whole number";
                                                    return;
                                                  }
                                                }

                                                // ✅ CRITICAL STOCK CHECK
                                                print("🔍 Stock Check - Item $index - Available: $availableStock, Entered: $qty");

                                                if (availableStock != null && availableStock > 0) {
                                                  if (qty > availableStock) {
                                                    print("❌ STOCK EXCEEDED! Item $index - Available: $availableStock, Entered: $qty");

                                                    // ✅ Mark THIS item as having violation
                                                    controller.itemsWithStockViolation.add(index);
                                                    controller.violationMessages[index] =
                                                    "${item.itemName}: Only ${availableStock.toStringAsFixed(availableStock % 1 == 0 ? 0 : 2)} ${item.unit ?? ''} available";

                                                    Get.snackbar(
                                                      "❌ Stock Limit Exceeded",
                                                      "Only ${availableStock.toStringAsFixed(availableStock % 1 == 0 ? 0 : 2)} ${item.unit ?? ''} available in stock.\nYou entered: $qty ${item.unit ?? ''}",
                                                      snackPosition: SnackPosition.TOP,
                                                      backgroundColor: Colors.red.shade700,
                                                      colorText: Colors.white,
                                                      duration: Duration(seconds: 4),
                                                      margin: EdgeInsets.all(10),
                                                      icon: Icon(Icons.warning_amber_rounded, color: Colors.white),
                                                    );

                                                    return; // ✅ STOP - DO NOT UPDATE
                                                  } else {
                                                    print("✅ Stock check passed for item $index - Quantity within limit");
                                                    // ✅ Clear violation for THIS item
                                                    controller.itemsWithStockViolation.remove(index);
                                                    controller.violationMessages.remove(index);
                                                  }
                                                } else {
                                                  print("⚠️ Stock check skipped for item $index");
                                                  // ✅ Clear violation for THIS item
                                                  controller.itemsWithStockViolation.remove(index);
                                                  controller.violationMessages.remove(index);
                                                }

                                                // Update if validation passes
                                                print("✅ Updating item $index with quantity: $qty");
                                                controller.updateItem(
                                                  index,
                                                  quantity: qty,
                                                  rate: item.rate,
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
                              ]
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),




                  if (!isFromChallan) ...[
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.addNewItem,
                        icon: Icon(Icons.add_circle_outline, size: 20),
                        label: Text('add_another_item'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tealColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],

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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'calculations'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: controller.isEditMode.value
                    ? Colors.orange.shade700
                    : AppColors.tealColor,
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
            Obx((){
              if (controller.invoiceType.value == InvoiceType.invoice){
                return  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Divider(),
                    Text("payment_status".tr),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
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
                    Obx(() {
                      if (controller.paymentStatus.value == 'Partial') {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Text(
                              "Received Amount",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: controller.receivedAmountController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.currency_rupee, size: 20),
                                hintText: 'Enter received amount',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (controller.paymentStatus.value == 'Partial') {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter received amount';
                                  }
                                  double? amount = double.tryParse(value);
                                  if (amount == null || amount <= 0) {
                                    return 'Please enter a valid amount';
                                  }
                                  if (amount > controller.totalAmount.value) {
                                    return 'Cannot exceed total amount';
                                  }
                                }
                                return null;
                              },
                              onChanged: (value) {
                                controller.updateReceivedAmount(value);
                              },
                            ),
                            SizedBox(height: 12),

                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pending Amount:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                  Obx(() => Text(
                                    '₹${AppUtil.formatCurrency(controller.pendingAmount.value)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.orange.shade800,
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return SizedBox.shrink();
                    }),

                    Obx(() {
                      if (controller.paymentStatus.value == 'Paid') {
                        return Column(
                          children: [
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Fully Paid',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else if (controller.paymentStatus.value == 'Pending') {
                        return Column(
                          children: [
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.pending, color: Colors.red.shade700, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Pending Amount:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '₹${AppUtil.formatCurrency(controller.totalAmount.value)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.red.shade800,
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
                color: controller.isEditMode.value
                    ? Colors.orange.shade700
                    : AppColors.tealColor,
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

  // Widget _buildActionButtons() {
  //   return Obx(() => Row(
  //     children: [
  //       Expanded(
  //         flex: 2,
  //         child: OutlinedButton(
  //           onPressed: controller.isLoading.value ? null : () => Get.back(),
  //           style: OutlinedButton.styleFrom(
  //             padding: EdgeInsets.symmetric(vertical: 12),
  //           ),
  //           child: Text('Cancel'),
  //         ),
  //       ),
  //       SizedBox(width: 8),
  //
  //       Expanded(
  //         flex: 4,
  //         child: ElevatedButton(
  //           onPressed: controller.isLoading.value ? null : () => controller.saveInvoice(isDraft: false),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: controller.isEditMode.value
  //                 ? Colors.orange.shade700
  //                 : AppColors.tealColor,
  //             padding: EdgeInsets.symmetric(vertical: 12),
  //           ),
  //           child: Text(
  //             controller.isEditMode.value
  //                 ? 'update_invoice'.tr
  //                 : controller.invoiceType.value == InvoiceType.invoice
  //                 ? 'create_invoice'.tr
  //                 : 'create_quotation'.tr,
  //             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
  //           ),
  //         ),
  //       ),
  //     ],
  //   ));
  // }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // ✅ Show warning banner with ALL violations
        Obx(() {
          if (controller.hasAnyStockViolation) {
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(8),
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
                          '⚠️ Cannot Create Invoice',
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
                  // ✅ List ALL items with violations
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

        // Buttons Row
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
                // ✅ Disable if ANY item has violation
                onPressed: (controller.isLoading.value || controller.hasAnyStockViolation)
                    ? null
                    : () => controller.saveInvoice(isDraft: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isEditMode.value
                      ? Colors.orange.shade700
                      : AppColors.tealColor,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: Text(
                  controller.isEditMode.value
                      ? 'update_invoice'.tr
                      : controller.invoiceType.value == InvoiceType.invoice
                      ? 'create_invoice'.tr
                      : 'create_quotation'.tr,
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
              Row(
                children: [
                  Checkbox(
                    value: controller.createFromChallan.value,
                    onChanged: (value) {
                      controller.createFromChallan.value = value ?? false;
                      if (value == true) {
                        controller.loadChallansForInvoice();
                      } else {
                        controller.selectedCustomerForInvoice.value = '';
                        controller.selectedCustomerChallans.clear();
                      }
                    },
                  ),
                  Text(
                    'create_invoice_from_challan'.tr,
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

              if (controller.createFromChallan.value) ...[
                SizedBox(height: 16),

                Text(
                  'select_date_range'.tr,
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Obx(() {
                          final customersWithChallans = controller.customerNames.where((customerName) {
                            final count = controller.allChallans.where((challan) =>
                            challan.customerName == customerName &&
                                challan.status?.toLowerCase() == "inprogress" &&
                                challan.challanDate != null &&
                                !challan.challanDate!.isBefore(controller.selectedFromDate.value) &&
                                !challan.challanDate!.isAfter(controller.selectedToDate.value))
                                .length;
                            return count > 0;
                          }).toList();

                          if (customersWithChallans.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 32),
                                  SizedBox(height: 8),
                                  Text(
                                    'No customers with in-progress challans in selected date range',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return DropdownButton<String>(
                            value: controller.selectedCustomerForInvoice.value.isEmpty
                                ? null
                                : controller.selectedCustomerForInvoice.value,
                            isExpanded: true,
                            hint: Text('Select Customer (${customersWithChallans.length} available)'),
                            underline: SizedBox(),
                            items: [
                              DropdownMenuItem(
                                value: null,
                                child: Text('Select Customer'),
                              ),
                              ...customersWithChallans.map((customerName) {
                                final challanCount = controller.allChallans
                                    .where((challan) =>
                                challan.customerName == customerName &&
                                    challan.status?.toLowerCase() == "inprogress" &&
                                    challan.challanDate != null &&
                                    !challan.challanDate!.isBefore(controller.selectedFromDate.value) &&
                                    !challan.challanDate!.isAfter(controller.selectedToDate.value))
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
                                          color: Colors.green.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: controller.selectCustomerForInvoice,
                          );
                        }),
                      ),

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

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Invoice'),
        content: Text('Are you sure you want to delete this invoice? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // controller.deleteInvoice();
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



///mobile working
// class NewInvoiceScreen extends GetView<NewInvoiceController> {
//   static const String pageId = '/NewInvoiceScreen';
//
//   const NewInvoiceScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Obx(() => Text(
//           controller.isEditMode.value
//               ? 'edit_invoice'.tr
//               : controller.invoiceType.value == InvoiceType.invoice
//               ? 'new_invoice'.tr
//               : 'new_quotation'.tr,
//         )),
//         backgroundColor: controller.isEditMode.value
//             ? Colors.orange.shade700
//             :         AppColors.tealColor,
//         foregroundColor: Colors.white,
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
//                     Obx(() {
//                       if (!controller.isEditMode.value  && !controller.isFromQuotation.value) {
//                         return Column(
//                           children: [
//                             _buildChallanToInvoiceSection(),
//                             SizedBox(height: 16),
//                           ],
//                         );
//                       }
//                       return SizedBox.shrink();
//                     }),
//                     _buildInvoiceDetailsCard(),
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
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                             controller.isEditMode.value
//                                 ? Colors.orange.shade700
//                                 : Colors.blue.shade700
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         controller.isEditMode.value ? 'Updating...' : 'Loading...',
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
//           tooltip: 'Delete Invoice',
//         ),
//         SizedBox(width: 8),
//       ],
//     );
//   }
//
//   Widget _buildInvoiceDetailsCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Obx(() => Text(
//                   controller.isEditMode.value ? 'invoice_details'.tr : '${controller.invoiceType.value.name} Details'.tr,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: controller.isEditMode.value
//                         ? Colors.orange.shade700
//                         : AppColors.tealColor,
//                   ),
//                 )),
//                 Spacer(),
//                 Obx(() => controller.isEditMode.value
//                     ? Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.shade100,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.orange.shade300),
//                   ),
//                   child: Text(
//                     'edit_mode'.tr,
//                     style: TextStyle(
//                       color: Colors.orange.shade800,
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
//
//             Obx(() {
//               if (!controller.isEditMode.value && !controller.createFromChallan.value && !controller.isFromQuotation.value) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'invoice_type'.tr,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.tealColor,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     _buildDocumentTypeSelection(),
//                     SizedBox(height: 16),
//                   ],
//                 );
//               }
//               return SizedBox();
//             }),
//
//             // Invoice Number - This works because it's wrapped in Obx
//             Obx(() => TextFormField(
//               controller: controller.invoiceNumberController,
//               decoration: InputDecoration(
//                 labelText: controller.isEditMode.value
//                     ? 'Invoice Number'
//                     : '${controller.invoiceType.value.name} Number',
//                 prefixIcon: Icon(Icons.receipt_long),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               readOnly: true,
//               style: TextStyle(
//                 color: controller.isEditMode.value ? Colors.grey.shade600 : Colors.black87,
//               ),
//             )),
//
//             SizedBox(height: 16),
//
//             // ✅ NEW: Invoice Date and Payment Due Date in Row
//             Row(
//               children: [
//                 // Invoice Date - Wrap this specific field in Obx
//                 Expanded(
//                   child: Obx(() => TextFormField(
//                     controller: controller.invoiceDateController,
//                     decoration: InputDecoration(
//                       labelText: '${controller.invoiceType.value.name} Date',
//                       prefixIcon: Icon(Icons.calendar_today, size: 20),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                     ),
//                     readOnly: true,
//                     onTap: controller.selectInvoiceDate,
//                     style: TextStyle(fontSize: 14),
//                   )),
//                 ),
//
//                 SizedBox(width: 12),
//
//                 // Payment Due Date - Wrap this specific field in Obx
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Obx(() => TextFormField(
//                         controller: controller.paymentDueDateController,
//                         decoration: InputDecoration(
//                           labelText: controller.invoiceType.value == InvoiceType.invoice
//                               ? 'Due Date'
//                               : 'Valid Until',
//                           prefixIcon: Icon(Icons.event_available, size: 20),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                         ),
//                         readOnly: true,
//                         onTap: controller.selectPaymentDueDate,
//                         style: TextStyle(fontSize: 14),
//                       )),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//
//             // ✅ Show days until due (optional info) - This also needs to be reactive for quotation
//             Obx(() {
//               if (!controller.isEditMode.value && !controller.isFromQuotation.value) {
//                 final daysUntilDue = controller.paymentDueDate.value.difference(controller.invoiceDate.value).inDays;
//
//                 // Update this to show different messages for invoice vs quotation
//                 if (controller.invoiceType.value == InvoiceType.invoice) {
//                   return Padding(
//                     padding: EdgeInsets.only(top: 8),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.info_outline, size: 14, color: Colors.blue.shade700),
//                           SizedBox(width: 6),
//                           Text(
//                             'Payment due in $daysUntilDue days',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.blue.shade700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 } else {
//                   // For quotation
//                   return Padding(
//                     padding: EdgeInsets.only(top: 8),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.shade50,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.info_outline, size: 14, color: Colors.orange.shade700),
//                           SizedBox(width: 6),
//                           Text(
//                             'Quotation valid for $daysUntilDue days',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.orange.shade700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }
//               }
//               return SizedBox.shrink();
//             }),
//
//             Obx(() {
//               if (controller.isEditMode.value && controller.originalInvoiceData != null) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 12),
//                     Divider(),
//                     Text(
//                       'original_invoice_information:'.tr,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey.shade600,
//                         fontSize: 14,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Date: ${controller.formatOriginalInvoiceDate()}',
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
//             // Add this in _buildInvoiceDetailsCard() after the invoice type section
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
//                               '🔒 Demo Mode: Invoice dates limited to 1990-1992',
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
//                     SizedBox(height: 12),
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
//   Widget _buildDocumentTypeSelection() {
//     return Row(
//       children: [
//         _buildDocumentTypeChip(InvoiceType.invoice, Icons.receipt, Colors.blue),
//         SizedBox(width: 8),
//         _buildDocumentTypeChip(InvoiceType.quotation, Icons.description, Colors.orange),
//       ],
//     );
//   }
//
//   Widget _buildDocumentTypeChip(InvoiceType type, IconData icon, Color color) {
//     return Obx(() {
//       final isSelected = controller.invoiceType.value == type;
//       return ChoiceChip(
//         label: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 16, color: isSelected ? Colors.white : color),
//             SizedBox(width: 4),
//             Text(type.name),
//           ],
//         ),
//         selected: isSelected,
//         onSelected: (_) => controller.setInvoiceType(type),
//         selectedColor: color,
//         backgroundColor: color.withOpacity(0.1),
//         labelStyle: TextStyle(
//           color: isSelected ? Colors.white : color,
//           fontWeight: FontWeight.bold,
//         ),
//       );
//     });
//   }
//
//   Widget _buildCustomerSection() {
//     return Obx(() {
//       if (controller.createFromChallan.value && controller.selectedCustomerForInvoice.value.isNotEmpty) {
//         return SizedBox.shrink();
//       }
//
//       return Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     'customer_information'.tr,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: controller.isEditMode.value
//                           ? Colors.orange.shade700
//                           : AppColors.tealColor,
//                     ),
//                   ),
//                   Text(
//                     ' *',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red,
//                     ),
//                   ),
//                   Spacer(),
//                   Obx(() => !controller.isEditMode.value ? IconButton(
//                     onPressed: controller.toggleCustomerForm,
//                     icon: Icon(
//                       controller.showCustomerForm.value
//                           ? Icons.person
//                           : Icons.person_add,
//                       color: controller.isEditMode.value
//                           ? Colors.orange.shade700
//                           : AppColors.tealColor,
//                     ),
//                     tooltip: controller.showCustomerForm.value
//                         ? 'Select from existing customers'
//                         : 'Add new customer manually',
//                   ) : SizedBox()),
//                 ],
//               ),
//               SizedBox(height: 16),
//
//               Obx(() {
//                 if (controller.isEditMode.value) {
//                   return _buildEditModeCustomerInfo();
//                 }
//                 else {
//                   if (controller.customers.isEmpty && !controller.showCustomerForm.value) {
//                     return Column(
//                       children: [
//                         Text(
//                           'No customers found. Please add a customer.',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         SizedBox(height: 12),
//                         ElevatedButton(
//                           onPressed: controller.toggleCustomerForm,
//                           child: Text('add_new_customer'.tr),
//                         ),
//                       ],
//                     );
//                   } else if (!controller.showCustomerForm.value) {
//                     // ✅ NEW: Use SearchableDropdown for customers
//                     return SearchableDropdown<Map<String, dynamic>>(
//                       value: controller.selectedCustomerId.value.isEmpty
//                           ? null
//                           : controller.customers.firstWhereOrNull(
//                               (c) => c['customerId']?.toString() == controller.selectedCustomerId.value
//                       ),
//                       items: controller.customers,
//                       itemLabel: (customer) => (customer['name'] ?? 'Unknown Customer').toString().toUpperCase(),
//                       hintText: 'Select Customer',
//                       searchHintText: 'Search customers by name...',
//                       itemBuilder: (customer) => Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             (customer['name'] ?? 'Unknown').toString().toUpperCase(),
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                             ),
//                           ),
//                           if (customer['mobile1'] != null && customer['mobile1'].toString().isNotEmpty)
//                             Padding(
//                               padding: EdgeInsets.only(top: 4),
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.phone, size: 12, color: Colors.grey.shade600),
//                                   SizedBox(width: 4),
//                                   Text(
//                                     customer['mobile1'].toString(),
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey.shade600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                         ],
//                       ),
//                       onChanged: (selectedCustomer) {
//                         if (selectedCustomer == null) {
//                           controller.selectCustomer(null);
//                         } else {
//                           controller.selectCustomer(selectedCustomer);
//                         }
//                       },
//                     );
//                   } else {
//                     return _buildNewCustomerForm();
//                   }
//                 }
//               }),
//             ],
//           ),
//         ),
//       );
//     });
//   }
//
//   Widget _buildEditModeCustomerInfo() {
//     return Column(
//       children: [
//         if (controller.originalInvoiceData != null) ...[
//
//         ],
//         _buildNewCustomerForm(),
//       ],
//     );
//   }
//
//   Widget _buildNewCustomerForm() {
//     return Column(
//       children: [
//         if (!controller.isEditMode.value) ...[
//           SizedBox(height: 12),
//           Text(
//             'add_new_customer',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.orange.shade700,
//             ),
//           ),
//           SizedBox(height: 12),
//         ],
//         TextFormField(
//           controller: controller.customerNameController,
//           decoration: InputDecoration(
//             labelText: 'customer_name'.tr,
//             prefixIcon: Icon(Icons.person),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
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
//                   prefixIcon: Icon(Icons.phone),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
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
//                   prefixIcon: Icon(Icons.email),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
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
//             prefixIcon: Icon(Icons.location_on),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//           maxLines: 2,
//         ),
//       ],
//     );
//   }
//
//
//   Widget _buildItemsSection() {
//     return Obx(() {
//       final isFromChallan = controller.createFromChallan.value &&
//           controller.selectedCustomerForInvoice.value.isNotEmpty;
//
//       // ✅ Check Business Type
//       final businessType = AppConstants.businessType?.toLowerCase() ?? '';
//
//       return Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     'invoice_items'.tr,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: controller.isEditMode.value
//                           ? Colors.orange.shade700
//                           : AppColors.tealColor,
//                     ),
//                   ),
//                   Spacer(),
//                   if (isFromChallan)
//                     Chip(
//                       label: Text('from_challan'.tr, style: TextStyle(color: Colors.white)),
//                       backgroundColor: Colors.purple.shade700,
//                     )
//                 ],
//               ),
//               SizedBox(height: 16),
//
//               Obx(() {
//                 if (controller.isEditMode.value && controller.originalItemsCount > 0) {
//                   return Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.orange.shade200),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.history, size: 16, color: Colors.orange.shade700),
//                         SizedBox(width: 8),
//                         Text(
//                           'Originally had ${controller.originalItemsCount} items',
//                           style: TextStyle(
//                             color: Colors.orange.shade800,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//                 return SizedBox();
//               }),
//               SizedBox(height: 12),
//
//               ///temparory Close items Header
//               // Container(
//               //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               //   decoration: BoxDecoration(
//               //     gradient: LinearGradient(
//               //       colors: controller.isEditMode.value
//               //           ? [Colors.orange.shade100, Colors.orange.shade50]
//               //           : [Colors.blue.shade100, Colors.blue.shade50],
//               //       begin: Alignment.topLeft,
//               //       end: Alignment.bottomRight,
//               //     ),
//               //     borderRadius: BorderRadius.circular(8),
//               //     border: Border.all(
//               //       color: controller.isEditMode.value
//               //           ? Colors.orange.shade200
//               //           : Colors.blue.shade200,
//               //       width: 1.5,
//               //     ),
//               //   ),
//               //   child: Row(
//               //     children: [
//               //       Expanded(
//               //         flex: 5,
//               //         child: Text(
//               //           businessType == 'trading' ? 'Item Name' :
//               //           'Service',
//               //           style: TextStyle(
//               //             fontWeight: FontWeight.w700,
//               //             fontSize: 13,
//               //             color: controller.isEditMode.value
//               //                 ? Colors.orange.shade900
//               //                 : Colors.blue.shade900,
//               //             letterSpacing: 0.5,
//               //           ),
//               //         ),
//               //       ),
//               //       if (businessType == 'service' || businessType == 'client')
//               //         Expanded(
//               //           flex: 5,
//               //           child: Text(
//               //             'Service Description',
//               //             style: TextStyle(
//               //               fontWeight: FontWeight.w700,
//               //               fontSize: 13,
//               //               color: controller.isEditMode.value
//               //                   ? Colors.orange.shade900
//               //                   : Colors.blue.shade900,
//               //               letterSpacing: 0.5,
//               //             ),
//               //           ),
//               //         ),
//               //     ],
//               //   ),
//               // ),
//               //
//               // SizedBox(height: 8),
//               //
//               // // Sub-header for Price & Quantity
//               // Container(
//               //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               //   decoration: BoxDecoration(
//               //     color: Colors.grey.shade100,
//               //     borderRadius: BorderRadius.circular(6),
//               //     border: Border.all(color: Colors.grey.shade300),
//               //   ),
//               //   child: Row(
//               //     children: [
//               //       Expanded(
//               //         flex: 2,
//               //         child: Text(
//               //           'Price (₹)',
//               //           style: TextStyle(
//               //             fontWeight: FontWeight.w600,
//               //             fontSize: 12,
//               //             color: Colors.grey.shade700,
//               //           ),
//               //         ),
//               //       ),
//               //       if (businessType != 'client')
//               //         Expanded(
//               //           flex: 1,
//               //           child: Text(
//               //             'Quantity',
//               //             style: TextStyle(
//               //               fontWeight: FontWeight.w600,
//               //               fontSize: 12,
//               //               color: Colors.grey.shade700,
//               //             ),
//               //           ),
//               //         ),
//               //       Spacer(flex: businessType == 'client' ? 3 : 2),
//               //     ],
//               //   ),
//               // ),
//               // SizedBox(height: 12),
//
//               Obx(() => Column(
//                 children: [
//                   if (controller.itemList.isEmpty && !isFromChallan)
//                     Container(
//                       padding: EdgeInsets.all(16),
//                       margin: EdgeInsets.only(bottom: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.orange.shade200),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.info, color: Colors.orange.shade700),
//                           SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               'no_items_available'.tr,
//                               style: TextStyle(color: Colors.orange.shade800),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                   ...controller.invoiceItems.asMap().entries.map((entry) {
//                     int index = entry.key;
//                     InvoiceItem item = entry.value;
//
//                     return Container(
//                       margin: EdgeInsets.only(bottom: 16),
//                       padding: EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(color: Colors.grey.shade300, width: 1.5),
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.08),
//                             blurRadius: 8,
//                             offset: Offset(0, 2),
//                             spreadRadius: 1,
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // ✅ TOP ROW: Item Selector (50%) + Description (50%)
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // ✅ Item Selector - 50% width
//                               Expanded(
//                                 flex: 5,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Container(
//                                           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                           decoration: BoxDecoration(
//                                             color: Colors.blue.shade600,
//                                             borderRadius: BorderRadius.circular(4),
//                                           ),
//                                           child: Text(
//                                             '#${index + 1}',
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.white,
//                                               fontSize: 11,
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(width: 8),
//                                         Text(
//                                           businessType == 'trading' ? 'Item' : 'Service',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                             color: Colors.grey.shade600,
//                                             fontSize: 11,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 8),
//
//                                     // Item Dropdown/TextField
//                                     if (controller.itemList.isNotEmpty)
//                                       Builder(
//                                         builder: (context) {
//                                           final isFromChallan = controller.createFromChallan.value &&
//                                               controller.selectedCustomerForInvoice.value.isNotEmpty;
//
//                                           Item? currentItem;
//                                           try {
//                                             currentItem = controller.itemList.firstWhere(
//                                                     (i) => i.itemId == item.itemId
//                                             );
//                                           } catch (e) {
//                                             currentItem = null;
//                                           }
//
//                                           final isInactive = currentItem != null && !(currentItem.isActive ?? true);
//
//                                           // Show read-only field for inactive items from challan
//                                           if (isFromChallan && (isInactive || currentItem == null) && item.itemName.isNotEmpty) {
//                                             return Container(
//                                               height: 40,
//                                               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                                               decoration: BoxDecoration(
//                                                 border: Border.all(color: Colors.grey.shade300),
//                                                 borderRadius: BorderRadius.circular(6),
//                                               ),
//                                               child: Row(
//                                                 children: [
//                                                   Expanded(
//                                                     child: Text(
//                                                       item.itemName,
//                                                       style: TextStyle(fontSize: 14),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             );
//                                           }
//
//                                           final activeItems = controller.itemList.where((i) => i.isActive ?? true).toList();
//                                           Item? selectedItem;
//                                           try {
//                                             selectedItem = activeItems.firstWhere((element) => element.itemId == item.itemId);
//                                           } catch (e) {
//                                             selectedItem = null;
//                                           }
//
//                                           // ✅ NEW: Use SearchableDropdown for items
//                                           return SearchableDropdown<Item>(
//                                             value: selectedItem,
//                                             items: activeItems,
//                                             itemLabel: (item) => item.itemName.toUpperCase(),
//                                             hintText: 'Select Item',
//                                             searchHintText: 'Search items by name...',
//                                             // Inside _buildItemsSection -> SearchableDropdown -> itemBuilder
//
//                                             itemBuilder: (item) {
//                                               // Check stock
//                                               double currentStock = (item.currentStock ?? 0.0).toDouble();
//                                               bool isOutOfStock = currentStock <= 0;
//
//                                               return Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: [
//                                                   Row(
//                                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                     children: [
//                                                       Text(
//                                                         item.itemName.toUpperCase(),
//                                                         style: TextStyle(
//                                                           fontWeight: FontWeight.w600,
//                                                           fontSize: 14,
//                                                           // Grey out text if out of stock
//                                                           color: isOutOfStock ? Colors.grey : Colors.black87,
//                                                         ),
//                                                       ),
//                                                       // Show "Out of Stock" badge
//                                                       if (isOutOfStock && businessType != 'service')
//                                                         Container(
//                                                           padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                                           decoration: BoxDecoration(
//                                                             color: Colors.red.shade50,
//                                                             borderRadius: BorderRadius.circular(4),
//                                                             border: Border.all(color: Colors.red.shade200),
//                                                           ),
//                                                           child: Text(
//                                                             "NO STOCK",
//                                                             style: TextStyle(fontSize: 9, color: Colors.red.shade700, fontWeight: FontWeight.bold),
//                                                           ),
//                                                         ),
//                                                     ],
//                                                   ),
//                                                   if (item.price > 0)
//                                                     Padding(
//                                                       padding: EdgeInsets.only(top: 4),
//                                                       child: Row(
//                                                         children: [
//                                                           Icon(Icons.currency_rupee, size: 12, color: isOutOfStock ? Colors.grey : Colors.green.shade600),
//                                                           Text(
//                                                             '${item.price.toStringAsFixed(2)}',
//                                                             style: TextStyle(
//                                                               color: isOutOfStock ? Colors.grey : Colors.green.shade600,
//                                                               fontSize: 12,
//                                                               fontWeight: FontWeight.w500,
//                                                             ),
//                                                           ),
//                                                           SizedBox(width: 10),
//                                                           // Show Stock Count
//                                                           if (businessType != 'service')
//                                                             Text(
//                                                               'Stock: ${currentStock.toStringAsFixed(0)}', // Show current stock
//                                                               style: TextStyle(
//                                                                 fontSize: 11,
//                                                                 color: isOutOfStock ? Colors.red : Colors.grey.shade600,
//                                                                 fontWeight: isOutOfStock ? FontWeight.bold : FontWeight.normal,
//                                                               ),
//                                                             ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                 ],
//                                               );
//                                             },
//                                             onChanged: (selectedItem) {
//                                               if (selectedItem != null) {
//                                                 controller.selectRemoteItemForIndex(index, selectedItem);
//                                               }
//                                             },
//                                           );
//                                         },
//                                       ),
//
//                                     if (controller.itemList.isEmpty)
//                                       TextFormField(
//                                         initialValue: item.description,
//                                         decoration: InputDecoration(
//                                           labelText: 'Item Description',
//                                           border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(6),
//                                           ),
//                                           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                                         ),
//                                         onChanged: (value) {
//                                           controller.updateItem(index, description: value);
//                                         },
//                                       ),
//                                   ],
//                                 ),
//                               ),
//
//                               SizedBox(width: 12),
//
//                               // ✅ Service Description - 50% width (only for service/client business type)
//                               if (businessType == 'service' || businessType == 'client')
//                                 Expanded(
//                                   flex: 5,
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Icon(Icons.description_outlined, size: 14, color: Colors.blue.shade600),
//                                           SizedBox(width: 6),
//                                           Text(
//                                             'Service Details',
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               color: Colors.grey.shade600,
//                                               fontSize: 11,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(height: 8),
//                                       TextFormField(
//                                         key: ValueKey('desc_${item.itemId}_$index'),
//                                         initialValue: item.descriptionController == null ? (item.description ?? '') : null,
//                                         controller: item.descriptionController,
//                                         decoration: InputDecoration(
//                                           labelText: 'Service Description',
//                                           labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                                           border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(8),
//                                             borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(8),
//                                             borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
//                                           ),
//                                           focusedBorder: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(8),
//                                             borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
//                                           ),
//                                           filled: true,
//                                           fillColor: Colors.blue.shade50.withOpacity(0.3),
//                                           alignLabelWithHint: true,
//                                           hintText: item.itemName.isEmpty
//                                               ? 'Select an item first'
//                                               : 'Add detailed description',
//                                           hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
//                                           contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                                         ),
//                                         maxLines: 3,
//                                         minLines: 1,
//                                         style: TextStyle(fontSize: 13),
//                                         onChanged: (value) {
//                                           controller.updateItemDescription(index, value);
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//
//                               // Delete Button
//                               if (!isFromChallan && controller.invoiceItems.length > 1)
//                                 Container(
//                                   margin: EdgeInsets.only(top: 30),
//                                   child: IconButton(
//                                     onPressed: () => controller.removeItem(index),
//                                     icon: Container(
//                                       padding: EdgeInsets.all(6),
//                                       decoration: BoxDecoration(
//                                         color: Colors.red.shade50,
//                                         borderRadius: BorderRadius.circular(6),
//                                         border: Border.all(color: Colors.red.shade200),
//                                       ),
//                                       child: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 20),
//                                     ),
//                                     padding: EdgeInsets.zero,
//                                     constraints: BoxConstraints(),
//                                     tooltip: 'Remove Item',
//                                   ),
//                                 ),
//                             ],
//                           ),
//
//                           SizedBox(height: 12),
//
//                           // ✅ BOTTOM ROW: Price and Quantity
//                           Row(
//                             children: [
//                               // Price Column
//                               Expanded(
//                                 flex: 2,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'price'.tr,
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey.shade600,
//                                       ),
//                                     ),
//                                     SizedBox(height: 4),
//                                     Container(
//                                       height: 40,
//                                       child: TextFormField(
//                                         controller: controller.getPriceController(index, initialValue: item.rate),
//                                         textAlign: TextAlign.center,
//                                         decoration: InputDecoration(
//                                           contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                                           border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(6),
//                                           ),
//                                         ),
//                                         keyboardType: TextInputType.numberWithOptions(decimal: true),
//                                         onChanged: (value) {
//                                           double? price = double.tryParse(value);
//                                           if (price != null && price >= 0) {
//                                             controller.updateItem(index, rate: price);
//                                           }
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//
//                               Spacer(),
//                               // ✅ Only show Quantity field if NOT client type
//                               if (businessType != 'client') ...[
//                                 SizedBox(width: 12),
//
//                                 // Quantity Column
//                                 Expanded(
//                                   flex: 2,
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         item.unit != null && item.unit!.isNotEmpty
//                                             ? 'Qty (${item.unit})' // Shows "Qty (PCS)"
//                                             :'Qty',
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.grey.shade600,
//                                         ),
//                                       ),
//                                       SizedBox(height: 4),
//                                       Obx(() {
//                                         if (controller.isEditMode.value) {
//                                           return Container(
//                                             height: 40,
//                                             child: TextFormField(
//                                               key: ValueKey('qty_edit_${item.itemId}_$index'),
//                                               controller: controller.getQuantityController(index, initialValue: item.quantity),
//                                               textAlign: TextAlign.center,
//                                               decoration: InputDecoration(
//                                                 contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                                                 border: OutlineInputBorder(
//                                                   borderRadius: BorderRadius.circular(6),
//                                                 ),
//                                                 // Optional: Add unit as suffix inside box too
//                                                 suffixText: item.unit,
//                                                 suffixStyle: TextStyle(fontSize: 10, color: Colors.grey),
//                                               ),
//                                               keyboardType: TextInputType.numberWithOptions(decimal: true),
//                                               onChanged: (value) {
//                                                 double? qty = double.tryParse(value);
//                                                 if (qty == null || qty <= 0) return;
//
//                                                 if (item.unit?.toLowerCase() == "pcs" || item.unit?.toLowerCase() == "box") {
//                                                   if (qty % 1 != 0) {
//                                                     Get.snackbar(
//                                                       "Invalid Qty",
//                                                       "You can only enter whole numbers for PCS items.",
//                                                       snackPosition: SnackPosition.BOTTOM,
//                                                     );
//                                                     return;
//                                                   }
//                                                 }
//
//                                                 controller.updateItem(
//                                                   index,
//                                                   quantity: qty,
//                                                   rate: item.rate,
//                                                   unit: item.unit,
//                                                 );
//                                               },
//                                             ),
//                                           );
//                                         } else {
//                                           final showQuantity = (controller.createFromChallan.value &&
//                                               controller.selectedCustomerForInvoice.value.isNotEmpty) ||
//                                               controller.isFromQuotation.value;
//
//                                           return Container(
//                                             height: 40,
//                                             child: TextFormField(
//                                               key: ValueKey('qty_create_$index'),
//                                               initialValue: showQuantity ? item.quantity.toString() : null,
//                                               textAlign: TextAlign.center,
//                                               decoration: InputDecoration(
//                                                 contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                                                 border: OutlineInputBorder(
//                                                   borderRadius: BorderRadius.circular(6),
//                                                 ),
//                                               ),
//                                               keyboardType: TextInputType.numberWithOptions(decimal: true),
//                                               onChanged: (value) {
//                                                 double? qty = double.tryParse(value);
//                                                 if (qty == null || qty <= 0) return;
//
//                                                 if (item.unit?.toLowerCase() == "pcs") {
//                                                   if (qty % 1 != 0) {
//                                                     Get.snackbar(
//                                                       "Invalid Qty",
//                                                       "You can only enter whole numbers for PCS items.",
//                                                       snackPosition: SnackPosition.BOTTOM,
//                                                     );
//                                                     return;
//                                                   }
//                                                 }
//
//                                                 controller.updateItem(
//                                                   index,
//                                                   quantity: qty,
//                                                   rate: item.rate,
//                                                   unit: item.unit,
//                                                 );
//                                               },
//                                             ),
//                                           );
//                                         }
//                                       }),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//
//                   if (!isFromChallan) ...[
//                     SizedBox(height: 16),
//                     Container(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: controller.addNewItem,
//                         icon: Icon(Icons.add_circle_outline, size: 20),
//                         label: Text('add_another_item'.tr),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.tealColor,
//                           foregroundColor: Colors.white,
//                           padding: EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//
//                   SizedBox(height: 16),
//                   Container(
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.green.shade200),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Total Items:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green.shade800,
//                           ),
//                         ),
//                         Text(
//                           '${controller.invoiceItems.length}',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green.shade800,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               )),
//             ],
//           ),
//         ),
//       );
//     });
//   }
//
//   Widget _buildCalculationsSection() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
//                 color: controller.isEditMode.value
//                     ? Colors.orange.shade700
//                     : AppColors.tealColor,
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
//            Obx((){
//              if (controller.invoiceType.value == InvoiceType.invoice){
//                return  Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: [
//                    SizedBox(height: 20),
//                    Divider(),
//                    Text("payment_status".tr),
//                    Row(
//                      children: [
//                        Expanded(
//                          child: Obx(() => Container(
//                            padding: EdgeInsets.symmetric(horizontal: 12),
//                            decoration: BoxDecoration(
//                              border: Border.all(color: Colors.grey.shade300),
//                              borderRadius: BorderRadius.circular(8),
//                            ),
//                            child: DropdownButton<String>(
//                              value: controller.paymentStatus.value,
//                              isExpanded: true,
//                              underline: SizedBox(),
//                              items: [
//                                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
//                                DropdownMenuItem(value: 'Paid', child: Text('Paid')),
//                                DropdownMenuItem(value: 'Partial', child: Text('Partial')),
//                              ],
//                              onChanged: (value) {
//                                if (value != null) {
//                                  controller.updatePaymentStatus(value);
//                                }
//                              },
//                            ),
//                          )),
//                        ),
//                      ],
//                    ),
//                    Obx(() {
//                      if (controller.paymentStatus.value == 'Partial') {
//                        return Column(
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          children: [
//                            SizedBox(height: 16),
//                            Text(
//                              "Received Amount",
//                              style: TextStyle(
//                                fontWeight: FontWeight.bold,
//                                fontSize: 14,
//                                color: Colors.grey.shade700,
//                              ),
//                            ),
//                            SizedBox(height: 8),
//                            TextFormField(
//                              controller: controller.receivedAmountController,
//                              decoration: InputDecoration(
//                                prefixIcon: Icon(Icons.currency_rupee, size: 20),
//                                hintText: 'Enter received amount',
//                                border: OutlineInputBorder(
//                                  borderRadius: BorderRadius.circular(8),
//                                ),
//                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                              ),
//                              keyboardType: TextInputType.numberWithOptions(decimal: true),
//                              validator: (value) {
//                                if (controller.paymentStatus.value == 'Partial') {
//                                  if (value == null || value.isEmpty) {
//                                    return 'Please enter received amount';
//                                  }
//                                  double? amount = double.tryParse(value);
//                                  if (amount == null || amount <= 0) {
//                                    return 'Please enter a valid amount';
//                                  }
//                                  if (amount > controller.totalAmount.value) {
//                                    return 'Cannot exceed total amount';
//                                  }
//                                }
//                                return null;
//                              },
//                              onChanged: (value) {
//                                controller.updateReceivedAmount(value);
//                              },
//                            ),
//                            SizedBox(height: 12),
//
//                            // Pending Amount Display
//                            Container(
//                              padding: EdgeInsets.all(12),
//                              decoration: BoxDecoration(
//                                color: Colors.orange.shade50,
//                                borderRadius: BorderRadius.circular(8),
//                                border: Border.all(color: Colors.orange.shade200),
//                              ),
//                              child: Row(
//                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                children: [
//                                  Text(
//                                    'Pending Amount:',
//                                    style: TextStyle(
//                                      fontWeight: FontWeight.bold,
//                                      color: Colors.orange.shade800,
//                                    ),
//                                  ),
//                                  Obx(() => Text(
//                                    '₹${AppUtil.formatCurrency(controller.pendingAmount.value)}',
//                                    style: TextStyle(
//                                      fontWeight: FontWeight.bold,
//                                      fontSize: 16,
//                                      color: Colors.orange.shade800,
//                                    ),
//                                  )),
//                                ],
//                              ),
//                            ),
//                          ],
//                        );
//                      }
//                      return SizedBox.shrink();
//                    }),
//
//                    // Show summary for Paid/Pending status
//                    Obx(() {
//                      if (controller.paymentStatus.value == 'Paid') {
//                        return Column(
//                          children: [
//                            SizedBox(height: 12),
//                            Container(
//                              padding: EdgeInsets.all(12),
//                              decoration: BoxDecoration(
//                                color: Colors.green.shade50,
//                                borderRadius: BorderRadius.circular(8),
//                                border: Border.all(color: Colors.green.shade200),
//                              ),
//                              child: Row(
//                                children: [
//                                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
//                                  SizedBox(width: 8),
//                                  Text(
//                                    'Fully Paid',
//                                    style: TextStyle(
//                                      fontWeight: FontWeight.bold,
//                                      color: Colors.green.shade800,
//                                    ),
//                                  ),
//                                ],
//                              ),
//                            ),
//                          ],
//                        );
//                      } else if (controller.paymentStatus.value == 'Pending') {
//                        return Column(
//                          children: [
//                            SizedBox(height: 12),
//                            Container(
//                              padding: EdgeInsets.all(12),
//                              decoration: BoxDecoration(
//                                color: Colors.red.shade50,
//                                borderRadius: BorderRadius.circular(8),
//                                border: Border.all(color: Colors.red.shade200),
//                              ),
//                              child: Row(
//                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                children: [
//                                  Row(
//                                    children: [
//                                      Icon(Icons.pending, color: Colors.red.shade700, size: 20),
//                                      SizedBox(width: 8),
//                                      Text(
//                                        'Pending Amount:',
//                                        style: TextStyle(
//                                          fontWeight: FontWeight.bold,
//                                          color: Colors.red.shade800,
//                                        ),
//                                      ),
//                                    ],
//                                  ),
//                                  Text(
//                                    '₹${AppUtil.formatCurrency(controller.totalAmount.value)}',
//                                    style: TextStyle(
//                                      fontWeight: FontWeight.bold,
//                                      fontSize: 16,
//                                      color: Colors.red.shade800,
//                                    ),
//                                  ),
//                                ],
//                              ),
//                            ),
//                          ],
//                        );
//                      }
//                      return SizedBox.shrink();
//                    }),
//                  ],
//                );
//              }
//              return SizedBox.shrink();
//            }),
//
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
//               (controller.isEditMode.value ? Colors.orange.shade700 : AppColors.tealColor)
//                   : Colors.black87,
//             ),
//           ),
//           Text(
//             '₹${AppUtil.formatCurrency(amount)}',
//             style: TextStyle(
//               fontSize: isTotal ? 18 : 16,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               color: isTotal ?
//               (controller.isEditMode.value ? Colors.orange.shade700 : AppColors.tealColor)
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
//                 color: controller.isEditMode.value
//                     ? Colors.orange.shade700
//                     : AppColors.tealColor,
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
//         Expanded(
//           flex: 4,
//           child: ElevatedButton(
//             onPressed: controller.isLoading.value ? null : () => controller.saveInvoice(isDraft: false),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: controller.isEditMode.value
//                   ? Colors.orange.shade700
//                   : AppColors.tealColor,
//               padding: EdgeInsets.symmetric(vertical: 12),
//             ),
//             child: Text(
//               controller.isEditMode.value
//                   ? 'update_invoice'.tr
//                   : controller.invoiceType.value == InvoiceType.invoice
//                   ? 'create_invoice'.tr
//                   : 'create_quotation'.tr,
//               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//           ),
//         ),
//       ],
//     ));
//   }
//
//   Widget _buildChallanToInvoiceSection() {
//     return Obx(() {
//       return Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Checkbox(
//                     value: controller.createFromChallan.value,
//                     onChanged: (value) {
//                       controller.createFromChallan.value = value ?? false;
//                       if (value == true) {
//                         controller.loadChallansForInvoice();
//                       } else {
//                         controller.selectedCustomerForInvoice.value = '';
//                         controller.selectedCustomerChallans.clear();
//                       }
//                     },
//                   ),
//                   Text(
//                     'create_invoice_from_challan'.tr,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.purple.shade700,
//                     ),
//                   ),
//                   Spacer(),
//                   if (controller.createFromChallan.value)
//                     IconButton(
//                       onPressed: controller.loadChallansForInvoice,
//                       icon: Icon(Icons.refresh),
//                       color: Colors.purple.shade700,
//                     ),
//                 ],
//               ),
//
//               if (controller.createFromChallan.value) ...[
//                 SizedBox(height: 16),
//
//                 Text(
//                   'select_date_range'.tr,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.purple.shade700,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: controller.fromDateController,
//                         decoration: InputDecoration(
//                           labelText: 'From Date',
//                           prefixIcon: Icon(Icons.calendar_today),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         readOnly: true,
//                         onTap: () => controller.selectFromDate(Get.context!),
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: TextFormField(
//                         controller: controller.toDateController,
//                         decoration: InputDecoration(
//                           labelText: 'To Date',
//                           prefixIcon: Icon(Icons.calendar_today),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         readOnly: true,
//                         onTap: () => controller.selectToDate(Get.context!),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//
//                 if (controller.allChallans.isEmpty)
//                   ElevatedButton(
//                     onPressed: controller.loadChallansForInvoice,
//                     child: Text('Load Challans'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.purple.shade700,
//                       foregroundColor: Colors.white,
//                     ),
//                   )
//                 else
//                   Column(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade300),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Obx(() {
//                           // Filter customers who have at least 1 in-progress challan in date range
//                           final customersWithChallans = controller.customerNames.where((customerName) {
//                             final count = controller.allChallans.where((challan) =>
//                             challan.customerName == customerName &&
//                                 challan.status?.toLowerCase() == "inprogress" &&
//                                 challan.challanDate != null &&
//                                 !challan.challanDate!.isBefore(controller.selectedFromDate.value) &&
//                                 !challan.challanDate!.isAfter(controller.selectedToDate.value))
//                                 .length;
//                             return count > 0;
//                           }).toList();
//
//                           // Show empty state if no customers have challans
//                           if (customersWithChallans.isEmpty) {
//                             return Padding(
//                               padding: EdgeInsets.all(16),
//                               child: Column(
//                                 children: [
//                                   Icon(Icons.info_outline, color: Colors.orange.shade700, size: 32),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     'No customers with in-progress challans in selected date range',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       color: Colors.orange.shade800,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }
//
//                           return DropdownButton<String>(
//                             value: controller.selectedCustomerForInvoice.value.isEmpty
//                                 ? null
//                                 : controller.selectedCustomerForInvoice.value,
//                             isExpanded: true,
//                             hint: Text('Select Customer (${customersWithChallans.length} available)'),
//                             underline: SizedBox(),
//                             items: [
//                               DropdownMenuItem(
//                                 value: null,
//                                 child: Text('Select Customer'),
//                               ),
//                               ...customersWithChallans.map((customerName) {
//                                 final challanCount = controller.allChallans
//                                     .where((challan) =>
//                                 challan.customerName == customerName &&
//                                     challan.status?.toLowerCase() == "inprogress" &&
//                                     challan.challanDate != null &&
//                                     !challan.challanDate!.isBefore(controller.selectedFromDate.value) &&
//                                     !challan.challanDate!.isAfter(controller.selectedToDate.value))
//                                     .length;
//
//                                 return DropdownMenuItem(
//                                   value: customerName,
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         customerName,
//                                         style: TextStyle(fontWeight: FontWeight.bold),
//                                       ),
//                                       Text(
//                                         '$challanCount challan(s)',
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.green.shade600,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }).toList(),
//                             ],
//                             onChanged: controller.selectCustomerForInvoice,
//                           );
//                         }),
//                       ),
//
//                       if (controller.selectedCustomerForInvoice.value.isNotEmpty)
//                         Column(
//                           children: [
//                             SizedBox(height: 16),
//                             Text(
//                               'Challans to be combined:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green.shade700,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             ...controller.selectedCustomerChallans.map((challan) {
//                               return ListTile(
//                                 contentPadding: EdgeInsets.zero,
//                                 leading: Icon(Icons.receipt, size: 20, color: Colors.blue),
//                                 title: Text(
//                                   'Challan #${challan.challanId}',
//                                   style: TextStyle(fontSize: 14),
//                                 ),
//                                 subtitle: Text(
//                                   DateFormat('MMM dd, yyyy').format(
//                                       challan.challanDate ?? DateTime.now()
//                                   ),
//                                   style: TextStyle(fontSize: 12, color: Colors.grey),
//                                 ),
//                               );
//                             }).toList(),
//
//                             SizedBox(height: 12),
//                             Container(
//                               padding: EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: Colors.green.shade50,
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(color: Colors.green.shade200),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Total Items:',
//                                     style: TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                   Text(
//                                     '${controller.invoiceItems.length}',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.green.shade700,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                     ],
//                   ),
//               ],
//             ],
//           ),
//         ),
//       );
//     });
//   }
//
//   void _showDeleteConfirmation() {
//     Get.dialog(
//       AlertDialog(
//         title: Text('Delete Invoice'),
//         content: Text('Are you sure you want to delete this invoice? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Get.back();
//               // controller.deleteInvoice();
//             },
//             child: Text(
//               'Delete',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

