import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http; // Import the http package

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:app17000ft_new/constants/color_const.dart';

import 'package:app17000ft_new/helper/database_helper.dart';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../base_client/baseClient_controller.dart';

import 'package:app17000ft_new/forms/issue_tracker/issue_tracker_modal.dart';
import 'package:app17000ft_new/forms/issue_tracker/lib_issue_modal.dart';

import 'package:app17000ft_new/forms/issue_tracker/playground_issue.dart';

import 'package:flutter/cupertino.dart';

import '../../home/home_controller.dart';
import 'alexa_issue.dart';
import 'digilab_issue.dart';
import 'furniture_issue.dart';

class IssueTrackerController extends GetxController with BaseController {
  var counterText = ''.obs;

  String? _tourValue;
  String? get tourValue => _tourValue;

  String? _schoolValue;
  String? get schoolValue => _schoolValue;
  String? _office;

  String? get office => _office; // Getter for office
  set office(String? value) => _office = value; // Setter for office
  bool isLoading = false;

  final TextEditingController correctUdiseCodeController =
      TextEditingController();
  final TextEditingController libraryDescriptionController =
      TextEditingController();
  final TextEditingController playgroundDescriptionController =
      TextEditingController();
  final TextEditingController digiLabDescriptionController =
      TextEditingController();
  final TextEditingController classroomDescriptionController =
      TextEditingController();
  final TextEditingController alexaDescriptionController =
      TextEditingController();
  final TextEditingController otherSolarDescriptionController =
      TextEditingController();
  final TextEditingController tabletNumberController = TextEditingController();
  final TextEditingController dotDeviceMissingController =
      TextEditingController();
  final TextEditingController dotDeviceNotConfiguredController =
      TextEditingController();
  final TextEditingController dotDeviceNotConnectingController =
      TextEditingController();
  final TextEditingController dotDeviceNotChargingController =
      TextEditingController();
  final TextEditingController dotOtherIssueController = TextEditingController();
  final TextEditingController tabletNumber3Controller = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController dateController2 = TextEditingController();
  final TextEditingController dateController3 = TextEditingController();
  final TextEditingController dateController4 = TextEditingController();
  final TextEditingController dateController5 = TextEditingController();
  final TextEditingController dateController6 = TextEditingController();
  final TextEditingController dateController7 = TextEditingController();
  final TextEditingController dateController8 = TextEditingController();
  final TextEditingController dateController9 = TextEditingController();
  final TextEditingController dateController10 = TextEditingController();

  bool validateRegister = false;
  bool isImageUploaded = false;

  bool validateRegister2 = false;
  bool isImageUploaded2 = false;

  bool validateRegister3 = false;
  bool isImageUploaded3 = false;

  bool validateRegister4 = false;
  bool isImageUploaded4 = false;

  bool validateRegister5 = false;
  bool isImageUploaded5 = false;

  bool dateFieldError = false; // For the date
  bool dateFieldError2 = false; // For the date
  bool dateFieldError3 = false; // For the date
  bool dateFieldError4 = false; // For the date
  bool dateFieldError5 = false; // For the date
  bool dateFieldError6 = false; // For the date
  bool dateFieldError7 = false; // For the date
  bool dateFieldError8 = false; // For the date
  bool dateFieldError9 = false; // For the date
  bool dateFieldError10 = false; // For the date

