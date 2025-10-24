import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../constant/constant.dart';
import '../screen/screen.dart';
import '../widgets/widgets.dart';

class CompanySelectionController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var companies = <Map<String, dynamic>>[].obs;
  var selectedCompany = Rxn<Map<String, dynamic>>();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadUserCompanies();
  }

  // Load all companies for the current user
  Future<void> loadUserCompanies() async {
    try {
      isLoading.value = true;
      print("🔍 Starting to load companies...");

      final user = _auth.currentUser;
      if (user == null) {
        print("❌ No user logged in!");
        showCustomSnackbar(
          title: "Error",
          message: "Please login first!",
          baseColor: AppColors.errorColor,
          icon: Icons.error,
        );
        return;
      }

      print("✅ User found: ${user.uid}");
      print("📧 User email: ${user.email}");

      // First, let's try to get ALL companies without any filters
      print("🔍 Trying to fetch ALL companies first...");
      final allCompaniesSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .get();

      print("📊 Total companies found (no filter): ${allCompaniesSnapshot.docs.length}");

      if (allCompaniesSnapshot.docs.isNotEmpty) {
        for (int i = 0; i < allCompaniesSnapshot.docs.length; i++) {
          final doc = allCompaniesSnapshot.docs[i];
          final data = doc.data();
          print("📋 Company $i:");
          print("   - ID: ${doc.id}");
          print("   - Name: ${data['companyName'] ?? 'NO NAME'}");
          print("   - Code: ${data['companyCode'] ?? 'NO CODE'}");
          print("   - IsActive: ${data['isActive']}");
          print("   - CreatedAt: ${data['createdAt']}");
          print("   - Full data: $data");
        }
      } else {
        print("❌ NO companies found at path: users/${user.uid}/companies");
      }

      // Now try with the isActive filter
      print("🔍 Now trying with isActive filter...");
      final companiesSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("companies")
          .where('isActive', isEqualTo: true)
          .get();

      print("📊 Active companies found: ${companiesSnapshot.docs.length}");

      companies.clear();
      for (var doc in companiesSnapshot.docs) {
        final companyData = doc.data();
        companyData['id'] = doc.id;
        companies.add(companyData);
        print("✅ Added active company: ${companyData['companyName']} (ID: ${doc.id})");
      }

      print("📋 Final companies list length: ${companies.length}");

      // Auto-select first company if only one exists
      if (companies.length == 1) {
        selectedCompany.value = companies.first;
        print("🎯 Auto-selected company: ${companies.first['companyName']}");
      }

      // Also try without orderBy in case that's causing issues
      if (companies.isEmpty) {
        print("🔍 Trying without orderBy clause...");
        try {
          final simpleSnapshot = await _firestore
              .collection("users")
              .doc(user.uid)
              .collection("companies")
              .where('isActive', isEqualTo: true)
              .get();

          print("📊 Simple query result: ${simpleSnapshot.docs.length} documents");
        } catch (orderByError) {
          print("❌ OrderBy might be the issue: $orderByError");
        }
      }

    } catch (e, stackTrace) {
      print("❌ Error loading companies: $e");
      print("📍 Stack trace: $stackTrace");
      showCustomSnackbar(
        title: "Error",
        message: "Failed to load companies: $e",
        baseColor: AppColors.errorColor,
        icon: Icons.error,
      );
    } finally {
      isLoading.value = false;
      print("🏁 Load companies completed. Final count: ${companies.length}");
    }
  }

  // Select a company
  void selectCompany(Map<String, dynamic> company) {
    print("🎯 Selecting company: ${company['companyName']} (ID: ${company['id']})");
    selectedCompany.value = company;
    print("✅ Company selected successfully");
  }

  // Navigate to customer registration with selected company
  void proceedToCustomerRegistration() {
    print("🚀 Attempting to navigate to customer registration...");

    if (selectedCompany.value == null) {
      print("❌ No company selected!");
      showCustomSnackbar(
        title: "Selection Required",
        message: "Please select a company first",
        baseColor: AppColors.errorColor,
        icon: Icons.error,
      );
      return;
    }

    print("✅ Selected company: ${selectedCompany.value!['companyName']}");
    print("📋 Company ID: ${selectedCompany.value!['id']}");
    print("🔄 Navigating to CustomerRegistrationScreen...");

    Get.toNamed(
      CustomerRegistrationScreen.pageId,
      arguments: {
        'companyId': selectedCompany.value!['id'],
        'companyData': selectedCompany.value,
      },
    );
  }

  // Navigate to create new company
  void createNewCompany() {
    print("🏭 Navigating to create new company...");
    Get.toNamed(CompanyRegistrationScreen.pageId);
  }
}