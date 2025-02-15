import 'package:fash_ai/backend_layer/main/navigation/routes/name.dart';
import 'package:fash_ai/global/widgets/build_text_field.dart';
import 'package:fash_ai/global/widgets/reusable_button.dart';
import 'package:fash_ai/global/widgets/social_buttons.dart';
import 'package:fash_ai/presentation_layer/authentication/widgets/third_party_plugins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../controller/register_controller.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      statusBarHeight, // Subtract status bar height
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/icons/logo.png",height: 40.h,width: 40.w,),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.headlineMedium,
                          children: [
                            const TextSpan(
                              text: 'Register to ',
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
                        text: 'Your Name',
                        textType: TextInputType.text,
                        onValueChange: (value) =>
                            context.read<RegisterBloc>().add(NameEvent(value)),
                      ),
                      SizedBox(height: 16.h),
                      BuildTextField(
                        text: 'Email',
                        textType: TextInputType.emailAddress,
                        onValueChange: (value) =>
                            context.read<RegisterBloc>().add(EmailEvent(value)),
                      ),
                      SizedBox(height: 16.h),
                      BuildTextField(
                        text: 'Password',
                        textType: TextInputType.text,
                        onValueChange: (value) => context
                            .read<RegisterBloc>()
                            .add(PasswordEvent(value)),
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      ReusableButton(
                          text: state.isLoading ? "Loading..." : "Sign Up",
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  RegisterController().handleSignUp(context);
                                },
                          isLoading: state.isLoading),
                      SizedBox(
                        height: 16.h,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: const Color(0xFFB6B6B6),
                              fontFamily: "JekoDemo",
                              fontSize: 12.sp,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Do you have an account? ',
                              ),
                              TextSpan(
                                text: 'Login now ', // Styled part
                                style: TextStyle(
                                  color: Colors.black, // Highlight color
                                  fontWeight:
                                      FontWeight.bold, // Bold or custom style
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
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
                      // const SocialButtons(),
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
                              TextSpan(
                                text:
                                    'By registering you with our ', // Normal text
                              ),
                              TextSpan(
                                text: 'Terms and Conditions', // Styled part
                                style: TextStyle(
                                  color: Color(0xFF23DD9A), // Highlight color
                                  fontWeight:
                                      FontWeight.bold, // Bold or custom style
                                ),
                              ),
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
      },
    );
  }
}