  String? selectedValue = ''; // For the UDISE code
  String? selectedValue2 = ''; // For the issue of library
  String? selectedValue3 = ''; // For the which part of library issue
  String? selectedValue4 = ''; // For the issue reported by
  String? selectedValue5 = ''; // For the library issue status
  String? selectedValue6 = ''; // For the issue of playground
  String? selectedValue7 = ''; // For the  which part of playground issue
  String? selectedValue8 = ''; // For the  issue reported by playground
  String? selectedValue9 = ''; // For the  playground issue status
  String? selectedValue10 = ''; // For the issue of DigiLab
  String? selectedValue11 = ''; // For the issue reported by digiLab
  String? selectedValue12 = ''; // For the digiLab issue status
  String? selectedValue13 = ''; // For the part of digilab issue
  String? selectedValue14 = ''; // For the issue of Classroom
  String? selectedValue15 = ''; // For the part of classroom issue
  String? selectedValue16 = ''; // For the issue reported by Clssssroom
  String? selectedValue17 = ''; // For the Classroom issue status
  String? selectedValue18 = ''; // For the issue of alexa
  String? selectedValue19 = ''; // For the part of alexa issue
  String? selectedValue20 = ''; // For the issue reported by alexa
  String? selectedValue21 = ''; // For the alexa issue status
  String? selectedValue22 = ''; // For the alexa issue status
  String? selectedValue26 = ''; // For the alexa issue status

  // End of selecting Field error

  // Start of radio Field
  bool radioFieldError = false; // For the UDISE code
  bool radioFieldError2 = false; // For the issue of library
  bool radioFieldError3 = false; // For the which part of library issue
  bool radioFieldError4 = false; // For the  issue reported by
  bool radioFieldError5 = false; // For the  library issue status
  bool radioFieldError6 = false; // For the  issue of playground
  bool radioFieldError7 = false; // For the  which part of playground issue
  bool radioFieldError8 = false; // For the  issue reported by playground
  bool radioFieldError9 = false; // For the  playground issue status
  bool radioFieldError10 = false; // For the issue of DigiLab
  bool radioFieldError11 = false; // For the issue reported by digiLab
  bool radioFieldError12 = false; // For the digiLab issue status
  bool radioFieldError13 = false; // For the part of digilab issue
  bool radioFieldError14 = false; // For the issue of Classroom
  bool radioFieldError15 = false; // For the part of classroom issue
  bool radioFieldError16 = false; // For the issue reported by Clssssroom
  bool radioFieldError17 = false; // For the Classroom issue status
  bool radioFieldError18 = false; // For the issue of alexa
  bool radioFieldError19 = false; // For the part of alexa issue
  bool radioFieldError20 = false; // For the issue reported by alexa
  bool radioFieldError21 = false; // For the alexa issue status
  bool radioFieldError22 = false; // For the alexa issue status
  bool radioFieldError23 = false; // For the alexa issue status
  bool radioFieldError24 = false; // For the alexa issue status
  bool radioFieldError26 = false; // For the alexa issue status

  // End of radio Field error

  // Start of Showing Fields
  bool showBasicDetails = true; // For show Basic Details
  bool showLibrary = false; // For show Library
  bool showPlayground = false; // For show Playground
  bool showDigiLab = false; // For show Playground
  bool showClassroom = false; // For show classroom
  bool showAlexa = false; // For show alexa

  // End of Showing Fields

  final FocusNode _tourIdFocusNode = FocusNode();
  FocusNode get tourIdFocusNode => _tourIdFocusNode;

  final FocusNode _schoolFocusNode = FocusNode();
  FocusNode get schoolFocusNode => _schoolFocusNode;

  List<IssueTrackerRecords> _issueTrackerList = [];
  List<IssueTrackerRecords> get issueTrackerList => _issueTrackerList;

  // Lib issue list
  List<LibIssue> _libIssueList = [];
  List<LibIssue> get libIssueList => _libIssueList;

  // Play issue list
  List<PlaygroundIssue> _playgroundIssueList = [];
  List<PlaygroundIssue> get playgroundIssueList => _playgroundIssueList;

  //digilab issue list
  List<DigiLabIssue> _digiLabIssueList = [];
  List<DigiLabIssue> get digiLabIssueList => _digiLabIssueList;

  //furniture issue list
  List<FurnitureIssue> _furnitureIssueList = [];
  List<FurnitureIssue> get furnitureIssueList => _furnitureIssueList;

