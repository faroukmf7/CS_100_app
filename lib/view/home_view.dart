import 'dart:convert';

import 'package:cs_100_project/constants.dart';
import 'package:cs_100_project/controller/usercontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userCtrl = Get.find<UserController>();
    final data = userCtrl.currentUser.value;
    final email = data?.email;
    final fName = data?.firstname;
    final sName = data?.surname;
    final mName = data?.middleName;
    final studentId = data?.studentid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Student ID: $studentId"),
        automaticallyImplyLeading: false,
        actions: [IconButton(onPressed: () {userCtrl.logout();}, icon: Icon(Icons.logout))],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Logged In'),
                ),
              ),
              Text('Welcome to class $fName ', style: kheadingB20),
            ],
          ),
        ),
      ),
    );
  }
}
