import 'package:cs_100_project/view/home_view.dart';
import 'package:cs_100_project/view/login.dart';
import 'package:cs_100_project/view/registeration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Attandance',
      home: Loginpage(),
      // initialRoute: '/login',
      // getPages: [
      //   GetPage(name: '/login', page: () => Loginpage()),
      //   GetPage(name: '/register', page: () => RegisterScreen()),
      //   GetPage(name: '/home', page: ()=>HomeScreen()),
      // ],
    );
  }
}
