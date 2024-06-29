import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class CarListing {
  final String id;
  final String brand;
  final String modelName;
  final String description;
  final String carPhotoURL;
  final int yearModel;
  final int dailyRentalRate;
  final Timestamp availabilityEndDate;
  final Timestamp availabilityStartDate;
  final GeoFirePoint location;
  final String sellerID;

  const CarListing({
    required this.id,
    required this.carPhotoURL,
    required this.brand,
    required this.description,
    required this.modelName,
    required this.yearModel,
    required this.availabilityEndDate,
    required this.availabilityStartDate,
    required this.dailyRentalRate,
    required this.sellerID,
    required this.location,
  });
  Map<String, dynamic> toJson() => {
        "carPhotoURL": carPhotoURL,
        "brand": brand,
        "modelName": modelName,
        "yearModel": yearModel,
        "availabilityEndDate": availabilityEndDate,
        "availabilityStartDate": availabilityStartDate,
        "dailyRentalRate": dailyRentalRate,
        "sellerID": sellerID,
        "location": location.data,
        "description": description,
        "isRented": false,
      };
  static CarListing fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    GeoPoint geoP = snapshot['location']['geopoint'] as GeoPoint;
    GeoFlutterFire geo = GeoFlutterFire();
    return CarListing(
      id: snap.id,
      carPhotoURL: snapshot['carPhotoURL'],
      brand: snapshot['brand'],
      modelName: snapshot['modelName'],
      yearModel: snapshot['yearModel'],
      availabilityEndDate: snapshot['availabilityEndDate'],
      availabilityStartDate: snapshot['availabilityStartDate'],
      dailyRentalRate: snapshot['dailyRentalRate'],
      sellerID: snapshot['sellerID'],
      location: geo.point(latitude: geoP.latitude, longitude: geoP.longitude),
      description: snapshot['description'],
    );
  }
}
