import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialButton(
          imagePath: 'assets/icons/google_logo.svg', // Path to your Google logo
          label: 'Google',
          onPressed: () {},
        ),
        const SizedBox(width: 16),
        SocialButton(
          imagePath: 'assets/icons/facebook_logo.svg', // Path to your Facebook logo
          label: 'Facebook',
          onPressed: () {},
        ),
      ],
    );
  }
}

class SocialButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onPressed;

  const SocialButton({
    Key? key,
    required this.imagePath,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      width: 140.w,
      decoration: BoxDecoration(color: Color(0xFFF3F3F3),borderRadius: BorderRadius.circular(12)),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: SvgPicture.asset(
          width: 16,
          height: 16,
          imagePath,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontFamily: "JekoDemo"
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Adjust corner radius
          ),
          backgroundColor: const Color(0xFFF5F5F5), // Light background color
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}
