import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fash_ai/global/constants/app_constant.dart';
import 'package:fash_ai/global/global.dart';
import 'package:flutter/material.dart';
import 'package:fash_ai/presentation_layer/preferences/widgets/circular_button.dart';

import '../../backend_layer/main/navigation/routes/name.dart';

class ClothingPreferencesScreen extends StatefulWidget {
  const ClothingPreferencesScreen({Key? key}) : super(key: key);

  @override
  _ClothingPreferencesScreenState createState() =>
      _ClothingPreferencesScreenState();
}

class _ClothingPreferencesScreenState extends State<ClothingPreferencesScreen>
    with SingleTickerProviderStateMixin {
  // Track current step (0 for Clothing, 1 for Product)
  int currentStep = 0;

  // Firebase References
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of clothing styles

  List<String> selectedStyles = [];

  // Product preferences

  List<int> selectedProducts = [];

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Create a tween animation for progress (0.0 to 0.5 initially)
    _progressAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void toggleClothingSelection(String style) {
    setState(() {
      if (selectedStyles.contains(style)) {
        selectedStyles.remove(style);
      } else {
        selectedStyles.add(style);
      }
    });
  }

  void toggleProductSelection(int index) {
    setState(() {
      if (selectedProducts.contains(index)) {
        selectedProducts.remove(index);
      } else {
        selectedProducts.add(index);
      }
    });
  }

  Future<void> savePreferencesToFirestore() async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        // Save selected preferences to Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'clothingStyles': selectedStyles,
          'selectedProducts': selectedProducts.map((index) => AppConstants.products[index]['label']).toList(),
          'preferenceScreenCompleted':true,
        });

        Global.storageServices.setBool(AppConstants.PREFERENCE_SCREEN_KEY, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving preferences: $e")),
        );
      }
    }
  }

  void proceedToNextStep() async {
    if (currentStep == 0) {
      if (selectedStyles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one clothing style.")),
        );
        return;
      }
      // Animate progress to 50% and switch to the Product Preferences screen
      _progressController.animateTo(1.0);
      setState(() {
        currentStep = 1;
      });
    } else {
      if (selectedProducts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one product.")),
        );
        return;
      }
      // Save preferences to Firestore
      await savePreferencesToFirestore();

      // Navigate to the next application route
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.application, (route) => false);
    }
  }

  void goBack() {
    if (currentStep == 1) {
      _progressController.animateBack(0.5);
      setState(() {
        currentStep = 0;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  currentStep == 0
                      ? "From the following clothing\nstyles which ones do you like?"
                      : "Which of the following products you'd rather wear?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: currentStep == 0
                    ? ListView.builder(
                        itemCount: AppConstants.clothingStyles.length,
                        itemBuilder: (context, index) {
                          final style = AppConstants.clothingStyles[index];
                          final isSelected = selectedStyles.contains(style);

                          return GestureDetector(
                            onTap: () => toggleClothingSelection(style),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFF4F4F4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    style,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.black
                                            : const Color(0XFFA3A5A4),
                                        width: 1,
                                      ),
                                      color: isSelected ? Colors.black : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                                        : const Icon(Icons.check, size: 16, color: Color(0XFFA3A5A4)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: AppConstants.products.length,
                        itemBuilder: (context, index) {
                          final product = AppConstants.products[index];
                          final isSelected = selectedProducts.contains(index);

                          return GestureDetector(
                            onTap: () => toggleProductSelection(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green.shade50
                                    : const Color(0XFFF3F3F3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.green
                                      : const Color(0XFFF3F3F3),
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    bottom: 1,
                                    right: 1,
                                    child: Image.asset(
                                      product['image']!,
                                      width: 110,
                                      height: 110,
                                    ),
                                  ),
                                  isSelected
                                      ? const Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 24,
                                          ),
                                        )
                                      : const Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Color(0XFFA3A5A4),
                                            size: 24,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return CircularProgressButton(
                      value: _progressAnimation.value,
                      onPressed: proceedToNextStep,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
