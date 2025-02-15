import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../backend_layer/main/navigation/routes/name.dart';

Widget backButton(context) {
  return Container(
    decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
      BoxShadow(blurRadius: 40, color: Colors.black.withOpacity(0.3))
    ]),
    child: IconButton(
      icon: SvgPicture.asset(
        height: 26.sp,
        'assets/icons/cancel-cross.svg',
      ),
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.application);
      },
      iconSize: 24.sp,
      padding: const EdgeInsets.all(12.0),
    ),
  );
}
