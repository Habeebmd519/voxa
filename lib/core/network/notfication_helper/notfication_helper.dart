import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationHelper {
  static String get _appId => dotenv.env['ONESIGNAL_APP_ID']!;
  static String get _restApiKey => dotenv.env['ONESIGNAL_REST_API_KEY']!;
  static Future<void> sendPushNotification({
    required String playerId,
    required String message,
    required String senderName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("https://onesignal.com/api/v1/notifications"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic $_restApiKey",
        },
        body: jsonEncode({
          "app_id": _appId,
          "include_player_ids": [playerId],
          "headings": {"en": senderName},
          "contents": {"en": message},
        }),
      );

      print("Notification sent: ${response.body}");
    } catch (e) {
      print("Notification error: $e");
    }
  }
}
