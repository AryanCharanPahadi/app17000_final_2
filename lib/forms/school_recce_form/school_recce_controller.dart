import 'dart:convert';
import 'dart:io';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:app17000ft_new/constants/color_const.dart';

import 'package:app17000ft_new/forms/school_recce_form/school_recce_modal.dart';
import 'package:app17000ft_new/helper/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../base_client/baseClient_controller.dart';

class SchoolRecceController extends GetxController with BaseController {
  String? _tourValue;
  String? get tourValue => _tourValue;

  //school Value
  String? _schoolValue;
  String? get schoolValue => _schoolValue;

  bool isLoading = false;

  List<String> splitSchoolLists = [];

  final TextEditingController remarksController = TextEditingController();
  final TextEditingController correctUdiseCodeController =
      TextEditingController();
  final TextEditingController nameOfHoiController = TextEditingController();
  final TextEditingController hoiPhoneNumberController =
      TextEditingController();
  final TextEditingController hoiEmailController = TextEditingController();
  final TextEditingController totalTeachingStaffController =
      TextEditingController();
  final TextEditingController totalNonTeachingStaffController =
      TextEditingController();
  final TextEditingController totalStaffController = TextEditingController();
  final TextEditingController nameOfSmcController = TextEditingController();
  final TextEditingController smcPhoneNumberController =
      TextEditingController();
  final TextEditingController totalnoOfSmcMemController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController noClassroomsController = TextEditingController();
  final TextEditingController measurnment1Controller = TextEditingController();
  final TextEditingController measurnment2Controller = TextEditingController();
  final TextEditingController specifyOtherController = TextEditingController();
  final TextEditingController supportingNgoController = TextEditingController();
  final TextEditingController keyPointsController = TextEditingController();
  final TextEditingController QualSpecifyController = TextEditingController();
  final TextEditingController freSpecifyController = TextEditingController();

  // Start of show Details
  bool showBasicDetails = true; // For show Basic Details
  bool showStaffDetails = false; // For show showStaffDetails
  bool showSmcVecDetails = false; // For show showStaffDetails
  bool showSchoolInfra = false; // For show showStaffDetails
  bool showSchoolStrngth = false; // For show showStaffDetails

  bool showOtherInfo = false; // For show showStaffDetails
  // End of show Details
  void updateTotalStaff() {
    final totalTeachingStaff =
        int.tryParse(totalTeachingStaffController.text) ?? 0;
    final totalNonTeachingStaff =
        int.tryParse(totalNonTeachingStaffController.text) ?? 0;
    final totalStaff = totalTeachingStaff + totalNonTeachingStaff;

    totalStaffController.text = totalStaff.toString();
  }

  @override
  void dispose() {
    totalTeachingStaffController.dispose();
    totalNonTeachingStaffController.dispose();
    totalStaffController.dispose();
    super.dispose();
  }

  String? selectedYear;
  String? selectedDesignation;
  String? selectedQualification;
  String? selectedMeetings;

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

  bool checkboxValue1 = false;
  bool checkboxValue2 = false;
  bool checkboxValue3 = false;
  bool checkboxValue4 = false;
  bool checkboxValue5 = false;
  bool checkboxValue6 = false;
  bool checkboxValue7 = false;
  bool checkboxValue8 = false;
  bool checkboxValue9 = false;
  bool checkboxValue10 = false;
  bool checkboxValue11 = false;
  bool checkboxValue12 = false;
  bool checkboxValue13 = false;
  bool checkboxValue14 = false;
  bool checkboxValue15 = false;
  bool checkboxValue16 = false;
  bool checkboxValue17 = false;
  bool checkboxValue18 = false;
  bool checkboxValue19 = false;
  bool checkboxValue20 = false;
  bool checkboxValue21 = false;
  bool checkboxValue22 = false;
  bool checkboxValue23 = false;
  bool checkboxValue24 = false;
  bool checkboxValue25 = false;

  bool checkBoxError = false; //for checkbox error
  bool checkBoxError2 = false; //for checkbox error
  bool checkBoxError3 = false; //for checkbox error
  bool checkBoxError4 = false; //for checkbox error

  // For the image
  bool validateSchoolBoard = false; // for the nursery timetable
  final bool isImageUploadedSchoolBoard = false; // for the nursery timetable

  bool validateSchoolBuilding = false; // for the LKG timetable
  final bool isImageUploadedSchoolBuilding = false; // for the LKG timetable

  bool validateTeacherRegister = false; // for the LKG timetable
  final bool isImageUploadedTeacherRegister = false; // for the LKG timetable

  bool validateSmartClass = false; // for the LKG timetable
  final bool isImageUploadedSmartClass = false; // for the LKG timetable

  bool validateProjector = false; // for the LKG timetable
  final bool isImageUploadedProjector = false; // for the LKG timetable

  bool validateComputer = false; // for the LKG timetable
  final bool isImageUploadedComputer = false; // for the LKG timetable

  bool validateExisitingLibrary = false; // for the LKG timetable
  final bool isImageUploadedExisitingLibrary = false; // for the LKG timetable

  bool validateAvailabaleSpace = false; // for the LKG timetable
  final bool isImageUploadedAvailabaleSpace = false; // for the LKG timetable

  bool validateEnrollement = false; // for the LKG timetable
  final bool isImageUploadedEnrollement = false; // for the LKG timetable

  bool validateDlInstallation = false; // for the LKG timetable
  final bool isImageUploadedDlInstallation = false; // for the LKG timetable

  bool validateLibrarySetup = false; // for the LKG timetable
  final bool isImageUploadedLibrarySetup = false; // for the LKG timetable

