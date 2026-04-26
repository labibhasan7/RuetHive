import 'dart:convert';

import 'package:http/http.dart' as http;

class Onesignal {
  Future<void> sendPushNotification(String title) async {
    const String appID = "bd57ea52-fe57-46c8-bf79-682ec94806a2";
    const String restKey =
        "os_v2_app_xvl6uux6k5dmrp3znaxmssaguknznff73xfez4eq4ir36d5i2ytxvnysvrjesebw5ce3x3of6yxff42ulvwl3vqsy2iyvjy2fccju3y";

    try {
      var response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Basic $restKey",
        },
        body: jsonEncode({
          "app_id": appID,
          "included_segments": ["All"],
          "headings": {"en": "Notification"},
          "contents": {"en": title},

          "priority": 10, 
          "android_accent_color": "FF5D3FD3",
          "android_visibility": 1,
        }),
      );

      print(response.body);
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}
