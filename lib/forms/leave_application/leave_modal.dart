// // class LeaveRequest {
// //   final String leaveRequest;
// //   final String empId;
// //   final String type;
// //   final String numberOfLeaves;
// //   final String startDate;
// //   final String endDate;
// //   final String reason;
// //   final String compoff;
// //   final String document;
// //
// //   LeaveRequest({
// //     required this.leaveRequest,
// //     required this.empId,
// //     required this.type,
// //     required this.numberOfLeaves,
// //     required this.startDate,
// //     required this.endDate,
// //     required this.reason,
// //     required this.compoff,
// //     required this.document,
// //   });
// //
// //   // Factory constructor for creating a LeaveRequest from JSON
// //   factory LeaveRequest.fromJson(Map<String, dynamic> json) {
// //     return LeaveRequest(
// //       leaveRequest: json['leave_request'] ,
// //       empId: json['emp_id'],
// //       type: json['type'] ,
// //       numberOfLeaves: json['Number_of_leaves'] ,
// //       startDate: json['start_date'] ,
// //       endDate: json['end_date'],
// //       reason: json['reason'] ,
// //       compoff: json['compoff'],
// //       document: json['document'],
// //     );
// //   }
// //
// //   // Method to convert LeaveRequest to JSON
// //   Map<String, dynamic> toJson() {
// //     return {
// //       'leave_request': leaveRequest,
// //       'emp_id': empId,
// //       'type': type,
// //       'Number_of_leaves': numberOfLeaves,
// //       'start_date': startDate,
// //       'end_date': endDate,
// //       'reason': reason,
// //       'compoff': compoff,
// //       'document': document,
// //     };
// //   }
// // }
//
//
//
// // To parse this JSON data, do
// //
// //     final enrolmentCollectionModel = enrolmentCollectionModelFromJson(jsonString);
//
// import 'dart:convert';
//
// LeaveRequestModal leaveRequestModalFromJson(String str) => LeaveRequestModal.fromJson(json.decode(str));
//
// String leaveRequestModalToJson(LeaveRequestModal data) => json.encode(data.toJson());
// class LeaveRequestModal {
//
//   String? leaveRequest;
//   String? empId;
//   String? type;
//   String? numberOfLeaves;
//   String? startDate;
//   String? endDate;
//   String? reason;
//   String? compoff;
//   String? document;
//
//
//   LeaveRequestModal({
//     this.leaveRequest,
//     this.empId,
//     this.type,
//     this.numberOfLeaves,
//     this.startDate,
//     this.endDate,
//     this.reason,
//     this.compoff,
//     this.document,
//
//   });
//
//   factory LeaveRequestModal.fromJson(Map<String, dynamic> json) => LeaveRequestModal(
//     leaveRequest: json['leave_request'] ,
//     empId: json['emp_id'],
//     type: json['type'] ,
//     numberOfLeaves: json['Number_of_leaves'] ,
//     startDate: json['start_date'] ,
//     endDate: json['end_date'],
//     reason: json['reason'] ,
//     compoff: json['compoff'],
//     document: json['document'],
//   );
//
//   Map<String, dynamic> toJson() => {
//     'leave_request': leaveRequest,
//     'emp_id': empId,
//     'type': type,
//     'Number_of_leaves': numberOfLeaves,
//     'start_date': startDate,
//     'end_date': endDate,
//     'reason': reason,
//     'compoff': compoff,
//     'document': document,
//
//   };
// }
