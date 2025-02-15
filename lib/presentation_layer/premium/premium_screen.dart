// import 'package:fash_ai/global/widgets/reusable_button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
//
// class ProSubscriptionScreen extends StatefulWidget {
//   const ProSubscriptionScreen({super.key});
//
//   @override
//   State<ProSubscriptionScreen> createState() => _ProSubscriptionScreenState();
// }
//
// class _ProSubscriptionScreenState extends State<ProSubscriptionScreen> {
//   int selectedOptionIndex = 0;
//
//   final List<Map<String, String>> options = [
//     {"title": "1 Week", "price": "\$4.90", "trialText": "3 days free trial"},
//     {"title": "1 Month", "price": "\$9.90", "trialText": "3 days free trial"},
//     {"title": "1 Year", "price": "\$49.90", "trialText": "3 days free trial"},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 15.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Close Button
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: SvgPicture.asset("assets/icons/exit.svg"),
//                     ),
//                   ),
//                   SizedBox(height: 20.h),
//
//                   // Title and Description
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       RichText(
//                         text: TextSpan(
//                           children: [
//                             TextSpan(
//                               text: "FashAI ",
//                               style: TextStyle(
//                                 fontSize: 28.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             WidgetSpan(
//                               alignment: PlaceholderAlignment.baseline,
//                               baseline: TextBaseline.alphabetic,
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 6.w, vertical: 2.h),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0XFF23DD9A),
//                                   borderRadius: BorderRadius.circular(8.r),
//                                 ),
//                                 child: Text(
//                                   "PRO",
//                                   style: TextStyle(
//                                     fontSize: 24.sp,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 8.h),
//                       Text(
//                         "Access All Features\nWith No Limits, No Ads",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20.h),
//                 ],
//               ),
//             ),
//
//             // Subscription Options
//             Expanded(
//               child: ListView.builder(
//                 padding: EdgeInsets.symmetric(horizontal: 24.w),
//                 itemCount: options.length,
//                 itemBuilder: (context, index) {
//                   final option = options[index];
//                   return SubscriptionOption(
//                     title: option["title"]!,
//                     price: option["price"]!,
//                     trialText: option["trialText"]!,
//                     isSelected: selectedOptionIndex == index,
//                     onTap: () {
//                       setState(() {
//                         selectedOptionIndex = index;
//                       });
//                     },
//                   );
//                 },
//               ),
//             ),
//
//             // Footer Section
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//               child: Column(
//                 children: [
//                   // Start Button
//                   ReusableButton(
//                     text: "Start using the 1 Week PRO version",
//                     onPressed: () {},
//                   ),
//                   SizedBox(height: 12.h),
//
//                   // Terms Text
//                   Text(
//                     "Subscription is auto-renewable. Cancel anytime\nat least 24h before your trial ends",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 10.sp,
//                       fontWeight: FontWeight.w500,
//                       color: const Color(0XFF7A7A7A),
//                     ),
//                   ),
//                   SizedBox(height: 12.h),
//
//                   // Footer Links
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       TextButton(
//                         onPressed: () {},
//                         child: Text(
//                           "Privacy Policy",
//                           style: TextStyle(
//                             fontSize: 10.sp,
//                             color: const Color(0XFF7A7A7A),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {},
//                         child: Text(
//                           "Manage Subscription",
//                           style: TextStyle(
//                             fontSize: 10.sp,
//                             color: const Color(0XFF7A7A7A),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {},
//                         child: Text(
//                           "Terms Of Use",
//                           style: TextStyle(
//                             fontSize: 10.sp,
//                             color: const Color(0XFF7A7A7A),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class SubscriptionOption extends StatelessWidget {
//   final String title;
//   final String price;
//   final String trialText;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const SubscriptionOption({
//     Key? key,
//     required this.title,
//     required this.price,
//     required this.trialText,
//     required this.isSelected,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 8.h),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? Colors.green : const Color(0XFF7A7A7A),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   isSelected
//                       ? Icons.radio_button_checked
//                       : Icons.radio_button_unchecked,
//                   color: isSelected ? Colors.black : Colors.grey,
//                 ),
//                 SizedBox(width: 8.w),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       trialText,
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             Text(
//               price,
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'dart:ui';

import 'package:fash_ai/presentation_layer/premium/provider/subscription_provider.dart';
import 'package:fash_ai/presentation_layer/premium/widgets/cross_button.dart';
import 'package:fash_ai/presentation_layer/premium/widgets/feature_item.dart';
import 'package:fash_ai/presentation_layer/premium/widgets/info_button_row.dart';
import 'package:fash_ai/presentation_layer/premium/widgets/subscription_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ProSubscriptionScreen extends StatelessWidget {
  const ProSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SubscriptionProvider(),
      child: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Stack(
                children: [
                  if (provider.productList.isEmpty)
                    _buildLoadingCenter(context)
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 15.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Close Button
                          Align(
                            alignment: Alignment.topLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: SvgPicture.asset("assets/icons/exit.svg"),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "FashAI ",
                                      style: TextStyle(
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0XFF23DD9A),
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          "PRO",
                                          style: TextStyle(
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Access All Features\nWith No Limits, No Ads",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          SizedBox(height: 20.h),

                          _buildPlanOptions(context, provider),

                          SizedBox(height: 20.h),

                          // Purchase button
                          provider.buildPurchaseButton(context),
                          SizedBox(height: 20.h),
                          Spacer(),
                          // const AppStoreGuidelines(),
                          InfoButtonRow(
                            title1: 'Privacy Policy',
                            url1:
                                'https://sites.google.com/view/refine-ai/privacy-policy',
                            title2: 'Terms of Use',
                            url2:
                                'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                            thirdButton: provider.buildRestorePurchaseButton(),
                          ),
                          if (Platform.isIOS) const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  if (provider.isLoading || provider.isSubscriptionProcessing)
                    _buildLoadingOverlay(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanOptions(
      BuildContext context, SubscriptionProvider provider) {
    if (provider.productList.isEmpty) {
      return Center(
        child: Text(
          "No subscription plans available",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: provider.productList.reversed.map((package) {
        return SubscriptionListTile(package: package);
      }).toList(),
    );
  }

  Widget _buildLoadingCenter(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 10.h),
          Text(
            "Loading Info, Please wait...",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // Loading overlay with a blurred background
  Widget _buildLoadingOverlay(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          color: Colors.black.withOpacity(0.5), // Slightly darken background
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 20.h),
              Text(
                "Processing Subscription...",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                "${Platform.isIOS ? "App Store" : "Google Play Store"}...",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String getPlanName(String title) {
  if (title.toLowerCase().contains('weekly')) {
    return 'week';
  } else if (title.toLowerCase().contains('yearly')) {
    return 'year';
  } else if (title.toLowerCase().contains('monthly')) {
    return 'month';
  }
  return title;
}
