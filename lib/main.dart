import 'package:eco_wise/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '/Screens/login.dart';
import '/Screens/signup.dart';
import 'Screens/home.dart';

final ProviderContainer providerContainer = ProviderContainer();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(
      UncontrolledProviderScope(container: providerContainer, child: MyApp())
  );
}

GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: LoginScreen.routeName,
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: SignUpScreen.routeName,
      builder: (context, state) => SignUpScreen(),
    ),
    GoRoute(
        path: HomeScreen.routeName,
        builder: (context, state) => HomeScreen()
    ),
  ],
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2e7d32), // Deep green
    primaryContainer: Color(0xFFd9f7e5), // Light green background
    secondary: Color(0xFF4db6ac), // Teal accent
    secondaryContainer: Color(0xFFb2f2bb), // Medium green
    surface: Colors.white,
    surfaceContainerHighest: Color(0xFFF1F8E9), // Very light green
    onPrimary: Colors.white,
    onPrimaryContainer: Color(0xFF2e7d32),
    onSecondary: Colors.white,
    onSecondaryContainer: Color(0xFF2e7d32),
    onSurface: Color(0xFF212121),
    onSurfaceVariant: Color(0xFF757575),
    outline: Color(0xFFE0E0E0),
  ),
  fontFamily: 'Roboto',
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2e7d32),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: 'Roboto',
      color: Colors.white,
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
      color: Color(0xFF2e7d32),
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
      color: Color(0xFF2e7d32),
    ),
    headlineLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
      color: Color(0xFF2e7d32),
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      fontFamily: 'Roboto',
      color: Color(0xFF757575),
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0xFF212121),
      fontFamily: 'Roboto',
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      color: Color(0xFF212121),
      fontFamily: 'Roboto',
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Color(0xFF212121),
      fontFamily: 'Roboto',
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFF757575),
      fontFamily: 'Roboto',
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: Color(0xFF757575),
      fontFamily: 'Roboto',
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    color: Colors.white.withValues(alpha:0.2),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2e7d32),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF2e7d32),
      side: const BorderSide(color: Color(0xFF2e7d32), width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF2e7d32),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withValues(alpha:0.3),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Colors.white.withValues(alpha:0.3),
        width: 1.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFF2e7d32),
        width: 2,
      ),
    ),
    labelStyle: const TextStyle(
      color: Color(0xFF757575),
      fontFamily: 'Roboto',
    ),
    hintStyle: const TextStyle(
      color: Color(0xFF757575),
      fontFamily: 'Roboto',
    ),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF2e7d32),
    size: 24,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF2e7d32),
    unselectedItemColor: Color(0xFF757575),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.normal,
    ),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EcoWise',
      theme: lightTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}