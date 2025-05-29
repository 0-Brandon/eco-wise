import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'Screens/Login.dart';
import 'Screens/signup.dart';

void main() {
  runApp(const MyApp());
}
GoRouter router = GoRouter(
  initialLocation: '/1',
  routes: [
    GoRoute(
      path:'/1',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path:'/2',
      builder: (context, state) => SignUpScreen(),
    )
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