import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Entities/user_profile.dart';
import '../Screens/profile_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../widgets/create_karya.dart';
import '../widgets/explore.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int currentPageIndex = 0;
  String? userId;

  Future<UserProfile> _userInit() async {
    const secureStorage = FlutterSecureStorage();
    userId = await secureStorage.read(key: "user_id");

    await dotenv.load(fileName: ".env");
    var response = await http.get(
      Uri.parse('${dotenv.env["API_URL"]}/profile'),
      headers: <String, String>{"Cookie": "user_id=$userId"},
    );
    return UserProfile.fromJson(jsonDecode(response.body));
  }

  void setPageIndex(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.background,
          statusBarIconBrightness: Brightness.light,
        ),
        child: FutureBuilder(
            future: _userInit(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                UserProfile userProfile = snapshot.data!;
                return Scaffold(
                  appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(70),
                      child: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                backgroundImage: NetworkImage(userProfile
                                        .image ??
                                    "https://petapixel.com/assets/uploads/2022/12/what-is-unsplash.jpg"),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hai, ${userProfile.firstName}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                  ),
                                  Text(
                                    "Apa yang ingin kamu temukan hari ini?",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton.filledTonal(
                                  onPressed: () {
                                    setPageIndex(0);
                                  },
                                  icon: const Icon(Icons.arrow_back)),
                              const SizedBox(width: 16),
                              Text(
                                "Tambah Karya",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(),
                      ][currentPageIndex]),
                  body: <Widget>[
                    ExploreWidget(userProfile: userProfile),
                    CreateKarya(setPageIndex: setPageIndex),
                    ProfileScreen(userProfile: userProfile),
                  ][currentPageIndex],
                  bottomNavigationBar: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(243, 237, 247, 1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: NavigationBar(
                      onDestinationSelected: (int index) {
                        setState(() {
                          currentPageIndex = index;
                        });
                      },
                      elevation: 0,
                      selectedIndex: currentPageIndex,
                      backgroundColor: Colors.transparent,
                      destinations: const [
                        NavigationDestination(
                          selectedIcon: Icon(Icons.explore),
                          icon: Icon(Icons.explore_outlined),
                          label: "Explore",
                        ),
                        NavigationDestination(
                          selectedIcon: Icon(Icons.add_circle),
                          icon: Icon(Icons.add_circle_outline),
                          label: "Create",
                        ),
                        NavigationDestination(
                          selectedIcon: Icon(Icons.settings),
                          icon: Icon(Icons.settings_outlined),
                          label: "Settings",
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }),
      ),
    );
  }
}
