import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photogram/responsive/const.dart';
import 'package:photogram/widgets/post_widget.dart';
import 'package:photogram/widgets/profile_box.dart';

class ProfileScreen extends StatefulWidget {
  final uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int follower = 0;
  int following = 0;
  int postLen = 0;
  String coverPhoto = "https://cdn.dribbble.com/users/1186261/screenshots/3718681/_______.gif";
  String profilePhoto = "https://icons8.com/preloaders/preloaders/1494/Spinner-2.gif";
  String username = "";
  String bio = "";
  bool verify = false;
  bool isLoading = false;
  List<String> followingList = [];
  String myUid = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
    getProfileData();
  }

  getUserData() async {
    setState(() {
      isLoading = true;
    });
    var snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .get();
    username = snap.data()!["username"];
    coverPhoto = snap.data()!["coverPhoto"];
    profilePhoto = snap.data()!["photoUrl"];
    verify = snap.data()!["verify"];
    bio = snap.data()!["bio"];
    setState(() {
      isLoading = false;
    });
  }

  getProfileData() async {
    var followingLen = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("following")
        .get();
    following = followingLen.docs.length;
    var followerLen = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("followers")
        .get();
    follower = followerLen.docs.length;
    var ProfilepostLen = await FirebaseFirestore.instance
        .collection("posts")
        .where("uid", isEqualTo: widget.uid)
        .get();
    postLen = ProfilepostLen.docs.length;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: !isLoading
          ? Container(
              width: screenWidth,
              height: screenHeight,
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("posts")
                    .where("uid", isEqualTo: widget.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: generalColor,
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: generalColor,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          index == 0
                              ? ProfileBox(
                                  screenWidth: screenWidth,
                                  postLen: postLen.toString(),
                                  follower: follower.toString(),
                                  following: following.toString(),
                                  coverPhoto: coverPhoto,
                                  profilePhoto: profilePhoto,
                                  uid: widget.uid,
                                  username: username,
                                  verify: verify,
                                  bio: bio,
                                )
                              : SizedBox(),
                          PostWidget(
                              snap: (snapshot.data! as dynamic).docs[index]),
                        ],
                      );
                    },
                  );
                },
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                color: generalColor,
              ),
            ),
    );
  }
}
