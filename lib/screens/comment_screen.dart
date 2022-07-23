import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:photogram/provider/user_provider.dart';
import 'package:photogram/resources/firestore_methods.dart';
import 'package:photogram/responsive/const.dart';
import 'package:photogram/utils/utils.dart';
import 'package:photogram/widgets/comment_card.dart';
import 'package:provider/provider.dart';

import '../models/users.dart';

class CommentScreen extends StatefulWidget {
  final snap;
  const CommentScreen({Key? key, required this.snap}) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = new ScrollController();
  bool isKeyboard = false;
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
    _commentController.dispose();
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    var keyboardVisibilityController = KeyboardVisibilityController();

    // Subscribe
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        isKeyboard = visible;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        foregroundColor: primaryColor,
        title: Text("Comments"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap['postId'])
            .collection('comments')
            .orderBy("datePublish", descending: true)
            .snapshots(),
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
                return CommentCard(
                  snap: (snapshot.data! as dynamic).docs[index].data(),
                );
              });
        },
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
            bottom: isKeyboard ? MediaQuery.of(context).size.height * 0.41 : 0),
        padding: const EdgeInsets.only(left: 16, right: 8, bottom: 6),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  user.photoUrl,
                ),
                radius: 18,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 8.0,
                ),
                child: TextField(
                  controller: _commentController,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Comment with ${user.username}',
                    border: InputBorder.none,
                  ),
                  maxLength: 500,
                  minLines: 1,
                  maxLines: 6,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: InkWell(
                onTap: () async {
                  String res = await FireStoreMethods().sendComment(widget.snap["postId"], user.uid, _commentController.text);
                  if(res!="succes"){
                    showSnackBar(res, context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 8.0,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: generalColor,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
