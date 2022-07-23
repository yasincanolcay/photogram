import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photogram/responsive/const.dart';
import 'package:photogram/utils/global.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({Key? key}) : super(key: key);

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  int _page = 0;
  late PageController pageController;
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
    setState(() {
      _page = page;
    });
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: webBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: mobileBackgroundColor,
        foregroundColor: primaryColor,
        centerTitle: false,
        title: Row(children: [
          SvgPicture.asset(
            "assets/images/logo.svg",
            width: 40,
            height: 40,
          ),
          Text(
            " Photogram",
            style: TextStyle(
              fontFamily: "sweet",
              fontWeight: FontWeight.bold,
              fontSize: 29,
            ),
          )
        ]),
        actions: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: _page == 0 ? generalColor : secondaryColor,
            ),
            onPressed: () => navigationTapped(0),
          ),
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: _page == 1 ? generalColor : secondaryColor,
            ),
            onPressed: () => navigationTapped(1),
          ),
                    IconButton(
            icon: Icon(
              Icons.add_circle,
              color: _page == 2 ? generalColor : secondaryColor,
            ),
            onPressed: () => navigationTapped(2),
          ),
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: _page == 3 ? generalColor : secondaryColor,
            ),
            onPressed: () => navigationTapped(3),
          ),
        ],
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        children: HomeScreenItems,
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
    );
  }
}
