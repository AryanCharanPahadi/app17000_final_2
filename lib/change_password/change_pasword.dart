import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/helper/responsive_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/custom_button.dart';
import '../components/custom_confirmation.dart';
import '../components/custom_labeltext.dart';
import '../components/custom_snackbar.dart';
import '../components/custom_textField.dart';
import '../home/home_controller.dart';
import '../user_controller/user_controller.dart';

class ChangePassword extends StatefulWidget {
  final String? userid;
  ChangePassword({
    super.key,
    this.userid,
  });

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final UserController _userController = Get.put(UserController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    // Ensure that userid is handled properly if it's null
    if (widget.userid != null) {
      print("UserId on init: ${widget.userid}");
    }
    _userNameController.text = _userController.username.value.toUpperCase();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _userNameController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      customSnackbar('Error', 'Passwords do not match!', Colors.red,
          Colors.white, Icons.error);
      return;
    }

    const apiUrl = 'https://mis.17000ft.org/17000ft_apis/edit_profile.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Accept": "Application/json"},
        body: {
          'username': username,
          'password': newPassword,
          'user_id': widget.userid ?? '',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 1) {
          customSnackbar(
              'Password Changed Successfully',
              'Changed',
              AppColors.primary,
              AppColors.onPrimary,
              Icons.verified);
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        } else {
          customSnackbar(
              'Error',
              'Failed to change password: ${responseData['message']}',
              Colors.red,
              Colors.white,
              Icons.error);
        }
      } else {
        customSnackbar('Error', 'Failed to change password. Please try again.',
            Colors.red, Colors.white, Icons.error);
      }
    } catch (e) {
      customSnackbar('Error', 'An error occurred. Please try again.',
          Colors.red, Colors.white, Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        IconData icon = Icons.check_circle;
        bool? shouldExit = await showDialog<bool>(
          context: context,
          builder: (_) => Confirmation(
            iconname: icon,
            title: 'Exit Confirmation',
            yes: 'Yes',
            no: 'No',
            desc: 'Are you sure you want to leave?',
            onPressed: () {
              Navigator.of(context).pop(true); // User confirms exit
            },
          ),
        );
        return shouldExit ?? false; // Default to false if shouldExit is null
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Change Password',
            style: AppStyles.appBarTitle(context, AppColors.onPrimary),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenWidth * 0.05,
            ),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelText(label: 'User Name'),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        textController: _userNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please fill this field';
                          }
                          return null;
                        },
                        prefixIcon: Icons.person,
                        readOnly: true,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 16),
                      LabelText(label: 'New Password'),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        textController: _newPasswordController,
                        labelText: 'Enter New Password',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          return null;
                        },
                        prefixIcon: Icons.password,
                        obscureText: _obscureNewPassword,
                        showCharacterCount: true,
                        borderRadius: BorderRadius.circular(12),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      LabelText(label: 'Confirm Password'),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        textController: _confirmPasswordController,
                        labelText: 'Confirm New Password',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        prefixIcon: Icons.password,
                        obscureText: _obscureConfirmPassword,
                        showCharacterCount: true,
                        borderRadius: BorderRadius.circular(12),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: CustomButton(
                          title: 'Submit',
                          onPressedButton: _changePassword,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
