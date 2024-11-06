// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class LeaveService {
//   final String baseUrl = 'https://mis.17000ft.org/apis/fast_apis/leave_apis/';
//
//   Future<Map<String, dynamic>> fetchRemainingLeaves(String empId) async {
//     final url = Uri.parse('${baseUrl}getRemainingLeaves.php?emp_id=$empId');
//     try {
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body) as Map<String, dynamic>;
//
//         // Adjusted condition to proceed even when "error" is true if "message" is "Success"
//         if ((data['error'] == true && data['message'] == "Success") || data['error'] == false) {
//           // Parse values as double to ensure compatibility
//           return {
//             'CL': (data['CL'] as num).toInt(),
//             'EL': (data['EL'] as num).toDouble(),
//             'SL': (data['SL'] as num).toInt(),
//           };
//         } else {
//           throw Exception('Error: ${data['message']}');
//         }
//       } else {
//         throw Exception('Failed to load leave data');
//       }
//     } catch (e) {
//       print("Error fetching leave data: $e");
//       rethrow;
//     }
//   }
// }
