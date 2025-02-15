import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fash_ai/global/widgets/reusable_button.dart';
import 'package:fash_ai/presentation_layer/application/bloc/app_bloc.dart';
import 'package:fash_ai/presentation_layer/application/bloc/app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addAssistant(BuildContext context) async {
    if (_nameController.text.isEmpty || _subtitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User not logged in");

      // Reference the user's document
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      // Fetch existing assistants
      final userSnapshot = await userDoc.get();
      final assistants =
          userSnapshot.data()?['assistants'] as List<dynamic>? ?? [];

      String uniqueId = const Uuid().v4();
      // Create new assistant
      final newAssistant = {
        "title": _nameController.text.trim(),
        "subtitle": _subtitleController.text.trim(),
        "icon": "assets/icons/fashion_assistant.png",
        "id": uniqueId,
      };

      // Add to the assistants list
      assistants.add(newAssistant);

      // Update in Firestore
      await userDoc.update({"assistants": assistants});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assistant added successfully')),
      );

      context.read<AppBlocs>().add(AppTriggeredEvents(0));

      // Clear fields after success
      _nameController.clear();
      _subtitleController.clear();

      // Navigate to the chat screen or perform other actions if needed
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add assistant: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Center(
                child: Text(
                  "Create a New Assistant",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40.h),

              // Assistant Name
              Text(
                "Assistant name",
                style: TextStyle(fontSize: 15.sp, color: Colors.black),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Enter assistant name",
                  hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                ),
              ),
              SizedBox(height: 24.h),
              // Subtitle
              Text(
                "Subtitle",
                style: TextStyle(fontSize: 15.sp, color: Colors.black),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                style: const TextStyle(color: Colors.black),
                controller: _subtitleController,
                decoration: InputDecoration(
                  hintText: "Enter subtitle",
                  hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ReusableButton(
                  text: _isLoading ? "Loading..." : "Create and start chatting",
                  onPressed: _isLoading
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          _addAssistant(context);
                        },
                  isLoading: _isLoading,
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
