import 'package:fash_ai/app.dart';
import 'package:fash_ai/backend_layer/main/navigation/routes/name.dart';
import 'package:fash_ai/presentation_layer/preferences/widgets/circular_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductPreferencesScreen extends StatefulWidget {
  @override
  _ProductPreferencesScreenState createState() =>
      _ProductPreferencesScreenState();
}

class _ProductPreferencesScreenState extends State<ProductPreferencesScreen> {
  // Sample product images
  final List<Map<String, String>> products = [
    {"image": "assets/icons/jacket.png", "label": "Jacket"},
    {"image": "assets/icons/pant.png", "label": "Pants"},
    {"image": "assets/icons/mini_skirt.png", "label": "Mini Skirt"},
    {"image": "assets/icons/shoes.png", "label": "Shoes"},
    {"image": "assets/icons/jacket_1.png", "label": "Coat"},
    {"image": "assets/icons/kot.png", "label": "Pink Pants"},
  ];

  List<int> selectedProducts = [];

  void toggleSelection(int index) {
    setState(() {
      if (selectedProducts.contains(index)) {
        selectedProducts.remove(index);
      } else {
        selectedProducts.add(index);
      }
    });
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
            const Center(
              child: Text(
                "Which of the following products you'd rather wear?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final isSelected = selectedProducts.contains(index);

                  return GestureDetector(
                    onTap: () => toggleSelection(index),
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
                            // Product Image
                            Positioned(
                              bottom: 1,
                              right: 1,
                              child: Image.asset(
                                product['image']!,
                                width: 110.w,
                                height: 110.h,
                                
                              ),
                            ),
                            // Checkmark Icon
                            isSelected ?
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ) : const Positioned(
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
            // Spacer to keep the button at a consistent position
            Align(
              alignment: Alignment.bottomCenter,
              child: CircularProgressButton(
                value: 1,
                onPressed: () =>   Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.application, (route) => false),
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

