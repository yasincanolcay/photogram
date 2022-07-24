import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photogram/provider/user_provider.dart';
import 'package:photogram/responsive/const.dart';
import 'package:photogram/responsive/mobile_screen.dart';
import 'package:photogram/responsive/responsive_layout.dart';
import 'package:photogram/responsive/web_screen.dart';
import 'package:photogram/screens/home_screen.dart';
import 'package:photogram/screens/login_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//login firebase and get options
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "your api",
        appId: "your Id",
        messagingSenderId: "your message sender Id",
        projectId: "your projectId",
        storageBucket: "your bucked",
      ),
    );
  } else {
    //SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        scrollBehavior: MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown
          },
        ),
        title: 'Photogram',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
          bannerTheme: const MaterialBannerThemeData(
            backgroundColor: Colors.white,
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  // ignore: unnecessary_string_interpolations
                  child: Text('${snapshot.error.toString()}'),
                );
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: generalColor),
              );
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
