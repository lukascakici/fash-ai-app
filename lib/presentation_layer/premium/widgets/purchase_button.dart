import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../global/app_theme/app_colors.dart';

class PurchaseButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final Color? buttonColor;
  final bool isEnabled;
  final bool isLoading;

  final bool isIcon;

  final Gradient? gradient;
  final String? iconAssetPath;

  const PurchaseButton({
    super.key,
    required this.text,
    this.onPressed,
    this.buttonColor,
    this.isLoading = false,
    this.isEnabled = true,
    this.gradient,
    required this.isIcon,
    this.iconAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: isEnabled && !isLoading ? onPressed : null, // Prevent onPressed when loading
      child: Container(
        height: 38.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,

          borderRadius: BorderRadius.circular(12),
        ),
        child: isLoading
            ? Center(
          child: SizedBox(
            height: 16.h,
            width: 16.h, // Adjust the width to keep it square
            child: CircularProgressIndicator(
              strokeWidth: 2.0.w, // Adjust strokeWidth to be more responsive
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.surface),
            ),
          ),
        )
            : Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: textTheme.titleSmall!.copyWith(fontSize:14.sp,fontWeight: FontWeight.w500),
              ),
              if (isIcon && iconAssetPath != null)
                Padding(
                  padding: EdgeInsets.only(left: 8.w, top: 3.h),
                  child: SizedBox(
                    height: 18.h, // Adjusted size for better responsiveness
                    width: 18.h, // Adjusted size for better responsiveness
                    child: SvgPicture.asset(
                      iconAssetPath!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
