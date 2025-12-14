import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_pages.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final isLoading = false.obs;

  Future<void> login() async {
    try {
      isLoading.value = true;
      await supabase.auth.signInWithPassword(
        email: emailC.text,
        password: passwordC.text,
      );
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup() async {
    try {
      isLoading.value = true;
      await supabase.auth.signUp(
        email: emailC.text,
        password: passwordC.text,
      );
      Get.back(); // Kembali ke login setelah daftar
      Get.snackbar("Sukses", "Akun berhasil dibuat. Silakan login.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
