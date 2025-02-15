import 'dart:io';
import 'package:fash_ai/global/widgets/reusable_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../backend_layer/main/navigation/routes/name.dart';
import '../../../global/app_theme/app_colors.dart';
import '../../../global/widgets/toast_info.dart';
import '../subscription_service.dart';
import '../widgets/purchase_button.dart';

class SubscriptionProvider with ChangeNotifier, WidgetsBindingObserver {
  List<Package> productList = [];
  int selectedItemIndex = 1;
  bool isPremium = false;
  bool hasUsedTrial = false; // Flag for trial usage
  bool isLoading = false; // Loading state
  bool isTrialEligible = false; // Flag for trial eligibility
  bool isSubscriptionProcessing =
      false; // Track if the subscription is being processed
  bool isCanceledButActive = false;
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _showedToast = false;
  bool _lastPremiumState = false;
  Map<String, IntroEligibility> introEligibility = {};

  SubscriptionProvider() {
    fetchProducts();
    checkPremiumStatus();
    _addPurchasesListener();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkPremiumStatus();
    }
  }

  void _addPurchasesListener() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      checkPremiumStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void selectItem(int index) {
    selectedItemIndex = index;
    notifyListeners();
  }

  /// Fetch products from RevenueCat API and check trial eligibility
  Future<void> fetchProducts() async {
    try {
      setLoading(true); // Show loading while fetching
      List<Package> products =
          await _subscriptionService.fetchAvailableProducts();
      productList = products;

      // Check trial eligibility for iOS users only
      if (Platform.isIOS) {
        final Map<String, IntroEligibility> eligibility =
            await Purchases.checkTrialOrIntroductoryPriceEligibility(
          products.map((p) => p.storeProduct.identifier).toList(),
        );
        introEligibility = eligibility;
        notifyListeners();
      }

      setLoading(false); // Remove loading once fetched
      notifyListeners();
    } catch (e) {
      setLoading(false); // Ensure loading is turned off even on error
      _showToastOnce("Failed to fetch products: ${e.toString()}");
    }
  }

  /// Check the user's premium status
  Future<void> checkPremiumStatus() async {
    try {
      setLoading(true); // Show loading while checking the premium status
      final purchaserInfo = await Purchases.getCustomerInfo();
      final entitlements = purchaserInfo.entitlements.active;

      _showedToast = false;

      if (entitlements.containsKey('premium')) {
        final premiumPlan = entitlements['premium']!;
        final expirationDateStr = premiumPlan.expirationDate;

        if (premiumPlan.isActive) {
          _updatePremiumState(true);
          if (expirationDateStr != null) {
            final expirationDate = DateTime.parse(expirationDateStr);
            if (expirationDate.isBefore(DateTime.now())) {
              _updatePremiumState(false);
              _showToastOnce("Your subscription has expired.");
            } else if (!premiumPlan.willRenew) {
              isCanceledButActive = true;
              _showToastOnce(
                  "Subscription canceled but active until ${expirationDate.toLocal()}.");
            }
          }
        } else {
          if (!isSubscriptionProcessing) {
            // Only show if not processing a subscription
            _updatePremiumState(false);
            _showToastOnce("Your subscription is inactive.");
          }
        }
      } else {
        if (!isSubscriptionProcessing) {
          // Only show if not processing a subscription
          _updatePremiumState(false);
          // _showToastOnce("No active premium subscription found.");
        }
      }

      // Check if the user has used the trial
      hasUsedTrial = purchaserInfo.nonSubscriptionTransactions.isNotEmpty;
      setLoading(false);
      notifyListeners();
    } catch (e) {
      setLoading(false);
      _updatePremiumState(false);
      _showToastOnce("Error checking subscription status: ${e.toString()}");
    }
  }

  /// Handle premium state changes and avoid redundant toasts
  void _updatePremiumState(bool isNowPremium) {
    if (isPremium != isNowPremium) {
      isPremium = isNowPremium;
      notifyListeners();
    }
    if (_lastPremiumState != isNowPremium) {
      _lastPremiumState = isNowPremium;
      _showedToast = false;
    }
  }

  /// Ensure only one toast is shown
  void _showToastOnce(String message) {
    if (!_showedToast) {
      _showedToast = true;
      showToast(msg: message);
    }
  }

  /// Set loading state
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  /// Purchase the selected product
  Future<void> purchaseProduct(Package package, BuildContext context) async {
    setLoading(true);
    isSubscriptionProcessing = true; // Start subscription processing
    notifyListeners();

    try {
      bool isPurchased = await _subscriptionService.purchasePackage(package);
      isSubscriptionProcessing = false; // End subscription processing
      setLoading(false);

      if (isPurchased) {
        _updatePremiumState(true);
        showToast(msg: "Purchase successful! You are now a premium user.");
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.application,
            (Route<dynamic> route) => false); // Navigate to home screen
      } else {
        showToast(msg: "");
      }
    } catch (e) {
      isSubscriptionProcessing = false; // End subscription processing
      setLoading(false);
      _showToastOnce("Failed to complete purchase: ${e.toString()}");
    }
  }

  /// Block user navigation to subscription screen until status updates to premium
  Future<void> handleSubscriptionNavigation(BuildContext context) async {
    if (!isPremium) {
      _showToastOnce("Waiting for subscription to complete...");
    } else {
      Navigator.pushNamed(context, AppRoutes.subscription);
    }
  }

  Widget buildPurchaseButton(BuildContext context) {
    String buttonText;

    // Check the conditions and update the button text accordingly
    if (isPremium) {
      buttonText =
          isCanceledButActive ? 'Subscription Active (Canceled)' : 'Premium';
    } else if (!isPremium && isTrialEligible) {
      buttonText =
          'Start Free Trial'; // If eligible for the trial, offer the trial
    } else if (hasUsedTrial) {
      buttonText = 'Get Pro'; // If the user has already used the trial
    } else {
      buttonText =
          'Upgrade to Pro'; // Default case for non-premium users without a trial
    }

    return ReusableButton(
      buttonColor: Colors.black,
      // gradient: AppColors.secondaryGradient,
      onPressed: () {
        if (productList.isNotEmpty && selectedItemIndex != -1) {
          purchaseProduct(productList[selectedItemIndex], context);
        } else {
          _showToastOnce("No product selected. Please try again.");
        }
      },
      text: buttonText,
      // isIcon: false,
    );
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      await _subscriptionService.restorePurchases();
      await checkPremiumStatus();
      showToast(msg: "Purchase restored successfully.");
    } catch (e) {
      _showToastOnce("Failed to restore purchases: ${e.toString()}");
    }
  }

  /// Build the restore purchase button
  Widget buildRestorePurchaseButton() {
    return TextButton(
      onPressed: restorePurchases,
      child: Text(
        'Restore Purchase',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          color: AppColors.secondary,
          fontSize: 8.sp,
        ),
      ),
    );
  }
}
