import 'package:fash_ai/app.dart';
import 'package:fash_ai/global/widgets/toast_info.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class Brand {
  final String name;
  final String description;
  final String logo;
  final String products;
  final String links;

  Brand(
      {required this.name,
      required this.description,
      required this.logo,
      required this.products,
      required this.links});
}

final List<Brand> brands = [
  Brand(
      name: "Koton",
      description:
          "Discover Koton's rich collection offering stylish and fashionable products for every taste this season.",
      logo: "assets/icons/koton.png",
      products: "View 30 Products",
      links: "https://www.koton.com/"),
  Brand(
      name: "Zara",
      description:
          "Explore Zara's trendy and modern collection that caters to all your fashion needs this season.",
      logo: "assets/icons/zara.png",
      products: "View 30 Products",
      links: "https://www.zara.com/"),
  Brand(
      name: "Mavi",
      description:
          "Find high-quality denim and clothing items with Mavi's signature style for every occasion.",
      logo: "assets/icons/mavi.png",
      products: "View 30 Products",
      links: "https://us.mavi.com/"),
  Brand(
      name: "H&M",
      description:
          "Shop H&M's wide range of products, offering affordable and fashionable pieces for everyone.",
      logo: "assets/icons/hnm.png",
      products: "View 30 Products",
      links: "https://www.hm.com/entrance.ahtml?orguri=%2F"),
  Brand(
      name: "Bershka",
      description:
          "Check out Bershka's youthful and trendy collection with the latest fashion for the season.",
      logo: "assets/icons/bershka.png",
      products: "View 30 Products",
      links: "https://www.bershka.com/"),
  Brand(
      name: "Vakko",
      description:
          "Experience Vakko's luxurious collection with premium products designed for sophistication.",
      logo: "assets/icons/vakko.png",
      products: "View 30 Products",
      links: "https://www.vakko.com/"),
];

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  _BrandsScreenState createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  String searchQuery = "";

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) {
      print('Invalid URL: $url');
      showToast(msg: 'Invalid URL: URL is null or empty');
      return;
    }

    // Normalize and encode the URL
    String normalizedUrl = normalizeUrl(url);
    print('Attempting to launch: $normalizedUrl');

    final Uri? uri = Uri.tryParse(normalizedUrl);

    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      print('Could not launch URL: $normalizedUrl');
      showToast(msg: 'Could not launch $normalizedUrl');
    }
  }

  String normalizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    List<Brand> filteredBrands = brands
        .where((brand) =>
            brand.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        title: const Text(
          'All Brands',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search brand",
                hintStyle: const TextStyle(color: Color(0XFF999999)),
                prefixIcon: const IconTheme(
                  data: IconThemeData(
                    size: 24, // Set the icon size
                    color: Color(0XFF999999), // Icon color
                  ),
                  child: Icon(Icons.search),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0XFFF3F3F3),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          // Brand Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                itemCount: filteredBrands.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final brand = filteredBrands[index];
                  return InkWell(
                    onTap: () {
                      if (brand.links != null && brand.links!.isNotEmpty) {
                        print("Launching link: ${brand.links}");
                        _launchURL(brand.links);
                      } else {
                        print("Link is null or empty");
                        // Optionally, show an error message or a dialog
                      }
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Brand Logo
                            SizedBox(
                              width: 153.w,
                              height: 55.h,
                              child: Center(
                                child: Image.asset(
                                  brand.logo,
                                  height: 15.h,
                                  width: 72.w,
                                ),
                              ),
                            ),
                            Divider(
                                height: 1, color: Colors.grey.withOpacity(0.2)),
                            SizedBox(height: 12.h),
                            // Brand Name
                            Text(
                              brand.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Brand Description
                            Expanded(
                              child: Text(
                                brand.description,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: const Color(0XFF909090),
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // View Products
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "View 30 Products",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SvgPicture.asset(
                                  "assets/icons/right_arrow_one.svg",
                                  width: 16.w,
                                  height: 16.h,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
