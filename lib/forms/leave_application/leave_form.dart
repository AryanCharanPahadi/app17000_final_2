// import 'dart:io';
//
// import 'package:app17000ft_new/forms/leave_application/leave_controller_form.dart';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pdfx/pdfx.dart';
//
// import '../../components/custom_appBar.dart';
// import '../../components/custom_button.dart';
// import '../../components/custom_confirmation.dart';
// import '../../components/custom_datePicker.dart';
// import '../../components/custom_dropdown_2.dart';
// import '../../components/custom_labeltext.dart';
// import '../../components/custom_sizedBox.dart';
// import '../../components/custom_snackbar.dart';
// import '../../components/custom_textField.dart';
// import '../../components/error_text.dart';
// import '../../constants/color_const.dart';
// import '../../helper/responsive_helper.dart';
// import 'comOff_service.dart';
// import 'leave_modal.dart';
// import 'leave_sync.dart';
//
// class LeaveForm extends StatefulWidget {
//   String? userid;
//   LeaveForm({
//     super.key,
//     this.userid,
//   });
//
//   @override
//   _LeaveFormState createState() => _LeaveFormState();
// }
//
// class _LeaveFormState extends State<LeaveForm> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final LeaveControllerForm leaveControllerForm =
//       Get.put(LeaveControllerForm());
//   final leaveController = Get.put(LeaveController());
//
//   @override
//   void initState() {
//     super.initState();
//     print(widget.userid);
//     if (widget.userid != null) {
//       leaveControllerForm.fetchLeaveData(widget.userid!);
//     }
//
// // Fetch dates when needed
//     leaveController.fetchAvailableDates(widget.userid!);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final responsive = Responsive(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       appBar: const CustomAppbar(
//         title: 'Leave Application',
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               GetBuilder<LeaveControllerForm>(
//                 init: LeaveControllerForm(),
//                 builder: (leaveControllerForm) {
//                   return Form(
//                     key: _formKey, // Make sure this is present
//
//                     child: Padding(
//                       padding: const EdgeInsets.only(
//                           left: 20.0), // Adjust this value as needed
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               Column(
//                                 children: [
//                                   LabelText(
//                                     label: 'CL',
//                                   ),
//                                   SizedBox(height: 8),
//                                   Obx(() => Text(
//                                         leaveControllerForm.cl.value.toString(),
//                                         style: TextStyle(fontSize: 16),
//                                       )),
//                                 ],
//                               ),
//                               SizedBox(width: screenWidth * 0.1), // Add spacing
//                               Column(
//                                 children: [
//                                   LabelText(
//                                     label: 'SL',
//                                   ),
//                                   SizedBox(height: 10),
//                                   Obx(() => Text(
//                                         leaveControllerForm.sl.value.toString(),
//                                         style: TextStyle(fontSize: 16),
//                                       )),
//                                 ],
//                               ),
//                               SizedBox(width: screenWidth * 0.1), // Add spacing
//
//                               Column(
//                                 children: [
//                                   LabelText(
//                                     label: 'EL',
//                                   ),
//                                   SizedBox(height: 10),
//                                   Obx(() => Text(
//                                         leaveControllerForm.el.value.toString(),
//                                         style: TextStyle(fontSize: 16),
//                                       )),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           CustomSizedBox(side: 'height', value: 40),
//                           Row(
//                             children: [
//                               // Leave Type Dropdown
//                               Expanded(
//                                 flex: 2,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     LabelText(
//                                       label: 'Leave Type',
//                                       astrick: true,
//                                     ),
//                                     SizedBox(height: 10),
//                                     CustomDropdown(
//                                       labelText: '-Select Type-',
//                                       selectedValue:
//                                           leaveControllerForm.selectedLeaveType,
//                                       items: [
//                                         DropdownMenuItem(
//                                             value: 'Select Type',
//                                             child: Text('Select Type')),
//                                         DropdownMenuItem(
//                                             value: 'SL',
//                                             child: Text('SL - Sick Leave')),
//                                         DropdownMenuItem(
//                                             value: 'CL',
//                                             child: Text('CL - Casual Leave')),
//                                         DropdownMenuItem(
//                                             value: 'EL',
//                                             child: Text('EL - Earned Leave')),
//                                         DropdownMenuItem(
//                                             value: 'CO',
//                                             child: Text(
//                                                 'CO - Compensatory Leave')),
//                                       ],
//                                       onChanged: (value) {
//                                         setState(() {
//                                           leaveControllerForm
//                                               .selectedLeaveType = value;
//                                         });
//                                       },
//                                       validator: (value) {
//                                         if (value == null ||
//                                             value == 'Select Type') {
//                                           return 'Please select a leave type';
//                                         }
//                                         return null;
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//
//                               SizedBox(width: 20),
//
//                               // Conditional In Lieu of Date Selector
//                               if (leaveControllerForm.selectedLeaveType == 'CO')
//                                 Expanded(
//                                   flex: 2,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       LabelText(
//                                           label: 'In Lieu of Date',
//                                           astrick: true),
//                                       SizedBox(height: 10),
//                                       Obx(() {
//                                         return CustomDropdown(
//                                           labelText: 'Select Lieu Date',
//                                           selectedValue: leaveControllerForm.selectedLieuDate, // Current selected value
//                                           items: leaveController.availableDates.map((String date) {
//                                             return DropdownMenuItem<String>(
//                                               value: date,
//                                               child: Text(date),
//                                             );
//                                           }).toList(),
//                                           onChanged: (String? newValue) {
//                                             // Update the selected value in both controllers
//                                             leaveControllerForm.selectedLieuDate = newValue; // Ensure this is observable
//                                           },
//                                           validator: (value) {
//                                             if (value == null) {
//                                               return 'Please select a date';
//                                             }
//                                             return null;
//                                           },
//                                         );
//                                       }),
//
//                                     ],
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           CustomSizedBox(
//                             value: 20,
//                             side: 'height',
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     LabelText(
//                                       label: 'Start Date',
//                                       astrick: true,
//                                     ),
//                                     CustomSizedBox(
//                                       value: 10,
//                                       side: 'height',
//                                     ),
//                                     CustomDatePicker(
//                                       selectedDate:
//                                           leaveControllerForm.startDate,
//                                       label: 'Start Date',
//                                       onDateChanged: (newDate) {
//                                         setState(() {
//                                           // Create a new DateTime object with only the date part
//                                           leaveControllerForm.startDate =
//                                               DateTime(newDate.year,
//                                                   newDate.month, newDate.day);
//
//                                           // Update total days and validate the start date
//                                           leaveControllerForm.updateTotalDays();
//                                           leaveControllerForm
//                                               .validateStartDate();
//                                         });
//                                       },
//                                       isStartDate: true,
//                                       errorText: leaveControllerForm
//                                           .startDateFieldError,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(width: 20), // Spacing between the fields
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     LabelText(
//                                       label: 'End Date',
//                                       astrick: true,
//                                     ),
//                                     CustomSizedBox(
//                                       value: 10,
//                                       side: 'height',
//                                     ),
//                                     CustomDatePicker(
//                                       selectedDate: leaveControllerForm.endDate,
//                                       label: 'End Date',
//                                       firstDate: leaveControllerForm
//                                               .startDate ??
//                                           DateTime(
//                                               2000), // Restrict to startDate
//                                       onDateChanged: (newDate) {
//                                         setState(() {
//                                           // Create a new DateTime object with only the date part
//                                           leaveControllerForm.endDate =
//                                               DateTime(newDate.year,
//                                                   newDate.month, newDate.day);
//
//                                           // Update total days and validate the end date
//                                           leaveControllerForm.updateTotalDays();
//                                           leaveControllerForm.validateEndDate();
//                                         });
//                                       },
//                                       isStartDate: false,
//                                       errorText:
//                                           leaveControllerForm.endDateFieldError,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           CustomSizedBox(
//                             value: 20,
//                             side: 'height',
//                           ),
//                           Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Number of Leaves Column
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       LabelText(
//                                         label: 'Number Of Leaves',
//                                         astrick: true,
//                                       ),
//                                       CustomSizedBox(
//                                         value: 10,
//                                         side: 'height',
//                                       ),
//                                       CustomTextFormField(
//                                         textController: leaveControllerForm
//                                             .numberOfLeaveController,
//                                         labelText: 'Total Number of Days',
//                                         readOnly: true,
//                                         validator: (value) {
//                                           if (value == null || value.isEmpty) {
//                                             return 'Please fill this field';
//                                           }
//
//                                           int? numberOfDays =
//                                               int.tryParse(value);
//                                           if (numberOfDays == null) {
//                                             return 'Please enter a valid number';
//                                           }
//
//                                           final DateTime currentDate =
//                                               DateTime.now();
//                                           final int daysDifference =
//                                               leaveControllerForm.startDate !=
//                                                       null
//                                                   ? leaveControllerForm
//                                                       .startDate!
//                                                       .difference(currentDate)
//                                                       .inDays
//                                                   : 0;
//
//                                           // Get available leave balance for each type
//                                           final int availableCL =
//                                               leaveControllerForm.cl.value;
//                                           final int availableSL =
//                                               leaveControllerForm.sl.value;
//                                           final double availableEL =
//                                               leaveControllerForm.el.value;
//
//                                           // Check balance and leave limits based on leave type
//                                           if (leaveControllerForm
//                                                   .selectedLeaveType ==
//                                               'CL') {
//                                             if (numberOfDays > availableCL) {
//                                               showConfirmationDialog(
//                                                   'Insufficient CL Leave $availableCL');
//                                               return 'Insufficient CL Leave $availableCL';
//                                             } else if (numberOfDays > 3) {
//                                               showConfirmationDialog(
//                                                   'Max Leave size 3');
//                                               return 'max Leave size 3';
//                                             }
//                                           }
//
//                                           if (leaveControllerForm
//                                                   .selectedLeaveType ==
//                                               'SL') {
//                                             if (numberOfDays > availableSL) {
//                                               showConfirmationDialog(
//                                                   'Insufficient SL Leave $availableSL');
//                                               return 'Insufficient SL Leave $availableSL';
//                                             } else if (numberOfDays > 7) {
//                                               showConfirmationDialog(
//                                                   'Max Leave size 7');
//                                               return 'max Leave size 7';
//                                             }
//                                           }
//
//                                           if (leaveControllerForm
//                                                   .selectedLeaveType ==
//                                               'EL') {
//                                             if (numberOfDays > availableEL) {
//                                               showConfirmationDialog(
//                                                   'Insufficient EL Leave $availableEL');
//                                               return 'Insufficient EL Leave $availableEL';
//                                             } else if (numberOfDays > 3 &&
//                                                 daysDifference < 15) {
//                                               showConfirmationDialog(
//                                                   'Request more then 3 EL only can apply before 15 days');
//                                               return 'Not Valid';
//                                             } else if (numberOfDays > 15) {
//                                               showConfirmationDialog(
//                                                   'Max Leave size 15');
//                                               return 'max Leave size 15';
//                                             }
//                                           }
//
//                                           if (leaveControllerForm
//                                                   .selectedLeaveType ==
//                                               'CO') {
//                                             if (numberOfDays > 1) {
//                                               showConfirmationDialog(
//                                                   'Max Leave size 1');
//                                               return 'max Leave size 1';
//                                             }
//                                           }
//
//                                           return null; // If all validations pass
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(width: 20),
//                                 if (leaveControllerForm.selectedLeaveType ==
//                                         'SL' &&
//                                     (int.tryParse(leaveControllerForm
//                                                 .numberOfLeaveController
//                                                 .text) ??
//                                             0) >
//                                         3) ...[
//                                   // Upload Medical Column
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         LabelText(
//                                           label: 'Upload Medical',
//                                           astrick: true,
//                                         ),
//                                         CustomSizedBox(
//                                           value: 10,
//                                           side: 'height',
//                                         ),
//                                         // Upload Field Container
//                                         // Upload Field Container
//
//                                         Container(
//                                           height: 57,
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(10.0),
//                                             border: Border.all(
//                                               width: 2,
//                                               color: leaveControllerForm
//                                                           .isImageUploadedNumberOfLeaves ==
//                                                       false
//                                                   ? Colors.grey
//                                                   : Colors.red,
//                                             ),
//                                           ),
//                                           child: ListTile(
//                                             title: const Text(
//                                                 'Click or Upload Image/PDF'),
//                                             trailing: const Icon(
//                                               Icons.camera_alt,
//                                               color: AppColors.onBackground,
//                                             ),
//                                             onTap: () {
//                                               // Show the bottom sheet for image or PDF upload
//                                               showModalBottomSheet(
//                                                 backgroundColor:
//                                                     AppColors.primary,
//                                                 context: context,
//                                                 builder: (builder) =>
//                                                     leaveControllerForm
//                                                         .bottomSheet(context),
//                                               );
//                                             },
//                                           ),
//                                         ),
//
//                                         const SizedBox(height: 8.0),
//
//                                         if (leaveControllerForm
//                                             .imagePaths.isNotEmpty)
//                                           GestureDetector(
//                                             onTap: () {
//                                               // Show responsive popup with uploaded files in a row
//                                               showDialog(
//                                                 context: context,
//                                                 builder: (context) {
//                                                   return AlertDialog(
//                                                     backgroundColor:
//                                                         AppColors.primary,
//                                                     title: Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceBetween,
//                                                       children: [
//                                                         const Text(
//                                                             'Uploaded Files',
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .white)),
//                                                         IconButton(
//                                                           icon: const Icon(
//                                                               Icons.close,
//                                                               color:
//                                                                   Colors.white),
//                                                           onPressed: () =>
//                                                               Navigator.of(
//                                                                       context)
//                                                                   .pop(), // Close the popup
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     content:
//                                                         SingleChildScrollView(
//                                                       scrollDirection:
//                                                           Axis.horizontal,
//                                                       child: Row(
//                                                         children: List.generate(
//                                                           leaveControllerForm
//                                                               .imagePaths
//                                                               .length,
//                                                           (index) {
//                                                             final filePath =
//                                                                 leaveControllerForm
//                                                                         .imagePaths[
//                                                                     index];
//                                                             final isImage = filePath
//                                                                     .endsWith(
//                                                                         '.jpg') ||
//                                                                 filePath
//                                                                     .endsWith(
//                                                                         '.png');
//
//                                                             return Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(8.0),
//                                                               child:
//                                                                   GestureDetector(
//                                                                 onTap: () {
//                                                                   if (isImage) {
//                                                                     // Show larger image in dialog
//                                                                     showDialog(
//                                                                       context:
//                                                                           context,
//                                                                       builder:
//                                                                           (context) {
//                                                                         return Dialog(
//                                                                           backgroundColor:
//                                                                               Colors.transparent,
//                                                                           child:
//                                                                               Stack(
//                                                                             children: [
//                                                                               Center(
//                                                                                 child: Image.file(
//                                                                                   File(filePath),
//                                                                                   fit: BoxFit.contain,
//                                                                                 ),
//                                                                               ),
//                                                                               Positioned(
//                                                                                 top: 10,
//                                                                                 right: 10,
//                                                                                 child: IconButton(
//                                                                                   icon: const Icon(Icons.close, color: Colors.white, size: 30),
//                                                                                   onPressed: () => Navigator.of(context).pop(),
//                                                                                 ),
//                                                                               ),
//                                                                             ],
//                                                                           ),
//                                                                         );
//                                                                       },
//                                                                     );
//                                                                   } else {
//                                                                     // Show PDF using pdfx package
//                                                                     showDialog(
//                                                                       context:
//                                                                           context,
//                                                                       builder:
//                                                                           (context) {
//                                                                         return Dialog(
//                                                                           backgroundColor:
//                                                                               Colors.white,
//                                                                           child:
//                                                                               Column(
//                                                                             children: [
//                                                                               Expanded(
//                                                                                 child: PdfView(
//                                                                                   controller: PdfController(
//                                                                                     document: PdfDocument.openFile(filePath),
//                                                                                   ),
//                                                                                 ),
//                                                                               ),
//                                                                               TextButton(
//                                                                                 onPressed: () => Navigator.of(context).pop(),
//                                                                                 child: const Text("Close"),
//                                                                               ),
//                                                                             ],
//                                                                           ),
//                                                                         );
//                                                                       },
//                                                                     );
//                                                                   }
//                                                                 },
//                                                                 child: Stack(
//                                                                   alignment:
//                                                                       Alignment
//                                                                           .topRight,
//                                                                   children: [
//                                                                     isImage
//                                                                         ? Image
//                                                                             .file(
//                                                                             File(filePath),
//                                                                             width:
//                                                                                 100,
//                                                                             height:
//                                                                                 100,
//                                                                             fit:
//                                                                                 BoxFit.cover,
//                                                                           )
//                                                                         : Container(
//                                                                             width:
//                                                                                 100,
//                                                                             height:
//                                                                                 100,
//                                                                             color:
//                                                                                 Colors.grey,
//                                                                             child: const Icon(Icons.picture_as_pdf,
//                                                                                 size: 40,
//                                                                                 color: Colors.white),
//                                                                           ),
//                                                                     Positioned(
//                                                                       top: 0,
//                                                                       right: 0,
//                                                                       child:
//                                                                           IconButton(
//                                                                         icon: const Icon(
//                                                                             Icons
//                                                                                 .delete,
//                                                                             color:
//                                                                                 Colors.red),
//                                                                         onPressed:
//                                                                             () {
//                                                                           // Delete file and update UI
//                                                                           setState(
//                                                                               () {
//                                                                             leaveControllerForm.imagePaths.removeAt(index);
//                                                                           });
//                                                                           Navigator.pop(
//                                                                               context); // Close the popup
//                                                                         },
//                                                                       ),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ),
//                                                             );
//                                                           },
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   );
//                                                 },
//                                               );
//                                             },
//                                             child: Text(
//                                               'Files Uploaded: ${leaveControllerForm.imagePaths.length}',
//                                               style: const TextStyle(
//                                                   color:
//                                                       AppColors.onBackground),
//                                             ),
//                                           ),
//
//                                         ErrorText(
//                                           isVisible: leaveControllerForm
//                                               .validateUploadPhoto,
//                                           message:
//                                               'Medical Image or PDF Required',
//                                         ),
//
// // Spacer
//                                         CustomSizedBox(
//                                           value: 20,
//                                           side: 'height',
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ]),
//                           CustomSizedBox(
//                             value: 20,
//                             side: 'height',
//                           ),
//                           LabelText(
//                             label: 'Message',
//                             astrick: true,
//                           ),
//                           CustomSizedBox(
//                             value: 20,
//                             side: 'height',
//                           ),
//                           CustomTextFormField(
//                             textController:
//                                 leaveControllerForm.messageController,
//                             labelText: 'Write your comments..',
//                             maxlines: 2,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please fill this field';
//                               }
//
//                               return null;
//                             },
//                           ),
//                           CustomSizedBox(
//                             value: 20,
//                             side: 'height',
//                           ),
//                           CustomButton(
//                             title: 'Submit',
//                             onPressedButton: () async {
//                               setState(() {
//                                 leaveControllerForm.validateStartDate();
//                                 leaveControllerForm.validateEndDate();
//
//                                 // Only require upload photo if leave type is 'SL' and number of leaves is more than 3
//                                 if (leaveControllerForm.selectedLeaveType == 'SL' &&
//                                     (int.tryParse(leaveControllerForm.numberOfLeaveController.text) ?? 0) > 3) {
//                                   leaveControllerForm.validateUploadPhoto = leaveControllerForm.multipleImage.isEmpty;
//                                 } else {
//                                   leaveControllerForm.validateUploadPhoto = false;
//                                 }
//                               });
//
//                               if (_formKey.currentState!.validate() &&
//                                   !leaveControllerForm.validateUploadPhoto) {
//                                 print(
//                                     "Form is valid! Proceeding with submission...");
//                                 print('UserId init: ${widget.userid}');
//
//                                 List<File> registerImageFiles =
//                                     leaveControllerForm.imagePaths
//                                         .map((imagePath) => File(imagePath))
//                                         .toList();
//
//                                 String registerImageFilePaths =
//                                     registerImageFiles
//                                         .map((file) => file.path)
//                                         .join(',');
//
//                                 LeaveRequestModal leaveRequestModal =
//                                     LeaveRequestModal(
//                                   empId: widget.userid.toString(),
//                                   type: leaveControllerForm.selectedLeaveType ??
//                                       'N/A',
//                                   numberOfLeaves: leaveControllerForm
//                                           .numberOfLeaveController
//                                           .text
//                                           .isNotEmpty
//                                       ? leaveControllerForm
//                                           .numberOfLeaveController.text
//                                       : 'N/A',
//                                   startDate: leaveControllerForm.startDate !=
//                                           null
//                                       ? "${leaveControllerForm.startDate!.year.toString().padLeft(4, '0')}-${leaveControllerForm.startDate!.month.toString().padLeft(2, '0')}-${leaveControllerForm.startDate!.day.toString().padLeft(2, '0')}"
//                                       : null,
//                                   endDate: leaveControllerForm.endDate != null
//                                       ? "${leaveControllerForm.endDate!.year.toString().padLeft(4, '0')}-${leaveControllerForm.endDate!.month.toString().padLeft(2, '0')}-${leaveControllerForm.endDate!.day.toString().padLeft(2, '0')}"
//                                       : null,
//                                   reason: leaveControllerForm
//                                       .messageController.text,
//                                   compoff:
//                                       leaveControllerForm.selectedLieuDate ??
//                                           '',
//                                   document: registerImageFilePaths ?? '',
//                                   leaveRequest: 'true',
//                                 );
//                                 print(
//                                     "Leave Request Modal: ${leaveRequestModal.toJson()}");
//
//                                 await submitLeaveRequest(leaveRequestModal);
//
//                                 // Show success message after successful submission
//                                 customSnackbar(
//                                     'Data Submitted Successfully',
//                                     'Submitted',
//                                     AppColors.primary,
//                                     AppColors.onPrimary,
//                                     Icons.verified);
//                                 leaveControllerForm.clearFields();
//                               } else {
//                                 customSnackbar(
//                                     'Fill all Fields',
//                                     'Failed',
//                                     AppColors.primary,
//                                     AppColors.onPrimary,
//                                     Icons.verified);
//                               }
//                             },
//                           )
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Method to show the confirmation dialog
// void showConfirmationDialog(String description) {
//   Get.dialog(
//     Confirmation(
//       title: 'Not Valid!',
//       desc: description,
//       onPressed: () {
//         // Handle what happens on 'Yes'
//         print('Confirmed!');
//         // You can also add any additional logic you need here
//       },
//       yes: 'OK',
//       iconname: Icons.warning, // You can choose any icon you like
//     ),
//   );
// }
