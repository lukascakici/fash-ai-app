import 'package:firebase_auth/firebase_auth.dart';
import 'package:fash_ai/backend_layer/main/navigation/routes/name.dart';
import 'package:fash_ai/global/constants/app_constant.dart';
import 'package:fash_ai/global/global.dart';
import 'package:fash_ai/global/widgets/toast_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';

class SignInController {
  const SignInController();

  Future<void> handleSignIn(String type, BuildContext context) async {
    final loginBloc = context.read<LoginBloc>();
    loginBloc.add(LoginLoadingEvent(true));

    try {
      if (type == "email") {
        final state = context.read<LoginBloc>().state;
        String emailAddress = state.email;
        String password = state.password;

        List<String> errors = [];

        if (emailAddress.isEmpty) {
          errors.add("Email must be filled in");
        }

        if (state.password.isEmpty) {
          errors.add("Password must be filled in");
        }

        if (errors.isNotEmpty) {
          if (!context.mounted) return;
          showToast(msg: errors.join(' and '));
          loginBloc.add(LoginLoadingEvent(false));
          return;
        }

        UserCredential credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailAddress, password: password);
        User? user = credential.user;

        if (user != null && !user.emailVerified) {
          if (!context.mounted) return;
          showToast(msg: "Please verify your email address to log in.");
          loginBloc.add(LoginLoadingEvent(false));
          return;
        } else if (user == null) {
          if (!context.mounted) return;
          showToast(msg: "Login failed. Please check your credentials.");
          loginBloc.add(LoginLoadingEvent(false));
          return;
        }

        String? token = await user.getIdToken();
        await Global.storageServices
            .setString(AppConstants.STORAGE_USER_TOKEN_KEY, token!);
        loginBloc.add(LoginCredentialsClearedEvent());

        if (!context.mounted) return;

        bool preferenceCompleted = Global.preferenceScreenCompleted;
        if(preferenceCompleted) {

        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.application, (route) => false);
        }
        else {
          Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.clothingPreferencesScreen, (route) => false);
        }
      }
      if (context.mounted) {
        loginBloc.add(LoginLoadingEvent(false));
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _handleFirebaseAuthException(e, loginBloc);
      }
    }
  }

  // Handle Firebase Authentication errors
  void _handleFirebaseAuthException(
      FirebaseAuthException e, LoginBloc loginBloc) {
    if (e.code == "user-not-found") {
      showToast(msg: "No user found for that email");
    } else if (e.code == "wrong-password") {
      showToast(msg: "Incorrect password provided for that user");
    } else if (e.code == "invalid-email") {
      showToast(msg: "The email address is not in a valid format");
    } else {
      showToast(msg: "An error occurred: ${e.message}");
    }
    loginBloc.add(LoginLoadingEvent(false));
  }
}
