import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './modules/model/location_model.dart';
import './modules/routes/app_pages.dart';
import './modules/service/settings_service.dart';
import 'package:firebase_core/firebase_core.dart';
import './modules/service/notification_handler.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://jjaqwfqxslsyamtzsdip.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpqYXF3ZnF4c2xzeWFtdHpzZGlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3ODQxMjYsImV4cCI6MjA3ODM2MDEyNn0.FvOKOf3XSDS9s5neya2RA2ds6N9Z0CsQ2IcwwtW_wLQ',
  );

  await Hive.initFlutter();
  Hive.registerAdapter(LocationAdapter());
  await Hive.openBox<List>('locationCache');

  final notificationHandler = NotificationHandler();
  await notificationHandler.initPushNotification();
  await notificationHandler.initLocalNotification();
  notificationHandler.listenForegroundMessage();

  await Get.putAsync(() => SettingsService().init());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsService settings = Get.find<SettingsService>();

    return Obx(
      () => GetMaterialApp(
        title: 'pkukostkontrakan App',
        debugShowCheckedModeBanner: false,
        theme: settings.isDarkMode.value ? ThemeData.dark() : ThemeData.light(),
        initialRoute: Supabase.instance.client.auth.currentSession != null
            ? Routes.HOME
            : Routes.LOGIN,
        getPages: AppPages.routes,
      ),
    );
  }
}
