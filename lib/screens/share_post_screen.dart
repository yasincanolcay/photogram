import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photogram/responsive/const.dart';
import 'package:photogram/screens/post_description.dart';
import 'package:photogram/utils/utils.dart';

class SharePostScreen extends StatefulWidget {
  const SharePostScreen({Key? key}) : super(key: key);

  @override
  State<SharePostScreen> createState() => _SharePostScreenState();
}

class _SharePostScreenState extends State<SharePostScreen> {
  final TextEditingController _urlController = TextEditingController();
  Uint8List? _image;
  void selectImages(
    ImageSource source,
  ) async {
    Uint8List im = await pickImage(source);
    setState(() {
      _image = im;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PostDescription(type: "photo", image: _image)));
    });
  }

  void selectUrl() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PostDescription(type: "url", image: _urlController.text)));
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          padding: screenWidth>webScreenSize?EdgeInsets.symmetric(horizontal: screenWidth*0.3):EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: mobileBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5.0,
                        color: primaryColor,
                      )
                    ]),
                width: screenWidth,
                margin: EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
                padding: EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            child: Column(children: [
                              ListTile(
                                onTap: () => selectImages(
                                  ImageSource.camera,
                                ),
                                leading: Icon(Icons.camera),
                                title: Text("Camera"),
                                subtitle: Text("Open device camera"),
                              ),
                              ListTile(
                                onTap: () => selectImages(
                                  ImageSource.gallery,
                                ),
                                leading: Icon(Icons.photo),
                                title: Text("Gallery"),
                                subtitle: Text("Select from Gallery"),
                              )
                            ]),
                          );
                        });
                  },
                  leading: Icon(Icons.photo),
                  title: Text("Photo Upload"),
                  subtitle: Text("camera or gallery"),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: mobileBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5.0,
                        color: primaryColor,
                      )
                    ]),
                width: screenWidth,
                margin: EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
                padding: EdgeInsets.all(8.0),
                child: ListTile(
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
                                  hintText: "https://photoUrl.com"),
                            ),
                          );
                        });
                  },
                  leading: Icon(Icons.add_link_rounded),
                  title: Text("Add Url"),
                  subtitle: Text("Only Photo Url"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
