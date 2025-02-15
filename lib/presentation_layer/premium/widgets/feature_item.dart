import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../global/app_theme/app_colors.dart';

class FeatureItem extends StatelessWidget {
  final String feature;
  const FeatureItem({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.sp),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 10.sp,
            ), // Tick icon with white color
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          Text(
            feature,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.w400, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
