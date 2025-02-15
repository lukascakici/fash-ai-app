import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fash_ai/backend_layer/main/navigation/routes/name.dart';
import 'package:fash_ai/global/app_theme/app_colors.dart';
import 'package:fash_ai/global/constants/app_constant.dart';
import 'package:fash_ai/global/global.dart';
import 'package:fash_ai/global/widgets/toast_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'logout_button.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          backgroundColor: AppColors.card,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
             
              SizedBox(height: 10.h),
              Text(
                'Are You Sure !',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              LogoutButton(
                onPressed: () async {
                  try {
                    // Close the dialog
                    Navigator.of(context).pop();

                    // Handle logout for different sign-in providers
                    User? user = FirebaseAuth.instance.currentUser;

                    if (user != null) {
                      for (UserInfo userInfo in user.providerData) {
                        if (userInfo.providerId == 'google.com') {
                          // Google sign-out
                          await GoogleSignIn().signOut();
                        } else if (userInfo.providerId == 'apple.com') {
                          // Apple sign-out (Apple doesn't have a native SDK logout method; Firebase handles it)
                        } else if (userInfo.providerId == 'password') {
                          // Email/password sign-out
                        }
                      }
                    }

                    // Firebase sign-out
                    await FirebaseAuth.instance.signOut();

                    // Clear locally stored data
                    await Global.storageServices
                        .remove(AppConstants.STORAGE_USER_TOKEN_KEY);
                    await Global.storageServices
                        .setPreferenceScreenCompleted(false);

                    // Navigate to login screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.login, (Route<dynamic> route) => false);
                  } catch (e) {
                    // Handle errors during logout
                    showToast(msg: 'Failed to logout. Please try again.');
                  }
                },
                text: 'Logout',
                isIcon: false,
              ),
            ],
          ),
        ),
      );
    },
  );
}
