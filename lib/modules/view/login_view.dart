import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';
import '../controller/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
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
                    : () => controller.login(),
                child:
                    Text(controller.isLoading.value ? "Loading..." : "Login"),
              )),
          TextButton(
            onPressed: () => Get.toNamed(Routes.SIGNUP),
            child: Text("Belum punya akun? Daftar"),
          ),
        ],
      ),
    );
  }
}
