import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../global/app_theme/app_colors.dart';
import 'divider.dart';


class InfoButtonRow extends StatelessWidget {
  final String title1;
  final String url1;
  final String title2;
  final String url2;
  final Widget? thirdButton;

  const InfoButtonRow({
    super.key,
    required this.title1,
    required this.url1,
    required this.title2,
    required this.url2,
    this.thirdButton,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h, // Using ScreenUtil for responsive height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: TextButton(
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(url1))) {
                  await launchUrl(Uri.parse(url1));
                }
              },
              child: Text(
                title1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: 8.sp,
                    color: AppColors.secondary

                  // Using ScreenUtil for font size
                    ),
              ),
            ),
          ),
          const RowDivider(),
          Flexible(
            child: TextButton(
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(url2))) {
                  await launchUrl(Uri.parse(url2));
                }
              },
              child: Text(
                title2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: 8.sp,
                  color: AppColors.secondary
                    ),
              ),
            ),
          ),
          if (thirdButton != null) const RowDivider(),
          if (thirdButton != null) thirdButton!,
        ],
      ),
    );
  }
}
