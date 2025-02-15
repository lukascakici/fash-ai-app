// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';

import 'dart:io';

import 'package:fash_ai/global/widgets/toast_info.dart';
import 'package:purchases_flutter/purchases_flutter.dart';


abstract class PackagesInfo {
  static final String _platform = Platform.operatingSystem;

  static String get platform => _platform;
  static String get weekly => _platform.weekly;
  static String get monthly => _platform.monthly;
  static String get annual => _platform.annual;
}

extension _PackageProperties on String {
  static const _weeklyID = {
    'android': 'veilnet_weekly',
    'ios': 'fashai_weekly',
  };

  static const _monthlyID = {
    'android': 'veilnet_monthly',
    'ios': 'fash_ai_monthly',
  };

  static const _annualID = {
    'android': 'veilnet_annual',
    'ios': 'fashai_yearly',
  };

  String get weekly => _weeklyID[this]!;
  String get monthly => _monthlyID[this]!;
  String get annual => _annualID[this]!;
}

class SubscriptionService {
  Future<bool> checkIfPremium() async {
    try {
      final purchaserInfo = await Purchases.getCustomerInfo();
      final entitlements = purchaserInfo.entitlements.active;

      if (entitlements.containsKey('premium') &&
          entitlements['premium']!.isActive) {
        return true;
      }
    } catch (e) {
      showToast(msg: e.toString());
    }
    return false;
  }
}
