import 'package:car_rent_flutter/models/car.dart';
import 'package:car_rent_flutter/widgets/car_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key});

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('car_listings')
            .where("availabilityStartDate",
                isLessThan: Timestamp.fromDate(DateTime.now()))
            .where("availabilityEndDate",
                isGreaterThan: Timestamp.fromDate(DateTime.now()))
            .where("isRented", isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No listings available'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var carListingDoc = snapshot.data!.docs[index];
              var carListingData = carListingDoc.data() as Map<String, dynamic>;
              String sellerID = carListingData['sellerID'];

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(sellerID)
                    .snapshots(),
                builder: (context, sellerSnapshot) {
                  if (sellerSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!sellerSnapshot.hasData) {
                    return const Center(
                      child: Text('Seller data not available'),
                    );
                  }

                  var sellerData =
                      sellerSnapshot.data!.data() as Map<String, dynamic>;
                  print(sellerData.toString());

                  String sellerEmail = sellerData['email'] ?? 'Unknown';
                  String sellerPhoneNumber =
                      sellerData['phoneNumber'] ?? 'Unknown';
                  double personRating = sellerData['rating'] != null
                      ? double.tryParse(sellerData['rating'].toString()) ?? 0.0
                      : 0.0;

                  return CarCard(
                    car: CarListing.fromSnap(carListingDoc),
                    sellerEmail: sellerEmail,
                    personRating: personRating,
                    sellerPhoneNumber: sellerPhoneNumber,
                    profile: false,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
