import 'package:fash_ai/global/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


void showToast({
  required String msg,
}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    backgroundColor: AppColors.background,
    textColor: AppColors.surface,
    fontSize: 16.0,
  );
}
