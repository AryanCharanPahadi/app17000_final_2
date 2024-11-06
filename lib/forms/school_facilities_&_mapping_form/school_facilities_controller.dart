import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/forms/school_facilities_&_mapping_form/school_facilities_modals.dart';
import 'package:app17000ft_new/helper/database_helper.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../base_client/baseClient_controller.dart';

class SchoolFacilitiesController extends GetxController with BaseController {
  var counterText = ''.obs;
  String? _tourValue;
  String? get tourValue => _tourValue;

  String? _schoolValue;
  String? get schoolValue => _schoolValue;

  bool isLoading = false;
  final TextEditingController noOfEnrolledStudentAsOnDateController = TextEditingController();
  final TextEditingController noOfFunctionalClassroomController = TextEditingController();
  final TextEditingController nameOfLibrarianController = TextEditingController();
  final TextEditingController correctUdiseCodeController = TextEditingController();



  // Map to store selected values for radio buttons
  final Map<String, String?> _selectedValues = {};
  String? getSelectedValue(String key) => _selectedValues[key];

  // Map to store error states for radio buttons
  final Map<String, bool> _radioFieldErrors = {};
  bool getRadioFieldError(String key) => _radioFieldErrors[key] ?? false;

  // Method to set the selected value and clear any previous error
  void setRadioValue(String key, String? value) {
    _selectedValues[key] = value;
    _radioFieldErrors[key] = false; // Clear error when a value is selected
    update(); // Update the UI
  }

  // Method to validate radio button selection
  bool validateRadioSelection(String key) {
    if (_selectedValues[key] == null) {
      _radioFieldErrors[key] = true;
      update(); // Update the UI
      return false;
    }
    _radioFieldErrors[key] = false;
    update(); // Update the UI
    return true;
  }


  // Start of selecting Field
  String? selectedValue = ''; // For the UDISE code
  String? selectedValue2 = ''; // For the Residential School
  String? selectedValue3 = ''; // For the Electricity Available
  String? selectedValue4 = ''; // For the Internet Connectivity
  String? selectedValue5 = ''; // For the Projector
  String? selectedValue6 = ''; // For the Smart Classroom
  String? selectedValue7 = ''; // For the Playground Available
  String? selectedValue8 = ''; // For the Library Available
  String? selectedValue9 = ''; // For the librarian training
  String? selectedValue10 = ''; // For the librarian register
  // End of selecting Field error


  // Start of radio Field
  bool radioFieldError = false; // For the UDISE code
  bool radioFieldError2 = false; // For the Residential School
  bool radioFieldError3 = false; // For the Electricity Available
  bool radioFieldError4 = false; // For the Internet Connectivity
  bool radioFieldError5 = false; // For the Projector
  bool radioFieldError6 = false; // For the Smart Classroom
  bool radioFieldError7 = false; // For the Playground Available
  bool radioFieldError8 = false; // For the Library Available
  bool radioFieldError9 = false; // For the librarian training
  bool radioFieldError10 = false; // For the librarian register
  // End of radio Field error

  // Start of Showing Fields
  bool showBasicDetails = true; // For show Basic Details
  bool showSchoolFacilities = false; //For show and hide School Facilities
  bool showLibrary = false; //For show and hide Library
  // End of Showing Fields

  bool validateRegister = false;
  bool isImageUploaded = false;

  bool validateRegister2 = false;
  bool isImageUploaded2 = false;

  List<String> splitSchoolLists = [];
  String? selectedDesignation;

  final FocusNode _tourIdFocusNode = FocusNode();
  FocusNode get tourIdFocusNode => _tourIdFocusNode;

  final FocusNode _schoolFocusNode = FocusNode();
  FocusNode get schoolFocusNode => _schoolFocusNode;

  List<SchoolFacilitiesRecords> _schoolFacilitiesList = [];
  List<SchoolFacilitiesRecords> get schoolFacilitiesList => _schoolFacilitiesList;


  final List<XFile> _multipleImage = [];
  List<XFile> get multipleImage => _multipleImage;
  List<String> _imagePaths = [];
  List<String> get imagePaths => _imagePaths;


  final List<XFile> _multipleImage2 = [];
  List<XFile> get multipleImage2 => _multipleImage2;
  List<String> _imagePaths2 = [];
  List<String> get imagePaths2 => _imagePaths2;

  Future<String> takePhoto(ImageSource source, int index) async {
    final ImagePicker picker = ImagePicker();
    List<XFile> selectedImages = [];
    XFile? pickedImage;

    // Determine which list to use based on the index parameter
    List<XFile> multipleImages;
    List<String> imagePaths;

    switch (index) {
      case 1:
        multipleImages = _multipleImage;
        imagePaths = _imagePaths;
        break;
      case 2:
        multipleImages = _multipleImage2;
        imagePaths = _imagePaths2;
        break;
      default:
        throw ArgumentError('Invalid index: $index');
    }

    if (source == ImageSource.gallery) {
      selectedImages = await picker.pickMultiImage();
      for (var selectedImage in selectedImages) {
        // Compress each selected image
        String compressedPath = await compressImage(selectedImage.path);
        multipleImages.add(XFile(compressedPath));
        imagePaths.add(compressedPath);
      }
      update();
    } else if (source == ImageSource.camera) {
      pickedImage = await picker.pickImage(source: source);
      if (pickedImage != null) {
        // Compress the picked image
        String compressedPath = await compressImage(pickedImage.path);
        multipleImages.add(XFile(compressedPath));
        imagePaths.add(compressedPath);
      }
      update();
    }

    return imagePaths.toString();
  }

  Future<String> compressImage(String imagePath) async {
    // Load the image
    final File imageFile = File(imagePath);
    final img.Image? originalImage = img.decodeImage(imageFile.readAsBytesSync());

    if (originalImage == null) return imagePath; // Return original path if decoding fails

    // Resize the image (optional) and compress
    final img.Image resizedImage = img.copyResize(originalImage, width: 768); // Change the width as needed
    final List<int> compressedImage = img.encodeJpg(resizedImage, quality: 12); // Adjust quality (0-100)

    // Save the compressed image to a new file
    final Directory appDir = await getTemporaryDirectory();
    final String compressedImagePath = '${appDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File compressedFile = File(compressedImagePath);
    await compressedFile.writeAsBytes(compressedImage);

    return compressedImagePath; // Return the path of the compressed image
  }




  void setSchool(String? value) {
    _schoolValue = value;

  }

  void setTour(String? value) {
    _tourValue = value;

  }


  Widget bottomSheet(BuildContext context, int index) {
    return Container(
      color: AppColors.primary,
      height: 100,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          const Text("Select Image",
              style: TextStyle(fontSize: 20.0, color: Colors.white)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto(ImageSource.camera, index);
                  Get.back();
                },
                child: const Text('Camera',
                    style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto(ImageSource.gallery, index);
                  Get.back();
                },
                child: const Text('Gallery',
                    style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void showImagePreview(String imagePath, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.file(File(imagePath), fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  void clearFields() {
    _tourValue = null;
    _schoolValue = null;
    correctUdiseCodeController.clear();
    noOfFunctionalClassroomController.clear();
    noOfEnrolledStudentAsOnDateController.clear();
    nameOfLibrarianController.clear();
    correctUdiseCodeController.clear();
  }

  Future<void> fetchData() async {
    isLoading = true;
    _schoolFacilitiesList = [];

    _schoolFacilitiesList = await LocalDbController().fetchLocalSchoolFacilitiesRecords();

    update();
  }
}