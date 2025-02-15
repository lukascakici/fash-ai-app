import 'package:fash_ai/global/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReusableButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final Color? buttonColor;
  final bool isEnabled;
  final bool isLoading;

  const ReusableButton({
    super.key,
    required this.text,
    this.onPressed,
    this.buttonColor,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: isEnabled && !isLoading
          ? onPressed
          : null, // Prevent onPressed when loading
      child: Container(
        width: double.infinity,
        height: 45.h,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  height: 16.h,
                  width: 16.h, // Adjust the width to keep it square
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0.w,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.background),
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
                      style: textTheme.titleSmall!
                          .copyWith(color: AppColors.background),
                    ),
                   
                  ],
                ),
              ),
      ),
    );
  }
}
