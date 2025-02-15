import 'dart:io';

import 'package:fash_ai/app.dart';
import 'package:fash_ai/global/global.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Global.init();

  if (Platform.isIOS) {
    await Purchases.configure(
        PurchasesConfiguration('appl_XiOTlpNGBHNukqFFespiLhWpOEP'));
  }
  runApp(const MyApp());
}


