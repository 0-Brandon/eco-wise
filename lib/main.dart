import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/Screens/login.dart';
import '/Screens/signup.dart';
import 'Screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //FIXME maybe? dunno if correct
  runApp(const MyApp());
}
GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path:'/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path:'/signup',
      builder: (context, state) => SignUpScreen(),
    ),
    GoRoute(
     path:'/',
        builder:(context, state) => HomeScreen()
    ),
  ],
);
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }
}