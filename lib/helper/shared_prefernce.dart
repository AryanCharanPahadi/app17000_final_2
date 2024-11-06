import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesHelper {
  static const String _userDataKey = 'userData';
  static const String _isLoggedInKey = 'isLoggedIn';

  // Store user data and update login state to true
  static Future<void> storeUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userDataJson = json.encode(userData);
      await prefs.setString(_userDataKey, userDataJson);
      await setLoginState(true);
      print('User data stored: $userData');
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  // Retrieve stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userDataJson = prefs.getString(_userDataKey);
      return userDataJson != null ? json.decode(userDataJson) : null;
    } catch (e) {
      print('Error retrieving user data: $e');
      return null;
    }
  }

  // Remove user data and set login state to false (logout)
  static Future<void> logout() async {
    try {
      await removeUserData();
      await setLoginState(false);
      print('User logged out.');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Set login state
  static Future<void> setLoginState(bool isLoggedIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, isLoggedIn);
      print('Login state set to: $isLoggedIn');
    } catch (e) {
      print('Error setting login state: $e');
    }
  }

  // Get login state
  static Future<bool> getLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error retrieving login state: $e');
      return false;
    }
  }

  // Remove user data
  static Future<void> removeUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      print('User data removed.');
    } catch (e) {
      print('Error removing user data: $e');
    }
  }
}
