import 'package:demo_prac_getx/screen/auth/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/controller.dart';


class AuthScreen extends GetView<AuthController> {
  static const pageId = "/AuthScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple,
                  Colors.teal,
                  Color(0xFF2575FC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          title: const Text("Authentication", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: controller.tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.white,
                tabs: [
                  const Tab(icon: Icon(Icons.login), text: "Login"),
                  // Register tab with 7-tap gesture
                  GestureDetector(
                    onTap: controller.handleRegisterTabTap,
                    child: const Tab(icon: Icon(Icons.person_add), text: "Register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(() => Stack(
        children: [
          TabBarView(
            controller: controller.tabController,
            children: [
              LoginForm(),
              RegistrationForm(showFormFields: controller.showFormFields.value),
            ],
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent),
              ),
            ),
        ],
      )),
    );
  }
}

