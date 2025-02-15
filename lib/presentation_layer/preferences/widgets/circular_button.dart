import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CircularProgressButton extends StatelessWidget {
  final double value;
  final Function()? onPressed;

  const CircularProgressButton({super.key, required this.value, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, top: 20, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align to the right
        children: [
          // Linear Progress Indicator with fixed width
          SizedBox(
            
            width: 40, // Define the width here
            height: 8,
            child: LinearProgressIndicator( 
              borderRadius: BorderRadius.circular(20),
              value: value, // Progress value (0.0 to 1.0)
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 20), // Spacing between elements
          // Circular Progress Button
          Stack(
            alignment: Alignment.center,
            children: [
              // Grey circular progress (background)
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 1.0, // Full circle
                  strokeWidth: 3,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.grey.shade50, // Grey color for the circle
                  ),
                ),
              ),
              // Green progress (dynamic progress)
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: value, // Progress value (0.0 to 1.0)
                  strokeWidth: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0XFF23DD9A), // Green progress color
                  ),
                ),
              ),
              // Inner Circular Button with Arrow Icon
              GestureDetector(
                onTap: onPressed,
                behavior: HitTestBehavior.translucent, // Disable ripple effect
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0XFF23DD9A),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons/right_arrow.svg",
                      width: 14,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
