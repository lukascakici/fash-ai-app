import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fash_ai/backend_layer/main/navigation/routes/name.dart';
import 'package:fash_ai/global/app_theme/app_colors.dart';
import 'package:fash_ai/presentation_layer/profile/widgets/logout_button.dart';
import 'package:fash_ai/presentation_layer/profile/widgets/logout_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../global/constants/app_constant.dart';
import '../../../global/global.dart';
import '../../premium/provider/subscription_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  late User? currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isUpdating = false;

  final List<Map<String, String>> products = [
    {"image": "assets/icons/jacket.png", "label": "Jacket"},
    {"image": "assets/icons/pant.png", "label": "Pants"},
    {"image": "assets/icons/mini_skirt.png", "label": "Mini Skirt"},
    {"image": "assets/icons/shoes.png", "label": "Shoes"},
    {"image": "assets/icons/jacket_1.png", "label": "Coat"},
    {"image": "assets/icons/kot.png", "label": "Pink Pants"},
  ];

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (currentUser != null) {
      final snapshot =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _confirmAccountDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete "),
          content: Text(
            "Are you sure you want to delete your account? This action cannot be undone",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteAccount(context);
              },
              child: Text(
                "delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isValidUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      // Delete profile image from Firebase Storage if it exists
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${currentUser!.uid}.jpg');
        await storageRef.delete();
      } catch (e) {
        print('Error deleting profile image: $e');
      }

      // Delete user data from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .delete();

      // Delete user from Firebase Auth
      await currentUser?.delete();

      // Sign out
      await FirebaseAuth.instance.signOut();

      // Clear locally stored data
      await Global.storageServices.remove(AppConstants.STORAGE_USER_TOKEN_KEY);
      await Global.storageServices.setPreferenceScreenCompleted(false);

      // Use WidgetsBinding to navigate after current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (Route<dynamic> route) => false,
        );
      });

      print('stage 6');
      // Show a success message if still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account deleted successfully')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please re-authenticate and try again.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: ${e.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updateProfileImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        setState(() {
          isUpdating = true; // Start loader
        });

        // Upload the image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${currentUser!.uid}.jpg');
        await storageRef.putFile(File(pickedFile.path));

        // Get the download URL
        final newImageUrl = await storageRef.getDownloadURL();

        // Update the Firestore document with the new image URL
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .update({'imageUrl': newImageUrl});

        // Update local state
        setState(() {
          userData!['imageUrl'] = newImageUrl;
          isUpdating = false; // Stop loader
        });
      } catch (e) {
        setState(() {
          isUpdating = false; // Stop loader in case of an error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload image: $e")),
        );
      }
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return "Unknown";
    }

    try {
      final DateTime date = (timestamp is Timestamp)
          ? timestamp.toDate()
          : DateTime.parse(timestamp.toString());

      return DateFormat('MMMM d yyyy').format(date);
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    bool isPremium = subscriptionProvider.isPremium;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40.h),
                        // Header Section
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    "My Profile",
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    // Premium Button
                                    Container(
                                      padding: EdgeInsets.only(left: 8.w),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(30.r),
                                        border: Border.all(
                                            color:
                                                Colors.grey.withOpacity(0.3)),
                                        color: AppColors.card,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          !isPremium
                                              ? Navigator.pushNamed(
                                                  context,
                                                  AppRoutes
                                                      .proSubscriptionScreen)
                                              : null;
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              "Premium",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            SvgPicture.asset(
                                              'assets/icons/premium_icon.svg',
                                              height: 30.sp,
                                              width: 30.sp,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    // Delete Account Button
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            // Profile Picture with Edit Option
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 50.r,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: userData?['imageUrl'] != null
                                      ? _isValidUrl(userData!['imageUrl'])
                                          ? NetworkImage(userData!['imageUrl'])
                                          : FileImage(
                                                  File(userData!['imageUrl']))
                                              as ImageProvider
                                      : null,
                                  child: userData?['imageUrl'] == null
                                      ? SvgPicture.asset(
                                          "assets/icons/default_avatar.svg",
                                          fit: BoxFit.fill,
                                          width: 90.w,
                                          height: 90.h,
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _updateProfileImage,
                                    child: CircleAvatar(
                                      radius: 14.r,
                                      backgroundColor: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            // Name and Username
                            Text(
                              userData?['name'] ?? 'Name Surname',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "@${userData?['email'] ?? 'username'}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset("assets/icons/date_icon.svg"),
                                SizedBox(width: 4.w),
                                Text(
                                  "Joined ${_formatTimestamp(userData?['createdAt'])}",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Container(
                              height: 30.h,
                              width: 160.w,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.r),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.3)),
                                color: AppColors.card,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _confirmAccountDeletion(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Delete Account",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    SvgPicture.asset(
                                      'assets/icons/delete.svg',
                                      colorFilter: ColorFilter.mode(
                                          Colors.red, BlendMode.srcIn),
                                      height: 15.sp,
                                      width: 15.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 10.h,
                        ),

                        SizedBox(height: 20.h),
                        // Clothing Styles
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Clothing Styles",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          alignment: Alignment.topLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  (userData?['clothingStyles'] ?? ['Casual'])
                                      .asMap()
                                      .entries
                                      .map<Widget>(
                                (entry) {
                                  int index = entry.key;
                                  String style = entry.value;

                                  final colors = [
                                    const Color.fromRGBO(0, 255, 163, 0.2),
                                    const Color.fromRGBO(255, 182, 109, 0.2),
                                    const Color.fromRGBO(222, 172, 255, 0.2),
                                    const Color.fromRGBO(255, 172, 174, 0.2)
                                  ];

                                  Color backgroundColor =
                                      colors[index % colors.length];

                                  return Padding(
                                    padding: EdgeInsets.only(right: 8.w),
                                    child: Chip(
                                      label: Text(
                                        style,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      backgroundColor: backgroundColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(
                                          color: Color(0xffE7E8EC),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        // Favorite Outfits
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Favorite Outfits",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        userData?['selectedProducts'] != null &&
                                userData!['selectedProducts'].isNotEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.2),
                                        width: 2)),
                                height: 80.h,
                                padding: const EdgeInsets.all(8),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      (userData!['selectedProducts'] as List)
                                          .length,
                                  itemBuilder: (context, index) {
                                    // Get product label from Firebase
                                    final selectedProduct =
                                        userData!['selectedProducts'][index];
                                    // Find matching product in the local list
                                    final product = products.firstWhere(
                                      (p) => p['label'] == selectedProduct,
                                      orElse: () => {"image": "", "label": ""},
                                    );
                                    if (product['image'] == "") {
                                      return const SizedBox();
                                    }

                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.asset(
                                        product['image']!,
                                        width: 80.w,
                                        height: 50.h,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                "No favorite outfits added.",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                        // SizedBox(height: 20.h),
                        // Notifications Toggle
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       "Notifications",
                        //       style: TextStyle(
                        //         fontSize: 14.sp,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //     ),
                        //     Switch(
                        //       activeColor: Colors.white,
                        //       activeTrackColor: Colors.green,
                        //       value: userData?['notificationsEnabled'] ?? false,
                        //       onChanged: (value) {
                        //         setState(() {
                        //           userData!['notificationsEnabled'] = value;
                        //         });
                        //         _firestore
                        //             .collection('users')
                        //             .doc(currentUser!.uid)
                        //             .update({'notificationsEnabled': value});
                        //       },
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: 20.h),
                        // Logout Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: LogoutButton(
                            onPressed: () async {
                              showLogoutDialog(context);
                            },
                            iconAssetPath: 'assets/icons/logout.svg',
                            text: 'Logout',
                            isIcon: true,
                            gradient: AppColors.secondaryGradient,
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
          if (isUpdating)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
