
import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/forms/alfa_observation_form/alfa_obervation_modal.dart';
import 'package:app17000ft_new/forms/school_enrolment/school_enrolment_model.dart';
import 'package:app17000ft_new/forms/school_enrolment/school_enrolment_sync.dart';
import 'package:app17000ft_new/helper/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../base_client/baseClient_controller.dart';

class AlfaObservationController extends GetxController with BaseController{

  String? _tourValue;
  String? get tourValue => _tourValue;

  //school Value
  String? _schoolValue;
  String? get schoolValue => _schoolValue;

  bool isLoading = false;

  final TextEditingController remarksController = TextEditingController();
  final TextEditingController correctUdiseCodeController = TextEditingController();
  final TextEditingController noOfStaffTrainedController = TextEditingController();
  final TextEditingController moduleEnglishController = TextEditingController();
  final TextEditingController alfaNumercyController = TextEditingController();
  final TextEditingController noOfTeacherTrainedController = TextEditingController();

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


  // Method to clear the selected value for a given key
  void clearRadioValue(String key) {
    _selectedValues[key] = null; // Clear the value
    update(); // Update the UI
  }


  //Focus nodes
  final FocusNode _tourIdFocusNode = FocusNode();
  FocusNode get  tourIdFocusNode => _tourIdFocusNode;
  final FocusNode _schoolFocusNode = FocusNode();
  FocusNode get  schoolFocusNode => _schoolFocusNode;

  List<AlfaObservationModel> _alfaObservationList =[];
  List<AlfaObservationModel> get alfaObservationList => _alfaObservationList;

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



  setSchool(value)
  {
    _schoolValue = value;
    // update();
  }

  setTour(value){
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

    update();
  }

  fetchData() async {
    isLoading = true;

    _alfaObservationList = [];
    _alfaObservationList = await LocalDbController().fetchLocalAlfaObservationModel();

    update();
  }
  void removeRecordFromList(int id) {
    _alfaObservationList.removeWhere((record) => record.id == id); // Remove synced record
    update();  // Refresh the UI
  }
//

//Update the UI


}