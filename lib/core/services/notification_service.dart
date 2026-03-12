import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Request permissions first
    // await _messaging.requestPermission(alert: true, badge: true, sound: true);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    // 2. Basic Local Notification Setup
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // 3. Setup listeners
    _configureListeners();

    // 4. FIRE AND FORGET token logic
    // We call this WITHOUT 'await' so main() can continue to the UI
    _fetchTokensSilently();
  }

  void _configureListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          id: 0,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'chat_channel',
              'Chat Notifications',
              importance: Importance.max,
            ),
          ),
        );
      }
    });
  }

  // This helper avoids crashing the app if APNS isn't ready yet
  Future<void> _fetchTokensSilently() async {
    try {
      // Wait a few seconds for iOS to register with Apple servers
      await Future.delayed(const Duration(seconds: 3));

      String? apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) {
        print("APNS Token: $apnsToken");
        String? fcmToken = await _messaging.getToken();
        print("FCM Token: $fcmToken");
      } else {
        print("APNS Token still null, will try again later.");
      }
    } catch (e) {
      print("Error fetching tokens: $e");
    }
  }
}
