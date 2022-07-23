import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photogram/components/categories.dart';
import 'package:photogram/resources/firestore_methods.dart';
import 'package:photogram/responsive/const.dart';
import 'package:photogram/utils/utils.dart';

class PostDescription extends StatefulWidget {
  final type;
  final image;
  const PostDescription({Key? key, required this.type, required this.image})
      : super(key: key);

  @override
  State<PostDescription> createState() => _PostDescriptionState();
}

class _PostDescriptionState extends State<PostDescription> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _descriptionController = TextEditingController();
  int categorieIndex = 0;
  bool _isLoading = false;

  uploadPost() async {
    setState(() {
      _isLoading = true;
    });
    String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        widget.image,
        uid,
        categories[categorieIndex]);
    setState(() {
      _isLoading = false;
      showSnackBar(res, context);
      Navigator.pop(context);
    });
  }

  shareUrl() async {
    setState(() {
      _isLoading = true;
    });
    String res = await FireStoreMethods().shareUrl(_descriptionController.text,
        widget.image, uid, categories[categorieIndex]);
    setState(() {
      _isLoading = false;
      showSnackBar(res, context);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        foregroundColor: primaryColor,
        title: Text("Post Upload"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: screenWidth > webScreenSize
                ? EdgeInsets.symmetric(horizontal: screenWidth * 0.3)
                : EdgeInsets.all(0),
            width: screenWidth,
            height: screenHeight,
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  height: 250,
                  child: widget.type == "photo"
                      ? Image.memory(
                          widget.image,
                          filterQuality: FilterQuality.medium,
                          fit: BoxFit.cover,
                        )
                      : Image.network(widget.image),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: screenWidth,
                    child: TextField(
                      controller: _descriptionController,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 300,
                      decoration: InputDecoration(
                        hintText: "Description...",
                        hintStyle: TextStyle(color: secondaryColor),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth,
                  height: 100,
                  child: ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          categorieIndex = index;
                          setState(() {
                          });
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10.0),
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                              color: categorieIndex == index
                                  ? Color.fromARGB(255, 20, 20, 20)
                                  : Color.fromARGB(255, 61, 61, 61),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(blurRadius: 5.0, color: primaryColor)
                              ]),
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              color: categorieIndex == index
                                  ? generalColor
                                  : secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: ElevatedButton(
                    onPressed: () async{
                      if (widget.type == "photo") {
                        await uploadPost();
                      } else {
                        await shareUrl();
                      }
                    },
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Share',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                                letterSpacing: 1),
                          ),
                    style: ElevatedButton.styleFrom(
                      primary: generalColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
