import 'package:fash_ai/global/app_theme/app_colors.dart';
import 'package:fash_ai/presentation_layer/brands/brands_screen.dart';
import 'package:fash_ai/presentation_layer/create/create_screen.dart';
import 'package:fash_ai/presentation_layer/home/home_screen.dart';
import 'package:fash_ai/presentation_layer/notification/notification_screen.dart';
import 'package:fash_ai/presentation_layer/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';


Widget buildPage(index) {
  List<Widget> widgets = [
    

    HomeScreen(),
    const BrandsScreen(),
    const CreateScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];
  return widgets[index];
}

var bottomTabs = [
  BottomNavigationBarItem(
    label: "Chat",
    icon: SizedBox(
      height: 24.h,
      width: 24.w,
      child: SvgPicture.asset(
        "assets/icons/home_unselected.svg",

      ),
    ),
    activeIcon: Center(
      child: SizedBox(
        height: 24.h,
        width: 24.w,
        child: SvgPicture.asset(
          "assets/icons/home_selected.svg",
          colorFilter:
              const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        ),
      ),
    ),
  ),
  BottomNavigationBarItem(
    label: "Brands",
    icon: SizedBox(
      height: 24.h,
      width: 24.w,
      child: SvgPicture.asset(
        "assets/icons/brands_unselected.svg",
        
      ),
    ),
    activeIcon: Center(
      child: SizedBox(
        height: 24.h,
        width: 24.w,
        child: SvgPicture.asset(
          "assets/icons/brands_selected.svg",
   
        ),
      ),
    ),
  ),
  BottomNavigationBarItem(
    label: "Create",
    icon: SizedBox(
      height: 24.h,
      width: 24.w,
      child: SvgPicture.asset(
        "assets/icons/create_unselected.svg",
  
      ),
    ),
    activeIcon: Center(
      child: SizedBox(
        height: 24.h,
        width: 24.w,
        child: SvgPicture.asset(
          "assets/icons/create_selected.svg",

        ),
      ),
    ),
  ),
  BottomNavigationBarItem(
    label: "Notifications",
    icon: SizedBox(
      height: 24.h,
      width: 24.w,
      child: SvgPicture.asset(
        "assets/icons/notification_unselected.svg",

      ),
    ),
    activeIcon: Center(
      child: SizedBox(
        height: 24.h,
        width: 24.w,
        child: SvgPicture.asset(
          "assets/icons/notification_selected.svg",

        ),
      ),
    ),
  ),
  BottomNavigationBarItem(
    label: "Profile",
    icon: SizedBox(
      height: 24.h,
      width: 24.w,
      child: SvgPicture.asset(
        "assets/icons/profile_unselected.svg",

      ),
    ),
    activeIcon: Center(
      child: SizedBox(
        height: 24.h,
        width: 24.w,
        child: SvgPicture.asset(
          "assets/icons/profile_selected.svg",
       
        ),
      ),
    ),
  ),
];
