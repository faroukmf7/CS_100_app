import 'dart:convert';

import 'package:cs_100_project/constants.dart';
import 'package:cs_100_project/model/user_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class UserController extends GetxController {
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;

  final baseURL = endpoint;

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final responds = await http.post(
        Uri.parse('${baseURL}login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email':email,'password':password})
      );
      if (responds.statusCode == 200){
        final data = jsonDecode(responds.body);
        if(data["status"] == true){
          currentUser.value=UserModel.fromjson(data["user"]);
          Get.snackbar("Success", data["message"]);
        }else{
          Get.snackbar("Failed", data['message']);
        }

      }else{

      }
    } catch (e) {
      print("$e");
    }
    isLoading.value = false;
  }
}
