// ignore_for_file: non_constant_identifier_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photogram/screens/home_screen.dart';
import 'package:photogram/screens/notifications_screen.dart';
import 'package:photogram/screens/profile_screen.dart';
import 'package:photogram/screens/search_screen.dart';
import 'package:photogram/screens/share_post_screen.dart';

const webScreenSize = 600;

List<Widget> HomeScreenItems = [
  const HomeScreen(),
  const SearchScreen(),
  const SharePostScreen(),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
];
