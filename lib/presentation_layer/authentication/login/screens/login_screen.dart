import 'package:fash_ai/backend_layer/main/navigation/routes/name.dart';
import 'package:fash_ai/global/widgets/build_text_field.dart';
import 'package:fash_ai/global/widgets/reusable_button.dart';
import 'package:fash_ai/presentation_layer/authentication/login/bloc/login_event.dart';
import 'package:fash_ai/presentation_layer/authentication/login/controller/login_controller.dart';
import 'package:fash_ai/presentation_layer/authentication/widgets/third_party_plugins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    size.height - statusBarHeight, // Subtract status bar height
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/logo.png",
                      height: 40.h,
                      width: 40.w,
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.headlineMedium,
                        children: [
                          const TextSpan(
                            text: 'Welcome to ', // Regular te
                          ),
                          TextSpan(
                            text: 'FashAI',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    BuildTextField(
                      text: 'Email',
                      textType: TextInputType.emailAddress,
                      onValueChange: (value) {
                        context.read<LoginBloc>().add(EmailEvents(value));
                      },
                    ),
                    SizedBox(height: 16.h),
                    BuildTextField(
                      text: 'Password',
                      textType: TextInputType.text,
                      onValueChange: (value) {
                        context.read<LoginBloc>().add(PasswordEvents(value));
                      },
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.forgetPassword);
                        },
                        child: Text(
                          'Forgot Password!',
                          style: TextStyle(
                            color: const Color(0xFFB6B6B6),
                            fontFamily: "JekoDemo",
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ),
                    ReusableButton(
                      text: state.isLoading ? "Loading..." : "Sign In",
                      onPressed: state.isLoading
                          ? null
                          : () {
                              // Dismiss the keyboard before proceeding with the sign-in
                              FocusScope.of(context).unfocus();

                              const SignInController()
                                  .handleSignIn("email", context);
                            },
                      isLoading: state.isLoading,
                    ),
                    SizedBox(
                      height: 16.h,
                    ),
                    ReusableButton(
                        text: "Register now",
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        }),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: Text(
                          'Or Continue with!',
                          style: TextStyle(
                            color: const Color(0xFFB6B6B6),
                            fontFamily: "JekoDemo",
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                    const ThirdPartyPlugins(),
                    SizedBox(height: 16.h),
                    Align(
                      alignment: Alignment.center,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: const Color(0xFFB6B6B6),
                            fontFamily: "JekoDemo",
                            fontSize: 12.sp,
                          ),
                          children: const [
                            // TextSpan(
                            //   text:
                            //       'By registering you with our ', // Normal text
                            // ),
                            // TextSpan(
                            //   text: 'Terms and Conditions', // Styled part
                            //   style: TextStyle(
                            //     color: Color(0xFF23DD9A), // Highlight color
                            //     fontWeight:
                            //         FontWeight.bold, // Bold or custom style
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
