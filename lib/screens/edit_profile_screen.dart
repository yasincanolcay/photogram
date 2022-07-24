import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photogram/resources/auth_methods.dart';
import 'package:photogram/resources/firestore_methods.dart';
import 'package:photogram/responsive/const.dart';
import 'package:photogram/responsive/mobile_screen.dart';
import 'package:photogram/responsive/responsive_layout.dart';
import 'package:photogram/responsive/web_screen.dart';
import 'package:photogram/screens/login_screen.dart';
import 'package:photogram/utils/utils.dart';

class EditProfileScreen extends StatefulWidget {
  final username;
  final bio;
  final photoUrl;
  final uid;
  const EditProfileScreen(
      {Key? key,
      required this.username,
      required this.bio,
      required this.photoUrl,
      required this.uid})
      : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  ImagePicker _picker = ImagePicker();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;
  bool _isVisible = true;
  bool isSelected = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bioController.text = widget.bio;
    _usernameController.text = widget.username;
  }

  void selectImages() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      if (im.isNotEmpty) {
        _image = im;
        isSelected = true;
      }
    });
  }

  void saveProfile() async {
    if (isSelected) {
      String res = await FireStoreMethods().editProfileFile(
        _usernameController.text,
        _bioController.text,
        _image!,
        widget.uid,
      );
      showSnackBar(res, context);
    } else {
      String res = await FireStoreMethods().editProfileUrl(
        _usernameController.text,
        _bioController.text,
        widget.photoUrl,
        widget.uid,
      );
      showSnackBar(res, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: mobileBackgroundColor,
            padding: MediaQuery.of(context).size.width > webScreenSize
                ? EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 3)
                : const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
            width: screenWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                //circular to accept and show selected file
                Stack(
                  children: [
                    !isSelected
                        ? CircleAvatar(
                            radius: 55,
                            backgroundImage: NetworkImage(widget.photoUrl),
                          )
                        : CircleAvatar(
                            radius: 55,
                            backgroundImage: MemoryImage(_image!),
                          ),
                    Positioned(
                      bottom: -10,
                      left: 65,
                      child: IconButton(
                        onPressed: () {
                          selectImages();
                        },
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: const Color(0xFFB4B4B4).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Center(
                      child: TextField(
                        cursorColor: Colors.green,
                        controller: _usernameController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Username',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: const Color(0xFFB4B4B4).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Center(
                      child: TextField(
                        cursorColor: Colors.green,
                        controller: _bioController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Bio',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: saveProfile,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Save',
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
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset(
          "assets/images/logo.svg",
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}
