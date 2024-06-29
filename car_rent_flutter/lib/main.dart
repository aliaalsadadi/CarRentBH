import 'package:car_rent_flutter/screens/login_screen.dart';
import 'package:car_rent_flutter/screens/main_layout.dart';
import 'package:car_rent_flutter/screens/signup_screen.dart';
import 'package:car_rent_flutter/utils/firebase_manager.dart';
import 'package:car_rent_flutter/widgets/text_field_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          storageBucket: "gs://rentroam-1d9ba.appspot.com",
          apiKey: "AIzaSyAISsovfV6s3i3c_DvslPQQoBvuKQ0hM10",
          appId: "1:399489229730:android:6b2ed306bfaae9f58508fb",
          messagingSenderId: "399489229730",
          projectId: "rentroam-1d9ba"));
  await FirebaseManager.instance.init();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bahrain Car Rental',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FirebaseAuth.instance.currentUser != null
          ? const MainLayout()
          : const LoginScreen(),
    );
  }
}
