import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/controller.dart';
import '../../../widgets/widgets.dart';

class LoginForm extends GetView<AuthController> {
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
                  "Login",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.loginUsernameController,
                  decoration: InputDecoration(
                    labelText: "User Name",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  ()=> TextFormField(
                    controller: controller.loginPasswordController,
                    obscureText: controller.isPasswordHidden.value,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Obx(() =>
                    CustomButton(
                      text: "Login",
                      backgroundColor: Colors.deepPurple,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.handleLogin,
                    ),
                //     ElevatedButton(
                //   onPressed: controller.isLoading.value ? null : controller.handleLogin,
                //   style: ElevatedButton.styleFrom(
                //     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                //     backgroundColor: Colors.deepPurple,
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                //   ),
                //   child: controller.isLoading.value
                //       ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                //       : const Text("Login", style: TextStyle(fontSize: 18)),
                // )
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: (){},//controller.isLoading.value ? null : controller.authenticateWithMobile,
                  child: const Text("Forget Password?", style: TextStyle(color: Colors.pinkAccent)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
