import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fash_ai/backend_layer/main/navigation/routes/name.dart';
import 'package:fash_ai/data_store/domain/entities/user.dart' as user_model;

import 'package:fash_ai/global/app_theme/app_colors.dart';
import 'package:fash_ai/global/constants/app_constant.dart';
import 'package:fash_ai/global/global.dart';
import 'package:fash_ai/global/widgets/toast_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:uuid/uuid.dart';

GestureDetector buildThirdPartyWidget(
    {required String iconPath, Function()? onPressed, required String text}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
        height: 40.h,
        width: 145.w,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.surface),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath),
            SizedBox(
              width: 5.w,
            ),
            Text(text),
          ],
        )),
  );
}

class ThirdPartyPlugins extends StatefulWidget {
  const ThirdPartyPlugins({super.key});

  @override
  State<ThirdPartyPlugins> createState() => _ThirdPartyPluginsState();
}

class _ThirdPartyPluginsState extends State<ThirdPartyPlugins> {
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  void _toggleLoading(bool value) {
    _isLoading.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) {
        return Column(
          children: [
            if (isLoading)
              Center(
                child: SpinKitFadingCircle(
                  color: Colors.black,
                  size: 35.r,
                ),
              ),
            if (!isLoading)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildThirdPartyWidget(
                    iconPath: "assets/icons/google_logo.svg",
                    onPressed: () {
                      FocusScope.of(context).unfocus();

                      _toggleLoading(true);
                      GoogleAuthentication()
                          .signInWithGoogle(context, _toggleLoading);
                    },
                    text: 'Google',
                  ),
                  SizedBox(width: 10.h),
                  buildThirdPartyWidget(
                    iconPath: "assets/icons/apple_icon.svg",
                    onPressed: () {
                      FocusScope.of(context).unfocus();

                      _toggleLoading(true);
                      AppleAuthentication()
                          .signInWithApple(context, _toggleLoading);
                    },
                    text: 'Apple',
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class GoogleAuthentication {
  final FirebaseAuth auth = FirebaseAuth.instance;

  void signInWithGoogle(
      BuildContext context, Function(bool) toggleLoading) async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        toggleLoading(false); // Stop loading when user cancels the login
        return;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        await storeUserDataInFirestore(user, context);
      }
      toggleLoading(false);
    } catch (error) {
      print(error);
      toggleLoading(false);
    }
  }
}

class AppleAuthentication {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> signInWithApple(
      BuildContext context, Function(bool) toggleLoading) async {
    try {
      debugPrint("Initiating Apple sign-in...");
      final result = await TheAppleSignIn.performRequests([
        const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);
      debugPrint("Apple sign-in result => Status: ${result.status}");

      switch (result.status) {
        case AuthorizationStatus.authorized:
          debugPrint("Apple sign-in authorized.");
          final AppleIdCredential credential = result.credential!;
          final oAuthProvider = OAuthProvider('apple.com');
          final AuthCredential authCredential = oAuthProvider.credential(
            idToken: String.fromCharCodes(credential.identityToken!),
            accessToken: String.fromCharCodes(credential.authorizationCode!),
          );

          debugPrint("Signing in with Firebase using Apple credentials...");
          final UserCredential userCredential =
          await auth.signInWithCredential(authCredential);
          final User? user = userCredential.user;

          if (user != null) {
            debugPrint("Firebase sign-in successful for user: ${user.uid}");
            await storeUserDataInFirestore(user, context);
            toggleLoading(false); // Stop loading after successful sign-in
            return user;
          }
          debugPrint("No user found after Firebase sign-in.");
          toggleLoading(false);
          throw Exception('No user found after Apple sign-in');

        case AuthorizationStatus.error:
          debugPrint("Apple sign-in error: ${result.error}");
          toggleLoading(false);
          throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: result.error.toString(),
          );

        case AuthorizationStatus.cancelled:
          debugPrint("Apple sign-in cancelled by user.");
          toggleLoading(false);
          throw PlatformException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Sign in aborted by user',
          );

        default:
          debugPrint("Apple sign-in unknown status: ${result.status}");
          toggleLoading(false);
          throw UnimplementedError('Unknown authorization status');
      }
    } catch (e) {
      debugPrint("Apple sign-in exception: $e");
      toggleLoading(false); // Stop loading on error
      rethrow;
    }
  }
}

// Future<void> storeUserDataInFirestore(
//     User firebaseUser, BuildContext context) async {
//   // Create a user model instance
//   user_model.User newUser = user_model.User(
//     name: firebaseUser.displayName ?? "",
//     id: firebaseUser.uid,
//     imageUrl: firebaseUser.photoURL ?? "",
//     createdAt: DateTime.now(),
//     email: firebaseUser.email ?? "",
//   );

//   try {
//     // Reference the Firestore collection and document
//     DocumentReference userDoc =
//         FirebaseFirestore.instance.collection("users").doc(firebaseUser.uid);

//     // Check if the user document already exists
//     DocumentSnapshot snapshot = await userDoc.get();

//     if (!snapshot.exists) {
//       // If the document doesn't exist, create a new user entry
//       await userDoc.set(newUser.toJson());
//     }

//     // Get and store the user token
//     String? token = await firebaseUser.getIdToken();
//     await Global.storageServices
//         .setString(AppConstants.STORAGE_USER_TOKEN_KEY, token!);
//     // Navigate to the application screen
//     Navigator.pushNamedAndRemoveUntil(
//         context, AppRoutes.home, (route) => false);
//     } catch (e) {
//     // Handle any errors
//     showToast(msg: e.toString());
//   }
// }


Future<void> storeUserDataInFirestore(
    User firebaseUser, BuildContext context) async {
  // Predefined assistants list
 final List<Map<String, String>> assistants = [
    {
      'title': 'Your Assistant',
      'subtitle': 'I am your favorite assistant. I can help you with everything.',
      'icon': 'assets/icons/your_assistant.png'
    },
    {
      'title': 'Fashion Assistant',
      'subtitle': 'I can help you with fashion.',
      'icon': 'assets/icons/fashion_assistant.png'
    },
    {
      'title': 'GymFit Assistant',
      'subtitle': 'I can help you with sportswear.',
      'icon': 'assets/icons/gymfit_assistant.png'
    },
    {
      'title': 'Daily Assistant',
      'subtitle': 'I can help you with daily clothing.',
      'icon': 'assets/icons/daily_assistant.png'
    },
    {
      'title': 'Special Assistant',
      'subtitle': 'I can help you with special day clothing.',
      'icon': 'assets/icons/special_assistant.png'
    },
  ];

  final List<Map<String, String>> assistantsWithIds = assistants.map((product) {
        String uniqueId = const Uuid().v4(); // Using UUID for unique ID
        return {
          'id': uniqueId,
          'title': product['title']!,
          'subtitle': product['subtitle']!,
          'icon':product['icon']!,
        };
      }).toList();

  // Create a user model instance
  user_model.User newUser = user_model.User(
    name: firebaseUser.displayName ?? "",
    id: firebaseUser.uid,
    imageUrl: firebaseUser.photoURL ?? "",
    createdAt: DateTime.now(),
    email: firebaseUser.email ?? "",
  );

  try {
    // Reference the Firestore collection and document
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection("users").doc(firebaseUser.uid);

    // Check if the user document already exists
    DocumentSnapshot snapshot = await userDoc.get();

    if (!snapshot.exists) {
      // If the document doesn't exist, create a new user entry
      await userDoc.set({
        ...newUser.toJson(),
        'assistants': assistantsWithIds,
      });
    }

    // Fetch user preferences from Firestore
    Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;
    bool hasCompletedPreferenceScreen =
        userData?['preferenceScreenCompleted'] ?? false; // Default to false

    // Navigate based on preferences
    if (!hasCompletedPreferenceScreen) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.clothingPreferencesScreen, (route) => false);
    } else {
      // Get and store the user token
      String? token = await firebaseUser.getIdToken();
      print("Id token is $token");

      await Global.storageServices
          .setString(AppConstants.STORAGE_USER_TOKEN_KEY, token!);

      // Navigate to the application screen
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.application, (route) => false);
    }
  } catch (e) {
    // Handle any errors
    showToast(msg: e.toString());
  }
}
