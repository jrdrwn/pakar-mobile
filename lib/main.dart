import 'package:flutter/material.dart';
import 'package:flutter_application_3/Screens/explore_screen.dart';
import 'package:flutter_application_3/Screens/introduction_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    const secureStorage = FlutterSecureStorage();
    var userId = secureStorage.read(key: "user_id");

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.interTextTheme()),
      home: FutureBuilder(
          future: userId,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const ExploreScreen();
            } else {
              return const IntroductionScreen();
            }
          }),
    );
  }
}
