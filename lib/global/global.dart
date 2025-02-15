import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fash_ai/firebase_options.dart';
import 'package:fash_ai/global/services/storage_services.dart';
import 'package:flutter/cupertino.dart';

class Global {
  static late StorageServices storageServices;
  static late bool preferenceScreenCompleted;

  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    storageServices = await StorageServices().init();

    User? currentUser = await _getCurrentUserWithRetry();

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        print("User doc ${currentUser.uid}");
        Global.preferenceScreenCompleted =
            userDoc.data()?['preferenceScreenCompleted'] ?? false;
      } else {
        Global.preferenceScreenCompleted = false;
      }
    } else {
      Global.preferenceScreenCompleted = false;
    }
  }

  static Future<User?> _getCurrentUserWithRetry({int maxRetries = 3, int delayMs = 500}) async {
    for (int i = 0; i < maxRetries; i++) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user;
      }
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    return null; // Return null if user is still not available
  }
}
