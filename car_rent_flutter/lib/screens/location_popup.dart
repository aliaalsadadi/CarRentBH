import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController mapController;
  final markers = Set<Marker>();
  MarkerId markerId = MarkerId("YOUR_MARKER_ID");
  LocationData? currentLocation;
  GeoFlutterFire geo = GeoFlutterFire();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  BehaviorSubject<double> radius = BehaviorSubject<double>.seeded(10);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) {});
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
            setState(() {
              markers
                  .add(Marker(markerId: markerId, position: position.target));
            });
          },
        ),
        Positioned(
          bottom: 50,
          right: 50,
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () {
              LatLng markerPosition = markers.last.position;
              GeoFirePoint gfp = _getGeoPoint(markerPosition);
              Navigator.pop(context, gfp);
            },
            child: const Icon(Icons.pin_drop),
          ),
        ),
      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  GeoFirePoint _getGeoPoint(LatLng position) {
    if (position != null) {
      GeoFirePoint geoPoint = geo.point(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return geoPoint;
    } else {
      throw Exception('Marker position is null');
    }
  }

  void _updateQuery(double value) {
    setState(() {
      radius.add(value);
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