  //Focus nodes
  final FocusNode _tourIdFocusNode = FocusNode();
  FocusNode get tourIdFocusNode => _tourIdFocusNode;
  final FocusNode _schoolFocusNode = FocusNode();
  FocusNode get schoolFocusNode => _schoolFocusNode;

  List<SchoolRecceModal> _schoolRecceList = [];
  List<SchoolRecceModal> get schoolRecceList => _schoolRecceList;

  final List<XFile> _multipleImage = [];
  List<XFile> get multipleImage => _multipleImage;
  List<String> _imagePaths = [];
  List<String> get imagePaths => _imagePaths;

  final List<XFile> _multipleImage2 = [];
  List<XFile> get multipleImage2 => _multipleImage2;

  List<String> _imagePaths2 = [];
  List<String> get imagePaths2 => _imagePaths2;

  final List<XFile> _multipleImage3 = [];
  List<XFile> get multipleImage3 => _multipleImage3;

  List<String> _imagePaths3 = [];
  List<String> get imagePaths3 => _imagePaths3;

  final List<XFile> _multipleImage4 = [];
  List<XFile> get multipleImage4 => _multipleImage4;

  List<String> _imagePaths4 = [];
  List<String> get imagePaths4 => _imagePaths4;

  final List<XFile> _multipleImage5 = [];
  List<XFile> get multipleImage5 => _multipleImage5;

  List<String> _imagePaths5 = [];
  List<String> get imagePaths5 => _imagePaths5;

  final List<XFile> _multipleImage6 = [];
  List<XFile> get multipleImage6 => _multipleImage6;

  List<String> _imagePaths6 = [];
  List<String> get imagePaths6 => _imagePaths6;

  final List<XFile> _multipleImage7 = [];
  List<XFile> get multipleImage7 => _multipleImage7;

  List<String> _imagePaths7 = [];
  List<String> get imagePaths7 => _imagePaths7;

  final List<XFile> _multipleImage8 = [];
  List<XFile> get multipleImage8 => _multipleImage8;

  List<String> _imagePaths8 = [];
  List<String> get imagePaths8 => _imagePaths8;

  final List<XFile> _multipleImage9 = [];
  List<XFile> get multipleImage9 => _multipleImage9;

  List<String> _imagePaths9 = [];
  List<String> get imagePaths9 => _imagePaths9;

  final List<XFile> _multipleImage10 = [];
  List<XFile> get multipleImage10 => _multipleImage10;

  List<String> _imagePaths10 = [];
  List<String> get imagePaths10 => _imagePaths10;

  final List<XFile> _multipleImage11 = [];
  List<XFile> get multipleImage11 => _multipleImage11;

  List<String> _imagePaths11 = [];
  List<String> get imagePaths11 => _imagePaths11;

  Future<String> compressImage(String imagePath) async {
    // Load the image
    final File imageFile = File(imagePath);
    final img.Image? originalImage =
        img.decodeImage(imageFile.readAsBytesSync());

    if (originalImage == null)
      return imagePath; // Return original path if decoding fails

    // Resize the image (optional) and compress
    final img.Image resizedImage =
        img.copyResize(originalImage, width: 768); // Change the width as needed
    final List<int> compressedImage =
        img.encodeJpg(resizedImage, quality: 12); // Adjust quality (0-100)

    // Save the compressed image to a new file
    final Directory appDir = await getTemporaryDirectory();
    final String compressedImagePath =
        '${appDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File compressedFile = File(compressedImagePath);
    await compressedFile.writeAsBytes(compressedImage);

    return compressedImagePath; // Return the path of the compressed image
  }

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
      case 3:
        multipleImages = _multipleImage3;
        imagePaths = _imagePaths3;
        break;
      case 4:
        multipleImages = _multipleImage4;
        imagePaths = _imagePaths4;
        break;
      case 5:
        multipleImages = _multipleImage5;
        imagePaths = _imagePaths5;
        break;
      case 6:
        multipleImages = _multipleImage6;
        imagePaths = _imagePaths6;
        break;
      case 7:
        multipleImages = _multipleImage7;
        imagePaths = _imagePaths7;
        break;
      case 8:
        multipleImages = _multipleImage8;
        imagePaths = _imagePaths8;
        break;
      case 9:
        multipleImages = _multipleImage9;
        imagePaths = _imagePaths9;
        break;
      case 10:
        multipleImages = _multipleImage10;
        imagePaths = _imagePaths10;
        break;
      case 11:
        multipleImages = _multipleImage11;
        imagePaths = _imagePaths11;
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

  setSchool(value) {
    _schoolValue = value;
    // update();
  }

  setTour(value) {
    _tourValue = value;
    // update();
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

  Widget bottomSheet2(BuildContext context, int index) {
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

  //Clear fields
  void clearFields() {
    correctUdiseCodeController.clear();
    remarksController.clear();
    nameOfHoiController.clear();
    hoiPhoneNumberController.clear();
    hoiEmailController.clear();
    totalTeachingStaffController.clear();
    totalNonTeachingStaffController.clear();
    totalStaffController.clear();
    nameOfSmcController.clear();
    smcPhoneNumberController.clear();
    totalnoOfSmcMemController.clear();
    descriptionController.clear();
    noClassroomsController.clear();
    measurnment1Controller.clear();
    measurnment2Controller.clear();
    specifyOtherController.clear();
    supportingNgoController.clear();
    keyPointsController.clear();
    freSpecifyController.clear();
    QualSpecifyController.clear();

    update();
  }

  fetchData() async {
    isLoading = true;

    _schoolRecceList = [];
    _schoolRecceList = await LocalDbController().fetchLocalSchoolRecceModal();

    update();
  }

  void removeRecordFromList(int id) {
    _schoolRecceList
        .removeWhere((record) => record.id == id); // Remove synced record
    update(); // Refresh the UI
  }

//Update the UI
}
