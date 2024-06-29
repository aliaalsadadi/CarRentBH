import 'package:car_rent_flutter/models/User.dart' as model;
import 'package:car_rent_flutter/models/car.dart';
import 'package:car_rent_flutter/utils/firebase_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Your CarListing class definition goes here...

class CarListingProvider extends ChangeNotifier {
  CarListing? _carListing;

  CarListing? get carListing => _carListing;

  void updateCarListing(CarListing newCarListing) {
    _carListing = newCarListing;
    notifyListeners();
  }
}

class UserProvider with ChangeNotifier {
  model.User? _user;
  FirebaseFirestore _db = FirebaseFirestore.instance;

  model.User get getUser => _user!;
  Future<void> refreshUser() async {
    _user = (await FirebaseManager.instance.getUserDetails()) as model.User?;
    notifyListeners();
  }
}
