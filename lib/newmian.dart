// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: ProductScreen(),
//     );
//   }
// }
//
// class ProductScreen extends StatefulWidget {
//   @override
//   _ProductScreenState createState() => _ProductScreenState();
// }
//
// class _ProductScreenState extends State<ProductScreen> {
//   final InAppPurchase _inAppPurchase = InAppPurchase.instance;
//   List<ProductDetails> _products = [];
//   String _errorMessage = '';
//   bool _loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProducts();
//   }
//
//   Future<void> _fetchProducts() async {
//     try {
//       print('Checking in-app purchase availability...');
//       final bool isAvailable = await _inAppPurchase.isAvailable();
//       print('In-app purchase available: $isAvailable');
//       if (!isAvailable) {
//         setState(() {
//           _errorMessage = 'In-app purchases are not available.';
//           _loading = false;
//         });
//         return;
//       }
//
//       const Set<String> productIds = {
//         'fashai_weekly',
//         'fash_ai_monthly',
//         'fashai_yearly',
//       };
//       print('Querying product details for: $productIds');
//
//       final ProductDetailsResponse response =
//       await _inAppPurchase.queryProductDetails(productIds);
//
//       print('Response error: ${response.error}');
//       print('Fetched products: ${response.productDetails}');
//
//       if (response.error != null) {
//         setState(() {
//           _errorMessage = 'Error fetching products: ${response.error!.message}';
//           _loading = false;
//         });
//         return;
//       }
//
//       if (response.productDetails.isEmpty) {
//         setState(() {
//           _errorMessage = 'No products found.';
//           _loading = false;
//         });
//         return;
//       }
//
//       setState(() {
//         _products = response.productDetails;
//         _loading = false;
//       });
//     } catch (e) {
//       print('Exception: $e');
//       setState(() {
//         _errorMessage = 'Error: $e';
//         _loading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('In-App Purchases')),
//       body: _loading
//           ? Center(child: CircularProgressIndicator())
//           : _errorMessage.isNotEmpty
//           ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
//           : ListView.builder(
//         itemCount: _products.length,
//         itemBuilder: (context, index) {
//           final product = _products[index];
//           return ListTile(
//             title: Text(product.title),
//             subtitle: Text(product.description),
//             trailing: Text(product.price),
//           );
//         },
//       ),
//     );
//   }
// }
