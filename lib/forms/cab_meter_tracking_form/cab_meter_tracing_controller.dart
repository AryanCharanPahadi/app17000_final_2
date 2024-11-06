import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/helper/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../base_client/baseClient_controller.dart';
import 'cab_meter_tracing_modal.dart';

class CabMeterTracingController extends GetxController with BaseController {
  String? _tourValue;
  String? get tourValue => _tourValue;

  String? _schoolValue;
  String? get schoolValue => _schoolValue;

  bool isLoading = false;

  final TextEditingController remarksController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController meterReadingController = TextEditingController();
  final TextEditingController placeVisitedController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();

  final Map<String, String?> _selectedValues = {};
  String? getSelectedValue(String key) => _selectedValues[key];

  final Map<String, bool> _radioFieldErrors = {};
  bool getRadioFieldError(String key) => _radioFieldErrors[key] ?? false;

  void setRadioValue(String key, String? value) {
    _selectedValues[key] = value;
    _radioFieldErrors[key] = false;
    update();
  }

  bool validateRadioSelection(String key) {
    if (_selectedValues[key] == null) {
      _radioFieldErrors[key] = true;
      update();
      return false;
    }
    _radioFieldErrors[key] = false;
    return true;
  }

  // Focus nodes
  final FocusNode _tourIdFocusNode = FocusNode();
  FocusNode get tourIdFocusNode => _tourIdFocusNode;

  final FocusNode _schoolFocusNode = FocusNode();
  FocusNode get schoolFocusNode => _schoolFocusNode;

  List<CabMeterTracingRecords> _cabMeterTracingList = [];
  List<CabMeterTracingRecords> get cabMeterTracingList => _cabMeterTracingList;

  List<XFile> _multipleImage = [];
  List<XFile> get multipleImage => _multipleImage;

  List<String> _imagePaths = [];
  List<String> get imagePaths => _imagePaths;

  Future<String> takePhoto(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    XFile? pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      // Compress the picked image
      String compressedPath = await compressImage(pickedImage.path);
      _multipleImage.clear(); // Clear previous selections
      _multipleImage.add(XFile(compressedPath));
      _imagePaths.clear(); // Clear previous paths
      _imagePaths.add(compressedPath);
    }

    update();
    return _imagePaths.toString();
  }

  Future<String> compressImage(String imagePath) async {
    final File imageFile = File(imagePath);
    final img.Image? originalImage = img.decodeImage(imageFile.readAsBytesSync());

    if (originalImage == null) return imagePath;

    // Resize the image (optional) and compress
    final img.Image resizedImage = img.copyResize(originalImage, width: 800);
    final List<int> compressedImage = img.encodeJpg(resizedImage, quality: 85);

    // Save the compressed image to a new file
    final Directory appDir = await getTemporaryDirectory();
    final String compressedImagePath = '${appDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File compressedFile = File(compressedImagePath);
    await compressedFile.writeAsBytes(compressedImage);

    return compressedImagePath;
  }

  void setSchool(String? value) {
    _schoolValue = value;
    update();
  }

  void setTour(String? value) {
    _tourValue = value;
    update();
  }

  Widget bottomSheet(BuildContext context) {
    return Container(
      color: AppColors.primary,
      height: 100,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          const Text(
            "Select Image",
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto(ImageSource.camera);
                  Get.back();
                },
                child: const Text(
                  'Camera',
                  style: TextStyle(fontSize: 20.0, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 30),
            ],
          )
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
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  void clearFields() {
    placeVisitedController.clear();
    vehicleNumberController.clear();
    driverNameController.clear();
    meterReadingController.clear();
    remarksController.clear();
    _tourValue = null;
    _multipleImage.clear();
    _imagePaths.clear();
    update();
  }

  Future<void> fetchData() async {
    isLoading = true;
    _cabMeterTracingList = await LocalDbController().fetchLocalCabMeterTracingRecord();
    isLoading = false;
    update(); // Refresh the UI
  }

  void removeRecordFromList(int id) {
    _cabMeterTracingList.removeWhere((record) => record.id == id);
    update(); // Refresh the UI
  }

  @override
  void onClose() {
    remarksController.dispose();
    driverNameController.dispose();
    meterReadingController.dispose();
    placeVisitedController.dispose();
    statusController.dispose();
    vehicleNumberController.dispose();
    _tourIdFocusNode.dispose();
    _schoolFocusNode.dispose();
    super.onClose();
  }
}
