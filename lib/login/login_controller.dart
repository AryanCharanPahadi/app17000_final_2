import 'dart:convert';
import 'package:app17000ft_new/base_client/base_client.dart';
import 'package:flutter/material.dart';
import '../base_client/app_exception.dart';
import '../base_client/baseClient_controller.dart';
import '../helper/dialog_helper.dart';
import 'package:get/get.dart';

class LoginController extends GetxController with BaseController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();


  authUser(String? username, String? password) async {
    var request = {'username': username ?? '', 'password': password ?? ''};
    showLoading('Please wait...');

    try {
      var response = await BaseClient()
          .post('https://mis.17000ft.org/apis/fast_apis/', 'login.php', request);

      var myresp = json.decode(response);
      hideLoading();

      return myresp;
    } catch (error) {
      hideLoading(); // Ensure loading dialog is hidden on error
      if (error is BadRequestException) {
        var apiError = json.decode(error.message!);
        DialogHelper.showErrorDialog(description: apiError["reason"]);
      } else {
        handleError(error);
      }
    }
  }


  clearFields() {
    usernameController.clear();
    phoneController.clear();
    passwordController.clear();
  }
}