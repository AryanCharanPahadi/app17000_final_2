import 'dart:async';
import 'package:app17000ft_new/helper/shared_prefernce.dart';
import 'package:app17000ft_new/home/home_screen.dart';
import 'package:app17000ft_new/login/login_screen.dart';
import 'package:app17000ft_new/splash/splash_screen.dart';
import 'package:app17000ft_new/utils/dependency_injection.dart';
import 'package:app17000ft_new/version_file/version_controller.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:app17000ft_new/theme/theme_constants.dart';
import 'package:app17000ft_new/theme/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  DependencyInjection.init();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  GetStorage().write('version', version);

  runApp(const MyApp());
}

ThemeManager themeManager = ThemeManager();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    themeManager.addListener(_themeListener);
    _initializeApp();
  }

  @override
  void dispose() {
    themeManager.removeListener(_themeListener);
    super.dispose();
  }

  void _themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeApp() async {
    _isLoggedIn = await SharedPreferencesHelper.getLoginState();

    if (_isLoggedIn == true) {
      Get.offAll(() => const HomeScreen());
      VersionController versionController = Get.put(VersionController());
      versionController.fetchVersion();
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeManager.themeMode,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
