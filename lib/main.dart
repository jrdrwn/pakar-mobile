import 'package:flutter/material.dart';
import './Screens/create_account_screen.dart';
import './Screens/explore_screen.dart';
import './Screens/introduction_screen.dart';
import './Screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
        path: '/register',
        builder: (context, state) => const CreateAccountScreen()),
    GoRoute(
        path: '/intro',
        builder: (context, state) => const IntroductionScreen()),
    GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
              fromRegister: bool.parse(
                  state.uri.queryParameters['from_register'] ?? 'false'),
            )),
    GoRoute(
        path: '/create-account',
        builder: (context, state) => const CreateAccountScreen()),
    GoRoute(
        path: '/',
        redirect: (context, state) async {
          const secureStorage = FlutterSecureStorage();
          var userId = await secureStorage.read(key: "user_id");
          if (userId != null) {
            return '/explore';
          } else {
            return '/';
          }
        },
        builder: (context, state) => const IntroductionScreen()),
    GoRoute(
        path: '/explore', builder: (context, state) => const ExploreScreen()),
  ],
);

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.interTextTheme()),
      routerConfig: _router,
    );
  }
}
