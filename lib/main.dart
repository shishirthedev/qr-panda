import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'src/services/ad_service.dart';
import 'src/services/premium_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PremiumService.instance.init();
  await AdService.instance.init();
  runApp(const MyApp());
}
