import 'package:get/get.dart';
import '../controller/note_controller.dart';

class NotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesController>(() => FavoritesController());
  }
}
