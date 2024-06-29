import 'dart:typed_data';
import 'package:car_rent_flutter/models/car.dart';
import 'package:car_rent_flutter/widgets/car_details.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

class FireMap extends StatefulWidget {
  const FireMap({super.key});

  @override
  State<FireMap> createState() => _FireMapState();
}

class _FireMapState extends State<FireMap> {
  late GoogleMapController mapController;
  final markers = Set<Marker>();
  MarkerId markerId = MarkerId("YOUR_MARKER_ID");
  LocationData? currentLocation;
  GeoFlutterFire geo = GeoFlutterFire();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  BehaviorSubject<double> radius = BehaviorSubject<double>.seeded(10);
  late Stream<List<DocumentSnapshot>> stream;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) {
      stream =
          geo.collection(collectionRef: _db.collection('car_listings')).within(
                center: geo.point(
                  latitude: currentLocation!.latitude!,
                  longitude: currentLocation!.longitude!,
                ),
                radius: radius.value,
                field: 'location',
              );
      print("first stream: ");
      print(stream.length);
      stream.forEach((element) {
        print(element);
      });
    });
  }

  @override
  void dispose() {
    radius.close();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    currentLocation = await location.getLocation();
    if (currentLocation != null) {
      setState(() {
        markers.add(
          Marker(
            markerId: markerId,
            position: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Center(
          child:
              CircularProgressIndicator()); // Show a loading indicator while waiting for the current location
    }

    return Scaffold(
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _updateMarkers(snapshot.data!);
          }
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    currentLocation!.latitude!,
                    currentLocation!.longitude!,
                  ),
                  zoom: 15,
                ),
                markers: markers,
                myLocationEnabled: true,
                onMapCreated: _onMapCreated,
                onCameraMove: (position) {
                  // for the red marker to update location.
                  setState(() {
                    markers.add(
                        Marker(markerId: markerId, position: position.target));
                  });
                },
              ),
              Positioned(
                bottom: 50,
                left: 10,
                child: Slider(
                  onChanged: _updateQuery,
                  value: radius.value,
                  min: 10,
                  max: 500,
                  divisions: 4,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _getMarkerIcon(String id, String sellerID) async {
    Uint8List? imageData = await _downloadImage(id, sellerID);
    if (imageData != null) {
      // Resize the image
      img.Image originalImage = img.decodeImage(imageData)!;
      img.Image resizedImage = img.copyResize(originalImage,
          width: 100, height: 100); // Adjust the width and height as needed
      Uint8List resizedImageData =
          Uint8List.fromList(img.encodePng(resizedImage));

      BitmapDescriptor bitmapDescriptor =
          BitmapDescriptor.fromBytes(resizedImageData);
      return [
        bitmapDescriptor,
        imageData
      ]; // Return both BitmapDescriptor and Uint8List
    } else {
      throw Exception('Could not load image');
    }
  }

  Future<void> _updateMarkers(List<DocumentSnapshot> snapshot) async {
    Set<Marker> newMarkers = {};

    for (var doc in snapshot) {
      GeoPoint geoPoint = doc['location']['geopoint'];
      String sellerID = doc['sellerID'];
      var sellerSnapshot = await _db
          .collection('users')
          .doc(sellerID)
          .get(); // Ensure sellerEmail is in the document
      var sellerData = sellerSnapshot.data() as Map<String, dynamic>;
      String sellerEmail = sellerData['email'] ?? 'Unknown';
      String sellerPhoneNumber = sellerData['phoneNumber'] ?? 'Unknown';
      List<dynamic> iconData = await _getMarkerIcon(doc.id, sellerID);
      BitmapDescriptor markerIcon = iconData[0];
      Uint8List imageData = iconData[1];

      newMarkers.add(
        Marker(
          markerId: MarkerId(doc.id),
          icon: markerIcon,
          position: LatLng(geoPoint.latitude, geoPoint.longitude),
          onTap: () async {
            CarListing car = await CarListing.fromSnap(doc);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarDetails(
                  car: car,
                  carImage:
                      Image.memory(imageData), // Use the Uint8List image data
                  sellerEmail: sellerEmail,
                  sellerPhoneNumber: sellerPhoneNumber, // Pass the sellerEmail
                ),
              ),
            );
          },
        ),
      );
    }

    setState(() {
      markers.clear();
      markers.addAll(newMarkers);
    });
  }

  Future<Uint8List?> _downloadImage(String id, String sellerID) async {
    try {
      String imagePath =
          'listings/$sellerID/$id'; // Adjust the path accordingly
      final ref = _storage.ref().child(imagePath);
      final data = await ref.getData();
      return data;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  Future<DocumentReference> _addGeoPoint(LatLng position) async {
    if (position != null) {
      GeoFirePoint geoPoint = geo.point(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Create a new document in Firestore with the GeoPoint
      DocumentReference docRef = await _db.collection('locations').add({
        'location': geoPoint.data,
      });

      return docRef;
    } else {
      throw Exception('Marker position is null');
    }
  }

  void _updateQuery(double value) {
    setState(() {
      radius.add(value);
      stream =
          geo.collection(collectionRef: _db.collection('locations')).within(
                center: geo.point(
                  latitude: currentLocation!.latitude!,
                  longitude: currentLocation!.longitude!,
                ),
                radius: value,
                field: 'location',
              );
      stream.forEach((element) {
        print(element);
      });
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            currentLocation!.latitude!,
            currentLocation!.longitude!,
          ),
          _getZoomLevel(value),
        ),
      );
    });
  }

  double _getZoomLevel(double radius) {
    if (radius <= 100) {
      return 15;
    } else if (radius <= 200) {
      return 14;
    } else if (radius <= 300) {
      return 13;
    } else if (radius <= 400) {
      return 12;
    } else {
      return 11;
    }
  }
}
