// ignore_for_file: unnecessary_import, unnecessary_brace_in_string_interps

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photogram/responsive/const.dart';
import 'package:photogram/utils/global.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({
    Key? key,
  }) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  int _page = 0;
  late PageController pageController;
  List<String> readedList = <String>[];
  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  Future<AudioPlayer> playLocalAsset() async {
    AudioCache cache = AudioCache();
    return await cache.play("refresh.mp3",
        mode: PlayerMode.LOW_LATENCY, volume: 0.50);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        foregroundColor: primaryColor,
        title: Row(children: [
          SvgPicture.asset(
            "assets/images/logo.svg",
            width: 40,
            height: 40,
          ),
          Text(
            " Photogram",
            style: TextStyle(
                fontFamily: "sweet", fontWeight: FontWeight.bold, fontSize: 29),
          )
        ]),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        children: HomeScreenItems,
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: DotNavigationBar(
        enablePaddingAnimation: true,
        backgroundColor: generalColor,
        currentIndex: _page,
        onTap: navigationTapped,
        dotIndicatorColor: Colors.black,
        // enableFloatingNavBar: false
        items: [
          DotNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _page == 0 ? Colors.white : secondaryColor,
            ),
          ),
          DotNavigationBarItem(
            icon: Icon(
              Icons.search_rounded,
              color: _page == 1 ? Colors.white : secondaryColor,
            ),
          ),
          DotNavigationBarItem(
            icon: Icon(
              Icons.add_circle,
              color: _page == 2 ? Colors.white : secondaryColor,
            ),
          ),
          DotNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _page == 3 ? Colors.white : secondaryColor,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 65, top: 10),
        child: Stack(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(uid)
                    .collection("bildirimler")
                    .where("okundu", isEqualTo: false)
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: SizedBox(),
                    );
                  }
                  int len = snapshot.data!.docs.length;
                  if (len != 0) {
                    playLocalAsset();
                  }
                  return Positioned(
                    child: len != 0
                        ? Text(
                            len < 99 ? "${len}" : "10++",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _page == 3 ? Colors.white : Colors.green,
                                shadows: const [
                                  Shadow(
                                      blurRadius: 9.0,
                                      offset: Offset.zero,
                                      color: primaryColor)
                                ]),
                          )
                        : const Text(""),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
