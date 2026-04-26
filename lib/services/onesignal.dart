import 'dart:convert';
import 'package:http/http.dart' as http;

class Onesignal {
  Future<void> sendPushNotification(String title, String body) async {
    const String appID = "ad0e2378-558f-4d8b-95cd-97093c47faa3";
    const String restKey = "os_v2_app_vuhcg6cvr5gyxfons4etyr72umfjuxy4atpetjfnhx5ptktoaqj5lpfykg5c7bftsukncq3umi2rxjksnch5mrvegvbzpm5u3n5x5qq";

    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Key $restKey", // ✅ fix
        },
        body: jsonEncode({
          "app_id": appID,
          "included_segments": ["All"],
          "headings": {"en": title},
          "contents": {"en": body},
          "priority": 10,
          "android_accent_color": "FF5D3FD3",
          "android_visibility": 1,
        }),
      );

      final result = jsonDecode(response.body);
      print("OneSignal response: $result");

      if (result['errors'] != null) {
        print("❌ Error: ${result['errors']}");
      } else {
        print("✅ Notification sent! ID: ${result['id']}");
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}