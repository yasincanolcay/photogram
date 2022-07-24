import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photogram/models/post.dart';
import 'package:photogram/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String categorie,
  ) async {
    String res = 'Bilinmeyen bir hata oluştu!';
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1();
      Post post = Post(
          description: description,
          uid: uid,
          postId: postId,
          datePublish: DateTime.now(),
          postUrl: photoUrl,
          categorie: categorie);
      _firestore.collection('posts').doc(postId).set(
            post.toJson(),
          );
      res = 'succes';
    } catch (err) {
      res = 'Gönderi yüklenemedi, lütfen tekrar deneyin';
    }
    return res;
  }

  Future<String> shareUrl(
    String description,
    String url,
    String uid,
    String categorie,
  ) async {
    String res = "";
    try {
      String postId = const Uuid().v1();
      await FirebaseFirestore.instance.collection("posts").doc(postId).set({
        "description": description,
        "uid": uid,
        "postId": postId,
        "datePublish": DateTime.now(),
        "postUrl": url,
        "categorie": categorie
      });

      res = "Succesfuly";
    } catch (e) {
      res = "Post Failed to Share!";
    }
    return res;
  }

  Future<String> likePost(String uid, String postId, bool liked) async {
    String res = "";
    try {
      if (!liked) {
        await FirebaseFirestore.instance
            .collection("posts")
            .doc(postId)
            .collection("likes")
            .doc(uid)
            .set({"uid": uid});
      } else {
        await FirebaseFirestore.instance
            .collection("posts")
            .doc(postId)
            .collection("likes")
            .doc(uid)
            .delete();
      }
      res = "succes";
    } catch (e) {
      res = "Like Failed!";
    }
    return res;
  }

  Future<String> sendComment(String postId, String uid, String text) async {
    String res = "";
    try {
      String commentId = Uuid().v1();
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .set({
        "text": text,
        "uid": uid,
        "commentId": commentId,
        "datePublish": DateTime.now(),
      });
      res = "succes";
    } catch (e) {
      res = "Could not share comment!";
    }
    return res;
  }

  Future<String> Follow(String uid, String myUid) async {
    String res = "";
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("followers")
          .doc(myUid)
          .set({
        "uid": myUid,
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc(myUid)
          .collection("following")
          .doc(uid)
          .set({
        "uid": uid,
      });
      res = "succes";
    } catch (e) {
      res = "operation failed!";
    }
    return res;
  }

  Future<String> UnFollow(String uid, String myUid) async {
    String res = "";
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("followers")
          .doc(myUid)
          .delete();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(myUid)
          .collection("following")
          .doc(uid)
          .delete();
    } catch (e) {
      res = "operation failed!";
    }
    return res;
  }

  Future<String> editCover(
    String url,
    String uid,
  ) async {
    String res = "";
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({"coverPhoto": url});

      res = "Succesfuly";
    } catch (e) {
      res = "error!";
    }
    return res;
  }

  Future<String> editProfileUrl(
    String username,
    String bio,
    String url,
    String uid,
  ) async {
    String res = "";
    try {
      if (username.isNotEmpty && url.isNotEmpty) {
        await FirebaseFirestore.instance.collection("users").doc(uid).update({
          "photoUrl": url,
          "username": username,
          "bio": bio,
        });

        res = "Succesfuly";
      }else{
        res = "There are empty fields";
      }
    } catch (e) {
      res = "error!";
    }
    return res;
  }

  Future<String> editProfileFile(
    String username,
    String bio,
    Uint8List file,
    String uid,
  ) async {
    String res = "";
    try {
      if (username.isNotEmpty && file.isNotEmpty) {
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePic', file, true);
        await FirebaseFirestore.instance.collection("users").doc(uid).update({
          "photoUrl": photoUrl,
          "username": username,
          "bio": bio,
        });

        res = "Succesfuly";
      }
      else{
        res = "There are empty fields";
      }
    } catch (e) {
      res = "error!";
    }
    return res;
  }
}
