import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app17000ft_new/forms/issue_tracker/playground_issue.dart';
import 'package:app17000ft_new/forms/issue_tracker/issue_tracker_modal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app17000ft_new/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:app17000ft_new/components/custom_appBar.dart';
import 'package:app17000ft_new/components/custom_button.dart';
import 'package:app17000ft_new/components/custom_imagepreview.dart';
import 'package:app17000ft_new/components/custom_textField.dart';
import 'package:app17000ft_new/components/error_text.dart';
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/helper/responsive_helper.dart';
import 'package:app17000ft_new/tourDetails/tour_controller.dart';
import 'package:app17000ft_new/components/custom_dropdown.dart';
import 'package:app17000ft_new/components/custom_labeltext.dart';
import 'package:app17000ft_new/components/custom_sizedBox.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import '../../components/custom_confirmation.dart';
import '../../components/custom_drawer.dart';
import '../../components/custom_snackbar.dart';
import '../../helper/database_helper.dart';
import '../../home/home_screen.dart';
import '../select_tour_id/select_controller.dart';
import 'alexa_issue.dart';
import 'digilab_issue.dart';
import 'furniture_issue.dart';
import 'issue_tracker_controller.dart';
import 'lib_issue_modal.dart';

class IssueTrackerForm extends StatefulWidget {
  String? userid;
  String? office;
  IssueTrackerForm({
    super.key,
    required this.userid,
    required this.office,
  });
  @override
  State<IssueTrackerForm> createState() => _IssueTrackerFormState();
}

