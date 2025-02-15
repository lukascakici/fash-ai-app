// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import '../../../config/subscription_config.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../main/navigation/routes/name.dart';
// import '../../../subscription/provider/subscription_provider.dart';
//
// class ProfileSubscriptionStatusWidget extends StatelessWidget {
//   final String premiumText;
//   final String upgradeText;
//   final String trialText;
//   final double height;
//   final double width;
//   final EdgeInsetsGeometry padding;
//
//   const ProfileSubscriptionStatusWidget({
//     super.key,
//     this.premiumText = 'Premium',
//     this.upgradeText = 'Upgrade to Pro',
//     this.trialText = 'Start Free Trial',
//     this.height = 90.0, // Height of the card
//     this.width = 250.0, // Width of the card
//     this.padding = const EdgeInsets.all(16.0),
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
//
//     bool isPremium = subscriptionProvider.isPremium;
//     bool hasUsedTrial = subscriptionProvider.hasUsedTrial;
//
//     bool isTrialEligible = false;
//     if (subscriptionProvider.introEligibility.isNotEmpty &&
//         subscriptionProvider.introEligibility
//             .containsKey('com.example.refineAi.yearly')) {
//       isTrialEligible = subscriptionProvider
//           .introEligibility['com.example.refineAi.yearly']!.status ==
//           IntroEligibilityStatus.introEligibilityStatusEligible;
//     }
//
//     // Determine button text based on user's status
//     String buttonText = isPremium
//         ? premiumText
//         : (hasUsedTrial || !isTrialEligible ? upgradeText : trialText);
//
//     // Determine plan label based on the user's status
//     String planLabel = isPremium ? 'Premium Plan' : 'Get Pro';
//     String iconName = 'assets/icons/premium_icon.svg'; // Icon for premium/free
//
//     return GestureDetector(
//       onTap: () {
//         // Navigate to subscription screen if not premium
//         if (!isPremium) {
//           Navigator.pushNamed(context, AppRoutes.subscription);
//         }
//       },
//       child: Container(
//         height: height.h,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: AppColors.secondaryGradient,
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         child: Padding(
//           padding: padding,
//           child: Row(
//             children: [
//               // Icon Section
//               SvgPicture.asset(
//                 iconName,
//                 height: 24.h,
//                 width: 24.w,
//               ),
//               SizedBox(width: 12.w),
//
//               // Text Section
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       planLabel,
//                       style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.surface,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     Text(
//                       buttonText,
//                       style: Theme.of(context).textTheme.bodySmall!.copyWith(
//                         color: AppColors.surface,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Arrow Icon
//               SvgPicture.asset(
//                 'assets/icons/arrow_icon.svg',
//                 height: 24.h,
//                 width: 24.w,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }