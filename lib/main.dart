import 'package:flutter/material.dart';
import 'package:flutter_mongo_lab1/Page/AddProductPage.dart';
import 'package:flutter_mongo_lab1/Page/home_admin.dart';

import 'package:flutter_mongo_lab1/Page/home_screen.dart';
import 'package:flutter_mongo_lab1/Page/login_screen.dart';
import 'package:flutter_mongo_lab1/Page/register.dart';
import 'package:flutter_mongo_lab1/providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
          title: 'Login Example',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          routes: {
            '/home': (context) => const HomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterPage(),
            '/admin': (context) => const HomeAdmin(),
            '/add_product': (context) => const AddProductPage(),
          }),
    );
  }
}
