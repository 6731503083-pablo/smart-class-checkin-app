import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/check_in_record.dart';
import '../models/finish_class_record.dart';

class FirebaseSyncService {
  FirebaseSyncService._();

  static Future<void> saveCheckIn(CheckInRecord record) async {
    if (!isFirebaseReady) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('check_in_records')
        .doc(record.id)
        .set(record.toMap());
  }

  static Future<void> saveFinishClass(FinishClassRecord record) async {
    if (!isFirebaseReady) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('finish_class_records')
        .doc(record.id)
        .set(record.toMap());
  }

  static bool get isFirebaseReady => Firebase.apps.isNotEmpty;
}