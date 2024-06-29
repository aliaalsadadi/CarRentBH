import 'package:car_rent_flutter/models/car.dart';
import 'package:car_rent_flutter/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CarDetails extends StatefulWidget {
  final CarListing car;
  final String sellerEmail;
  final Image carImage;
  final String sellerPhoneNumber;
  CarDetails({
    super.key,
    required this.car,
    required this.carImage,
    required this.sellerEmail,
    required this.sellerPhoneNumber,
  });

  @override
  State<CarDetails> createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  double _userRating = 0.0;
  bool _hasRated = false;
  final _db = FirebaseFirestore.instance;

  Future<void> _updateUserRating(double rating) async {
    try {
      if (!_hasRated) {
        DocumentSnapshot snapshot =
            await _db.collection('users').doc(widget.car.sellerID).get();

        if (snapshot.exists) {
          double currentRating = double.parse(snapshot['rating'].toString());
          double newRating = (currentRating + rating) / 2;

          print(newRating);
          await _db.collection('users').doc(widget.car.sellerID).update({
            'rating': newRating,
          });
        } else {
          await _db.collection('users').doc(widget.car.sellerID).set({
            'rating': rating,
          });
        }

        setState(() {
          _hasRated = true;
        });
      } else {
        await showSnackBar("You have already rated this car.", context);
      }
    } catch (e) {
      print('Error updating rating: $e');
      await showSnackBar("Error rating the car.", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 340,
                height: 200, // Adjust the height as needed
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: FittedBox(
                    fit: BoxFit.cover, // Ensure the image covers the container
                    child: widget.carImage,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200], // Slightly greyish background
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      const Text(
                        "Description:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        widget.car.description,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const TableRow(
                    children: [
                      SizedBox(height: 8.0), // Add spacing between rows
                      SizedBox(height: 8.0),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Brand:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        widget.car.brand,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const TableRow(
                    children: [
                      SizedBox(height: 8.0), // Add spacing between rows
                      SizedBox(height: 8.0),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Model Name:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        widget.car.modelName,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const TableRow(
                    children: [
                      SizedBox(height: 8.0), // Add spacing between rows
                      SizedBox(height: 8.0),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Year Model:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        "${widget.car.yearModel}",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const TableRow(
                    children: [
                      SizedBox(height: 8.0), // Add spacing between rows
                      SizedBox(height: 8.0),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Daily Rental Rate:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        "${widget.car.dailyRentalRate} BD",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const TableRow(
                    children: [
                      SizedBox(height: 8.0), // Add spacing between rows
                      SizedBox(height: 8.0),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Seller Email:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        widget.sellerEmail,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Seller Mobile:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        "+973 ${widget.sellerPhoneNumber}",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) async {
                    setState(() {
                      _userRating = rating;
                    });
                    await _updateUserRating(rating);

                    print('Rating: $rating');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: () async {
                      // Implement the rent action here
                      String res = await rentListing(widget.car, widget.car.id);
                      await showSnackBar(res, context);
                    },
                    child: const Text(
                      "Rent",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: () async {
                      // Implement the location action here
                      final geoPoint = widget.car.location;
                      final lat = geoPoint.latitude;
                      final long = geoPoint.longitude;
                      final googleMapsUrl =
                          'https://www.google.com/maps/search/?api=1&query=$lat,$long';
                      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
                        await launchUrl(Uri.parse(googleMapsUrl));
                      } else {
                        throw 'Could not launch $googleMapsUrl';
                      }
                    },
                    icon: const Icon(
                      Icons.location_on,
                      color: Colors.black,
                    ),
                    label: const Text(
                      "Location",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
