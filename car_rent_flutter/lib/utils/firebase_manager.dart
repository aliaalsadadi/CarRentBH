import 'package:car_rent_flutter/models/user.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseManager {
  FirebaseManager._privateConstructor();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  late model.User user;
  static final FirebaseManager instance = FirebaseManager._privateConstructor();
  init() async {
    if (FirebaseAuth.instance.currentUser != null) {
      user = await getUserDetails();
    }
  }

  Stream<model.User> getUserStream(String uid) {
    return db.collection("users").doc(uid).snapshots().map((snapshot) {
      return model.User.fromSnap(snapshot);
    });
  }

  Future<model.User> getUserDetails() async {
    User currentUser = auth.currentUser!;
    DocumentSnapshot snap =
        await db.collection("users").doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    String res = "";
    try {
      UserCredential cred = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      db.collection("users").doc(cred.user!.uid).set({
        "uid": cred.user!.uid,
        "email": email,
        "rating": 0.0,
        "phoneNumber": phoneNumber,
        "photoUrl": "",
      });
      user = model.User(
          uid: cred.user!.uid,
          email: email,
          photoUrl: "",
          phoneNumber: phoneNumber,
          rating: 0);
      res = "success";
    } on FirebaseAuthException catch (err) {
      switch (err.code) {
        case "invalid-email":
          res = "The email is badly formatted.";
          break;
        case "weak-password":
          res = "The password provided is too weak.";
          break;
        case "email-already-in-use":
          res = "The account already exists for that email.";
          break;
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential cred = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      }
    } on FirebaseAuthException catch (err) {
      switch (err.code) {
        case "user-not-found":
          res = "No user found for that email.";
          break;
        case "wrong-password":
          res = "Wrong password";
          break;
        default:
          res = err.message.toString();
          break;
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> signout() async {
    await auth.signOut();
  }
}
