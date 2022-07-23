import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photogram/responsive/const.dart';
import 'package:photogram/screens/profile_screen.dart';
import 'package:photogram/widgets/post_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isSearch = false;
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        foregroundColor: primaryColor,
        title: TextField(
          onSubmitted: (s) {
            setState(() {
              if (!isSearch && _controller.text.isNotEmpty) {
                isSearch = true;
              } else {
                isSearch = false;
              }
            });
          },
          controller: _controller,
          decoration: InputDecoration(
              hintText: "Search User...",
              prefixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    if (!isSearch && _controller.text.isNotEmpty) {
                      isSearch = true;
                    } else {
                      isSearch = false;
                    }
                  });
                },
                icon: Icon(!isSearch
                    ? Icons.search_rounded
                    : Icons.arrow_drop_down_rounded),
              )),
        ),
      ),
      body: isSearch
          ? SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("users")
                    .where("username", isGreaterThanOrEqualTo: _controller.text)
                    .get(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: generalColor,
                      ),
                    );
                  }
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: generalColor,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: (snap.data! as dynamic).docs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                    uid: (snap.data! as dynamic).docs[index]
                                        ["uid"]))),
                        title: Row(
                          children: [
                            Text((snap.data! as dynamic).docs[index]
                                ["username"]),
                            Icon(
                              (snap.data! as dynamic).docs[index]["verify"]
                                  ? Icons.verified
                                  : null,
                              color: generalColor,
                              size: 16,
                            )
                          ],
                        ),
                        leading: CircleAvatar(
                          backgroundColor: generalColor,
                          backgroundImage: NetworkImage(
                              (snap.data! as dynamic).docs[index]["photoUrl"]),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          : SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: FutureBuilder(
                future: FirebaseFirestore.instance.collection("posts").get(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: generalColor,
                      ),
                    );
                  }
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: generalColor,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: (snap.data! as dynamic).docs.length,
                    itemBuilder: (context, index) {
                      return PostWidget(
                          snap: (snap.data! as dynamic).docs[index]);
                    },
                  );
                },
              ),
            ),
    );
  }
}
