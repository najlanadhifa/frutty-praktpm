import 'package:flutter/material.dart';
import 'package:fruitymart/views/splash/splash_screen.dart';
import 'package:fruitymart/views/auth/login_page.dart';
import 'package:fruitymart/views/home/home_page.dart';
import 'package:fruitymart/views/profile/profile_page.dart';
import 'package:fruitymart/views/profile/feedback_page.dart';
import 'package:fruitymart/views/conversion/currency_page.dart';
import 'package:fruitymart/views/conversion/time_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const FruityMartApp());
}

class FruityMartApp extends StatelessWidget {
  const FruityMartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FruityMart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/feedback': (context) => const FeedbackPage(),
        '/currency': (context) => const CurrencyPage(),
        '/time': (context) => const TimePage(),
      },
    );
  }
}
