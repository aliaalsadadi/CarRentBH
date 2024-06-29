import 'dart:developer';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:car_rent_flutter/models/car.dart';
import 'package:car_rent_flutter/utils/firebase_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();

  XFile? img = await imagePicker.pickImage(source: source);

  if (img != null) {
    return await img.readAsBytes();
  }
  print("no image selected");
}

Future<String> addListing(
    CarListing carListing, Uint8List file, String id) async {
  try {
    CollectionReference ref =
        FirebaseFirestore.instance.collection('car_listings');
    await ref.doc(id).set(carListing.toJson());
    return "Succesfully added car!";
  } on Exception catch (e) {
    log(e.toString());
    return "failed to publish car";
  }
}

Future<String> rentListing(CarListing carListing, String carID) async {
  try {
    CollectionReference ref =
        FirebaseFirestore.instance.collection('car_listings');
    await ref.doc(carID).update(
      {
        'isRented': true,
      },
    );
    return "Succesfully rented car!";
  } catch (e) {
    return "failed to rent car";
  }
}

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}
