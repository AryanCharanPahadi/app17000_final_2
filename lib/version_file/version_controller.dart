import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/custom_confirmation.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For checking network status

class VersionController extends GetxController {
  var version = ''.obs;
  var isLoading = false.obs;
  var currentVersion = 3.4;

  @override
  void onInit() {
    super.onInit();
    fetchVersion();
  }

  // Fetch version from API or local storage
  Future<void> fetchVersion() async {
    try {
      isLoading(true);

      // Step 1: Check for network connectivity
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('No internet connection, loading version from local storage.');
        await _loadVersion();
        _checkForUpdate();
        return;
      }

      // Step 2: Fetch version from API
      final response = await http.get(Uri.parse('https://mis.17000ft.org/apis/fast_apis/version.php'));

      print('Status Code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data.containsKey('version')) {
          version.value = data['version'] ?? '';
          print('Version from API: ${version.value}');

          // Store the version locally
          await _storeVersion(version.value);

          // Compare versions
          _checkForUpdate();
        } else {
          print('Error: "version" field not found in API response.');
        }
      } else {
        print('Error fetching version from API: ${response.statusCode}, ${response.body}');
        await _loadVersion();
        _checkForUpdate();  // Check stored version in case of error
      }
    } catch (e) {
      print('Exception during version fetch: $e');
      await _loadVersion();
      _checkForUpdate();  // Check stored version in case of exception
    } finally {
      isLoading(false);
    }
  }

  // Store version in SharedPreferences
  Future<void> _storeVersion(String version) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_version', version);
      print('Version stored locally: $version');
    } catch (e) {
      print('Error storing version locally: $e');
    }
  }

  // Load version from SharedPreferences
  Future<void> _loadVersion() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedVersion = prefs.getString('app_version');
      if (savedVersion != null) {
        version.value = savedVersion;
        print('Loaded version from local storage: $savedVersion');
      } else {
        print('No version found in local storage.');
      }
    } catch (e) {
      print('Error loading version from local storage: $e');
    }
  }

  // Compare API version with the current version
  void _checkForUpdate() {
    double apiVersion = double.tryParse(version.value) ?? 0.0;
    print('Parsed API version as double: $apiVersion');

    if (apiVersion != currentVersion) {
      print('API version differs from current version, showing upgrade prompt.');
      showUpgradePrompt();
    } else {
      print('Current version matches API version, no upgrade needed.');
    }
  }

  // Show an upgrade prompt dialog
  void showUpgradePrompt() {
    if (Get.isDialogOpen != true) {
      Get.dialog(
        Confirmation(
          title: "Update Available",
          desc: "A new version of the app is available. Please update to the latest version.",
          onPressed: () {
            print("Navigating to update...");  // Handle update action
            // TODO: Add actual navigation or logic for updating the app
          },
          yes: "OK",
          iconname: Icons.update,
        ),
      );
    }
  }
}
