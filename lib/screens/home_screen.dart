import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photogram/responsive/const.dart';
import 'package:photogram/widgets/post_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> followingList = [];
  String uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFollowing();
  }

  getFollowing() async {
    var snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("following")
        .get()
        .then((value) {
      List.from(value.docs).forEach((element) {
        followingList.add(element["uid"]);
      });
    });
    followingList.add(uid);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('datePublish', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: generalColor),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: generalColor),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return followingList.contains(snapshot.data!.docs[index]["uid"])
                  ? PostWidget(
                      snap: snapshot.data!.docs[index].data(),
                    )
                  : SizedBox();
            },
          );
        },
      ),
    );
  }
}
