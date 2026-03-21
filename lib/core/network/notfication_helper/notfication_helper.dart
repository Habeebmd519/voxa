import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationHelper {
  static const String _appId = "887ea13a-f0ef-41f5-96bd-6cb3eb1a3988";
  static const String _restApiKey =
      "REMOVED";

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
