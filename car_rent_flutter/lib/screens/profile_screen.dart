import 'package:car_rent_flutter/models/car.dart';
import 'package:car_rent_flutter/models/user.dart' as model;
import 'package:car_rent_flutter/utils/firebase_manager.dart';
import 'package:car_rent_flutter/widgets/auth_button.dart';
import 'package:car_rent_flutter/widgets/car_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Stream<model.User> userStream;
  final _db = FirebaseFirestore.instance;
  model.User? user;

  @override
  void initState() {
    super.initState();
    userStream = FirebaseManager.instance.getUserStream(widget.uid);
  }

  Future<List<DocumentSnapshot>> _fetchUserCars() async {
    var querySnapshot = await _db
        .collection('car_listings')
        .where('sellerID', isEqualTo: widget.uid)
        .get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Screen'),
      ),
      body: StreamBuilder<model.User>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = snapshot.data;
            return buildProfileContent();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget buildProfileContent() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            user!.photoUrl != ""
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user!.photoUrl),
                  )
                : const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
            const SizedBox(height: 10),
            Text(user!.email, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text(user!.phoneNumber, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            RatingBar.builder(
              initialRating: user!.rating.toDouble(),
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              ignoreGestures: true, // This makes the rating bar read-only
              onRatingUpdate: (rating) {
                setState(() {
                  rating = user!.rating.toDouble();
                });
              },
            ),
            const SizedBox(height: 20),
            AuthButton(
              backgroundColor: Colors.redAccent,
              text: "Log out",
              func: () {
                // Add your logout function here
              },
              borderColor: Colors.white,
              textColor: Colors.white,
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<DocumentSnapshot>>(
              future: _fetchUserCars(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No cars listed');
                }
                return Column(
                  children: snapshot.data!.map((doc) {
                    return CarCard(
                      car: CarListing.fromSnap(doc),
                      sellerEmail: user!.email,
                      sellerPhoneNumber: user!.phoneNumber,
                      personRating: user!.rating.toDouble(),
                      profile: true,
                      // Add other necessary parameters for CarCard here
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
