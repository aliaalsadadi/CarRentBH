import 'package:car_rent_flutter/screens/add_listing_screen.dart';
import 'package:car_rent_flutter/screens/listing_screen.dart';
import 'package:car_rent_flutter/screens/map_screen.dart';
import 'package:car_rent_flutter/screens/profile_screen.dart';
import 'package:car_rent_flutter/screens/search_screen.dart';
import 'package:car_rent_flutter/utils/firebase_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

List<Widget> HomeScreenItems = [
  ListingScreen(),
  SearchScreen(),
  AddListingScreen(),
  FireMap(),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
];
