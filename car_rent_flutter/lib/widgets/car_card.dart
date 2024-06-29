import 'package:car_rent_flutter/models/car.dart';
import 'package:car_rent_flutter/widgets/car_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CarCard extends StatefulWidget {
  final CarListing car;
  late Image carImage;
  final String sellerEmail;
  final String sellerPhoneNumber;
  final String? sellerPhoto;
  final double personRating;
  final bool profile;
  CarCard({
    super.key,
    required this.car,
    required this.sellerEmail,
    required this.personRating,
    required this.sellerPhoneNumber,
    required this.profile,
    this.sellerPhoto,
  });

  @override
  State<CarCard> createState() => CarCardState();
}

class CarCardState extends State<CarCard> {
  @override
  void initState() {
    super.initState();
    widget.carImage = Image.network(
      widget.car.carPhotoURL,
      width: 200,
      height: 200,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!widget.profile) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CarDetails(
                car: widget.car,
                carImage: widget.carImage,
                sellerEmail: widget.sellerEmail,
                sellerPhoneNumber: widget.sellerPhoneNumber,
              ),
            ),
          );
        }
      },
      child: Card(
        borderOnForeground: true,
        color: Colors.white,
        elevation: 5.0,
        margin: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: widget.profile
              ? 300
              : 400, // Adjusted height based on profile flag
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.profile
                ? _buildProfileContent() // Conditionally build content for profile
                : _buildFullContent(), // Build full content for non-profile
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProfileContent() {
    return [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: widget.car.carPhotoURL.isEmpty && widget.carImage == null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    width: double.infinity,
                    height: 200.0,
                    color: Colors.grey,
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  height: 200.0,
                  child: widget.car.carPhotoURL.isNotEmpty
                      ? Image.network(
                          widget.car.carPhotoURL,
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                                child: Text('Image not available'));
                          },
                        )
                      : widget.carImage,
                ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          '${widget.car.brand} ${widget.car.modelName}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 10), // Added space between text and button
      Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 32.0), // Increased padding for bigger button
          ),
          onPressed: () async {},
          child: const Text(
            "Cancel",
            style: TextStyle(
                color: Colors.black, fontSize: 18), // Increased font size
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildFullContent() {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            widget.sellerPhoto != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget.sellerPhoto!),
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person, size: 20),
                    ),
                  ),
            const SizedBox(width: 4),
            Text(
              widget.sellerEmail,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'PermanentMarker',
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: widget.car.carPhotoURL.isEmpty && widget.carImage == null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    width: double.infinity,
                    height: 200.0,
                    color: Colors.grey,
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  height: 200.0,
                  child: widget.car.carPhotoURL.isNotEmpty
                      ? Image.network(
                          widget.car.carPhotoURL,
                          width: 200,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                                child: Text('Image not available'));
                          },
                        )
                      : widget.carImage,
                ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.car.brand} ${widget.car.modelName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Year: ${widget.car.yearModel}',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            Text(
              'Rate: ${widget.car.dailyRentalRate} BD per day',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8.0),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.payments,
                  color: Colors.green,
                ),
                Text(
                  '${widget.car.dailyRentalRate} BD per day',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            RatingBar.builder(
              initialRating: widget.personRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemSize: 20,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              ignoreGestures: true,
              onRatingUpdate: (rating) {
                // Update the personRating variable here if needed
              },
            ),
          ],
        ),
      ),
    ];
  }
}
