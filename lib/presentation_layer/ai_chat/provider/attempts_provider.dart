import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../config/subscription_config.dart'; // SubscriptionService location

class AttemptsProvider with ChangeNotifier {
  int _totalAttempts = 0;
  DateTime? _lastAttemptDate;
  bool _isPremiumUser = false;

  int get totalAttempts => _totalAttempts;
  bool get isPremium => _isPremiumUser;

  AttemptsProvider() {
    loadAttempts();
  }

  Future<void> loadAttempts() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      debugPrint("No user logged in for attempts tracking.");
      return;
    }

    try {
      // 1) Check premium status from RevenueCat
      await _updatePremiumStatus();

      // 2) Fetch or initialize user attempts in Firestore
      final userDoc =
      FirebaseFirestore.instance.collection('user_attempts').doc(userId);
      final doc = await userDoc.get();

      if (doc.exists) {
        final data = doc.data();
        _totalAttempts = data?['total_attempts'] ?? 0;
        _lastAttemptDate = (data?['last_attempt_date'] != null)
            ? DateTime.parse(data!['last_attempt_date'])
            : null;

        // Reset attempts if it's a new day
        final today = DateTime.now();
        if (_lastAttemptDate == null ||
            _lastAttemptDate!.year != today.year ||
            _lastAttemptDate!.month != today.month ||
            _lastAttemptDate!.day != today.day) {
          _totalAttempts = 0;
          _lastAttemptDate = today;
          await userDoc.set({
            'total_attempts': _totalAttempts,
            'last_attempt_date': _lastAttemptDate!.toIso8601String(),
          });
        }
      } else {
        // No record found, create initial record
        _totalAttempts = 0;
        _lastAttemptDate = DateTime.now();
        await userDoc.set({
          'total_attempts': _totalAttempts,
          'last_attempt_date': _lastAttemptDate!.toIso8601String(),
        });
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading attempts: $e');
    }
  }

  Future<bool> attemptConsultation() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      debugPrint("No user logged in.");
      return false;
    }

    // 1) Check the latest premium status each time
    await _updatePremiumStatus();

    // 2) If the user is premium, allow unlimited
    if (_isPremiumUser) {
      return true;
    }

    // Otherwise, limit daily attempts (example: 6)
    final userDoc =
    FirebaseFirestore.instance.collection('user_attempts').doc(userId);
    final today = DateTime.now();

    try {
      // Reset attempts if it's a new day
      if (_lastAttemptDate == null ||
          _lastAttemptDate!.year != today.year ||
          _lastAttemptDate!.month != today.month ||
          _lastAttemptDate!.day != today.day) {
        _totalAttempts = 0;
        _lastAttemptDate = today;
        await userDoc.set({
          'total_attempts': _totalAttempts,
          'last_attempt_date': _lastAttemptDate!.toIso8601String(),
        });
      }

      // Check if user has daily free attempts left
      if (_totalAttempts >= 6) {
        return false; // Reached daily limit
      }

      // Increment the attempts
      _totalAttempts += 1;
      await userDoc.update({
        'total_attempts': _totalAttempts,
        'last_attempt_date': today.toIso8601String(),
      });

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating attempts: $e');
      return false;
    }
  }

  Future<void> _updatePremiumStatus() async {
    final subscriptionService = SubscriptionService();
    _isPremiumUser = await subscriptionService.checkIfPremium();
    notifyListeners();
  }
}
