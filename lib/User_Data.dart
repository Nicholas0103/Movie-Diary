import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// * To store user data in Firestore.
// * This file is used to save user data when they sign up or log in.

Future<void> saveUserData(User user) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  final doc = await userRef.get();
  if (!doc.exists) {
    await userRef.set({
      'favorites': [],
      'email': user.email,
      'name': user.displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print("User doc created.");
  } else {
    print("User doc already exists.");
  }
}
