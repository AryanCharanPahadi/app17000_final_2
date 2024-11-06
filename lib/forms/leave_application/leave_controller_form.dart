// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:image/image.dart' as img;
// import '../../base_client/baseClient_controller.dart';
// import '../../constants/color_const.dart';
// import 'leave_modal.dart';
// import 'leave_service.dart';
//
// class LeaveControllerForm extends GetxController with BaseController {
//   final LeaveService _leaveService = LeaveService();
//
//
//   // CL SL El Section
//   // Observables for leave types
//   var cl = 0.obs;
//   var sl = 0.obs;
//   var el = 0.0.obs;
//
//   // Method to fetch leave data based on empId
//   Future<void> fetchLeaveData(String empId) async {
//     try {
//       final leaveData = await _leaveService.fetchRemainingLeaves(empId);
//       cl.value = leaveData['CL'];
//       sl.value = leaveData['SL'];
//       el.value = leaveData['EL'];
//     } catch (e) {
//       print("Error fetching leave data: $e");
//     }
//   }
//   // CL SL El Section
//
//
//   //Controller Section
//   final TextEditingController leaveTypeController = TextEditingController();
//   final TextEditingController startDateController = TextEditingController();
//   final TextEditingController endDateController = TextEditingController();
//   final TextEditingController numberOfLeaveController = TextEditingController();
//   final TextEditingController medicalPhotoController = TextEditingController();
//   final TextEditingController messageController = TextEditingController();
//   final TextEditingController lieuDateController = TextEditingController();
//   //Controller Section
//
//
//   //Date Section
//   DateTime? startDate;
//   DateTime? endDate;
//
//
// // Example of setting the dates
//   void setDates(DateTime selectedStartDate, DateTime selectedEndDate) {
//     startDate = DateTime(selectedStartDate.year, selectedStartDate.month, selectedStartDate.day);
//     endDate = DateTime(selectedEndDate.year, selectedEndDate.month, selectedEndDate.day);
//   }
//
//   String? startDateFieldError; // Add this line for managing error messages
//   String? endDateFieldError; // Add this line for managing error messages
//
//   void validateStartDate() {
//     if (startDate == null) {
//       startDateFieldError =
//       'Please select a start date.'; // Set an error message if no date is selected
//     } else {
//       startDateFieldError = null; // Clear the error if the date is valid
//     }
//   }
//
//   validateEndDate() {
//     if (endDate == null) {
//       endDateFieldError = 'Please select a End date.'; // Example error message
//     } else {
//       endDateFieldError = null; // Clear the error if the date is valid
//     }
//   }
//   //Date Section
//
//
//   // update in the number of Leaves
//   updateTotalDays() {
//     if (startDate != null && endDate != null) {
//       // Calculate total days
//       final totalDays = endDate!.difference(startDate!).inDays +
//           1; // Include both start and end dates
//       numberOfLeaveController.text =
//           totalDays.toString(); // Update the controller
//     } else {
//       numberOfLeaveController.clear(); // Clear if dates are not selected
//     }
//   }
//   // update in the number of Leaves
//
//
// // dropdown Section
//   String? selectedLeaveType;
//   String? selectedLieuDate;
//   // dropdown Section
//
//
//   // Image Section
//   final List<XFile> _multipleImage = [];
//   List<XFile> get multipleImage => _multipleImage;
//   List<String> _imagePaths = [];
//   List<String> get imagePaths => _imagePaths;
//
//   bool validateUploadPhoto = false;
//   bool isImageUploadedNumberOfLeaves = false;
//
//   Future<String> takePhoto(ImageSource source) async {
//     final ImagePicker picker = ImagePicker();
//     List<XFile> selectedImages = [];
//     XFile? pickedImage;
//
//     if (source == ImageSource.gallery) {
//       selectedImages = await picker.pickMultiImage();
//       for (var selectedImage in selectedImages) {
//         // Compress each selected image
//         String compressedPath = await compressImage(selectedImage.path);
//         _multipleImage.add(XFile(compressedPath));
//         _imagePaths.add(compressedPath);
//       }
//       update();
//     } else if (source == ImageSource.camera) {
//       pickedImage = await picker.pickImage(source: source);
//       if (pickedImage != null) {
//         // Compress the picked image
//         String compressedPath = await compressImage(pickedImage.path);
//         _multipleImage.add(XFile(compressedPath));
//         _imagePaths.add(compressedPath);
//       }
//       update();
//     }
//
//     return _imagePaths.toString();
//   }
//
//   Future<String> pickPdf() async {
//     // Use file_picker to select a PDF file
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//     );
//
//     if (result != null && result.files.isNotEmpty) {
//       // Add the selected PDF file path to your list
//       String pdfPath = result.files.single.path!;
//       _imagePaths.add(pdfPath);
//       update();
//       return pdfPath;
//     }
//     return '';
//   }
//
//   Future<String> compressImage(String imagePath) async {
//     // Load the image
//     final File imageFile = File(imagePath);
//     final img.Image? originalImage =
//     img.decodeImage(imageFile.readAsBytesSync());
//
//     if (originalImage == null)
//       return imagePath; // Return original path if decoding fails
//
//     // Resize the image (optional) and compress
//     final img.Image resizedImage =
//     img.copyResize(originalImage, width: 768); // Change the width as needed
//     final List<int> compressedImage =
//     img.encodeJpg(resizedImage, quality: 20); // Adjust quality (0-100)
//
//     // Save the compressed image to a new file
//     final Directory appDir = await getTemporaryDirectory();
//     final String compressedImagePath =
//         '${appDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final File compressedFile = File(compressedImagePath);
//     await compressedFile.writeAsBytes(compressedImage);
//
//     return compressedImagePath; // Return the path of the compressed image
//   }
//
//   Widget bottomSheet(BuildContext context) {
//     String? imagePicked;
//     PickedFile? imageFile;
//     final ImagePicker picker = ImagePicker();
//     XFile? image;
//     return Container(
//       color: AppColors.primary,
//       height: 100,
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(
//         horizontal: 20,
//         vertical: 20,
//       ),
//       child: Column(
//         children: <Widget>[
//           const Text(
//             "Select Image or PDF",
//             style: TextStyle(fontSize: 20.0, color: Colors.white),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
//                 onPressed: () async {
//                   imagePicked = await takePhoto(ImageSource.camera);
//                   Get.back();
//                 },
//                 child: const Text(
//                   'Camera',
//                   style: TextStyle(fontSize: 20.0, color: AppColors.primary),
//                 ),
//               ),
//               const SizedBox(
//                 width: 30,
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
//                 onPressed: () async {
//                   imagePicked = await takePhoto(ImageSource.gallery);
//                   Get.back();
//                 },
//                 child: const Text(
//                   'Gallery',
//                   style: TextStyle(fontSize: 20.0, color: AppColors.primary),
//                 ),
//               ),
//               const SizedBox(
//                 width: 30,
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
//                 onPressed: () async {
//                   String pdfPath = await pickPdf();
//                   if (pdfPath.isNotEmpty) {
//                     // Handle the PDF upload if needed
//                   }
//                   Get.back();
//                 },
//                 child: const Text(
//                   'PDF',
//                   style: TextStyle(fontSize: 20.0, color: AppColors.primary),
//                 ),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
//
//   //Image Section
//
//   void clearFields() {
//   selectedLeaveType = null;
//   numberOfLeaveController.clear();
//   startDate = null;
//   endDate = null;
//   messageController.clear();
//   selectedLieuDate = null;
//   multipleImage.clear();
//   imagePaths.clear();
//   validateUploadPhoto = false;
//   update(); // If using GetX, call this to refresh the UI
//   }
//   }
//
//
