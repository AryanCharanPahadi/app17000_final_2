//
// import 'dart:convert';
// import 'dart:io';
//
// import 'leave_modal.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart';
//
//
// Future<void> submitLeaveRequest(LeaveRequestModal leaveRequestModal) async {
//   const String apiUrl =
//       'https://mis.17000ft.org/apis/fast_apis/leave_apis/insertLeave.php';
//
//   try {
//     var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
//
//     // Add form fields
//     request.fields['emp_id'] = leaveRequestModal.empId!;
//     request.fields['type'] = leaveRequestModal.type ?? '';
//     request.fields['Number_of_leaves'] = leaveRequestModal.numberOfLeaves ?? '';
//     request.fields['start_date'] = leaveRequestModal.startDate ?? '';
//     request.fields['end_date'] = leaveRequestModal.endDate ?? '';
//     request.fields['reason'] = leaveRequestModal.reason ?? '';
//     request.fields['compoff'] = leaveRequestModal.compoff ?? '';
//     request.fields['leave_request'] = leaveRequestModal.leaveRequest ?? '';
//
//     // Attach document files
//     for (var filePath in leaveRequestModal.document!.split(',')) {
//       if (filePath.isNotEmpty) {
//         File file = File(filePath);
//         request.files.add(await http.MultipartFile.fromPath(
//           'document',
//           file.path,
//           filename: basename(file.path),
//         ));
//       }
//     }
//
//     // Send the request
//     var response = await request.send();
//     final responseBody = await response.stream.bytesToString();
//
//     print("Response body: $responseBody");
//
//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(responseBody);
//       if (jsonResponse['success']) {
//         print("Leave request submitted successfully.");
//       } else {
//         print("Failed to submit leave request: ${jsonResponse['message']}");
//       }
//     } else {
//       print("Failed to submit leave request: ${response.reasonPhrase}");
//     }
//   } catch (e) {
//     print("Error during submission: $e");
//   }
// }
