import 'package:fash_ai/backend_layer/main/navigation/routes/name.dart';
import 'package:fash_ai/backend_layer/main/navigation/routes/page.dart';
import 'package:fash_ai/global/app_theme/app_theme.dart';
import 'package:fash_ai/presentation_layer/ai_chat/provider/attempts_provider.dart';
import 'package:fash_ai/presentation_layer/ai_chat/provider/chat_provider.dart';
import 'package:fash_ai/presentation_layer/authentication/login/screens/login_screen.dart';
import 'package:fash_ai/presentation_layer/premium/provider/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
// import '../presentation/ai_chat/provider/chat_provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 3));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...AppPage.allBlocProviders(context),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AttemptsProvider()),
      ],
      child: ScreenUtilInit(
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateRoute: AppPage.generateRouteSettings,
            initialRoute: AppRoutes.initial,
            themeMode: ThemeMode.light,
            theme: AppTheme.lightTheme,
          );
        },
      ),
    );
  }
}
