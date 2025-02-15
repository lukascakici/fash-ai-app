import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../backend_layer/main/navigation/routes/name.dart';
import '../../../../global/app_theme/app_colors.dart';
import '../../../../global/widgets/build_text_field.dart';
import '../../../../global/widgets/reusable_button.dart';
import '../../../../global/widgets/toast_info.dart';
import '../widgets/reusable_text.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new)),
              const ReusableTitleCard(
                  title: 'Forget Password',
                  subtitle: 'Enter your email to reset your password',
                  icon: 'assets/icons/logo.png'),
              SizedBox(
                height: 50.h,
              ),
              BuildTextField(
                text: "Email",
                textType: TextInputType.emailAddress,
                onValueChange: (value) {
                  emailController.text = value.toString();
                },
              ),
              SizedBox(
                height: 30.h,
              ),
              ReusableButton(
                buttonColor: Colors.black,
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: emailController.text.trim(),
                    );
                    emailController.clear();
                    emailController.text = "";

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushNamed(
                          context, AppRoutes.forgetNotification);
                    });
                  } catch (e) {
                    showToast(msg: e.toString());
                  }
                },
                text: "Reset Password",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
