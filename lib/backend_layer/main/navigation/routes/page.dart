import 'package:fash_ai/data_store/local/user_database.dart';
import 'package:fash_ai/global/global.dart';
import 'package:fash_ai/presentation_layer/ai_chat/screens/chat_screen.dart';
import 'package:fash_ai/presentation_layer/application/bloc/app_bloc.dart';
import 'package:fash_ai/presentation_layer/application/screens/application_screen.dart';
import 'package:fash_ai/presentation_layer/authentication/forgetPassword/forgot_notification.dart';
import 'package:fash_ai/presentation_layer/authentication/login/bloc/login_bloc.dart';
import 'package:fash_ai/presentation_layer/authentication/login/screens/login_screen.dart';
import 'package:fash_ai/presentation_layer/authentication/register/bloc/register_bloc.dart';
import 'package:fash_ai/presentation_layer/authentication/register/screens/register_screen.dart';
import 'package:fash_ai/presentation_layer/brands/brands_screen.dart';
import 'package:fash_ai/presentation_layer/home/home_screen.dart';
import 'package:fash_ai/presentation_layer/notification/notification_screen.dart';
import 'package:fash_ai/presentation_layer/preferences/clothing_preferences.dart';
import 'package:fash_ai/presentation_layer/preferences/product_preference.dart';
import 'package:fash_ai/presentation_layer/profile/bloc/profile_bloc.dart';
import 'package:fash_ai/presentation_layer/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../global/constants/app_constant.dart';
import '../../../../presentation_layer/authentication/forgetPassword/forgot_password.dart';
import '../../../../presentation_layer/premium/premium_screen.dart';
import 'name.dart';

class AppPage {
  static List<PageEntity> routes = [
    PageEntity(
      route: AppRoutes.initial,
      page: const LoginScreen(),
      bloc: BlocProvider(
        create: (_) => LoginBloc(),
      ),
    ),
    PageEntity(
      route: AppRoutes.login,
      page: const LoginScreen(),
      bloc: BlocProvider(
        create: (_) => LoginBloc(),
      ),
    ),
    PageEntity(
      route: AppRoutes.register,
      page: const RegistrationScreen(),
      bloc: BlocProvider(
        create: (_) => RegisterBloc(),
      ),
    ),
    PageEntity(
      route: AppRoutes.clothingPreferencesScreen,
      page: const ClothingPreferencesScreen(),
    ),
    PageEntity(
      route: AppRoutes.productPreferencesScreen,
      page: ProductPreferencesScreen(),
    ),
    PageEntity(
      route: AppRoutes.home,
      page: HomeScreen(),
    ),
    // PageEntity(
    //   route: AppRoutes.aiChatScreen,
    //   page: const ChatScreen(),
    // ),
    PageEntity(
      route: AppRoutes.application,
      page: const ApplicationPage(),
      bloc: BlocProvider(
        create: (_) => AppBlocs(),
      ),
    ),
    PageEntity(
      route: AppRoutes.notificationScreen,
      page: const NotificationScreen(),
    ),
    PageEntity(
      route: AppRoutes.forgetNotification,
      page: const ForgotNotificationScreen(),
    ),
    PageEntity(
      route: AppRoutes.brandsScreen,
      page: const BrandsScreen(),
    ),
    PageEntity(
      route: AppRoutes.proSubscriptionScreen,
      page: const ProSubscriptionScreen(),
    ),
    PageEntity(
      route: AppRoutes.forgetNotification,
      page: const ProSubscriptionScreen(),
    ),
    PageEntity(
      route: AppRoutes.forgetPassword,
      page: ForgotPasswordScreen(),
    ),
    PageEntity(
      route: AppRoutes.profile,
      page: const ProfileScreen(),
      bloc: BlocProvider(
        create: (_) => ProfileBloc(databaseHelper: DatabaseHelper()),
      ),
    )
  ];

  static List<BlocProvider> allBlocProviders(BuildContext context) {
    List<BlocProvider> blocProviders = <BlocProvider>[];
    for (var bloc in routes) {
      if (bloc.bloc != null) {
        blocProviders.add(bloc.bloc as BlocProvider);
      }
    }
    return blocProviders;
  }

  static MaterialPageRoute generateRouteSettings(RouteSettings settings) {
    var result = routes.where((element) => element.route == settings.name);

    // Check if user is logged in
    bool isLoggedIn = Global.storageServices.getIsLoggedIn();

    if (result.isNotEmpty) {
      if (result.first.route == AppRoutes.initial) {
        if (isLoggedIn) {
          print("User is logged in, checking preferences...");

          // Assume preferenceScreenCompleted is stored locally or passed as a parameter
          bool preferenceCompleted = Global.preferenceScreenCompleted;
          bool preferenceCompletedTwo = Global.storageServices
              .getBool(AppConstants.PREFERENCE_SCREEN_KEY, true);
          print(
              "Preferences are ${preferenceCompleted}"); // Fetch this value earlier in app flow

          if (preferenceCompleted || preferenceCompletedTwo) {
            print("Preferences are completed, navigating to HomeScreen");
            return MaterialPageRoute(
                builder: (_) => const ApplicationPage(), settings: settings);
          } else {
            print(
                "Preferences not completed, navigating to ClothingPreferencesScreen");
            return MaterialPageRoute(
                builder: (_) => const ClothingPreferencesScreen(),
                settings: settings);
          }
        } else {
          print("User not logged in, navigating to LoginScreen");
          return MaterialPageRoute(
              builder: (_) => const LoginScreen(), settings: settings);
        }
      }

      return MaterialPageRoute(
          builder: (_) => result.first.page, settings: settings);
    }

    return MaterialPageRoute(
        builder: (_) => const LoginScreen(), settings: settings);
  }
}

class PageEntity {
  String route;
  Widget page;
  dynamic bloc;
  PageEntity({required this.route, required this.page, this.bloc});
}
