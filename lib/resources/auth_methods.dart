// ignore_for_file: unused_import, avoid_print
import 'dart:typed_data';
import 'package:photogram/models/users.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photogram/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  //sign up user
  Future<String> signUpUser(
    String email,
    String password,
    String username,
    String bio,
    Uint8List file,
  ) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
        //register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        String photoUrl = "https://firebasestorage.googleapis.com/v0/b/bahce-2608a.appspot.com/o/LoadingProfile%2Fdefaultprofile.png?alt=media&token=3bfd878d-9589-4496-a4f5-aef9eb0778ad";
        if (file!=null) {
          photoUrl = await StorageMethods()
              .uploadImageToStorage('profilePics', file, false);
        }
        //add user to database
        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
          bio: bio.isNotEmpty?bio:" ",
          photoUrl: photoUrl,
          verify: false,
        );
        await _firestore.collection('users').doc(cred.user!.uid).set(
              user.toJson(),
            );
        await FirebaseFirestore.instance
            .collection("stories")
            .doc(cred.user!.uid)
            .set({
          "show": false,
          "uid": cred.user!.uid,
          "type": "story",
          "datePublish": DateTime.now(),
          "photoUrl": []
        });
        //
        res = 'Welcome to Photogram, enjoy :-)';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //log in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Something went wrong';

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'succes';
      } else {
        res = 'There are empty fields';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'User not found!';
      } else if (e.code == 'invalid-email') {
        res = 'email address is invalid!';
      } else if (e.code == 'invalid-password') {
        res = 'Enter long password!';
      } else {
        res = 'Something went wrong, please try again!';
      }
    }

    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
