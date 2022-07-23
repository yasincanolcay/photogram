

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String uid;
  final String email;
  final String bio;
  final String photoUrl;
  final bool verify;
  const User({
    required this.username,
    required this.uid,
    required this.email,
    required this.bio,
    required this.photoUrl,
    required this.verify,
  });

  Map<String,dynamic> toJson()=>{
    'username':username,
    'uid':uid,
    'email':email,
    'bio':bio,
    'photoUrl':photoUrl,
    'verify':verify,
    'coverPhoto':'https://images.unsplash.com/photo-1464618663641-bbdd760ae84a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80',
  };

  static User fromSnap(DocumentSnapshot snap){
    var snapshot = (snap.data() as Map<String,dynamic>);
    return User(
      username: snapshot['username'],
      uid: snapshot['uid'],
      email: snapshot['email'],
      photoUrl: snapshot['photoUrl'],
      bio: snapshot['bio'],
      verify: snapshot['verify'],
    );
  }
}
