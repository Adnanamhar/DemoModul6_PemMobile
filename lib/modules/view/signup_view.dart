import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Akun')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextField(
              controller: controller.emailC,
              decoration: InputDecoration(labelText: "Email")),
          TextField(
              controller: controller.passwordC,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true),
          SizedBox(height: 20),
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.signup(),
                child:
                    Text(controller.isLoading.value ? "Loading..." : "Daftar"),
              )),
        ],
      ),
    );
  }
}