class _IssueTrackerFormState extends State<IssueTrackerForm> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var uniqueId = UniqueIdGenerator.generate(6); // Generate a 6-digit ID

  List<String> splitSchoolLists = [];
  List<Map<String, dynamic>> issues = [];

  String? _selectedStaff; // Variable to hold the selected staff name
  String? _selectedStaff2; // Variable to hold the selected staff name
  String? _selectedStaff3; // Variable to hold the selected staff name
  String? _selectedStaff4; // Variable to hold the selected staff name
  String? _selectedStaff5; // Variable to hold the selected staff name

  @override
  void initState() {
    super.initState();
    print('Generated Unique ID: $uniqueId');
  }

  final IssueTrackerController issueTrackerController =
      Get.put(IssueTrackerController());

  Future<void> _selectDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        switch (index) {
          case 1:
            issueTrackerController.dateController.text =
                "${picked.toLocal()}".split(' ')[0];
            issueTrackerController.dateFieldError = false;
            break;
          case 2:
            issueTrackerController.dateController2.text =
                "${picked.toLocal()}".split(' ')[0];
            issueTrackerController.dateFieldError2 = false;
            break;
          case 3:
            issueTrackerController.dateController3.text =
                "${picked.toLocal()}".split(' ')[0];
            issueTrackerController.dateFieldError3 = false;
            break;
          case 4:
            issueTrackerController.dateController4.text =
                "${picked.toLocal()}".split(' ')[0];
            issueTrackerController.dateFieldError4 = false;
            break;
          case 5:
            issueTrackerController.dateController5.text =
                "${picked.toLocal()}".split(' ')[0];
            issueTrackerController.dateFieldError5 = false;
            break;
          case 6:
            issueTrackerController.dateController6.text =
                "${picked.toLocal()}".split(' ')[0];
            issueTrackerController.dateFieldError6 = false;
            break;
          case 7:
            issueTrackerController.dateController7.text =
                "${picked.toLocal()}".split(' ')[0];
            issueTrackerController.dateFieldError7 = false;
            break;
          case 8:
            issueTrackerController.dateController8.text =
                "${picked.toLocal()}".split(' ')[0];
            issueTrackerController.dateFieldError8 = false;
            break;
          case 9:
            issueTrackerController.dateController9.text =
                "${picked.toLocal()}".split(' ')[0];
            issueTrackerController.dateFieldError9 = false;
            break;
          case 10:
            issueTrackerController.dateController10.text =
                "${picked.toLocal()}".split(' ')[0];
            issueTrackerController.dateFieldError10 = false;
            break;
          default:
            break;
        }
      });
    }
  }

  List<Map<String, String?>> lib_issuesList = [];

  Future<void> _addIssue() async {
    // Validate form fields
    bool isValid = true;

    // Validate "Did you find any issues in the Library?" field
    if (issueTrackerController.selectedValue2 == null ||
        issueTrackerController.selectedValue2!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError2 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError2 = false;
      });
    }

    // Validate Library part selection if the user answered "Yes"
    if (issueTrackerController.selectedValue2 == 'Yes') {
      if (issueTrackerController.selectedValue3 == null ||
          issueTrackerController.selectedValue3!.isEmpty) {
        setState(() {
          issueTrackerController.radioFieldError3 = true;
        });
        isValid = false;
      } else {
        setState(() {
          issueTrackerController.radioFieldError3 = false;
        });
      }
    }

    // Validate Issue Reported By selection
    if (issueTrackerController.selectedValue4 == null ||
        issueTrackerController.selectedValue4!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError4 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError4 = false;
      });
    }

    // Validate "Resolved On" date field if the issue status is 'Closed'
    if (issueTrackerController.selectedValue5 == 'Closed' &&
        issueTrackerController.dateController2.text.isEmpty) {
      setState(() {
        issueTrackerController.dateFieldError2 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.dateFieldError2 = false;
      });
    }

    // Validate image upload
    if (issueTrackerController.multipleImage.isEmpty) {
      setState(() {
        issueTrackerController.validateRegister = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.validateRegister = false;
      });
    }

    // Validate "Library Issue Reported On" date field
    if (issueTrackerController.dateController.text.isEmpty) {
      setState(() {
        issueTrackerController.dateFieldError = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.dateFieldError = false;
      });
    }

    // If all validations pass, add the issue
    if (isValid && (_formKey.currentState!.validate())) {
      List<File> lib_issue_imgFiles = [];
      for (var imagePath in issueTrackerController.imagePaths) {
        lib_issue_imgFiles.add(File(imagePath)); // Convert image path to File
      }
      String lib_issue_imgFilesPaths =
          lib_issue_imgFiles.map((file) => file.path).join(',');

      // Add issue to the list
      lib_issuesList.add({
        'lib_issue':
            issueTrackerController.selectedValue2!, // Default to 'No' if null
        'lib_issue_value':
            issueTrackerController.selectedValue3!, // Default to empty if null
        'lib_desc': issueTrackerController.libraryDescriptionController.text,
        'reported_on': issueTrackerController.dateController.text,
        'resolved_on': issueTrackerController.dateController2.text,
        'reported_by':
            issueTrackerController.selectedValue4!, // Default to empty if null
        'resolved_by': _selectedStaff ?? '', // Default to empty if null
        'issue_status':
            issueTrackerController.selectedValue5!, // Default to empty if null
        'lib_issue_img': lib_issue_imgFilesPaths,
        'unique_id': uniqueId, // Add unique ID here
      });

      // Reset form for next input
      _resetForm();
    }
  }

  void _resetForm() {
    issueTrackerController.selectedValue2 = '';
    issueTrackerController.selectedValue3 = '';
    issueTrackerController.selectedValue4 = '';
    issueTrackerController.selectedValue5 = '';
    _selectedStaff = null; // Reset staff name selection
    issueTrackerController.libraryDescriptionController.clear();
    issueTrackerController.multipleImage.clear();
    issueTrackerController.dateController.clear();
    issueTrackerController.dateController2.clear();
  }

  List<Map<String, String>> issuesList2 = [];
  Future<void> _addIssue2() async {
    // Validate form fields
    bool isValid = true;

    // Validate Library part selection
    if (issueTrackerController.selectedValue7 == null ||
        issueTrackerController.selectedValue7!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError7 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError7 = false;
      });
    }

    // Validate Issue Reported By selection
    if (issueTrackerController.selectedValue8 == null ||
        issueTrackerController.selectedValue8!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError8 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError8 = false;
      });
    }

    if (issueTrackerController.dateFieldError4 =
        issueTrackerController.selectedValue9 == 'Closed' &&
            issueTrackerController.dateController4.text.isEmpty) {
      setState(() {
        issueTrackerController.dateFieldError4 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.dateFieldError4 = false;
      });
    }

    if (issueTrackerController.selectedValue9 == null ||
        issueTrackerController.selectedValue9!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError9 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError9 = false;
      });
    }

    // Validate image upload
    if (issueTrackerController.multipleImage2.isEmpty) {
      setState(() {
        issueTrackerController.validateRegister2 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.validateRegister2 = false;
      });
    }

    // Validate "Library Issue Reported On" date field
    if (issueTrackerController.dateController3.text.isEmpty) {
      setState(() {
        issueTrackerController.dateFieldError3 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.dateFieldError3 = false;
      });
    }

    // If all validations pass, add the issue
    if (isValid && (_formKey.currentState!.validate())) {
      List<File> play_issue_imgFiles = [];
      for (var imagePath in issueTrackerController.imagePaths2
      ) {
        play_issue_imgFiles.add(File(imagePath)); // Convert image path to File
      }
      String play_issue_imgFilesPaths =
          play_issue_imgFiles.map((file) => file.path).join(',');

      issuesList2.add({
        'play_issue': issueTrackerController.selectedValue6!,
        'play_issue_value': issueTrackerController.selectedValue7!,
        'play_desc':
            issueTrackerController.playgroundDescriptionController.text,
        'reported_on': issueTrackerController.dateController3.text,
        'resolved_on': issueTrackerController.dateController4.text,
        'reported_by': issueTrackerController.selectedValue8!,
        'resolved_by': _selectedStaff2 ?? '',
        'issue_status': issueTrackerController.selectedValue9!,
        'play_issue_img': play_issue_imgFilesPaths,
        'unique_id': uniqueId, // Add unique ID here
      });

      _resetForm2();
    }
  }

  void _resetForm2() {
    issueTrackerController.selectedValue6 = '';
    issueTrackerController.selectedValue7 = '';
    issueTrackerController.selectedValue8 = '';
    issueTrackerController.selectedValue9 = '';
    _selectedStaff2 = null;
    issueTrackerController.playgroundDescriptionController.clear();
    issueTrackerController.multipleImage2.clear();
    issueTrackerController.dateController3.clear();
    issueTrackerController.dateController4.clear();
  }

  List<Map<String, String>> issuesList3 = [];
  Future<void> _addIssue3() async {
    // Validate form fields
    bool isValid = true;

    // Validate Library part selection
    if (issueTrackerController.selectedValue13 == null ||
        issueTrackerController.selectedValue13!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError13 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError13 = false;
      });
    }

    // Validate Issue Reported By selection
    if (issueTrackerController.selectedValue11 == null ||
        issueTrackerController.selectedValue11!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError11 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError11 = false;
      });
    }

    if (issueTrackerController.selectedValue12 == null ||
        issueTrackerController.selectedValue12!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError12 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError12 = false;
      });
    }

    if (issueTrackerController.dateFieldError6 =
        issueTrackerController.selectedValue12 == 'Closed' &&
            issueTrackerController.dateController6.text.isEmpty) {
      setState(() {
        issueTrackerController.dateFieldError6 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.dateFieldError6 = false;
      });
    }

    // Validate image upload
    if (issueTrackerController.multipleImage3.isEmpty) {
      setState(() {
        issueTrackerController.validateRegister3 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.validateRegister3 = false;
      });
    }

    // Validate "Library Issue Reported On" date field
    if (issueTrackerController.dateController5.text.isEmpty) {
      setState(() {
        issueTrackerController.dateFieldError5 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.dateFieldError5 = false;
      });
    }

    // If all validations pass, add the issue
    if (isValid && (_formKey.currentState!.validate())) {
      List<File> imagesFiles = [];
      for (var imagePath in issueTrackerController.imagePaths3) {
        imagesFiles.add(File(imagePath)); // Convert image path to File
      }
      String imagesFilesFilesPaths =
          imagesFiles.map((file) => file.path).join(',');

      issuesList3.add({
        'issue': issueTrackerController.selectedValue12!,
        'part': issueTrackerController.selectedValue26!,
        'description': issueTrackerController.digiLabDescriptionController.text,
        'reportedOn': issueTrackerController.dateController5.text,
        'resolvedOn': issueTrackerController.dateController6.text,
        'resolvedBy': _selectedStaff3 ?? '',
        'reportedBy': issueTrackerController.selectedValue11!,
        'status': issueTrackerController.selectedValue12!,
        'tabletNumber': issueTrackerController.tabletNumberController.text,
        'images': imagesFilesFilesPaths,
        'unique_id': uniqueId,
      });

      _resetForm3();
    }
  }

  void _resetForm3() {
    issueTrackerController.selectedValue10 = '';
    issueTrackerController.selectedValue13 = '';
    issueTrackerController.selectedValue11 = '';
    issueTrackerController.selectedValue12 = '';
    _selectedStaff3 = null;
    issueTrackerController.digiLabDescriptionController.clear();
    issueTrackerController.multipleImage3.clear();
    issueTrackerController.dateController5.clear();
    issueTrackerController.dateController6.clear();
  }

  List<Map<String, String>> issuesList4 = [];
  Future<void> _addIssue4() async {
    // Validate form fields
    bool isValid = true;

    // Validate Library part selection
    if (issueTrackerController.selectedValue15 == null ||
        issueTrackerController.selectedValue15!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError15 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError15 = false;
      });
    }

    // Validate Issue Reported By selection
    if (issueTrackerController.selectedValue16 == null ||
        issueTrackerController.selectedValue16!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError16 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError16 = false;
      });
    }

    if (issueTrackerController.selectedValue17 == null ||
        issueTrackerController.selectedValue17!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError17 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError17 = false;
      });
    }

    if (issueTrackerController.dateFieldError8 =
        issueTrackerController.selectedValue17 == 'Closed' &&
            issueTrackerController.dateController8.text.isEmpty) {
      setState(() {
        issueTrackerController.dateFieldError8 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.dateFieldError8 = false;
      });
    }

    // Validate image upload
    if (issueTrackerController.multipleImage4.isEmpty) {
      setState(() {
        issueTrackerController.validateRegister4 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.validateRegister4 = false;
      });
    }

    // Validate "Library Issue Reported On" date field
    if (issueTrackerController.dateController7.text.isEmpty) {
      setState(() {
        issueTrackerController.dateFieldError7 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.dateFieldError7 = false;
      });
    }

    // If all validations pass, add the issue
    if (isValid && (_formKey.currentState!.validate())) {
      List<File> images2Files = [];
      for (var imagePath in issueTrackerController.imagePaths4) {
        images2Files.add(File(imagePath)); // Convert image path to File
      }
      String images2FilesPaths =
          images2Files.map((file) => file.path).join(',');

      issuesList4.add({
        'issue': issueTrackerController.selectedValue14!,
        'part': issueTrackerController.selectedValue15!,
        'description':
            issueTrackerController.classroomDescriptionController.text,
        'reportedOn': issueTrackerController.dateController7.text,
        'resolvedOn': issueTrackerController.dateController8.text,
        'reportedBy': issueTrackerController.selectedValue16!,
        'status': issueTrackerController.selectedValue17!,
        'images': images2FilesPaths,
        'resolvedBy': _selectedStaff4 ?? '',
        'unique_id': uniqueId,
      });

      _resetForm4();
    }
  }

  void _resetForm4() {
    issueTrackerController.selectedValue16 = '';
    issueTrackerController.selectedValue15 = '';
    issueTrackerController.selectedValue11 = '';
    issueTrackerController.selectedValue14 = '';
    issueTrackerController.selectedValue17 = '';
    _selectedStaff4 = null;
    issueTrackerController.classroomDescriptionController.clear();
    issueTrackerController.multipleImage4.clear();
    issueTrackerController.dateController7.clear();
    issueTrackerController.dateController8.clear();
  }

  List<Map<String, String>> issuesList5 = [];

  Future<void> _addIssue5() async {
    // Validate form fields
    bool isValid = true;

    // Validate Library part selection
    if (issueTrackerController.selectedValue19 == null ||
        issueTrackerController.selectedValue19!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError19 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError19 = false;
      });
    }

    // Validate Issue Reported By selection
    if (issueTrackerController.selectedValue20 == null ||
        issueTrackerController.selectedValue20!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError20 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError20 = false;
      });
    }

    // Validate Issue Status selection
    if (issueTrackerController.selectedValue21 == null ||
        issueTrackerController.selectedValue21!.isEmpty) {
      setState(() {
        issueTrackerController.radioFieldError21 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.radioFieldError21 = false;
      });
    }

    // Validate resolved date field
    if (issueTrackerController.selectedValue21 == 'Closed' &&
        issueTrackerController.dateController10.text.isEmpty) {
      setState(() {
        issueTrackerController.dateFieldError10 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.dateFieldError10 =
            false; // Corrected this from _dateFieldError8
      });
    }

    // Validate image upload
    if (issueTrackerController.multipleImage5.isEmpty) {
      setState(() {
        issueTrackerController.validateRegister5 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.validateRegister5 = false;
      });
    }

    // Validate "Library Issue Reported On" date field
    if (issueTrackerController.dateController9.text.isEmpty) {
      setState(() {
        issueTrackerController.dateFieldError9 = true;
      });
      isValid = false;
    } else {
      setState(() {
        issueTrackerController.dateFieldError9 = false;
      });
    }

    print(issueTrackerController.imagePaths5);

    // If all validations pass, add the issue
    if (isValid && (_formKey.currentState!.validate())) {
      List<File> images3Files = [];
      for (var imagePath in issueTrackerController.imagePaths5) {
        images3Files.add(File(imagePath)); // Convert image path to File
      }
      String images3FilesPaths =
          images3Files.map((file) => file.path).join(',');

      issuesList5.add({
        'issue': issueTrackerController.selectedValue18!,
        'part': issueTrackerController.selectedValue19!,
        'description': issueTrackerController.alexaDescriptionController.text,
        'reportedOn': issueTrackerController.dateController9.text,
        'resolvedOn': issueTrackerController.dateController10.text,
        'reportedBy': issueTrackerController.selectedValue20!,
        'status': issueTrackerController.selectedValue21!,
        'other': issueTrackerController.otherSolarDescriptionController.text,
        'missingDot': issueTrackerController.dotDeviceMissingController.text,
        'notConfiguredDot':
            issueTrackerController.dotDeviceNotConfiguredController.text,
        'notConnectingDot':
            issueTrackerController.dotDeviceNotConnectingController.text,
        'notChargingDot':
            issueTrackerController.dotDeviceNotChargingController.text,
        'images': images3FilesPaths,
        'resolvedBy': _selectedStaff5 ?? '',
        'unique_id': uniqueId,
      });

      _resetForm5();
    }
  }

  void _resetForm5() {
    issueTrackerController.selectedValue20 = '';
    issueTrackerController.selectedValue19 = '';
    issueTrackerController.selectedValue18 = '';
    issueTrackerController.selectedValue21 = '';
    _selectedStaff5 = null;
    issueTrackerController.alexaDescriptionController.clear();
    issueTrackerController.otherSolarDescriptionController.clear();
    issueTrackerController.dotDeviceMissingController.clear();
    issueTrackerController.dotDeviceMissingController.clear();
    issueTrackerController.dotDeviceNotConnectingController.clear();
    issueTrackerController.dotDeviceNotChargingController.clear();
    issueTrackerController.multipleImage5.clear();
    issueTrackerController.dateController9.clear();
    issueTrackerController.dateController10.clear();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final HomeController controller = Get.find<HomeController>();
    final responsive = Responsive(context);

    return WillPopScope(
      onWillPop: () async {
        IconData icon = Icons.check_circle;
        bool? shouldExit = await showDialog<bool>(
          context: context,
          builder: (_) => Confirmation(
            iconname: icon,
            title: 'Exit Confirmation',
            yes: 'Yes',
            no: 'No',
            desc: 'Are you sure you want to leave?',
            onPressed: () {
              Navigator.of(context).pop(true); // User confirms exit
            },
          ),
        );

        // If shouldExit is null, default to false
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar:  CustomAppbar(
          title: 'Issue Tracker Form',
        ),
        body: Padding(
            padding:  EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(children: [
                  GetBuilder<IssueTrackerController>(
                      init: IssueTrackerController(),
                      builder: (issueTrackerController) {
                        return Form(
                            key: _formKey,
                            child: GetBuilder<TourController>(
                                init: TourController(),
                                builder: (tourController) {
                                  // Fetch tour details
                                  tourController.fetchTourDetails();

                                  // Get locked tour ID from SelectController
                                  final selectController =
                                  Get.put(SelectController());
                                  String? lockedTourId =
                                      selectController.lockedTourId;

                                  // Consider the lockedTourId as the selected tour ID if it's not null
                                  String? selectedTourId = lockedTourId ??
                                      issueTrackerController.tourValue;

                                  // Fetch the corresponding schools if lockedTourId or selectedTourId is present
                                  if (selectedTourId != null) {
                            splitSchoolLists = tourController
                                        .getLocalTourList
                                        .where((e) => e.tourId == selectedTourId)
                                        .map((e) => e.allSchool!
                                        .split(',')
                                        .map((s) => s.trim())
                                        .toList())
                                        .expand((x) => x)
                                        .toList();
                                  }

                                  return Column(
                                      children: [
                                        if (issueTrackerController.showBasicDetails) ...[
                                          LabelText(
                                            label: 'Basic Details',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label: 'Tour ID',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          CustomDropdownFormField(
                                            focusNode: issueTrackerController
                                                .tourIdFocusNode,
                                            // Show the locked tour ID directly, and disable dropdown interaction if locked
                                            options: lockedTourId != null
                                                ? [
                                              lockedTourId
                                            ] // Show only the locked tour ID
                                                : tourController.getLocalTourList
                                                .map((e) => e
                                                .tourId!) // Ensure tourId is non-nullable
                                                .toList(),
                                            selectedOption: selectedTourId,
                                            onChanged: lockedTourId ==
                                                null // Disable changing when tour ID is locked
                                                ? (value) {
                                              // Fetch and set the schools for the selected tour
                               splitSchoolLists = tourController
                                                  .getLocalTourList
                                                  .where(
                                                      (e) => e.tourId == value)
                                                  .map((e) => e.allSchool!
                                                  .split(',')
                                                  .map((s) => s.trim())
                                                  .toList())
                                                  .expand((x) => x)
                                                  .toList();

                                              // Single setState call for efficiency
                                              setState(() {
                                                issueTrackerController
                                                    .setSchool(null);
                                                issueTrackerController
                                                    .setTour(value);
                                              });
                                            }
                                                : null, // Disable dropdown if lockedTourId is present
                                            labelText: "Select Tour ID",
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label: 'School',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          DropdownSearch<String>(
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return "Please Select School";
                                              }
                                              return null;
                                            },
                                            popupProps: PopupProps.menu(
                                              showSelectedItems: true,
                                              showSearchBox: true,
                                              disabledItemFn: (String s) => s.startsWith(
                                                  'I'), // Disable based on condition
                                            ),
                                            items:
                                        splitSchoolLists, // Show schools based on selected or locked tour ID
                                            dropdownDecoratorProps:
                                             DropDownDecoratorProps(
                                              dropdownSearchDecoration:
                                              InputDecoration(
                                                labelText: "Select School",
                                                hintText: "Select School",
                                              ),
                                            ),
                                            onChanged: (value) {
                                              // Set the selected school
                                              setState(() {
                                                issueTrackerController
                                                    .setSchool(value);
                                              });
                                            },
                                            selectedItem:
                                            issueTrackerController.schoolValue,
                                          ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label: 'Is this UDISE code is correct?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                             EdgeInsets.only( right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue: issueTrackerController
                                                  .selectedValue,
                                              onChanged: (value) {
                                                setState(() {
                                                  issueTrackerController
                                                          .selectedValue =
                                                      value as String?;
                                                });
                                                if (value == 'Yes') {
                                                  issueTrackerController
                                                      .correctUdiseCodeController
                                                      .clear();
                                                }
                                              },
                                            ),
                                             Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                             EdgeInsets.only( right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue: issueTrackerController
                                                  .selectedValue,
                                              onChanged: (value) {
                                                setState(() {
                                                  issueTrackerController
                                                          .selectedValue =
                                                      value as String?;
                                                });
                                              },
                                            ),
                                             Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (issueTrackerController
                                          .radioFieldError)
                                         Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (issueTrackerController
                                              .selectedValue ==
                                          'No') ...[
                                        LabelText(
                                          label:
                                              'Write Correct UDISE school code',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController: issueTrackerController
                                              .correctUdiseCodeController,
                                          textInputType: TextInputType.number,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                13),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          labelText: 'Enter correct UDISE code',
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please fill this field';
                                            }
                                            if (!RegExp(r'^[0-9]+$')
                                                .hasMatch(value)) {
                                              return 'Please enter a valid number';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                      ],

                                      CustomButton(
                                        title: 'Next',
                                        onPressedButton: () {
                                          print('submit Basic Details');

                                          setState(() {
                                            issueTrackerController
                                                    .radioFieldError =
                                                issueTrackerController
                                                            .selectedValue ==
                                                        null ||
                                                    issueTrackerController
                                                        .selectedValue!.isEmpty;
                                          });

                                          if (_formKey.currentState!
                                                  .validate() &&
                                              !issueTrackerController
                                                  .radioFieldError) {
                                            setState(() {
                                              issueTrackerController
                                                  .showBasicDetails = false;
                                              issueTrackerController
                                                  .showLibrary = true;
                                            });
                                          }
                                        },
                                      ),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ], // End of basic details

                                    //Start of Library
                                    if (issueTrackerController.showLibrary) ...[
                                      LabelText(
                                        label: 'Library',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            'Did you find any issues in the Library?',
                                        astrick: true,
                                      ),

                                      Padding(
                                        padding:
                                             EdgeInsets.only( right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue: issueTrackerController
                                                  .selectedValue2,
                                              onChanged: (value) {
                                                setState(() {
                                                  issueTrackerController
                                                          .selectedValue2 =
                                                      value as String?;
                                                });
                                              },
                                            ),
                                             Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                             EdgeInsets.only( right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue: issueTrackerController
                                                  .selectedValue2,
                                              onChanged: (value) {
                                                setState(() {
                                                  issueTrackerController
                                                          .selectedValue2 =
                                                      value as String?;
                                                });
                                              },
                                            ),
                                             Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (issueTrackerController
                                          .radioFieldError2)
                                         Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),

                                      if (issueTrackerController
                                              .selectedValue2 ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '1) Which part of the Library is the issue related to?',
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Library Register',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue3,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue3 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Library Register'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Library Racks',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue3,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue3 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Library Racks'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Books',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue3,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue3 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Books'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Carpet',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue3,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue3 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Carpet'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Time table not there',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue3,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue3 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text(
                                                    'Time table not there'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value:
                                                      'Library in bad condition',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue3,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue3 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text(
                                                    'Library in bad condition'),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (issueTrackerController
                                            .radioFieldError3)
                                           Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label:
                                              '2) Click an Image related to the selected issue',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        Container(
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(10.0),
                                            border: Border.all(
                                                width: 2,
                                                color: issueTrackerController.isImageUploaded == false
                                                    ? AppColors.primary
                                                    : AppColors.error),
                                          ),
                                          child: ListTile(
                                              title: issueTrackerController.isImageUploaded == false
                                                  ?  Text(
                                                'Click or Upload Image',
                                              )
                                                  :  Text(
                                                'Click or Upload Image',
                                                style: TextStyle(
                                                    color:
                                                    AppColors.error),
                                              ),
                                              trailing:  Icon(
                                                  Icons.camera_alt,
                                                  color:
                                                  AppColors.onBackground),
                                              onTap: () {
                                                showModalBottomSheet(
                                                    backgroundColor:
                                                    AppColors.primary,
                                                    context: context,
                                                    builder: ((builder) =>
                                                        issueTrackerController
                                                            .bottomSheet(
                                                            context)));
                                              }),
                                        ),
                                        ErrorText(
                                          isVisible: issueTrackerController.validateRegister,
                                          message: 'Image Required',
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        issueTrackerController
                                            .multipleImage.isNotEmpty
                                            ? Container(
                                          width:
                                          responsive.responsiveValue(
                                              small: 600.0,
                                              medium: 900.0,
                                              large: 1400.0),
                                          height:
                                          responsive.responsiveValue(
                                              small: 170.0,
                                              medium: 170.0,
                                              large: 170.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey),
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child:
                                          issueTrackerController
                                              .multipleImage
                                              .isEmpty
                                              ?  Center(
                                            child: Text(
                                                'No images selected.'),
                                          )
                                              : ListView.builder(
                                            scrollDirection:
                                            Axis.horizontal,
                                            itemCount:
                                            issueTrackerController
                                                .multipleImage
                                                .length,
                                            itemBuilder:
                                                (context,
                                                index) {
                                              return SizedBox(
                                                height: 200,
                                                width: 200,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:  EdgeInsets
                                                          .all(
                                                          8.0),
                                                      child:
                                                      GestureDetector(
                                                        onTap:
                                                            () {
                                                          CustomImagePreview.showImagePreview(
                                                              issueTrackerController.multipleImage[index].path,
                                                              context);
                                                        },
                                                        child: Image
                                                            .file(
                                                          File(issueTrackerController
                                                              .multipleImage[index]
                                                              .path),
                                                          width:
                                                          190,
                                                          height:
                                                          120,
                                                          fit: BoxFit
                                                              .fill,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap:
                                                          () {
                                                        setState(
                                                                () {
                                                              issueTrackerController
                                                                  .multipleImage
                                                                  .removeAt(index);
                                                            });
                                                      },
                                                      child:
                                                       Icon(
                                                        Icons
                                                            .delete,
                                                        color: Colors
                                                            .red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                            :  SizedBox(),
                                        CustomSizedBox(
                                          value: 40,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label:
                                              '3) Write brief description related to the selected issue',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController: issueTrackerController
                                              .libraryDescriptionController,
                                          maxlines: 3,
                                          labelText: 'Write Description',
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: '4) Issue Reported On',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        TextField(
                                          controller: issueTrackerController
                                              .dateController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: 'Select Date',
                                            errorText: issueTrackerController
                                                    .dateFieldError
                                                ? 'Date is required'
                                                : null,
                                            suffixIcon: IconButton(
                                              icon:  Icon(
                                                  Icons.calendar_today),
                                              onPressed: () {
                                                _selectDate(context,
                                                    1); // Pass index 1 for dateController
                                              },
                                            ),
                                          ),
                                          onTap: () {
                                            _selectDate(context,
                                                1); // Pass index 1 for dateController
                                          },
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: '5) Issue Reported By',
                                          astrick: true,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Teacher',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue4,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue4 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Teacher'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'HeadMaster/Incharge',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue4,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue4 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text(
                                                    'HeadMaster/Incharge'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'SMC/VEC',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue4,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue4 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('SMC/VEC'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: '17000ft Team Member',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue4,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue4 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text(
                                                    '17000ft Team Member'),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (issueTrackerController
                                            .radioFieldError4)
                                           Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: '6) Issue Status',
                                          astrick: true,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Open',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue5,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue5 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Open'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Closed',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue5,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue5 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Closed'),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (issueTrackerController
                                            .radioFieldError5)
                                           Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        if (issueTrackerController
                                                .selectedValue5 ==
                                            'Closed') ...[
                                          LabelText(
                                            label: '7) Issue resolved On',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          TextField(
                                            controller: issueTrackerController
                                                .dateController2,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              labelText: 'Select Date',
                                              errorText: issueTrackerController
                                                      .dateFieldError2
                                                  ? 'Date is required'
                                                  : null,
                                              suffixIcon: IconButton(
                                                icon:  Icon(
                                                    Icons.calendar_today),
                                                onPressed: () {
                                                  _selectDate(context,
                                                      2); // Pass index 2 for dateController2
                                                },
                                              ),
                                            ),
                                            onTap: () {
                                              _selectDate(context,
                                                  2); // Pass index 2 for dateController2
                                            },
                                          ),

                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label: '8) Issue Resolved By',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          DropdownButton<String>(
                                            value: _selectedStaff,
                                            hint: Container(
                                              padding: EdgeInsets.symmetric(vertical: 12), // Add padding for better appearance
                                              child: Text(
                                                'Select a staff member',
                                                style: TextStyle(
                                                  color: Colors.grey, // Hint text color
                                                  fontSize: 16, // Hint text size
                                                  fontWeight: FontWeight.w500, // Hint text weight
                                                ),
                                              ),
                                            ),
                                            items: issueTrackerController.filteredStaffNames.map((staff) {
                                              return DropdownMenuItem<String>(
                                                value: staff,
                                                child: Padding(
                                                  padding:  EdgeInsets.symmetric(vertical: 12), // Add padding for each item
                                                  child: Text(
                                                    staff,
                                                    style: TextStyle(
                                                      fontSize: 16, // Item text size
                                                      color: Colors.black, // Item text color
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                _selectedStaff = newValue; // Update selected staff
                                              });
                                            },
                                            isExpanded: true, // Expand the dropdown to fill the available space
                                            style: TextStyle(color: Colors.black, fontSize: 16), // Set the text style of the selected item
                                            underline: Container(
                                              height: 1, // Underline thickness
                                              color: Colors.grey, // Underline color
                                            ),
                                            icon: Icon(Icons.arrow_drop_down), // Custom dropdown icon
                                          ),



                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          // for select value 5
                                        ],
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: _addIssue,
                                          child: Text('Add Issue'),
                                        ),
                                      ],

                                      Row(
                                        children: [
                                          CustomButton(
                                              title: 'Back',
                                              onPressedButton: () {
                                                setState(() {
                                                  issueTrackerController
                                                      .showBasicDetails = true;
                                                  issueTrackerController
                                                      .showLibrary = false;
                                                });
                                              }),
                                           Spacer(),
                                          CustomButton(
                                              title: 'Next',
                                              onPressedButton: () {
                                                setState(() {
                                                  issueTrackerController
                                                          .radioFieldError2 =
                                                      issueTrackerController
                                                                  .selectedValue2 ==
                                                              null ||
                                                          issueTrackerController
                                                              .selectedValue2!
                                                              .isEmpty;
                                                });

                                                if (_formKey.currentState!
                                                        .validate() &&
                                                    !issueTrackerController
                                                        .radioFieldError2) {
                                                  setState(() {
                                                    issueTrackerController
                                                        .showLibrary = false;
                                                    issueTrackerController
                                                        .showPlayground = true;
                                                  });
                                                }
                                              })
                                        ],
                                      ),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ], //End of Library
                                    // start of Playground
                                    if (issueTrackerController
                                        .showPlayground) ...[
                                      LabelText(
                                        label: 'Playground',
                                      ),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            'Did you find any issues in the Playground?',
                                        astrick: true,
                                      ),

                                      Padding(
                                        padding:
                                             EdgeInsets.only( right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue: issueTrackerController
                                                  .selectedValue6,
                                              onChanged: (value) {
                                                setState(() {
                                                  issueTrackerController
                                                          .selectedValue6 =
                                                      value as String?;
                                                });
                                              },
                                            ),
                                             Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                             EdgeInsets.only( right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue: issueTrackerController
                                                  .selectedValue6,
                                              onChanged: (value) {
                                                setState(() {
                                                  issueTrackerController
                                                          .selectedValue6 =
                                                      value as String?;
                                                });
                                              },
                                            ),
                                             Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (issueTrackerController
                                          .radioFieldError6)
                                         Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),

                                      if (issueTrackerController
                                              .selectedValue6 ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '1) Which part of the Library is the issue related to?',
                                        ),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Swing',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue7,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue7 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Swing'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'See Saw',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue7,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue7 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('See Saw'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Slide',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue7,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue7 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Slide'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Net Scrambler',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue7,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue7 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Net Scrambler'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Monkey bar',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue7,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue7 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Monkey bar'),
                                              ],
                                            ),
                                          ],
                                        ),

                                        if (issueTrackerController
                                            .radioFieldError7)
                                           Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),

                                        LabelText(
                                          label:
                                              '1.1.2) Click an image related to the selected issue',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        Container(
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(10.0),
                                            border: Border.all(
                                                width: 2,
                                                color:
                                                issueTrackerController.isImageUploaded2 == false
                                                    ? AppColors.primary
                                                    : AppColors.error),
                                          ),
                                          child: ListTile(
                                              title: issueTrackerController.isImageUploaded2 == false
                                                  ?  Text(
                                                'Click or Upload Image',
                                              )
                                                  :  Text(
                                                'Click or Upload Image',
                                                style: TextStyle(
                                                    color:
                                                    AppColors.error),
                                              ),
                                              trailing:  Icon(
                                                  Icons.camera_alt,
                                                  color:
                                                  AppColors.onBackground),
                                              onTap: () {
                                                showModalBottomSheet(
                                                    backgroundColor:
                                                    AppColors.primary,
                                                    context: context,
                                                    builder: ((builder) =>
                                                        issueTrackerController
                                                            .bottomSheet2(
                                                            context)));
                                              }),
                                        ),
                                        ErrorText(
                                          isVisible: issueTrackerController.validateRegister2,
                                          message:
                                          'library Register Image Required',
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        issueTrackerController
                                            .multipleImage2.isNotEmpty
                                            ? Container(
                                          width:
                                          responsive.responsiveValue(
                                              small: 600.0,
                                              medium: 900.0,
                                              large: 1400.0),
                                          height:
                                          responsive.responsiveValue(
                                              small: 170.0,
                                              medium: 170.0,
                                              large: 170.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey),
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child:
                                          issueTrackerController
                                              .multipleImage2
                                              .isEmpty
                                              ?  Center(
                                            child: Text(
                                                'No images selected.'),
                                          )
                                              : ListView.builder(
                                            scrollDirection:
                                            Axis.horizontal,
                                            itemCount:
                                            issueTrackerController
                                                .multipleImage2
                                                .length,
                                            itemBuilder:
                                                (context,
                                                index) {
                                              return SizedBox(
                                                height: 200,
                                                width: 200,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:  EdgeInsets
                                                          .all(
                                                          8.0),
                                                      child:
                                                      GestureDetector(
                                                        onTap:
                                                            () {
                                                          CustomImagePreview2.showImagePreview2(
                                                              issueTrackerController.multipleImage2[index].path,
                                                              context);
                                                        },
                                                        child: Image
                                                            .file(
                                                          File(issueTrackerController
                                                              .multipleImage2[index]
                                                              .path),
                                                          width:
                                                          190,
                                                          height:
                                                          120,
                                                          fit: BoxFit
                                                              .fill,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap:
                                                          () {
                                                        setState(
                                                                () {
                                                              issueTrackerController
                                                                  .multipleImage2
                                                                  .removeAt(index);
                                                            });
                                                      },
                                                      child:
                                                       Icon(
                                                        Icons
                                                            .delete,
                                                        color: Colors
                                                            .red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                            :  SizedBox(),

                                        CustomSizedBox(
                                          value: 40,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label:
                                              '3) Write brief description related to the selected issue',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController: issueTrackerController
                                              .playgroundDescriptionController,
                                          maxlines: 3,
                                          labelText: 'Write Description',
                                          showCharacterCount: true,
                                        ),

                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: '4) Issue Reported On',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        TextField(
                                          controller: issueTrackerController
                                              .dateController3,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: 'Select Date',
                                            errorText: issueTrackerController
                                                    .dateFieldError3
                                                ? 'Date is required'
                                                : null,
                                            suffixIcon: IconButton(
                                              icon:  Icon(
                                                  Icons.calendar_today),
                                              onPressed: () {
                                                _selectDate(context,
                                                    3); // Pass index 3 for dateController3
                                              },
                                            ),
                                          ),
                                          onTap: () {
                                            _selectDate(context,
                                                3); // Pass index 3 for dateController3
                                          },
                                        ),

                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: '5) Issue Reported By',
                                          astrick: true,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Teacher',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue8,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue8 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Teacher'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'HeadMaster/Incharge',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue8,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue8 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text(
                                                    'HeadMaster/Incharge'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'SMC/VEC',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue8,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue8 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('SMC/VEC'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: '17000ft Team Member',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue8,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue8 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text(
                                                    '17000ft Team Member'),
                                              ],
                                            ),
                                          ],
                                        ),

                                        if (issueTrackerController
                                            .radioFieldError8)
                                           Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),

                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: '6) Issue Status',
                                          astrick: true,
                                        ),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Open',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue9,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue9 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Open'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Closed',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue9,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue9 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Closed'),
                                              ],
                                            ),
                                          ],
                                        ),

                                        if (issueTrackerController
                                            .radioFieldError9)
                                           Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        if (issueTrackerController
                                                .selectedValue9 ==
                                            'Closed') ...[
                                          LabelText(
                                            label: '7) Issue resolved On',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          TextField(
                                            controller: issueTrackerController
                                                .dateController4,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              labelText: 'Select Date',
                                              errorText: issueTrackerController
                                                      .dateFieldError4
                                                  ? 'Date is required'
                                                  : null,
                                              suffixIcon: IconButton(
                                                icon:  Icon(
                                                    Icons.calendar_today),
                                                onPressed: () {
                                                  _selectDate(context,
                                                      4); // Pass index 4 for dateController4
                                                },
                                              ),
                                            ),
                                            onTap: () {
                                              _selectDate(context,
                                                  4); // Pass index 4 for dateController4
                                            },
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label: '8) Issue Resolved By',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          DropdownButton<String>(
                                            value: _selectedStaff2,
                                            hint: Container(
                                              padding: EdgeInsets.symmetric(vertical: 12), // Add padding for better appearance
                                              child: Text(
                                                'Select a staff member',
                                                style: TextStyle(
                                                  color: Colors.grey, // Hint text color
                                                  fontSize: 16, // Hint text size
                                                  fontWeight: FontWeight.w500, // Hint text weight
                                                ),
                                              ),
                                            ),
                                            items: issueTrackerController.filteredStaffNames.map((staff) {
                                              return DropdownMenuItem<String>(
                                                value: staff,
                                                child: Padding(
                                                  padding:  EdgeInsets.symmetric(vertical: 12), // Add padding for each item
                                                  child: Text(
                                                    staff,
                                                    style: TextStyle(
                                                      fontSize: 16, // Item text size
                                                      color: Colors.black, // Item text color
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                _selectedStaff2 = newValue; // Update selected staff
                                              });
                                            },
                                            isExpanded: true, // Expand the dropdown to fill the available space
                                            style: TextStyle(color: Colors.black, fontSize: 16), // Set the text style of the selected item
                                            underline: Container(
                                              height: 1, // Underline thickness
                                              color: Colors.grey, // Underline color
                                            ),
                                            icon: Icon(Icons.arrow_drop_down), // Custom dropdown icon
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ], // end of selectvalue9

                                        ElevatedButton(
                                          onPressed: _addIssue2,
                                          child: Text('Add Issue'),
                                        ),
                                      ], // for selectvalue6
                                      if (issueTrackerController
                                              .selectedValue6 !=
                                          'Yes') ...[
                                        Row(
                                          children: [
                                            CustomButton(
                                                title: 'Back',
                                                onPressedButton: () {
                                                  setState(() {
                                                    issueTrackerController
                                                        .showLibrary = true;
                                                    issueTrackerController
                                                        .showPlayground = false;
                                                  });
                                                }),
                                             Spacer(),
                                            CustomButton(
                                                title: 'Next',
                                                onPressedButton: () {
                                                  setState(() {
                                                    issueTrackerController
                                                            .radioFieldError6 =
                                                        issueTrackerController
                                                                    .selectedValue6 ==
                                                                null ||
                                                            issueTrackerController
                                                                .selectedValue6!
                                                                .isEmpty;
                                                  });

                                                  if (_formKey.currentState!
                                                          .validate() &&
                                                      !issueTrackerController
                                                          .radioFieldError6) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .showPlayground =
                                                          false;
                                                      issueTrackerController
                                                          .showDigiLab = true;
                                                    });
                                                  }
                                                })
                                          ],
                                        ),
                                      ],
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ], // end of playground
                                    // start of digiLab

                                    if (issueTrackerController.showDigiLab) ...[
                                      LabelText(
                                        label: 'DigiLab',
                                      ),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            'Did you find any issues in the Digilab?',
                                        astrick: true,
                                      ),

                                      Padding(
                                        padding:
                                             EdgeInsets.only( right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue: issueTrackerController
                                                  .selectedValue10,
                                              onChanged: (value) {
                                                setState(() {
                                                  issueTrackerController
                                                          .selectedValue10 =
                                                      value as String?;
                                                });
                                              },
                                            ),
                                             Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                             EdgeInsets.only( right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue: issueTrackerController
                                                  .selectedValue10,
                                              onChanged: (value) {
                                                setState(() {
                                                  issueTrackerController
                                                          .selectedValue10 =
                                                      value as String?;
                                                });
                                              },
                                            ),
                                             Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (issueTrackerController
                                          .radioFieldError10)
                                         Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),

                                      if (issueTrackerController
                                              .selectedValue10 ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '1) Which part of the DigiLab is the issue related to?',
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Solar',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue13,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue13 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Solar'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Battery Box',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue13,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue13 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Battery Box'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Charging Dock',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue13,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue13 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Charging Dock'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Raspberry Pi',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue13,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue13 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Raspberry Pi'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'TV',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue13,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue13 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('TV'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Converter Box',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue13,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue13 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Converter Box'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Tablets',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue13,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue13 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Tablets'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'CG State',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue13,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue13 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('CG State'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value:
                                                      'DigiLab Room/Generic Issues',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue13,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue13 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text(
                                                    'DigiLab Room/Generic Issues'),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (issueTrackerController
                                            .radioFieldError13)
                                           Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),

                                        if (issueTrackerController
                                                .selectedValue13 ==
                                            'Solar') ...[
                                          LabelText(
                                            label:
                                                '1.1) Select the related issue',
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Solar Panel',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Solar Panel'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Pole and Frame',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Pole and Frame'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Lightning Rod',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Lightning Rod'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'External Wiring',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('External Wiring'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Internal Wiring',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Internal Wiring'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'other',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('other'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (issueTrackerController
                                              .radioFieldError26)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ],

                                        if (issueTrackerController
                                                .selectedValue13 ==
                                            'Battery Box') ...[
                                          LabelText(
                                            label:
                                                '1.1) Select the related issue',
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Battery Box-Charge Controller',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Battery Box-Charge Controller'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Battery Box-Battery',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Battery Box-Battery'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Battery Box-Terminal',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Battery Box-Terminal'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Battery Box-Transformer/Top up box',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Battery Box-Transformer/Top up box'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Load Switches',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Load Switches'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'other',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('other'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (issueTrackerController
                                              .radioFieldError26)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ],
                                        if (issueTrackerController
                                                .selectedValue13 ==
                                            'Charging Dock') ...[
                                          LabelText(
                                            label:
                                                '1.1) Select the related issue',
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Charging Dock',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Charging Dock'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (issueTrackerController
                                              .radioFieldError26)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ],

                                        if (issueTrackerController
                                                .selectedValue13 ==
                                            'Raspberry Pi') ...[
                                          LabelText(
                                            label:
                                                '1.1) Select the related issue',
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Raspberry Pi-Pi box',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Raspberry Pi-Pi box'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Raspberry Pi-Motherboard',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Raspberry Pi-Motherboard'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Raspberry Pi-SD Card',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Raspberry Pi-SD Card'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Raspberry Pi-Ports not working',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Raspberry Pi-Ports not working'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Raspberry Pi-Content not coming up on the TV',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Raspberry Pi-Content not coming up on the TV'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'other',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('other'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (issueTrackerController
                                              .radioFieldError26)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ],

                                        if (issueTrackerController
                                                .selectedValue13 ==
                                            'TV') ...[
                                          LabelText(
                                            label:
                                                '1.1) Select the related issue',
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'TV-Screen damaged/ not working/ not turning on',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'TV-Screen damaged/ not working/ not turning on'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'TV-HDMI not working',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'TV-HDMI not working'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'TV-Ports not working',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'TV-Ports not working'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'TV-Remote not working',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'TV-Remote not working'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'other',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('other'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (issueTrackerController
                                              .radioFieldError26)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ],

                                        if (issueTrackerController
                                                .selectedValue13 ==
                                            'Converter Box') ...[
                                          LabelText(
                                            label:
                                                '1.1) Select the related issue',
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Converter Box-ports not working',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Converter Box-ports not working'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Converter Box-Faulty/Damaged/Not turning on',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Converter Box-Faulty/Damaged/Not turning on'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Converter Box-Wire Damaged',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Converter Box-Wire Damaged'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'other',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('other'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (issueTrackerController
                                              .radioFieldError26)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ],

                                        if (issueTrackerController
                                                .selectedValue13 ==
                                            'Tablets') ...[
                                          LabelText(
                                            label:
                                                '1.1) Select the related issue',
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Tablets-Display not working',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Tablets-Display not working'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Tablets-Damaged/Faulty',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Tablets-Damaged/Faulty'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Tablets-SD card not working',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Tablets-SD card not working'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Tablets-Cover not there',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Tablets-Cover not there'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'other',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('other'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (issueTrackerController
                                              .radioFieldError26)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ],

                                        if (issueTrackerController
                                                .selectedValue26 ==
                                            'Tablets-Display not working') ...[
                                          LabelText(
                                            label: 'Enter the tablet Number',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          CustomTextFormField(
                                            textController:
                                                issueTrackerController
                                                    .tabletNumberController,
                                            showCharacterCount: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ],

                                        if (issueTrackerController
                                                .selectedValue26 ==
                                            'Tablets-SD card not working') ...[
                                          LabelText(
                                            label: 'Enter the tablet Number',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          CustomTextFormField(
                                            textController:
                                                issueTrackerController
                                                    .tabletNumberController,
                                            showCharacterCount: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ],

                                        if (issueTrackerController
                                                .selectedValue26 ==
                                            'Tablets-Cover not there') ...[
                                          LabelText(
                                            label: 'Enter the tablet Number',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          CustomTextFormField(
                                            textController:
                                                issueTrackerController
                                                    .tabletNumberController,
                                            showCharacterCount: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ],

                                        if (issueTrackerController
                                                .selectedValue13 ==
                                            'CG State') ...[
                                          LabelText(
                                            label:
                                                '1.1) Select the related issue',
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Wrap each Row with Expanded to manage space better on smaller screens
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'CG State-App not working/keeps crashing',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                        'CG State-App not working/keeps crashing'),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'CG State-license issue',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                        'CG State-license issue'),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'CG State-Master pin/Admin pin/Password registration problem',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                        'CG State-Master pin/Admin pin/Password registration problem'),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'CG State-Modules not loading',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                        'CG State-Modules not loading'),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'CG State-issue with the IDs',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                        'CG State-issue with the IDs'),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'CG State-Send report not happening',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                        'CG State-Send report not happening'),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'CG State-Unknown issue/some new notification popping up',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                        'CG State-Unknown issue/some new notification popping up'),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'CG State-App not there in the tablet/s',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                        'CG State-App not there in the tablet/s'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (issueTrackerController
                                              .radioFieldError26)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          CustomSizedBox(
                                            value: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02, // Dynamic sizing based on screen height
                                            side: 'height',
                                          ),
                                        ],

                                        if (issueTrackerController
                                                .selectedValue13 ==
                                            'DigiLab Room/Generic Issues') ...[
                                          LabelText(
                                            label:
                                                '1.1) Select the related issue',
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Wrap each Row with Expanded to manage space better on smaller screens
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Problem in the furniture',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                        'Problem in the furniture'),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Carpet Issue',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: Text('Carpet Issue'),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'TV stand Issue',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child:
                                                        Text('TV stand Issue'),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Time table not there',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                        'Time table not there'),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'DOs and DONOTs chart not there',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                        'DOs and DONOTs chart not there'),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Unkept DigiLab Room',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue26,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue26 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                        'Unkept DigiLab Room'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (issueTrackerController
                                              .radioFieldError26)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          CustomSizedBox(
                                            value: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02, // Dynamic sizing based on screen height
                                            side: 'height',
                                          ),
                                        ],

                                        LabelText(
                                          label:
                                              '1.1.2) Click an image related to the selected issue',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        Container(
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(10.0),
                                            border: Border.all(
                                                width: 2,
                                                color:
                                                issueTrackerController.isImageUploaded3 == false
                                                    ? AppColors.primary
                                                    : AppColors.error),
                                          ),
                                          child: ListTile(
                                              title: issueTrackerController.isImageUploaded3 == false
                                                  ?  Text(
                                                'Click or Upload Image',
                                              )
                                                  :  Text(
                                                'Click or Upload Image',
                                                style: TextStyle(
                                                    color:
                                                    AppColors.error),
                                              ),
                                              trailing:  Icon(
                                                  Icons.camera_alt,
                                                  color:
                                                  AppColors.onBackground),
                                              onTap: () {
                                                showModalBottomSheet(
                                                    backgroundColor:
                                                    AppColors.primary,
                                                    context: context,
                                                    builder: ((builder) =>
                                                        issueTrackerController
                                                            .bottomSheet3(
                                                            context)));
                                              }),
                                        ),
                                        ErrorText(
                                          isVisible: issueTrackerController.validateRegister3,
                                          message:
                                          'library Register Image Required',
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        issueTrackerController
                                            .multipleImage3.isNotEmpty
                                            ? Container(
                                          width:
                                          responsive.responsiveValue(
                                              small: 600.0,
                                              medium: 900.0,
                                              large: 1400.0),
                                          height:
                                          responsive.responsiveValue(
                                              small: 170.0,
                                              medium: 170.0,
                                              large: 170.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey),
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child:
                                          issueTrackerController
                                              .multipleImage3
                                              .isEmpty
                                              ?  Center(
                                            child: Text(
                                                'No images selected.'),
                                          )
                                              : ListView.builder(
                                            scrollDirection:
                                            Axis.horizontal,
                                            itemCount:
                                            issueTrackerController
                                                .multipleImage3
                                                .length,
                                            itemBuilder:
                                                (context,
                                                index) {
                                              return SizedBox(
                                                height: 200,
                                                width: 200,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:  EdgeInsets
                                                          .all(
                                                          8.0),
                                                      child:
                                                      GestureDetector(
                                                        onTap:
                                                            () {
                                                          CustomImagePreview3.showImagePreview3(
                                                              issueTrackerController.multipleImage3[index].path,
                                                              context);
                                                        },
                                                        child: Image
                                                            .file(
                                                          File(issueTrackerController
                                                              .multipleImage3[index]
                                                              .path),
                                                          width:
                                                          190,
                                                          height:
                                                          120,
                                                          fit: BoxFit
                                                              .fill,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap:
                                                          () {
                                                        setState(
                                                                () {
                                                              issueTrackerController
                                                                  .multipleImage3
                                                                  .removeAt(index);
                                                            });
                                                      },
                                                      child:
                                                       Icon(
                                                        Icons
                                                            .delete,
                                                        color: Colors
                                                            .red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                            :  SizedBox(),
                                        CustomSizedBox(
                                          value: 40,
                                          side: 'height',
                                        ),

                                        LabelText(
                                          label:
                                              '1.1.3) Write brief description related to the selected issue',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController: issueTrackerController
                                              .digiLabDescriptionController,
                                          maxlines: 3,
                                          labelText: 'Write Description',
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),

                                        LabelText(
                                          label: '4) Issue Reported On',
                                          astrick: true,
                                        ),

                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        TextField(
                                          controller: issueTrackerController
                                              .dateController5,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: 'Select Date',
                                            errorText: issueTrackerController
                                                    .dateFieldError5
                                                ? 'Date is required'
                                                : null,
                                            suffixIcon: IconButton(
                                              icon:  Icon(
                                                  Icons.calendar_today),
                                              onPressed: () {
                                                _selectDate(context,
                                                    5); // Pass index 5 for dateController5
                                              },
                                            ),
                                          ),
                                          onTap: () {
                                            _selectDate(context,
                                                5); // Pass index 5 for dateController5
                                          },
                                        ),

                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: '5) Issue Reported By',
                                          astrick: true,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Teacher',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue11,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue11 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Teacher'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'HeadMaster/Incharge',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue11,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue11 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text(
                                                    'HeadMaster/Incharge'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'SMC/VEC',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue11,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue11 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('SMC/VEC'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: '17000ft Team Member',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue11,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue11 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text(
                                                    '17000ft Team Member'),
                                              ],
                                            ),
                                          ],
                                        ),

                                        if (issueTrackerController
                                            .radioFieldError11)
                                           Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),

                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),

                                        LabelText(
                                          label: '6) Issue Status',
                                          astrick: true,
                                        ),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Open',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue12,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue12 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Open'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Radio(
                                                  value: 'Closed',
                                                  groupValue:
                                                      issueTrackerController
                                                          .selectedValue12,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      issueTrackerController
                                                              .selectedValue12 =
                                                          value as String?;
                                                    });
                                                  },
                                                ),
                                                 Text('Closed'),
                                              ],
                                            ),
                                          ],
                                        ),

                                        if (issueTrackerController
                                            .radioFieldError12)
                                           Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        if (issueTrackerController
                                                .selectedValue12 ==
                                            'Closed') ...[
                                          LabelText(
                                            label: '7) Issue resolved On',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          TextField(
                                            controller: issueTrackerController
                                                .dateController6,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              labelText: 'Select Date',
                                              errorText: issueTrackerController
                                                      .dateFieldError6
                                                  ? 'Date is required'
                                                  : null,
                                              suffixIcon: IconButton(
                                                icon:  Icon(
                                                    Icons.calendar_today),
                                                onPressed: () {
                                                  _selectDate(context,
                                                      6); // Pass index 6 for dateController6
                                                },
                                              ),
                                            ),
                                            onTap: () {
                                              _selectDate(context,
                                                  6); // Pass index 6 for dateController6
                                            },
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label: '8) Issue Resolved By',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          DropdownButton<String>(
                                            value: _selectedStaff3,
                                            hint: Container(
                                              padding: EdgeInsets.symmetric(vertical: 12), // Add padding for better appearance
                                              child: Text(
                                                'Select a staff member',
                                                style: TextStyle(
                                                  color: Colors.grey, // Hint text color
                                                  fontSize: 16, // Hint text size
                                                  fontWeight: FontWeight.w500, // Hint text weight
                                                ),
                                              ),
                                            ),
                                            items: issueTrackerController.filteredStaffNames.map((staff) {
                                              return DropdownMenuItem<String>(
                                                value: staff,
                                                child: Padding(
                                                  padding:  EdgeInsets.symmetric(vertical: 12), // Add padding for each item
                                                  child: Text(
                                                    staff,
                                                    style: TextStyle(
                                                      fontSize: 16, // Item text size
                                                      color: Colors.black, // Item text color
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                _selectedStaff3 = newValue; // Update selected staff
                                              });
                                            },
                                            isExpanded: true, // Expand the dropdown to fill the available space
                                            style: TextStyle(color: Colors.black, fontSize: 16), // Set the text style of the selected item
                                            underline: Container(
                                              height: 1, // Underline thickness
                                              color: Colors.grey, // Underline color
                                            ),
                                            icon: Icon(Icons.arrow_drop_down), // Custom dropdown icon
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ], // for select value 12

                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: _addIssue3,
                                          child: Text('Add Issue'),
                                        ),
                                      ], //for selectvalue10

                                      if (issueTrackerController
                                              .selectedValue10 !=
                                          'Yes') ...[
                                        Row(
                                          children: [
                                            CustomButton(
                                                title: 'Back',
                                                onPressedButton: () {
                                                  setState(() {
                                                    issueTrackerController
                                                        .showPlayground = true;
                                                    issueTrackerController
                                                        .showDigiLab = false;
                                                  });
                                                }),
                                             Spacer(),
                                            CustomButton(
                                                title: 'Next',
                                                onPressedButton: () {
                                                  setState(() {
                                                    issueTrackerController
                                                            .radioFieldError10 =
                                                        issueTrackerController
                                                                    .selectedValue10 ==
                                                                null ||
                                                            issueTrackerController
                                                                .selectedValue10!
                                                                .isEmpty;
                                                  });

                                                  if (_formKey.currentState!
                                                          .validate() &&
                                                      !issueTrackerController
                                                          .radioFieldError10) {
                                                    setState(() {
                                                      issueTrackerController
                                                          .showDigiLab = false;
                                                      issueTrackerController
                                                          .showClassroom = true;
                                                    });
                                                  }
                                                })
                                          ],
                                        ),
                                      ],
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ], // end of digiLab

                                    // start of clasroom
                                    if (issueTrackerController
                                        .showClassroom) ...[
                                      LabelText(
                                        label: 'Classroom',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),

                                      if (controller.office == 'Sikkim')
                                         Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Center(
                                            // Center the text in the middle of the available space
                                            child: Text(
                                              'This program is not for Sikkim.',
                                              style: TextStyle(
                                                color: Colors
                                                    .black, // Set the text color to black
                                                fontSize: 28,
                                                fontWeight: FontWeight
                                                    .bold, // Make the text bold for clarity
                                              ),
                                              textAlign: TextAlign
                                                  .center, // Center align the text
                                            ),
                                          ),
                                        )
                                      else ...[
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label:
                                              'Did you find any issues in the Classroom?',
                                          astrick: true,
                                        ),

                                        Padding(
                                          padding:
                                               EdgeInsets.only( right: screenWidth * 0.1),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'Yes',
                                                groupValue:
                                                    issueTrackerController
                                                        .selectedValue14,
                                                onChanged: (value) {
                                                  setState(() {
                                                    issueTrackerController
                                                            .selectedValue14 =
                                                        value as String?;
                                                  });
                                                },
                                              ),
                                               Text('Yes'),
                                            ],
                                          ),
                                        ),
                                        CustomSizedBox(
                                          value: 150,
                                          side: 'width',
                                        ),
                                        // make it that user can also edit the tourId and school
                                        Padding(
                                          padding:
                                               EdgeInsets.only( right: screenWidth * 0.1),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'No',
                                                groupValue:
                                                    issueTrackerController
                                                        .selectedValue14,
                                                onChanged: (value) {
                                                  setState(() {
                                                    issueTrackerController
                                                            .selectedValue14 =
                                                        value as String?;
                                                  });
                                                },
                                              ),
                                               Text('No'),
                                            ],
                                          ),
                                        ),
                                        if (issueTrackerController
                                            .radioFieldError14)
                                           Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),

                                        if (issueTrackerController
                                                .selectedValue14 ==
                                            'Yes') ...[
                                          LabelText(
                                            label:
                                                '1) Which part of the classroom Furniture is the issue related to?',
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Round bean for Pre primary',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue15,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue15 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Round bean for Pre primary'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Small Plastic Chair',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue15,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue15 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Small Plastic Chair'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'Medium Plastic Chair',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue15,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue15 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Medium Plastic Chair'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Metal Desk-Small',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue15,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue15 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Metal Desk-Small'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Metal Chair-Small',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue15,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue15 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Metal Chair-Small'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Metal Desk-Large',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue15,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue15 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Metal Desk-Large'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Metal Chair-Large',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue15,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue15 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Metal Chair-Large'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Carpet',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue15,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue15 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Carpet'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Other',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue15,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue15 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Other'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (issueTrackerController
                                              .radioFieldError15)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),

                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),

                                          LabelText(
                                            label:
                                                '1.1.2) Click an image related to the selected issue',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10.0),
                                              border: Border.all(
                                                  width: 2,
                                                  color:
                                                  issueTrackerController.isImageUploaded4 == false
                                                      ? AppColors.primary
                                                      : AppColors.error),
                                            ),
                                            child: ListTile(
                                                title:
                                                issueTrackerController.isImageUploaded4 == false
                                                    ?  Text(
                                                  'Click or Upload Image',
                                                )
                                                    :  Text(
                                                  'Click or Upload Image',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .error),
                                                ),
                                                trailing:  Icon(
                                                    Icons.camera_alt,
                                                    color:
                                                    AppColors.onBackground),
                                                onTap: () {
                                                  showModalBottomSheet(
                                                      backgroundColor:
                                                      AppColors.primary,
                                                      context: context,
                                                      builder: ((builder) =>
                                                          issueTrackerController
                                                              .bottomSheet4(
                                                              context)));
                                                }),
                                          ),
                                          ErrorText(
                                            isVisible: issueTrackerController.validateRegister4,
                                            message:
                                            'library Register Image Required',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          issueTrackerController
                                              .multipleImage4.isNotEmpty
                                              ? Container(
                                            width: responsive
                                                .responsiveValue(
                                                small: 600.0,
                                                medium: 900.0,
                                                large: 1400.0),
                                            height: responsive
                                                .responsiveValue(
                                                small: 170.0,
                                                medium: 170.0,
                                                large: 170.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  10),
                                            ),
                                            child:
                                            issueTrackerController
                                                .multipleImage4
                                                .isEmpty
                                                ?  Center(
                                              child: Text(
                                                  'No images selected.'),
                                            )
                                                : ListView.builder(
                                              scrollDirection:
                                              Axis.horizontal,
                                              itemCount:
                                              issueTrackerController
                                                  .multipleImage4
                                                  .length,
                                              itemBuilder:
                                                  (context,
                                                  index) {
                                                return SizedBox(
                                                  height: 200,
                                                  width: 200,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:  EdgeInsets
                                                            .all(
                                                            8.0),
                                                        child:
                                                        GestureDetector(
                                                          onTap:
                                                              () {
                                                            CustomImagePreview4.showImagePreview4(issueTrackerController.multipleImage4[index].path,
                                                                context);
                                                          },
                                                          child:
                                                          Image.file(
                                                            File(issueTrackerController.multipleImage4[index].path),
                                                            width:
                                                            190,
                                                            height:
                                                            120,
                                                            fit:
                                                            BoxFit.fill,
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap:
                                                            () {
                                                          setState(
                                                                  () {
                                                                issueTrackerController.multipleImage4.removeAt(index);
                                                              });
                                                        },
                                                        child:
                                                         Icon(
                                                          Icons
                                                              .delete,
                                                          color:
                                                          Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                              :  SizedBox(),
                                          CustomSizedBox(
                                            value: 40,
                                            side: 'height',
                                          ),

                                          LabelText(
                                            label:
                                                '1.1.3) Describe the issue in detail ? Also mention quantities of the damaged part?',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          CustomTextFormField(
                                            textController: issueTrackerController
                                                .classroomDescriptionController,
                                            maxlines: 3,
                                            labelText: 'Write Description',
                                            showCharacterCount: true,
                                          ),

                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),

                                          LabelText(
                                            label: '4) Issue Reported On',
                                            astrick: true,
                                          ),

                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          TextField(
                                            controller: issueTrackerController
                                                .dateController7,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              labelText: 'Select Date',
                                              errorText: issueTrackerController
                                                      .dateFieldError7
                                                  ? 'Date is required'
                                                  : null,
                                              suffixIcon: IconButton(
                                                icon:  Icon(
                                                    Icons.calendar_today),
                                                onPressed: () {
                                                  _selectDate(context,
                                                      7); // Pass index 6 for dateController6
                                                },
                                              ),
                                            ),
                                            onTap: () {
                                              _selectDate(context,
                                                  7); // Pass index 6 for dateController6
                                            },
                                          ),

                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),

                                          LabelText(
                                            label: '5) Issue Reported By',
                                            astrick: true,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Teacher',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue16,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue16 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Teacher'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'HeadMaster/Incharge',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue16,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue16 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'HeadMaster/Incharge'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'SMC/VEC',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue16,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue16 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('SMC/VEC'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        '17000ft Team Member',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue16,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue16 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      '17000ft Team Member'),
                                                ],
                                              ),
                                            ],
                                          ),

                                          if (issueTrackerController
                                              .radioFieldError16)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),

                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label: '6) Issue Status',
                                            astrick: true,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Open',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue17,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue17 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Open'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Closed',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue17,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue17 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Closed'),
                                                ],
                                              ),
                                            ],
                                          ),

                                          if (issueTrackerController
                                              .radioFieldError17)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          if (issueTrackerController
                                                  .selectedValue17 ==
                                              'Closed') ...[
                                            LabelText(
                                              label: '7) Issue resolved On',
                                              astrick: true,
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            TextField(
                                              controller: issueTrackerController
                                                  .dateController8,
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                labelText: 'Select Date',
                                                errorText:
                                                    issueTrackerController
                                                            .dateFieldError8
                                                        ? 'Date is required'
                                                        : null,
                                                suffixIcon: IconButton(
                                                  icon:  Icon(
                                                      Icons.calendar_today),
                                                  onPressed: () {
                                                    _selectDate(context,
                                                        8); // Pass index 6 for dateController6
                                                  },
                                                ),
                                              ),
                                              onTap: () {
                                                _selectDate(context,
                                                    8); // Pass index 6 for dateController6
                                              },
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            LabelText(
                                              label: '8) Issue Resolved By',
                                              astrick: true,
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            DropdownButton<String>(
                                              value: _selectedStaff4,
                                              hint: Container(
                                                padding: EdgeInsets.symmetric(vertical: 12), // Add padding for better appearance
                                                child: Text(
                                                  'Select a staff member',
                                                  style: TextStyle(
                                                    color: Colors.grey, // Hint text color
                                                    fontSize: 16, // Hint text size
                                                    fontWeight: FontWeight.w500, // Hint text weight
                                                  ),
                                                ),
                                              ),
                                              items: issueTrackerController.filteredStaffNames.map((staff) {
                                                return DropdownMenuItem<String>(
                                                  value: staff,
                                                  child: Padding(
                                                    padding:  EdgeInsets.symmetric(vertical: 12), // Add padding for each item
                                                    child: Text(
                                                      staff,
                                                      style: TextStyle(
                                                        fontSize: 16, // Item text size
                                                        color: Colors.black, // Item text color
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _selectedStaff4 = newValue; // Update selected staff
                                                });
                                              },
                                              isExpanded: true, // Expand the dropdown to fill the available space
                                              style: TextStyle(color: Colors.black, fontSize: 16), // Set the text style of the selected item
                                              underline: Container(
                                                height: 1, // Underline thickness
                                                color: Colors.grey, // Underline color
                                              ),
                                              icon: Icon(Icons.arrow_drop_down), // Custom dropdown icon
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                          ], // for select value 17

                                          ElevatedButton(
                                            onPressed: _addIssue4,
                                            child: Text('Add Issue'),
                                          ),
                                        ]
                                      ],
                                      if (issueTrackerController
                                              .selectedValue14 !=
                                          'Yes') ...[
                                        Row(
                                          children: [
                                            CustomButton(
                                                title: 'Back',
                                                onPressedButton: () {
                                                  setState(() {
                                                    issueTrackerController
                                                        .showDigiLab = true;
                                                    issueTrackerController
                                                        .showClassroom = false;
                                                  });
                                                }),
                                             Spacer(),
                                            CustomButton(
                                                title: 'Next',
                                                onPressedButton: () {
                                                  setState(() {
                                                    // Only validate radioFieldError14 if the office is NOT 'Sikkim'
                                                    if (controller.office != 'Sikkim') {
                                                      issueTrackerController.radioFieldError14 = issueTrackerController.selectedValue14 == null || issueTrackerController.selectedValue14!.isEmpty;
                                                    } else {
                                                      issueTrackerController.radioFieldError14 = false; // No validation for Sikkim
                                                    }
                                                  });

                                                  // Validate the form only if the office is NOT 'Sikkim'
                                                  if (_formKey.currentState!.validate() && !issueTrackerController.radioFieldError14) {
                                                    setState(() {
                                                      issueTrackerController.showClassroom = false;
                                                      issueTrackerController.showAlexa = true;
                                                    });
                                                  }
                                                }
                                            )

                                          ],
                                        ),
                                      ],
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ), // selectvalue14
                                    ], //end of classroom

                                    // start of Alexa project
                                    if (issueTrackerController.showAlexa) ...[
                                      LabelText(
                                        label: 'Alexa project',
                                      ),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (controller.office == 'Sikkim')
                                         Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Center(
                                            // Center the text in the middle of the available space
                                            child: Text(
                                              'This program is not for Sikkim.',
                                              style: TextStyle(
                                                color: Colors
                                                    .black, // Set the text color to black
                                                fontSize: 28,
                                                fontWeight: FontWeight
                                                    .bold, // Make the text bold for clarity
                                              ),
                                              textAlign: TextAlign
                                                  .center, // Center align the text
                                            ),
                                          ),
                                        )
                                      else ...[
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label:
                                              'Did you find any issues in the Alexa Project?',
                                          astrick: true,
                                        ),

                                        Padding(
                                          padding:
                                               EdgeInsets.only( right: screenWidth * 0.1),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'Yes',
                                                groupValue:
                                                    issueTrackerController
                                                        .selectedValue18,
                                                onChanged: (value) {
                                                  setState(() {
                                                    issueTrackerController
                                                            .selectedValue18 =
                                                        value as String?;
                                                  });
                                                },
                                              ),
                                               Text('Yes'),
                                            ],
                                          ),
                                        ),
                                        CustomSizedBox(
                                          value: 150,
                                          side: 'width',
                                        ),
                                        // make it that user can also edit the tourId and school
                                        Padding(
                                          padding:
                                               EdgeInsets.only( right: screenWidth * 0.1),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'No',
                                                groupValue:
                                                    issueTrackerController
                                                        .selectedValue18,
                                                onChanged: (value) {
                                                  setState(() {
                                                    issueTrackerController
                                                            .selectedValue18 =
                                                        value as String?;
                                                  });
                                                },
                                              ),
                                               Text('No'),
                                            ],
                                          ),
                                        ),
                                        if (issueTrackerController
                                            .radioFieldError18)
                                           Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),

                                        if (issueTrackerController
                                                .selectedValue18 ==
                                            'Yes') ...[
                                          LabelText(
                                            label:
                                                '1) Which part of the Alexa Project is the issue related to?',
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Solar Panel',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue19,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue19 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Solar Panel'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Charging Station',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue19,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue19 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'Charging Station'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Router',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue19,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue19 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Router'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Dot Device',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue19,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue19 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Dot Device'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (issueTrackerController
                                              .radioFieldError19)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),

                                          if (issueTrackerController
                                                  .selectedValue19 ==
                                              'Solar Panel') ...[
                                            LabelText(
                                              label:
                                                  '1.1) Select the related issue',
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value:
                                                          'Panel damaged/missing',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text(
                                                        'Panel damaged/missing'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value:
                                                          'Panel not connecting',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text(
                                                        'Panel not connecting'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value: 'other',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text('other'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (issueTrackerController
                                                .radioFieldError22)
                                               Padding(
                                                padding:
                                                    EdgeInsets.only(left: 16.0),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Please select an option',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            if (issueTrackerController
                                                    .selectedValue22 ==
                                                'other') ...[
                                              LabelText(
                                                label:
                                                    'Please specify the other issue',
                                              ),
                                              CustomSizedBox(
                                                value: 20,
                                                side: 'height',
                                              ),
                                              CustomTextFormField(
                                                textController:
                                                    issueTrackerController
                                                        .otherSolarDescriptionController,
                                                showCharacterCount: true,
                                              ),
                                              CustomSizedBox(
                                                value: 20,
                                                side: 'height',
                                              ),
                                            ],
                                          ],

                                          if (issueTrackerController
                                                  .selectedValue19 ==
                                              'Charging Station') ...[
                                            LabelText(
                                              label:
                                                  '1.1) Select the related issue',
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value:
                                                          'Charging Station damaged/missing',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text(
                                                        'Charging Station damaged/missing'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value:
                                                          'Battery not Charging',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text(
                                                        'Battery not Charging'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value: 'other',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text('other'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (issueTrackerController
                                                .radioFieldError23)
                                               Padding(
                                                padding:
                                                    EdgeInsets.only(left: 16.0),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Please select an option',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                          ],

                                          if (issueTrackerController
                                                  .selectedValue19 ==
                                              'Router') ...[
                                            LabelText(
                                              label:
                                                  '1.1) Select the related issue',
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value:
                                                          'Router damaged/missing',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text(
                                                        'Router damaged/missing'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value:
                                                          'Sim card damaged/missing',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text(
                                                        'Sim card damaged/missing'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value:
                                                          'Router not Configured',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text(
                                                        'Router not Configured'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value: 'other',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text('other'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (issueTrackerController
                                                .radioFieldError24)
                                               Padding(
                                                padding:
                                                    EdgeInsets.only(left: 16.0),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Please select an option',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                          ],

                                          if (issueTrackerController
                                                  .selectedValue19 ==
                                              'Dot Device') ...[
                                            LabelText(
                                              label:
                                                  '1.1) Select the related issue',
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value:
                                                          'Dot damaged/missing',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text(
                                                        'Dot damaged/missing'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value:
                                                          'Dot not configured',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text(
                                                        'Dot not configured'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value:
                                                          'Dot not connecting',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text(
                                                        'Dot not connecting'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value: 'Dot not charging',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text(
                                                        'Dot not charging'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Radio(
                                                      value: 'other',
                                                      groupValue:
                                                          issueTrackerController
                                                              .selectedValue22,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          issueTrackerController
                                                                  .selectedValue22 =
                                                              value as String?;
                                                        });
                                                      },
                                                    ),
                                                     Text('other'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (issueTrackerController
                                                .radioFieldError24)
                                               Padding(
                                                padding:
                                                    EdgeInsets.only(left: 16.0),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Please select an option',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                          ],

                                          if (issueTrackerController
                                                  .selectedValue22 ==
                                              'Dot damaged/missing') ...[
                                            LabelText(
                                              label:
                                                  'Enter number of missing/damaged Dot devices',
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            CustomTextFormField(
                                              textController:
                                                  issueTrackerController
                                                      .dotDeviceMissingController,
                                              showCharacterCount: true,
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                          ],

                                          if (issueTrackerController
                                                  .selectedValue22 ==
                                              'Dot not configured') ...[
                                            LabelText(
                                              label:
                                                  'Enter number of not Configured Dot devices',
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            CustomTextFormField(
                                              textController: issueTrackerController
                                                  .dotDeviceNotConfiguredController,
                                              showCharacterCount: true,
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                          ],

                                          if (issueTrackerController
                                                  .selectedValue22 ==
                                              'Dot not connecting') ...[
                                            LabelText(
                                              label:
                                                  'Enter number of not Connecting Dot devices',
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            CustomTextFormField(
                                              textController: issueTrackerController
                                                  .dotDeviceNotConnectingController,
                                              showCharacterCount: true,
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                          ],

                                          if (issueTrackerController
                                                  .selectedValue22 ==
                                              'Dot not charging') ...[
                                            LabelText(
                                              label:
                                                  'Enter number of not Charging Dot devices',
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            CustomTextFormField(
                                              textController: issueTrackerController
                                                  .dotDeviceNotChargingController,
                                              showCharacterCount: true,
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                          ],

                                          if (issueTrackerController
                                                  .selectedValue22 ==
                                              'other') ...[
                                            LabelText(
                                              label:
                                                  'Please Specify the other issues',
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            CustomTextFormField(
                                              textController: issueTrackerController
                                                  .otherSolarDescriptionController,
                                              showCharacterCount: true,
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                          ],

                                          LabelText(
                                            label:
                                                '1.1.2) Click an image related to the selected issue',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10.0),
                                              border: Border.all(
                                                  width: 2,
                                                  color:
                                                  issueTrackerController.isImageUploaded5 == false
                                                      ? AppColors.primary
                                                      : AppColors.error),
                                            ),
                                            child: ListTile(
                                                title:
                                                issueTrackerController.isImageUploaded5 == false
                                                    ?  Text(
                                                  'Click or Upload Image',
                                                )
                                                    :  Text(
                                                  'Click or Upload Image',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .error),
                                                ),
                                                trailing:  Icon(
                                                    Icons.camera_alt,
                                                    color:
                                                    AppColors.onBackground),
                                                onTap: () {
                                                  showModalBottomSheet(
                                                      backgroundColor:
                                                      AppColors.primary,
                                                      context: context,
                                                      builder: ((builder) =>
                                                          issueTrackerController
                                                              .bottomSheet5(
                                                              context)));
                                                }),
                                          ),
                                          ErrorText(
                                            isVisible: issueTrackerController.validateRegister5,
                                            message:
                                            'library Register Image Required',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          issueTrackerController
                                              .multipleImage5.isNotEmpty
                                              ? Container(
                                            width: responsive
                                                .responsiveValue(
                                                small: 600.0,
                                                medium: 900.0,
                                                large: 1400.0),
                                            height: responsive
                                                .responsiveValue(
                                                small: 170.0,
                                                medium: 170.0,
                                                large: 170.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  10),
                                            ),
                                            child:
                                            issueTrackerController
                                                .multipleImage5
                                                .isEmpty
                                                ?  Center(
                                              child: Text(
                                                  'No images selected.'),
                                            )
                                                : ListView.builder(
                                              scrollDirection:
                                              Axis.horizontal,
                                              itemCount:
                                              issueTrackerController
                                                  .multipleImage5
                                                  .length,
                                              itemBuilder:
                                                  (context,
                                                  index) {
                                                return SizedBox(
                                                  height: 200,
                                                  width: 200,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:  EdgeInsets
                                                            .all(
                                                            8.0),
                                                        child:
                                                        GestureDetector(
                                                          onTap:
                                                              () {
                                                            CustomImagePreview5.showImagePreview5(issueTrackerController.multipleImage5[index].path,
                                                                context);
                                                          },
                                                          child:
                                                          Image.file(
                                                            File(issueTrackerController.multipleImage5[index].path),
                                                            width:
                                                            190,
                                                            height:
                                                            120,
                                                            fit:
                                                            BoxFit.fill,
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap:
                                                            () {
                                                          setState(
                                                                  () {
                                                                issueTrackerController.multipleImage5.removeAt(index);
                                                              });
                                                        },
                                                        child:
                                                         Icon(
                                                          Icons
                                                              .delete,
                                                          color:
                                                          Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                              :  SizedBox(),
                                          CustomSizedBox(
                                            value: 40,
                                            side: 'height',
                                          ),

                                          LabelText(
                                            label:
                                                '1.1.3) Write brief description related to the selected issue',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          CustomTextFormField(
                                            textController:
                                                issueTrackerController
                                                    .alexaDescriptionController,
                                            maxlines: 3,
                                            labelText: 'Write Description',
                                            showCharacterCount: true,
                                          ),

                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),

                                          LabelText(
                                            label: '4) Issue Reported On',
                                            astrick: true,
                                          ),

                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          TextField(
                                            controller: issueTrackerController
                                                .dateController9,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              labelText: 'Select Date',
                                              errorText: issueTrackerController
                                                      .dateFieldError9
                                                  ? 'Date is required'
                                                  : null,
                                              suffixIcon: IconButton(
                                                icon:  Icon(
                                                    Icons.calendar_today),
                                                onPressed: () {
                                                  _selectDate(context,
                                                      9); // Pass index 6 for dateController6
                                                },
                                              ),
                                            ),
                                            onTap: () {
                                              _selectDate(context,
                                                  9); // Pass index 6 for dateController6
                                            },
                                          ),

                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),

                                          LabelText(
                                            label: '5) Issue Reported By',
                                            astrick: true,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Teacher',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue20,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue20 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Teacher'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        'HeadMaster/Incharge',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue20,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue20 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      'HeadMaster/Incharge'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'SMC/VEC',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue20,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue20 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('SMC/VEC'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value:
                                                        '17000ft Team Member',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue20,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue20 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text(
                                                      '17000ft Team Member'),
                                                ],
                                              ),
                                            ],
                                          ),

                                          if (issueTrackerController
                                              .radioFieldError20)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),

                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label: '6) Issue Status',
                                            astrick: true,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Open',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue21,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue21 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Open'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio(
                                                    value: 'Closed',
                                                    groupValue:
                                                        issueTrackerController
                                                            .selectedValue21,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        issueTrackerController
                                                                .selectedValue21 =
                                                            value as String?;
                                                      });
                                                    },
                                                  ),
                                                   Text('Closed'),
                                                ],
                                              ),
                                            ],
                                          ),

                                          if (issueTrackerController
                                              .radioFieldError21)
                                             Padding(
                                              padding:
                                                  EdgeInsets.only(left: 16.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Please select an option',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ),
                                          if (issueTrackerController
                                                  .selectedValue21 ==
                                              'Closed') ...[
                                            LabelText(
                                              label: '7) Issue resolved On',
                                              astrick: true,
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            TextField(
                                              controller: issueTrackerController
                                                  .dateController10,
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                labelText: 'Select Date',
                                                errorText:
                                                    issueTrackerController
                                                            .dateFieldError10
                                                        ? 'Date is required'
                                                        : null,
                                                suffixIcon: IconButton(
                                                  icon:  Icon(
                                                      Icons.calendar_today),
                                                  onPressed: () {
                                                    _selectDate(context,
                                                        10); // Pass index 6 for dateController6
                                                  },
                                                ),
                                              ),
                                              onTap: () {
                                                _selectDate(context,
                                                    10); // Pass index 6 for dateController6
                                              },
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            LabelText(
                                              label: '8) Issue Resolved By',
                                              astrick: true,
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            DropdownButton<String>(
                                              value: _selectedStaff5,
                                              hint: Container(
                                                padding: EdgeInsets.symmetric(vertical: 12), // Add padding for better appearance
                                                child: Text(
                                                  'Select a staff member',
                                                  style: TextStyle(
                                                    color: Colors.grey, // Hint text color
                                                    fontSize: 16, // Hint text size
                                                    fontWeight: FontWeight.w500, // Hint text weight
                                                  ),
                                                ),
                                              ),
                                              items: issueTrackerController.filteredStaffNames.map((staff) {
                                                return DropdownMenuItem<String>(
                                                  value: staff,
                                                  child: Padding(
                                                    padding:  EdgeInsets.symmetric(vertical: 12), // Add padding for each item
                                                    child: Text(
                                                      staff,
                                                      style: TextStyle(
                                                        fontSize: 16, // Item text size
                                                        color: Colors.black, // Item text color
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _selectedStaff5 = newValue; // Update selected staff
                                                });
                                              },
                                              isExpanded: true, // Expand the dropdown to fill the available space
                                              style: TextStyle(color: Colors.black, fontSize: 16), // Set the text style of the selected item
                                              underline: Container(
                                                height: 1, // Underline thickness
                                                color: Colors.grey, // Underline color
                                              ),
                                              icon: Icon(Icons.arrow_drop_down), // Custom dropdown icon
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                          ], // for select value 17

                                          ElevatedButton(
                                            onPressed: _addIssue5,
                                            child: Text('Add Issue'),
                                          ),
                                        ]
                                      ],
                                      if (issueTrackerController
                                              .selectedValue18 !=
                                          'Yes') ...[
                                        Row(
                                          children: [
                                            CustomButton(
                                                title: 'Back',
                                                onPressedButton: () {
                                                  setState(() {
                                                    issueTrackerController
                                                        .showClassroom = true;
                                                    issueTrackerController
                                                        .showAlexa = false;
                                                  });
                                                }),
                                             Spacer(),
                                            CustomButton(
                                                title: 'Submit',
                                                onPressedButton: () async {
                                                  setState(() {
                                                    // Only validate radioFieldError18 if the office is NOT 'Sikkim'
                                                    if (controller.office != 'Sikkim') {
                                                      issueTrackerController.radioFieldError18 = issueTrackerController.selectedValue18 == null || issueTrackerController.selectedValue18!.isEmpty;
                                                    } else {
                                                      issueTrackerController.radioFieldError18 = false; // No validation for Sikkim
                                                    }
                                                  });

                                                  if (_formKey.currentState!
                                                      .validate() &&
                                                      !issueTrackerController
                                                          .radioFieldError18) {
                                                    final selectController =
                                                    Get.put(SelectController());
                                                    String? lockedTourId =
                                                        selectController.lockedTourId;

                                                    // Use lockedTourId if it is available, otherwise use the selected tour ID from schoolEnrolmentController
                                                    String tourIdToInsert =
                                                        lockedTourId ??
                                                            issueTrackerController
                                                                .tourValue ??
                                                            '';
                                                    DateTime now =
                                                        DateTime.now();
                                                    String formattedDate =
                                                        DateFormat('yyyy-MM-dd')
                                                            .format(now);

                                                    // Call the _addIssue method to validate and get issue data
                                                    _addIssue();

                                                    // Check if all necessary fields are populated before creating the objects
                                                    if (issueTrackerController
                                                                .selectedValue2 !=
                                                            null &&
                                                        issueTrackerController
                                                                .selectedValue3 !=
                                                            null) {
                                                      // Create IssueTrackerRecords object
                                                      IssueTrackerRecords
                                                          basicIssueObj =
                                                          IssueTrackerRecords(
                                                        tourId:
                                                        tourIdToInsert,
                                                        school:
                                                            issueTrackerController
                                                                    .schoolValue ??
                                                                '',
                                                        udiseCode:
                                                            issueTrackerController
                                                                .selectedValue!,
                                                        correctUdise:
                                                            issueTrackerController
                                                                .correctUdiseCodeController
                                                                .text,
                                                        createdAt: formattedDate
                                                            .toString(),
                                                        created_by: widget
                                                            .userid
                                                            .toString(),
                                                        office: widget.office
                                                            .toString(), // Add null check and default value
                                                        uniqueId:
                                                            uniqueId, // Add unique ID here
                                                      );

// For the Library
                                                      // Create LibIssue object(s) from lib_issuesList
                                                      List<LibIssue> libIssues =
                                                          lib_issuesList
                                                              .map((issueData) {
                                                        return LibIssue(
                                                          issueExist: issueData[
                                                              'lib_issue'],
                                                          issueName: issueData[
                                                              'lib_issue_value'],
                                                          issueDescription:
                                                              issueData[
                                                                  'lib_desc'],
                                                          issueReportOn:
                                                              issueData[
                                                                  'reported_on'],
                                                          issueResolvedOn:
                                                              issueData[
                                                                  'resolved_on'],
                                                          issueReportBy:
                                                              issueData[
                                                                  'reported_by'],
                                                          issueResolvedBy:
                                                              issueData[
                                                                  'resolved_by'],
                                                          issueStatus: issueData[
                                                              'issue_status'],
                                                          lib_issue_img: issueData[
                                                              'lib_issue_img'],
                                                          uniqueId: issueData[
                                                              'unique_id'],
                                                        );
                                                      }).toList();

                                                      //for the Playground issue
                                                      List<PlaygroundIssue>
                                                          playgroundIssueObj =
                                                          issuesList2
                                                              .map((issueData) {
                                                        return PlaygroundIssue(
                                                          issueExist: issueData[
                                                              'play_issue'],
                                                          issueName: issueData[
                                                              'play_issue_value'],
                                                          issueDescription:
                                                              issueData[
                                                                  'play_desc'],
                                                          issueReportOn:
                                                              issueData[
                                                                  'reported_on'],
                                                          issueResolvedOn:
                                                              issueData[
                                                                  'resolved_on'],
                                                          issueReportBy:
                                                              issueData[
                                                                  'reported_by'],
                                                          issueResolvedBy:
                                                              issueData[
                                                                  'resolved_by'],
                                                          issueStatus: issueData[
                                                              'issue_status'],
                                                          play_issue_img: issueData[
                                                              'play_issue_img'],
                                                          uniqueId: issueData[
                                                              'unique_id'],
                                                        );
                                                      }).toList();

                                                      // for the digiLab
                                                      List<DigiLabIssue>
                                                          digiLabIssueObj =
                                                          issuesList3
                                                              .map((issueData) {
                                                        return DigiLabIssue(
                                                          issueExist: issueData[
                                                              'issue'],
                                                          issueName:
                                                              issueData['part'],
                                                          issueDescription:
                                                              issueData[
                                                                  'description'],
                                                          issueReportOn:
                                                              issueData[
                                                                  'reportedOn'],
                                                          issueResolvedOn:
                                                              issueData[
                                                                  'resolvedOn'],
                                                          issueReportBy:
                                                              issueData[
                                                                  'reportedBy'],
                                                          issueResolvedBy:
                                                              issueData[
                                                                  'resolvedBy'],
                                                          issueStatus:
                                                              issueData[
                                                                  'status'],
                                                          tabletNumber: issueData[
                                                              'tabletNumber'],
                                                          dig_issue_img:
                                                              issueData[
                                                                  'images'],
                                                          uniqueId: issueData[
                                                              'unique_id'],
                                                        );
                                                      }).toList();

// for the Furniture
                                                      List<FurnitureIssue>
                                                          furnitureIssueObj =
                                                          issuesList4
                                                              .map((issueData) {
                                                        return FurnitureIssue(
                                                          issueExist: issueData[
                                                              'issue'],
                                                          issueName:
                                                              issueData['part'],
                                                          issueDescription:
                                                              issueData[
                                                                  'description'],
                                                          issueReportOn:
                                                              issueData[
                                                                  'reportedOn'],
                                                          issueResolvedOn:
                                                              issueData[
                                                                  'resolvedOn'],
                                                          issueReportBy:
                                                              issueData[
                                                                  'reportedBy'],
                                                          issueResolvedBy:
                                                              issueData[
                                                                  'resolvedBy'],
                                                          issueStatus:
                                                              issueData[
                                                                  'status'],
                                                          furn_issue_img:
                                                              issueData[
                                                                  'images'],
                                                          uniqueId: issueData[
                                                              'unique_id'],
                                                        );
                                                      }).toList();

                                                      // for alexa
                                                      List<AlexaIssue>
                                                          alexaIssueObj =
                                                          issuesList5
                                                              .map((issueData) {
                                                        return AlexaIssue(
                                                          issueExist: issueData[
                                                              'issue'],
                                                          issueName:
                                                              issueData['part'],
                                                          issueDescription:
                                                              issueData[
                                                                  'description'],
                                                          issueReportOn:
                                                              issueData[
                                                                  'reportedOn'],
                                                          issueResolvedOn:
                                                              issueData[
                                                                  'resolvedOn'],
                                                          issueReportBy:
                                                              issueData[
                                                                  'reportedBy'],
                                                          issueResolvedBy:
                                                              issueData[
                                                                  'resolvedBy'],
                                                          issueStatus:
                                                              issueData[
                                                                  'status'],
                                                          other: issueData[
                                                              'other'],
                                                          missingDot: issueData[
                                                              'missingDot'],
                                                          notConfiguredDot:
                                                              issueData[
                                                                  'notConfiguredDot'],
                                                          notConnectingDot:
                                                              issueData[
                                                                  'notConnectingDot'],
                                                          notChargingDot: issueData[
                                                              'notChargingDot'],
                                                          alexa_issue_img:
                                                              issueData[
                                                                  'images'],
                                                          uniqueId: issueData[
                                                              'unique_id'],
                                                        );
                                                      }).toList();

                                                      // Save data to local database
                                                      int result =
                                                          await LocalDbController()
                                                              .addData(
                                                        issueTrackerRecords:
                                                            basicIssueObj,
                                                        libIssues: libIssues,
                                                        playgroundIssues:
                                                            playgroundIssueObj,
                                                        digiLabIssues:
                                                            digiLabIssueObj,
                                                        furnitureIssues:
                                                            furnitureIssueObj,
                                                        alexaIssues:
                                                            alexaIssueObj,
                                                      );

                                                      if (result > 0) {
                                                        issueTrackerController
                                                            .clearFields();
                                                        setState(() {});

                                                        // Call the function to save data to a file
                                                        await saveIssuesToFile(
                                                          basicIssueObj,
                                                          libIssues,
                                                          playgroundIssueObj,
                                                          digiLabIssueObj,
                                                          furnitureIssueObj,
                                                          alexaIssueObj,
                                                        ).then((_) {
                                                          // If successful, show a snackbar indicating the file was downloaded
                                                          customSnackbar(
                                                            'File downloaded successfully',
                                                            'Downloaded',
                                                            AppColors.primary,
                                                            AppColors.onPrimary,
                                                            Icons
                                                                .file_download_done,
                                                          );
                                                        }).catchError((error) {
                                                          // If there's an error during download, show an error snackbar
                                                          customSnackbar(
                                                            'Error',
                                                            'File download failed: $error',
                                                            AppColors.primary,
                                                            AppColors.onPrimary,
                                                            Icons.error,
                                                          );
                                                        });
                                                      }

                                                      customSnackbar(
                                                        'Submitted Successfully',
                                                        'submitted',
                                                        AppColors.primary,
                                                        AppColors.onPrimary,
                                                        Icons.verified,
                                                      );
                                                      // Navigate to HomeScreen
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                 HomeScreen()),
                                                      );
                                                    } else {
                                                      customSnackbar(
                                                        'Error',
                                                        'Something went wrong',
                                                        AppColors.primary,
                                                        AppColors.onPrimary,
                                                        Icons.error,
                                                      );
                                                    }
                                                  } else {
                                                    customSnackbar(
                                                      'Error',
                                                      'Please fill out all required fields',
                                                      AppColors.primary,
                                                      AppColors.onPrimary,
                                                      Icons.error,
                                                    );
                                                  }
                                                })
                                          ],
                                        ),
                                      ],
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ), // selectvalue14
                                    ], //end of alexa
                                  ]);
                                }));
                      })
                ]))),
        floatingActionButton: issueTrackerController.showLibrary
            ? IssuesFloatingButton(
                issuesList: lib_issuesList,
                onDelete: (index) {
                  setState(() {
                    lib_issuesList.removeAt(index);
                  });
                },
              )
            : issueTrackerController.showPlayground
                ? IssuesFloatingButton2(
                    issuesList2: issuesList2,
                    onDelete: (index) {
                      setState(() {
                        issuesList2.removeAt(index);
                      });
                    },
                  )
                : issueTrackerController.showDigiLab
                    ? IssuesFloatingButton3(
                        issuesList3: issuesList3,
                        onDelete: (index) {
                          setState(() {
                            issuesList3.removeAt(index);
                          });
                        },
                      )
                    : issueTrackerController.showClassroom
                        ? IssuesFloatingButton4(
                            issuesList4: issuesList4,
                            onDelete: (index) {
                              setState(() {
                                issuesList4.removeAt(index);
                              });
                            },
                          )
                        : issueTrackerController.showAlexa
                            ? IssuesFloatingButton5(
                                issuesList5: issuesList5,
                                onDelete: (index) {
                                  setState(() {
                                    issuesList5.removeAt(index);
                                  });
                                },
                              )
                            : null,
      ),
    );
  }
}

class IssuesFloatingButton extends StatelessWidget {
  final List<Map<String, dynamic>> issuesList;
  final Function(int) onDelete; // Callback to handle delete action

  IssuesFloatingButton({required this.issuesList, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              children: [
                AppBar(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Library Issue List',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Text(
                        'Total Issues: ${issuesList.length}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  elevation: 0, // Optional: remove shadow
                  automaticallyImplyLeading:
                      false, // Prevent the default back button
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: issuesList.length,
                    itemBuilder: (context, index) {
                      final issue = issuesList[index];
                      return ListTile(
                        title: Text(
                          '1) Issue: ${issue['lib_issue_value'] ?? "N/A"}\n'
                          '2) Description: ${issue['lib_desc'] ?? "N/A"}\n'

                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Navigator.pop(context); // Close bottom sheet
                            onDelete(index); // Notify parent to remove item
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Icon(
        Icons.list,
        color: Colors.white,
      ),
      backgroundColor: AppColors.primary,
    );
  }
}

class IssuesFloatingButton2 extends StatelessWidget {
  final List<Map<String, dynamic>> issuesList2;
  final Function(int) onDelete; // Callback to handle delete action

  IssuesFloatingButton2({required this.issuesList2, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              children: [
                AppBar(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Playground Issue List',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Text(
                        'Total Issues: ${issuesList2.length}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  elevation: 0, // Optional: remove shadow
                  automaticallyImplyLeading:
                      false, // Prevent the default back button
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: issuesList2.length,
                    itemBuilder: (context, index) {
                      final issue = issuesList2[index];
                      return ListTile(
                        title: Text(
                          '1) Issue: ${issue['play_issue_value']}\n'
                          '2) Description: ${issue['play_desc']}\n'
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Navigator.pop(context); // Close bottom sheet
                            onDelete(index); // Notify parent to remove item
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Icon(
        Icons.list,
        color: Colors.white,
      ),
      backgroundColor: AppColors.primary,
    );
  }
}

class IssuesFloatingButton3 extends StatelessWidget {
  final List<Map<String, dynamic>> issuesList3;
  final Function(int) onDelete; // Callback to handle delete action

  IssuesFloatingButton3({required this.issuesList3, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              children: [
                AppBar(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'DigiLab Issue List',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Text(
                        'Total Issues: ${issuesList3.length}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  elevation: 0, // Optional: remove shadow
                  automaticallyImplyLeading:
                      false, // Prevent the default back button
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: issuesList3.length,
                    itemBuilder: (context, index) {
                      final issue = issuesList3[index];
                      return ListTile(
                        title: Text(
                            '1) Issue: ${issue['part']}\n'
                            '2) Description: ${issue['description']}\n'

                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Navigator.pop(context); // Close bottom sheet
                            onDelete(index); // Notify parent to remove item
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Icon(
        Icons.list,
        color: Colors.white,
      ),
      backgroundColor: AppColors.primary,
    );
  }
}

class IssuesFloatingButton4 extends StatelessWidget {
  final List<Map<String, dynamic>> issuesList4;
  final Function(int) onDelete; // Callback to handle delete action

  IssuesFloatingButton4({required this.issuesList4, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              children: [
                AppBar(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Classroom Issue List',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Text(
                        'Total Issues: ${issuesList4.length}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  elevation: 0, // Optional: remove shadow
                  automaticallyImplyLeading:
                      false, // Prevent the default back button
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: issuesList4.length,
                    itemBuilder: (context, index) {
                      final issue = issuesList4[index];
                      return ListTile(
                        title: Text(
                            '1) Issue: ${issue['part']}\n'
                            '2) Description: ${issue['description']}\n'

                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Navigator.pop(context); // Close bottom sheet
                            onDelete(index); // Notify parent to remove item
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Icon(
        Icons.list,
        color: Colors.white,
      ),
      backgroundColor: AppColors.primary,
    );
  }
}

class IssuesFloatingButton5 extends StatelessWidget {
  final List<Map<String, dynamic>> issuesList5;
  final Function(int) onDelete; // Callback to handle delete action

  IssuesFloatingButton5({required this.issuesList5, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              children: [
                AppBar(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Alexa Issue List',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Text(
                        'Total Issues: ${issuesList5.length}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  elevation: 0, // Optional: remove shadow
                  automaticallyImplyLeading:
                      false, // Prevent the default back button
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: issuesList5.length,
                    itemBuilder: (context, index) {
                      final issue = issuesList5[index];
                      return ListTile(
                        title: Text(
                            '1) Issue: ${issue['part']}\n'
                            '2) Description: ${issue['description']}\n'

                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Navigator.pop(context); // Close bottom sheet
                            onDelete(index); // Notify parent to remove item
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Icon(
        Icons.list,
        color: Colors.white,
      ),
      backgroundColor: AppColors.primary,
    );
  }
}

class UniqueIdGenerator {
  static String generate(int length) {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}


Future<void> saveIssuesToFile(
    IssueTrackerRecords issueRecord,
    List<LibIssue> libIssues,
    List<PlaygroundIssue> playgroundIssues,
    List<DigiLabIssue> digiLabIssues,
    List<FurnitureIssue> furnitureIssues,
    List<AlexaIssue> alexaIssues,
    ) async {
  try {
    // Request storage permissions
    var permissionGranted = await _requestStoragePermission();
    if (permissionGranted) {
      // Determine the correct storage directory based on the platform
      Directory? directory;

      if (Platform.isAndroid) {
        directory = await _getAndroidDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create the directory if it doesn't exist
      if (directory != null && !await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Prepare the path for the file
      final path =
          '${directory!.path}/issue_tracker_${issueRecord.uniqueId}.txt';

      // Function to convert image file to Base64
      Future<String?> convertImageToBase64(String? imagePath) async {
        if (imagePath == null) return null;
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          return base64Encode(bytes);
        }
        return null;
      }

      // Combine all objects into one JSON structure with Base64 images
      Map<String, dynamic> dataToSave = {
        'issueRecord': issueRecord.toJson(),
        'libIssues': await Future.wait(libIssues.map((issue) async {
          String? base64Image = await convertImageToBase64(issue.lib_issue_img);
          return {
            ...issue.toJson(),
            'lib_issue_img': base64Image,
          };
        })),
        'playgroundIssues': await Future.wait(playgroundIssues.map((issue) async {
          String? base64Image =
          await convertImageToBase64(issue.play_issue_img);
          return {
            ...issue.toJson(),
            'play_issue_img': base64Image,
          };
        })),
        'digiLabIssues': await Future.wait(digiLabIssues.map((issue) async {
          String? base64Image = await convertImageToBase64(issue.dig_issue_img);
          return {
            ...issue.toJson(),
            'dig_issue_img': base64Image,
          };
        })),
        'furnitureIssues': await Future.wait(furnitureIssues.map((issue) async {
          String? base64Image =
          await convertImageToBase64(issue.furn_issue_img);
          return {
            ...issue.toJson(),
            'furn_issue_img': base64Image,
          };
        })),
        'alexaIssues': await Future.wait(alexaIssues.map((issue) async {
          String? base64Image =
          await convertImageToBase64(issue.alexa_issue_img);
          return {
            ...issue.toJson(),
            'alexa_issue_img': base64Image,
          };
        })),
      };

      // Convert the combined object to a JSON string
      String jsonString = jsonEncode(dataToSave);

      // Write the JSON string to a file
      File file = File(path);
      await file.writeAsString(jsonString);

      print('Data saved to $path');

      // Notify media scanner to make the file visible to the user (Android only)
      if (Platform.isAndroid) {
         MethodChannel channel =
        MethodChannel('com.example.app/media_scanner');
        await channel.invokeMethod('scanMedia', {'path': path});
      }
    } else {
      print('Storage permission not granted');
    }
  } catch (e) {
    print('Error saving data: $e');
  }
}

// Helper method to request storage permissions
Future<bool> _requestStoragePermission() async {
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;

    // For Android 11+ (API level 30 and above)
    if (androidInfo.version.sdkInt >= 30) {
      var manageStoragePermission = await Permission.manageExternalStorage.status;
      if (manageStoragePermission.isDenied) {
        manageStoragePermission = await Permission.manageExternalStorage.request();
        return manageStoragePermission.isGranted;
      }
      return true; // Permission already granted
    }

    // For Android 10 and below
    if (await Permission.storage.isDenied) {
      var storagePermission = await Permission.storage.request();
      return storagePermission.isGranted;
    }
  }

  // For iOS and other platforms, permission is not needed
  return true;
}

// Method to get Android directory based on version
Future<Directory?> _getAndroidDirectory() async {
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;

    // Handle Android 11+ (API level 30 and above)
    if (androidInfo.version.sdkInt >= 30 &&
        await Permission.manageExternalStorage.isGranted) {
      return Directory('/storage/emulated/0/Download');
    }

    // For Android 10 and below, use external storage directory
    return await getExternalStorageDirectory();
  }
  return null;
}
