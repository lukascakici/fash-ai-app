import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogoWithText extends StatelessWidget {
  const LogoWithText({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Image.asset(
            "assets/images/MeditaHUB logo.png",
            height: 22.h,
            // Replace with actual avatar image URL
          ),
          SizedBox(
            width: 5.w,
          ),
          Text(
            'MeditaHUB',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(fontSize: 12.sp),
          )
        ],
      ),
    );
  }
}
