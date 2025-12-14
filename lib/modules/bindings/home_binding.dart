import 'package:get/get.dart';
import '../service/settings_service.dart'; // Import service
import '../controller/home_controller.dart';
import '../service/api_service.dart';
import '../controller/note_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<FavoritesController>(() => FavoritesController());
    Get.lazyPut<HomeController>(() => HomeController(
          Get.find<ApiService>(),
          Get.find<SettingsService>(),
        ));
  }
}
