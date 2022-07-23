

// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String postId;
  final datePublish;
  final String postUrl;
  final String categorie;
  const Post({
    required this.description,
    required this.uid,
    required this.postId,
    required this.datePublish,
    required this.postUrl,
    required this.categorie,
  });

  Map<String,dynamic> toJson()=>{
    'description':description,
    'uid':uid,
    'postId':postId,
    'datePublish':datePublish,
    'postUrl':postUrl,
    "categorie":categorie,
  };

  static Post fromSnap(DocumentSnapshot snap){
    var snapshot = (snap.data() as Map<String,dynamic>);
    return Post(
      uid: snapshot['uid'],
      description: snapshot['description'],
      postId: snapshot['postId'],
      datePublish: snapshot['datePublish'],
      postUrl: snapshot['postUrl'],
      categorie: snapshot["categorie"],
    );
  }
}
