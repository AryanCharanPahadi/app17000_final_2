import 'dart:io';
import 'package:app17000ft_new/components/curved_container.dart';
import 'package:app17000ft_new/components/custom_button.dart';
import 'package:app17000ft_new/components/custom_snackbar.dart';
import 'package:app17000ft_new/components/custom_textField.dart';
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/helper/responsive_helper.dart';
import 'package:app17000ft_new/helper/shared_prefernce.dart';
import 'package:app17000ft_new/home/home_screen.dart';
import 'package:app17000ft_new/login/login_controller.dart';
import 'package:app17000ft_new/services/network_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../forms/issue_tracker/issue_tracker_controller.dart';
import '../forms/select_tour_id/select_controller.dart';
import '../version_file/version_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _loginFormkey = GlobalKey<FormState>();
  final loginController = Get.put(LoginController());
  bool passwordVisible = true;

  @override
  void initState() {
    super.initState();
    passwordVisible = true;

    // Check if the user is already logged in on app start
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    bool isLoggedIn = await SharedPreferencesHelper.getLoginState();
    if (isLoggedIn) {
      // If already logged in, navigate to HomeScreen
      Get.offAll(() => const HomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.onPrimary,
      body: GetBuilder<NetworkManager>(
        init: NetworkManager(),
        builder: (networkManager) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const CurvedContainer(),
                Image.asset(
                  'assets/logo.png',
                  height: responsive.responsiveValue(
                      small: 60.0, medium: 80.0, large: 100.0),
                  width: responsive.responsiveValue(
                      small: 150.0, medium: 200.0, large: 250.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Login',
                      style: AppStyles.heading1(
                          context, AppColors.onBackground),
                    ),
                  ),
                ),
                Form(
                  key: _loginFormkey,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 40, right: 40, top: 40),
                    child: Column(
                      children: [
                        SizedBox(
                          height: responsive.responsiveValue(
                              small: 60.0, medium: 70.0, large: 80.0),
                          child: CustomTextFormField(
                            textController: loginController.usernameController,
                            textInputType: TextInputType.text,
                            prefixIcon: Icons.phone,
                            hintText: 'Username',
                            labelText: 'Enter your username',
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: responsive.responsiveValue(
                              small: 30.0, medium: 40.0, large: 50.0),
                        ),
                        SizedBox(
                          height: responsive.responsiveValue(
                              small: 60.0, medium: 70.0, large: 80.0),
                          child: CustomTextFormField(
                            textController: loginController.passwordController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            obscureText: passwordVisible,
                            prefixIcon: Icons.password,
                            hintText: 'Password',
                            labelText: 'Enter your password',
                            suffixIcon: IconButton(
                              icon: Icon(passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: responsive.responsiveValue(
                              small: 20.0, medium: 30.0, large: 40.0),
                        ),
                        CustomButton(
                          onPressedButton: () async {
                            if (networkManager.connectionType == 0) {
                              customSnackbar(
                                'Error',
                                'No Internet Connection',
                                AppColors.secondary,
                                AppColors.onSecondary,
                                Icons.error,
                              );
                            } else {
                              if (_loginFormkey.currentState!.validate()) {
                                await SharedPreferencesHelper.logout();

                                try {
                                  var myrsp = await loginController.authUser(
                                    loginController.usernameController.text,
                                    loginController.passwordController.text,
                                  );

                                  if (myrsp != null && myrsp['status'] == 1) {
                                    await SharedPreferencesHelper.storeUserData(
                                        myrsp);

                                    customSnackbar(
                                      'Success',
                                      myrsp['message'],
                                      AppColors.secondary,
                                      AppColors.onSecondary,
                                      Icons.verified,
                                    );
                                    _loginFormkey.currentState?.reset();
                                    loginController.clearFields();

                                    // Request for storage permission after successful login
                                    bool permissionGranted = await requestPermission();
                                    if (!permissionGranted) {
                                      // Handle denied permission if needed
                                    }

                                    final IssueTrackerController controller = Get
                                        .put(IssueTrackerController());
                                    controller.office = myrsp['office'];

                                    final SelectController selectController = Get
                                        .put(SelectController());
                                    selectController.unlockTourAndSchools();
                                    selectController
                                        .clearFields(); // Reset fields for new data

                                    // Navigate to HomeScreen
                                    Get.offAll(() => const HomeScreen());

                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      VersionController versionController = Get
                                          .put(VersionController());
                                      versionController.fetchVersion();
                                    });
                                  } else {
                                    customSnackbar(
                                      'Invalid',
                                      myrsp['message'],
                                      AppColors.secondary,
                                      AppColors.onSecondary,
                                      Icons.warning,
                                    );
                                  }
                                } catch (error) {
                                  customSnackbar(
                                    'Error',
                                    'An error occurred during login: ${error
                                        .toString()}',
                                    AppColors.secondary,
                                    AppColors.onSecondary,
                                    Icons.error,
                                  );
                                }
                              }
                            }
                          },
                          title: 'Login',
                        ),
                        SizedBox(
                          height: responsive.responsiveValue(
                              small: 10.0, medium: 20.0, large: 30.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


// Request permission for storage access
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;

      // Android 11+ (API level 30 and above)
      if (androidInfo.version.sdkInt >= 30) {
        var manageStoragePermission = await Permission.manageExternalStorage
            .status;
        if (manageStoragePermission.isDenied) {
          manageStoragePermission =
          await Permission.manageExternalStorage.request();
          return manageStoragePermission.isGranted;
        }
        return true;
      }

      // Android 10 and below
      if (await Permission.storage.isDenied) {
        var permissionStatus = await Permission.storage.request();
        return permissionStatus.isGranted;
      }
    } else if (Platform.isIOS) {
      // On iOS, permission might not be needed for internal directories
      return true;
    }

    return true;
  }

}
