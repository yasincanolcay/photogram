import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photogram/resources/auth_methods.dart';
import 'package:photogram/responsive/const.dart';
import 'package:photogram/responsive/mobile_screen.dart';
import 'package:photogram/responsive/responsive_layout.dart';
import 'package:photogram/responsive/web_screen.dart';
import 'package:photogram/screens/login_screen.dart';
import 'package:photogram/utils/utils.dart';

class SignScreen extends StatefulWidget {
  const SignScreen({Key? key}) : super(key: key);

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  ImagePicker _picker = ImagePicker();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;
  bool _isVisible = true;

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
  }

  void selectImages() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    if (_image == null) {
      String defaultPicture = "assets/images/user.png"; //path to asset
      ByteData bytes = await rootBundle.load(defaultPicture);
      _image =
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    }
    String res = await AuthMethods().signUpUser(
      _emailController.text,
      _passwordController.text,
      _usernameController.text,
      _bioController.text,
      _image!,
    );
    setState(() {
      _isLoading = false;
    });
    showSnackBar(res, context);
    if (res == "Welcome to Photogram, enjoy :-)") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      );
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
                    _image != null
                        ? CircleAvatar(
                            radius: 55,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : const CircleAvatar(
                            radius: 55,
                            backgroundColor: generalColor,
                            backgroundImage:
                                AssetImage('assets/images/user.png'),
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
                const SizedBox(
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
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Gmail Address..',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
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
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        obscureText: _isVisible,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                            suffixIcon: IconButton(
                                onPressed: () {
                                  if (_isVisible) {
                                    _isVisible = false;
                                  } else {
                                    _isVisible = true;
                                  }
                                  setState(() {});
                                },
                                icon: Icon(_isVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility_rounded))),
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
                    onPressed: signUpUser,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Sign In',
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
                RichText(
                  text: TextSpan(
                    text: "Do you have Accound?",
                    style: const TextStyle(color: generalColor, fontSize: 18),
                    children: [
                      TextSpan(
                        text: ' Log In',
                        style:
                            const TextStyle(color: primaryColor, fontSize: 18),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const LoginScreen()));
                          },
                      ),
                    ],
                  ),
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
