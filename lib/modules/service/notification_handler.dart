import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Pesan diterima di background: ${message.notification?.title}');
}

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotification =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
    'channel_custom_sound', // ID Channel
    'High Importance Notification', // Nama Channel
    description: 'Channel untuk notifikasi kost dengan suara custom',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound(
        'notif'), 
  );

  Future<void> initPushNotification() async {
    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Izin user: ${settings.authorizationStatus}');

    // 2. Ambil Token FCM 
    _firebaseMessaging.getToken().then((token) {
      print('FCM Token: $token');
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print(
            "Aplikasi dibuka dari Terminated state: ${message.notification?.title}");
        _handleMessageNavigation(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(
          "Aplikasi dibuka dari Background state: ${message.notification?.title}");
      _handleMessageNavigation(message);
    });
  }

  Future<void> initLocalNotification() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotification.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          print("Notifikasi Lokal diklik: ${response.payload}");
          Get.toNamed(Routes.NOTES); // Navigasi ke halaman Favorit (Notes)
        }
      },
    );

    final platform = _localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  void listenForegroundMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@mipmap/ic_launcher',
              playSound: true,
              sound: const RawResourceAndroidNotificationSound(
                  'notif'), 
            ),
          ),
          payload: jsonEncode(message.data), 
        );
      }
    });
  }

  void _handleMessageNavigation(RemoteMessage message) {
    if (message.data.containsKey('route')) {
      Get.toNamed(message.data['route']);
    } else {
      Get.toNamed(Routes.NOTES); // Default ke Favorites
    }
  }
}
