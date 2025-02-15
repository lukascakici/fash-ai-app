import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RowDivider extends StatelessWidget {
  const RowDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return
      Container(
        width: 1.1.w,
        height: 10.h,
        color: Theme.of(context).hintColor,
      );
  }
}
