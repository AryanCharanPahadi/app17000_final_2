// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class LeaveController extends GetxController {
//   final RxList<String> availableDates = <String>[].obs;
//   String? selectedLieuDate;
//
//   // Method to fetch dates based on employee ID
//   Future<void> fetchAvailableDates(String empId) async {
//     try {
//       print('Fetching available dates for emp_id: $empId');
//
//       final requestBody = 'emp_id=$empId';
//       print('Request Body: $requestBody');
//
//       final response = await http.post(
//         Uri.parse('https://mis.17000ft.org/modules/leaveApplication/compoff.php'),
//         headers: {
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: requestBody,
//       );
//
//       print('Response status code: ${response.statusCode}');
//       print('Response headers: ${response.headers}');
//       print('Response body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         if (response.body.isEmpty) {
//           print('Received empty response body');
//           Get.snackbar('Error', 'No available dates found.');
//           return;
//         }
//
//         try {
//           final List<dynamic> data = json.decode(response.body);
//           availableDates.assignAll(data.map((e) => e.toString()).toList());
//           print('Available dates fetched: $availableDates');
//         } catch (e) {
//           print('Failed to decode JSON: $e');
//           Get.snackbar('Error', 'Failed to decode available dates.');
//         }
//       } else {
//         print('Failed to fetch dates. Response body: ${response.body}');
//         throw Exception('Failed to load dates: ${response.body}');
//       }
//     } catch (e, stackTrace) {
//       print('Error occurred: $e');
//       print('Stack trace: $stackTrace');
//       // Get.snackbar('Error', 'Failed to fetch available dates: $e');
//     }
//   }
//
//
//
// }
