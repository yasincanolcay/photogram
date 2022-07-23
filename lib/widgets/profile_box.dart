import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photogram/main.dart';
import 'package:photogram/resources/auth_methods.dart';
import 'package:photogram/resources/firestore_methods.dart';
import 'package:photogram/responsive/const.dart';
import 'package:photogram/screens/login_screen.dart';
import 'package:photogram/utils/utils.dart';
import 'package:photogram/widgets/buildColumn.dart';

class ProfileBox extends StatefulWidget {
  final screenWidth;
  final postLen;
  final follower;
  final following;
  final coverPhoto;
  final profilePhoto;
  final uid;
  final username;
  final verify;
  const ProfileBox({
    Key? key,
    required this.screenWidth,
    required this.postLen,
    required this.follower,
    required this.following,
    required this.coverPhoto,
    required this.profilePhoto,
    required this.uid,
    required this.username,
    required this.verify,
  }) : super(key: key);

  @override
  State<ProfileBox> createState() => _ProfileBoxState();
}

class _ProfileBoxState extends State<ProfileBox> {
  final TextEditingController _urlController = TextEditingController();
  String myUid = FirebaseAuth.instance.currentUser!.uid;
  bool isFollowing = false;
  List<String> followingList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFollowing();
  }

  getFollowing() async {
    var following = await FirebaseFirestore.instance
        .collection("users")
        .doc(myUid)
        .collection("following")
        .get()
        .then((value) {
      List.from(value.docs).forEach((element) {
        setState(() {
          followingList.add(element["uid"]);
        });
      });
    });
    isFollowing = followingList.contains(widget.uid);
    setState(() {});
  }
  selectUrl() async{
    String res = await FireStoreMethods().editCover(_urlController.text, myUid);
    if(res!="succes"){
      showSnackBar(res, context);
    }
    setState(() {
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.coverPhoto),
          filterQuality: FilterQuality.medium,
          fit: BoxFit.cover,
          opacity: 0.8,
        ),
      ),
      width: widget.screenWidth,
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.username,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontSize: 18),
              ),
              SizedBox(
                width: 2,
              ),
              Icon(
                widget.verify ? Icons.verified : null,
                color: generalColor,
                size: 16,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: generalColor,
                backgroundImage: NetworkImage(
                  widget.profilePhoto,
                ),
                radius: 30,
              ),
              SizedBox(
                width: 8,
              ),
              BuildColumn(
                header: "Posts",
                text: widget.postLen,
              ),
              SizedBox(
                width: 8,
              ),
              BuildColumn(
                header: "Followers",
                text: widget.follower,
              ),
              SizedBox(
                width: 8,
              ),
              BuildColumn(
                header: "Following",
                text: widget.following,
              ),
              SizedBox(
                width: 10,
              ),
              widget.uid == myUid
                  ? PopupMenuButton(
                      icon: Icon(Icons.more_vert_rounded),
                      itemBuilder: (context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          child: myUid == widget.uid
                              ? ListTile(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Enter Url'),
                                            content: TextField(
                                              onSubmitted: (value) {
                                                selectUrl();
                                              },
                                              controller: _urlController,
                                              decoration: InputDecoration(
                                                  hintText:
                                                      "https://photoUrl.com"),
                                            ),
                                          );
                                        });
                                  },
                                  title: Text(
                                    "Edit Cover",
                                  ),
                                  leading: Icon(
                                    Icons.edit,
                                  ),
                                )
                              : SizedBox(),
                        ),
                        PopupMenuItem(
                          child: myUid == widget.uid
                              ? ListTile(
                                  onTap: () async {
                                    await AuthMethods().signOut();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyApp(),
                                      ),
                                    );
                                  },
                                  title: Text(
                                    "Log Out",
                                  ),
                                  leading: Icon(
                                    Icons.logout_rounded,
                                  ),
                                )
                              : SizedBox(),
                        ),
                      ],
                    )
                  : PopupMenuButton(
                      icon: Icon(Icons.more_vert_rounded),
                      itemBuilder: (context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          child: ListTile(
                            title: Text(
                              "Report",
                            ),
                            leading: Icon(
                              Icons.report,
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: generalColor,
            ),
            width: 180,
            height: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: myUid == widget.uid
                  ? FlatButton(
                      onPressed: () {},
                      child: Text(
                        "Edit Profile",
                        style: style,
                      ),
                    )
                  : isFollowing
                      ? FlatButton(
                          onPressed: () async {
                            String res = await FireStoreMethods()
                                .UnFollow(widget.uid, myUid);
                            if (res != "succes") {
                              showSnackBar(res, context);
                            }
                            setState(() {
                              followingList.remove(widget.uid);
                              isFollowing = false;
                            });
                          },
                          child: Text(
                            "Un Follow",
                            style: style,
                          ),
                        )
                      : FlatButton(
                          onPressed: () async {
                            String res = await FireStoreMethods()
                                .Follow(widget.uid, myUid);
                            if (res != "succes") {
                              showSnackBar(res, context);
                            }
                            setState(() {
                              followingList.add(widget.uid);
                              isFollowing = true;
                            });
                          },
                          child: Text(
                            "Follow",
                            style: style,
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
