import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');
  }

  Future<String> getReceiverToken() async {
    final receiverToken = await _firebaseMessaging.getToken();
    return receiverToken ?? '';
  }

  Future<void> sendNotification(
      String receiverToken, String title, String body) async {
    final message = {
      'notification': {
        'title': title,
        'body': body,
      },
      'to': receiverToken,
    };
  }
}