  //alexa issue list
  List<AlexaIssue> _alexaIssueList = [];
  List<AlexaIssue> get alexaIssueList => _alexaIssueList;

  List<String> _staffNames = [];
  List<String> get staffNames => _staffNames;

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
        img.encodeJpg(resizedImage, quality: 40); // Adjust quality (0-100)

    // Save the compressed image to a new file
    final Directory appDir = await getTemporaryDirectory();
    final String compressedImagePath =
        '${appDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File compressedFile = File(compressedImagePath);
    await compressedFile.writeAsBytes(compressedImage);

    return compressedImagePath; // Return the path of the compressed image
  }

  Future<String> takePhoto(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    List<XFile> selectedImages = [];
    XFile? pickedImage;

    if (source == ImageSource.gallery) {
      selectedImages = await picker.pickMultiImage();
      for (var selectedImage in selectedImages) {
        // Compress each selected image
        String compressedPath = await compressImage(selectedImage.path);
        _multipleImage.add(XFile(compressedPath));
        _imagePaths.add(compressedPath);
      }
      update();
    } else if (source == ImageSource.camera) {
      pickedImage = await picker.pickImage(source: source);
      if (pickedImage != null) {
        // Compress the picked image
        String compressedPath = await compressImage(pickedImage.path);
        _multipleImage.add(XFile(compressedPath));
        _imagePaths.add(compressedPath);
      }
      update();
    }

    return _imagePaths.toString();
  }

  Future<String> takePhoto2(ImageSource source) async {
    final ImagePicker picker2 = ImagePicker();
    List<XFile> selectedImages2 = [];
    XFile? pickedImage;

    if (source == ImageSource.gallery) {
      selectedImages2 = await picker2.pickMultiImage();
      for (var selectedImage2 in selectedImages2) {
        // Compress each selected image
        String compressedPath = await compressImage(selectedImage2.path);
        _multipleImage2.add(XFile(compressedPath));
        _imagePaths2.add(compressedPath);
      }
      update();
    } else if (source == ImageSource.camera) {
      pickedImage = await picker2.pickImage(source: source);
      if (pickedImage != null) {
        // Compress the picked image
        String compressedPath = await compressImage(pickedImage.path);
        _multipleImage2.add(XFile(compressedPath));
        _imagePaths2.add(compressedPath);
      }
      update();
    }

    return _imagePaths2.toString();
  }

  Future<String> takePhoto3(ImageSource source) async {
    final ImagePicker picker3 = ImagePicker();
    List<XFile> selectedImages3 = [];
    XFile? pickedImage;

    if (source == ImageSource.gallery) {
      selectedImages3 = await picker3.pickMultiImage();
      for (var selectedImage3 in selectedImages3) {
        // Compress each selected image
        String compressedPath = await compressImage(selectedImage3.path);
        _multipleImage3.add(XFile(compressedPath));
        _imagePaths3.add(compressedPath);
      }
      update();
    } else if (source == ImageSource.camera) {
      pickedImage = await picker3.pickImage(source: source);
      if (pickedImage != null) {
        // Compress the picked image
        String compressedPath = await compressImage(pickedImage.path);
        _multipleImage3.add(XFile(compressedPath));
        _imagePaths3.add(compressedPath);
      }
      update();
    }

    return _imagePaths3.toString();
  }

  Future<String> takePhoto4(ImageSource source) async {
    final ImagePicker picker4 = ImagePicker();
    List<XFile> selectedImages4 = [];
    XFile? pickedImage;

    if (source == ImageSource.gallery) {
      selectedImages4 = await picker4.pickMultiImage();
      for (var selectedImage4 in selectedImages4) {
        // Compress each selected image
        String compressedPath = await compressImage(selectedImage4.path);
        _multipleImage4.add(XFile(compressedPath));
        _imagePaths4.add(compressedPath);
      }
      update();
    } else if (source == ImageSource.camera) {
      pickedImage = await picker4.pickImage(source: source);
      if (pickedImage != null) {
        // Compress the picked image
        String compressedPath = await compressImage(pickedImage.path);
        _multipleImage4.add(XFile(compressedPath));
        _imagePaths4.add(compressedPath);
      }
      update();
    }

    return _imagePaths4.toString();
  }

  Future<String> takePhoto5(ImageSource source) async {
    final ImagePicker picker5 = ImagePicker();
    List<XFile> selectedImages5 = [];
    XFile? pickedImage;

    if (source == ImageSource.gallery) {
      selectedImages5 = await picker5.pickMultiImage();
      for (var selectedImage5 in selectedImages5) {
        // Compress each selected image
        String compressedPath = await compressImage(selectedImage5.path);
        _multipleImage5.add(XFile(compressedPath));
        _imagePaths5.add(compressedPath);
      }
      update();
    } else if (source == ImageSource.camera) {
      pickedImage = await picker5.pickImage(source: source);
      if (pickedImage != null) {
        // Compress the picked image
        String compressedPath = await compressImage(pickedImage.path);
        _multipleImage5.add(XFile(compressedPath));
        _imagePaths5.add(compressedPath);
      }
      update();
    }

    return _imagePaths5.toString();
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
          const Text("Select Image",
              style: TextStyle(fontSize: 20.0, color: Colors.white)),
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
                child: const Text('Camera',
                    style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto(ImageSource.gallery);
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

  Widget bottomSheet2(BuildContext context) {
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
                  await takePhoto2(ImageSource.camera);
                  Get.back();
                },
                child: const Text('Camera',
                    style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto2(ImageSource.gallery);
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

  Widget bottomSheet3(BuildContext context) {
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
                  await takePhoto3(ImageSource.camera);
                  Get.back();
                },
                child: const Text('Camera',
                    style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto3(ImageSource.gallery);
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

  Widget bottomSheet4(BuildContext context) {
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
                  await takePhoto4(ImageSource.camera);
                  Get.back();
                },
                child: const Text('Camera',
                    style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto4(ImageSource.gallery);
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

  Widget bottomSheet5(BuildContext context) {
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
                  await takePhoto5(ImageSource.camera);
                  Get.back();
                },
                child: const Text('Camera',
                    style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto5(ImageSource.gallery);
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

  void showImagePreview2(String imagePath2, BuildContext context) {
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
              child: Image.file(File(imagePath2), fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  void showImagePreview3(String imagePath3, BuildContext context) {
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
              child: Image.file(File(imagePath3), fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  void showImagePreview4(String imagePath4, BuildContext context) {
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
              child: Image.file(File(imagePath4), fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  void showImagePreview5(String imagePath5, BuildContext context) {
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
              child: Image.file(File(imagePath5), fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  bool _isLoading1 = true;
  bool get isLoading1 => _isLoading1; // Expose the loading state

  List<String> _filteredStaffNames = []; // for alexa
  List<String> get filteredStaffNames => _filteredStaffNames;

  List<String> _filteredStaffNames2 = []; // for classroom
  List<String> get filteredStaffNames2 => _filteredStaffNames2;

  List<String> _filteredStaffNames3 = []; // for library
  List<String> get filteredStaffNames3 => _filteredStaffNames3;

  List<String> _filteredStaffNames4 = []; // for playground
  List<String> get filteredStaffNames4 => _filteredStaffNames4;

  List<String> _filteredStaffNames5 = []; // for digiLab
  List<String> get filteredStaffNames5 => _filteredStaffNames5;

  @override
  void onInit() {
    super.onInit();
    _initializeStaffNames(); // Call the initialization method here
  }

  Future<void> _initializeStaffNames() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool isOffline = (connectivityResult == ConnectivityResult.none);

    if (isOffline) {
      await _loadStaffNamesOffline(1);
      await _loadStaffNamesOffline(2);
      await _loadStaffNamesOffline(3);
      await _loadStaffNamesOffline(4);
      await _loadStaffNamesOffline(5);
    } else {
      await _fetchFilteredStaffNames(1);
      await _fetchFilteredStaffNames(2);
      await _fetchFilteredStaffNames(3);
      await _fetchFilteredStaffNames(4);
      await _fetchFilteredStaffNames(5);
    }
  }

  final HomeController controller = Get.put(HomeController());

  Future<void> _fetchFilteredStaffNames(int category) async {
    const String url = 'https://mis.17000ft.org/17000ft_apis/allStaff.php';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        String? office = controller.office; // Assuming `controller` is defined
        List<String> filteredStaff = data.where((item) {
          String location = item['location'] ?? '';
          return location == office;
        }).map<String>((item) {
          String firstName = item['first_name'] ?? '';
          String lastName = item['last_name'] ?? '';
          return '$firstName $lastName';
        }).toList();

        final dbController = SqfliteDatabaseHelper();
        for (var staff in filteredStaff) {
          await dbController.insertStaffName(category, staff);
        }

        switch (category) {
          case 1:
            _filteredStaffNames = filteredStaff;
            break;
          case 2:
            _filteredStaffNames2 = filteredStaff;

            break;
          case 3:
            _filteredStaffNames3 = filteredStaff;
            break;
          case 4:
            _filteredStaffNames4 = filteredStaff;
            break;
          case 5:
            _filteredStaffNames5 = filteredStaff;
            break;
        }
        _isLoading1 = false;
        update(); // Notify listeners
      } else {
        _isLoading1 = false;
        update(); // Notify listeners
      }
    } catch (e) {
      _isLoading1 = false;
      update(); // Notify listeners
    }
  }

  Future<void> _loadStaffNamesOffline(int category) async {
    try {
      final dbController = SqfliteDatabaseHelper();
      List<String> staffNames =
          await dbController.getStaffNamesByCategory(category);

      switch (category) {
        case 1:
          _filteredStaffNames = staffNames;
          break;
        case 2:
          _filteredStaffNames2 = staffNames;
          break;
        case 3:
          _filteredStaffNames3 = staffNames;
          break;
        case 4:
          _filteredStaffNames4 = staffNames;
          break;
        case 5:
          _filteredStaffNames5 = staffNames;
          break;
      }
      _isLoading1 = false;
      update(); // Notify listeners
    } catch (e) {
      print('Error loading staff names from SQLite: $e');
      _isLoading1 = false;
      update(); // Notify listeners
    }
  }

  void clearFields() {
    selectedValue = '';
    selectedValue2 = '';
    selectedValue6 = '';
    selectedValue10 = '';
    selectedValue14 = '';
    selectedValue18 = '';
    _tourValue = null;
    _schoolValue = null;
    correctUdiseCodeController.clear();
    libraryDescriptionController.clear();
    playgroundDescriptionController.clear();
    digiLabDescriptionController.clear();
    classroomDescriptionController.clear();
    alexaDescriptionController.clear();
    dateController.clear();
    dateController2.clear();
    _multipleImage.clear();
    _imagePaths.clear();
    _multipleImage2.clear();
    _imagePaths2.clear();
    _multipleImage3.clear();
    _imagePaths3.clear();
    _multipleImage4.clear();
    _imagePaths4.clear();
    _multipleImage5.clear();
    _imagePaths5.clear();
    update();
  }

  Future<void> fetchData() async {
    isLoading = true;

    _issueTrackerList =
        await LocalDbController().fetchLocalIssueTrackerRecords();
    _libIssueList = await LocalDbController().fetchLocalLibIssueRecords();
    _furnitureIssueList = await LocalDbController().fetchLocalFurnitureIssue();
    _playgroundIssueList =
        await LocalDbController().fetchLocalPlaygroundIssue();
    _digiLabIssueList = await LocalDbController().fetchLocalDigiLabIssue();
    _alexaIssueList = await LocalDbController().fetchLocalAlexaIssue();

    update();
  }
}
