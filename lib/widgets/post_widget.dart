import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photogram/resources/firestore_methods.dart';
import 'package:photogram/responsive/const.dart';
import 'package:photogram/screens/comment_screen.dart';
import 'package:photogram/screens/profile_screen.dart';
import 'package:photogram/utils/utils.dart';
import 'package:share_plus/share_plus.dart';

class PostWidget extends StatefulWidget {
  final snap;
  const PostWidget({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  List<String> likeList = [];
  int likesLen = 0;
  int commentLen = 0;
  bool verify = false;
  bool isLike = false;
  String username = "...";
  String profImage =
      "https://icons8.com/preloaders/preloaders/1494/Spinner-2.gif";
  String myUid = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
    getPostData();
  }

  getUserData() async {
    var userSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.snap["uid"])
        .get();
    username = userSnap.data()!["username"];
    profImage = userSnap.data()!["photoUrl"];
    verify = userSnap.data()!["verify"];
    setState(() {});
  }

  getPostData() async {
    var postSnap = await FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.snap["postId"])
        .collection("likes")
        .get();
    likesLen = postSnap.docs.length;
    var commentSnap = await FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.snap["postId"])
        .collection("comments")
        .get();
    commentLen = commentSnap.docs.length;

    await FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.snap["postId"])
        .collection("likes")
        .get()
        .then((value) {
      // ignore: avoid_function_literals_in_foreach_calls
      List.from(value.docs).forEach((element) {
        setState(() {
          if (element != null) {
            likeList.add(element["uid"]);
          }
        });
      });
    });
    isLike = likeList.contains(FirebaseAuth.instance.currentUser!.uid);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          color: mobileBackgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(blurRadius: 5.0, color: secondaryColor)]),
      margin: screenWidth > webScreenSize
          ? EdgeInsets.symmetric(horizontal: screenWidth * 0.3, vertical: 10)
          : EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          ListTile(
            tileColor: mobileBackgroundColor,
            leading: CircleAvatar(
              backgroundColor: generalColor,
              backgroundImage: NetworkImage(profImage),
            ),
            title: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        uid: widget.snap["uid"],
                      ),
                    ),
                  ),
                  child: Text(
                    username,
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Icon(
                  verify ? Icons.verified : null,
                  color: Colors.blue,
                  size: 17,
                )
              ],
            ),
            trailing: IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert_rounded),
            ),
            subtitle: Text(widget.snap["categorie"]),
          ),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: mobileBackgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(7.0),
              constraints: const BoxConstraints(
                maxHeight: 400,
                maxWidth: double.infinity,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(widget.snap["postUrl"],
                    fit: webScreenSize < MediaQuery.of(context).size.width
                        ? BoxFit.contain
                        : BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/error.png',
                    fit: BoxFit.contain,
                    width: 100,
                    height: 100,
                  );
                }, loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: generalColor,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  //like function
                  String res = await FireStoreMethods()
                      .likePost(myUid, widget.snap["postId"], isLike);
                  if (res != "succes") {
                    showSnackBar(res, context);
                  }
                  //for quick update
                  if (isLike) {
                    likeList.remove(myUid);
                    isLike = false;
                    likesLen--;
                  } else {
                    likeList.add(myUid);
                    isLike = true;
                    likesLen++;
                  }
                  setState(() {
                    //update
                  });
                },
                icon: Icon(
                  isLike ? Icons.favorite : Icons.favorite_border,
                  color: isLike ? Colors.red : primaryColor,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentScreen(
                      snap: widget.snap,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.comment_rounded,
                ),
              ),
              IconButton(
                onPressed: () {
                  Share.share(widget.snap["postUrl"],
                      subject: "With Photogram");
                },
                icon: const Icon(
                  Icons.share,
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.symmetric(
              vertical: 4,
            ),
            child: Text(
              "  ${likesLen} Likes",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: primaryColor,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ': ${widget.snap['description']}',
                    style: TextStyle(
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CommentScreen(
                  snap: widget.snap,
                ),
              ),
            ),
            child: Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.symmetric(
                vertical: 4,
              ),
              child: Text(
                '  See all Reviews $commentLen',
                style: const TextStyle(
                  fontSize: 16,
                  color: secondaryColor,
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              DateFormat.yMMMd().format(
                widget.snap['datePublish'].toDate(),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
