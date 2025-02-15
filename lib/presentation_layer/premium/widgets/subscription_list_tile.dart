import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../config/subscription_config.dart';
import '../../../global/app_theme/app_colors.dart';
import '../provider/subscription_provider.dart';

class SubscriptionListTile extends StatelessWidget {
  final Package package;

  const SubscriptionListTile({
    super.key,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, notifier, child) {
        bool isSelected =
            notifier.selectedItemIndex == notifier.productList.indexOf(package);

        StoreProduct storeProduct = package.storeProduct;

        double? weeklyPrice;
        double offerPrice = storeProduct.price;

        // Correctly assign weekly price for each package type
        if (storeProduct.identifier == PackagesInfo.annual) {
          weeklyPrice = 2.99; // Assuming your weekly price is 6.99
        } else if (storeProduct.identifier == PackagesInfo.monthly) {
          weeklyPrice = storeProduct.price / 4;
        } else if (storeProduct.identifier == PackagesInfo.weekly) {
          weeklyPrice = storeProduct.price;
        }

        double calculatedYearlyPrice = (weeklyPrice ?? 0) * 52;

        // Ensure weeklyPrice is valid before calculating the discount
        String discountText = storeProduct.identifier == PackagesInfo.weekly
            ? 'No Discount'
            : calculateDiscount(calculatedYearlyPrice, offerPrice);

        return GestureDetector(
          onTap: () {
            // Update the selected index when the user taps on a plan
            notifier.selectItem(notifier.productList.indexOf(package));
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            padding: EdgeInsets.symmetric(
              vertical: 8.h,
              horizontal: 10.w,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(0XFFdcfef1).withOpacity(0.43)
                  : Colors.white,
              border: Border.all(
                color: isSelected
                    ? Color(0XFF1ee09b).withOpacity(0.43)
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? Color(0XFF1ee09b)
                      : Colors.grey.shade600,
                  size: 20.sp,
                ),
                // Subscription Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [
                          SizedBox(width: 8.w),
                          Text(
                            storeProduct.title.split(' ').first,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding:  EdgeInsets.only(left: 10.0.w),
                        child: Text(
                          "3 days free trial",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Subscription Price
                Text(
                  storeProduct.priceString,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String calculateDiscount(double calculatedYearlyPrice, double offerPrice) {
    if (calculatedYearlyPrice == 0 || calculatedYearlyPrice <= offerPrice) {
      return 'Best Value';
    }

    // Calculate the actual discount
    double discount =
        ((calculatedYearlyPrice - offerPrice) / calculatedYearlyPrice) * 100;
    return 'Save ${discount.toStringAsFixed(0)}%';
  }
}
