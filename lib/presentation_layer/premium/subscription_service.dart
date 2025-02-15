import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  Future<List<Package>> fetchAvailableProducts() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      // print('Error fetching products: $e');
    }
    return [];
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      // print('Error purchasing package: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      // print('Error restoring purchases: $e');
    }
  }
}
