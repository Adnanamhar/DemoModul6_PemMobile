import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends GetxService {
  late SharedPreferences _prefs;
  final isDarkMode = false.obs;

  Future<SettingsService> init() async {
    _prefs = await SharedPreferences.getInstance();
    isDarkMode.value = _prefs.getBool('isDarkMode') ?? false;
    return this;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _prefs.setBool('isDarkMode', isDarkMode.value);
  }
}
