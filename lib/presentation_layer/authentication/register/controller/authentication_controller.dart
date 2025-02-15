import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fash_ai/backend_layer/main/navigation/routes/name.dart';
import 'package:fash_ai/data_store/domain/entities/user.dart';
import 'package:fash_ai/data_store/domain/repositories/user_repository.dart';
import 'package:fash_ai/data_store/repositories/firebase_user_repository.dart';
import 'package:fash_ai/global/widgets/toast_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';

class AuthenticationController {
  UserRepository userRepository = FirebaseUserRepository();
  final FirebaseStorage storage = FirebaseStorage.instance;

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

  Future<void> signUp(
      String email, String password, String name, BuildContext context) async {
    try {
      firebase_auth.UserCredential userCredential = await firebase_auth
          .FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!.sendEmailVerification();
      userCredential.user?.emailVerified;

      // Generate unique IDs for products
      final List<Map<String, String>> productsWithIds = assistants.map((product) {
        String uniqueId = const Uuid().v4(); // Using UUID for unique ID
        return {
          'id': uniqueId,
          'title': product['title']!,
          'subtitle': product['subtitle']!,
          'icon':product['icon']!,
        };
      }).toList();

      // Create user data with products
      User newUser = User(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        imageUrl: '',
        createdAt: DateTime.now(),
        preferenceScreenCompleted: false,
      );

      // Store user data in Firebase Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'id': newUser.id,
        'name': newUser.name,
        'email': newUser.email,
        'imageUrl': newUser.imageUrl,
        'createdAt': newUser.createdAt,
        'assistants': productsWithIds,
        'preferenceScreenCompleted':newUser.preferenceScreenCompleted // Add the products list to the user data
      });

      showToast(
          msg: "Verification email has been sent. Please check your email.");
      context.read<RegisterBloc>().add(RegisterLoadingEvent(false));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (route) => false);
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred";
      switch (e.code) {
        case 'weak-password':
          errorMessage = "The password provided is too weak.";
          context
              .read<RegisterBloc>()
              .add(RegisterLoadingEvent(false)); // Stop loading

          break;
        case 'email-already-in-use':
          errorMessage = "An account already exists for that email.";
          context
              .read<RegisterBloc>()
              .add(RegisterLoadingEvent(false)); // Stop loading

          break;
        case 'invalid-email':
          errorMessage = "The email address is not valid.";
          context
              .read<RegisterBloc>()
              .add(RegisterLoadingEvent(false)); // Stop loading

          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }
      showToast(
        msg: errorMessage,
      );
    } catch (e) {
      showToast(
        msg: "Error during registration: ${e.toString()}",
      );
    }
  }

  Future<void> signOut() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
  }

  void resetPassword(String email, BuildContext context) async {
    try {
      await firebase_auth.FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);
      showToast(
        msg: "Password reset email sent.",
      );
    } catch (e) {
      showToast(
        msg: "Error sending reset email: ${e.toString()}",
      );
    }
  }
}
