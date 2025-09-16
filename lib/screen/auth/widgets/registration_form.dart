import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/controller.dart';
import '../../../widgets/widgets.dart';

class RegistrationForm extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "For New Registration Contact your Authorised Person",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const Text(
                  "New Registration",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.regUsernameController,
                  decoration: InputDecoration(
                    labelText: "User Name *",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.regEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email ID *",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.loginPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password *",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.regMobile1Controller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Mobile No. 1 *",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.regMobile2Controller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Mobile No. 2 (Optional)",
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.regCityController,
                  decoration: InputDecoration(
                    labelText: "City *",
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.regStateController,
                  decoration: InputDecoration(
                    labelText: "State *",
                    prefixIcon: const Icon(Icons.map),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.regCountryController,
                  decoration: InputDecoration(
                    labelText: "Country *",
                    prefixIcon: const Icon(Icons.public),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 30),
                Obx(() =>
                    CustomButton(
                      text: "Register",
                      backgroundColor: Colors.deepPurple,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.handleRegistration,
                    ),
                //     ElevatedButton(
                //   onPressed: controller.isLoading.value ? null : controller.handleRegistration,
                //   style: ElevatedButton.styleFrom(
                //     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                //     backgroundColor: Colors.pinkAccent,
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                //   ),
                //   child: controller.isLoading.value
                //       ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                //       : const Text("Register", style: TextStyle(fontSize: 18)),
                // )
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: controller.isLoading.value ? null : controller.authenticateWithMobile,
                  child: const Text("Authenticate via Mobile", style: TextStyle(color: Colors.deepPurple)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}