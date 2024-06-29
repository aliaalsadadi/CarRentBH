import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String photoUrl;
  final String phoneNumber;
  final num rating;

  const User({
    required this.uid,
    required this.email,
    required this.photoUrl,
    required this.phoneNumber,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "phoneNumber": phoneNumber,
        "rating": rating,
      };
  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      uid: snapshot["uid"],
      email: snapshot['email'],
      photoUrl: snapshot['photoUrl'],
      phoneNumber: snapshot['phoneNumber'],
      rating: snapshot["rating"],
    );
  }
}
