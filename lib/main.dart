import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'auth/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/main_navigation.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/item_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FindItTelU());
}

class FindItTelU extends StatelessWidget {
  const FindItTelU({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (_, themeVm, __) => MaterialApp(
          title: 'FindIt Tel-U',
          debugShowCheckedModeBanner: false,
          themeMode: themeVm.themeMode,
          theme: ThemeData(
            primaryColor: const Color(0xFFB71C1C),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFB71C1C),
              primary: const Color(0xFFB71C1C),
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            primaryColor: const Color(0xFFB71C1C),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFB71C1C),
              primary: const Color(0xFFB71C1C),
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            ),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const MainNavigation();
        }
        return const LoginScreen();
      },
    );
  }
}