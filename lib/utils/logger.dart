import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addActivityLog(String type, String message) async {
  await FirebaseFirestore.instance.collection('activity_logs').add({
    'type': type,
    'message': message,
    'timestamp': DateTime.now(),
  });
}
