import 'package:get/get.dart';
import '../bindings/auth_binding.dart';
import '../view/login_view.dart';
import '../view/signup_view.dart';
import '../bindings/home_binding.dart';
import '../view/home_view.dart';
import '../bindings/note_binding.dart';
import '../view/note_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.NOTES,
      page: () => FavoritesView(),
      binding: NotesBinding(),
    ),
  ];
}
