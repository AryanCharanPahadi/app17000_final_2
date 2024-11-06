import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

import 'package:intl/intl.dart';
import 'package:app17000ft_new/components/custom_appBar.dart';
import 'package:app17000ft_new/components/custom_button.dart';
import 'package:app17000ft_new/components/custom_imagepreview.dart';
import 'package:app17000ft_new/components/custom_snackbar.dart';
import 'package:app17000ft_new/components/custom_textField.dart';
import 'package:app17000ft_new/components/error_text.dart';
import 'package:app17000ft_new/constants/color_const.dart';

import 'package:app17000ft_new/helper/database_helper.dart';
import 'package:app17000ft_new/helper/responsive_helper.dart';
import 'package:app17000ft_new/tourDetails/tour_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:app17000ft_new/components/custom_dropdown.dart';
import 'package:app17000ft_new/components/custom_labeltext.dart';
import 'package:app17000ft_new/components/custom_sizedBox.dart';

import 'package:app17000ft_new/home/home_screen.dart';

import '../../components/custom_confirmation.dart';
import '../select_tour_id/select_controller.dart';
import 'in_person_quantitative_controller.dart';
import 'in_person_quantitative_modal.dart';
import 'in_person_quantitative_sync.dart';

class InPersonQuantitative extends StatefulWidget {
  String? userid;
  String? office;
  // final InPersonQuantitativeRecords? existingRecord;
  InPersonQuantitative({
    super.key,
    this.userid,
    this.office,
    // this.existingRecord,
  });

  @override
  State<InPersonQuantitative> createState() => _InPersonQuantitativeState();
}

class _InPersonQuantitativeState extends State<InPersonQuantitative> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    print('Office init ${widget.office}');
  }

  // For managing issues and resolutions
  List<Issue> issues = [];

  void _addIssue() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows BottomSheet to resize when the keyboard pops up
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
        ),
        child: SingleChildScrollView(
          child: AddIssueBottomSheet(),
        ),
      ),
    );

    if (result != null && result is Issue) {
      setState(() {
        issues.add(result);
      });
    }
  }

  void _deleteIssue(int index) {
    setState(() {
      issues.removeAt(index);
    });
  }

  final InPersonQuantitativeController inPersonQuantitativeController =
      Get.put(InPersonQuantitativeController());

  List<Participants> participants = [];
  bool showError = false;
  String errorMessage = '';

  void _addParticipants() async {
    int staffAttended = int.tryParse(inPersonQuantitativeController
            .staafAttendedTrainingController.text) ??
        0;

    if (staffAttended <= 0) {
      setState(() {
        showError = true;
        errorMessage = 'Please fill a number greater than 0';
      });
      return;
    }

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows BottomSheet to resize when the keyboard pops up
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
        ),
        child: SingleChildScrollView(
          child: AddParticipantsBottomSheet(
            existingRoles: participants.map((p) => p.designation).toList(),
          ),
        ),
      ),
    );

    void _showErrorDialog(String message) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: SizedBox(
              width: 300, // Adjust width for consistency
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                color: Colors.white,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Wrap(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      color: AppColors.primary, // Use the primary color
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10),
                          Icon(
                            Icons.error, // Error icon
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Invalid',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          Text(
                            message,
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            child: Text(
                              'OK',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    if (result != null && result is Participants) {
      setState(() {
        if (result.designation == 'DigiLab Admin') {
          // Check if "DigiLab Admin" already exists
          int existingIndex =
              participants.indexWhere((p) => p.designation == 'DigiLab Admin');
          if (existingIndex >= 0) {
            // Show error dialog if trying to add another "DigiLab Admin"
            _showErrorDialog(
                'No duplicate designation allowed,except for Teacher and HM,In-Charge cannot have both designations simultaneously');
          } else {
            // Add "DigiLab Admin" if it doesn't exist yet
            participants.add(result);
          }
        } else {
          // For other roles, always add a new entry (don't replace any existing participant)
          participants.add(result);
        }

        showError = false; // Reset error if participants are added successfully
        errorMessage = '';
      });
    }
  }

  void _handleStaffAttendedChange(String value) {
    int staffAttended = int.tryParse(value) ?? 0;
    setState(() {
      if (staffAttended == 0) {
        showError = true;
        errorMessage = 'Please fill a number greater than 0';
      } else {
        showError = false;
        errorMessage = '';
      }
    });
  }

  void _deleteParticipants(int index) {
    setState(() {
      participants.removeAt(index);
    });
  }

  void _onNextPressed() {
    int staffAttended = int.tryParse(inPersonQuantitativeController
            .staafAttendedTrainingController.text) ??
        0;

    // Check if staff attended is greater than 0
    if (staffAttended <= 0) {
      setState(() {
        showError = true;
        errorMessage = 'Please fill a number greater than 0';
      });
      return;
    }
    // Check if the number of participants matches the number of staff attended

    // Reset error and proceed to the next step if checks are passed
    setState(() {
      showError = false;
      errorMessage = '';
      inPersonQuantitativeController.showSchoolRefresherTraining = false;
      inPersonQuantitativeController.showDigiLabClasses = true;
    });
  }

// make this code that if user fill 0 in the staff attendend in the training then show error
  bool _isImageUploaded = false;
  bool validateRegister = false;

  bool _isImageUploaded2 = false;
  bool validateRegister2 = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now, // Disable future dates by setting this to now
    );
    if (picked != null) {
      setState(() {
        inPersonQuantitativeController.dateController.text =
            "${picked.toLocal()}".split(' ')[0];
        inPersonQuantitativeController.dateFieldError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
          appBar: CustomAppbar(
            title: 'In-Person Quantitative',
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  GetBuilder<InPersonQuantitativeController>(
                      init: InPersonQuantitativeController(),
                      builder: (inPersonQuantitativeController) {
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
                                      inPersonQuantitativeController.tourValue;

                                  // Fetch the corresponding schools if lockedTourId or selectedTourId is present
                                  if (selectedTourId != null) {
                                    inPersonQuantitativeController
                                            .splitSchoolLists =
                                        tourController.getLocalTourList
                                            .where((e) =>
                                                e.tourId == selectedTourId)
                                            .map((e) => e.allSchool!
                                                .split(',')
                                                .map((s) => s.trim())
                                                .toList())
                                            .expand((x) => x)
                                            .toList();
                                  }

                                  return Column(children: [
                                    if (inPersonQuantitativeController
                                        .showBasicDetails) ...[
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
                                        focusNode:
                                            inPersonQuantitativeController
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
                                                inPersonQuantitativeController
                                                        .splitSchoolLists =
                                                    tourController
                                                        .getLocalTourList
                                                        .where((e) =>
                                                            e.tourId == value)
                                                        .map((e) => e.allSchool!
                                                            .split(',')
                                                            .map(
                                                                (s) => s.trim())
                                                            .toList())
                                                        .expand((x) => x)
                                                        .toList();

                                                // Single setState call for efficiency
                                                setState(() {
                                                  inPersonQuantitativeController
                                                      .setSchool(null);
                                                  inPersonQuantitativeController
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
                                          disabledItemFn: (String s) =>
                                              s.startsWith(
                                                  'I'), // Disable based on condition
                                        ),
                                        items: inPersonQuantitativeController
                                            .splitSchoolLists, // Show schools based on selected or locked tour ID
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
                                            inPersonQuantitativeController
                                                .setSchool(value);
                                          });
                                        },
                                        selectedItem:
                                            inPersonQuantitativeController
                                                .schoolValue,
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth *
                                                0.1), // Responsive padding

                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'udiCode'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'udiCode', value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth *
                                                0.1), // Responsive padding

                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'udiCode'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'udiCode', value);
                                                inPersonQuantitativeController
                                                    .clearTrainingInputs();
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('udiCode'))
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
                                      if (inPersonQuantitativeController
                                              .getSelectedValue('udiCode') ==
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
                                          textController:
                                              inPersonQuantitativeController
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
                                      LabelText(
                                        label: 'Click Image of School Board',
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
                                              color: _isImageUploaded == false
                                                  ? AppColors.primary
                                                  : AppColors.error),
                                        ),
                                        child: ListTile(
                                            title: _isImageUploaded == false
                                                ? Text(
                                                    'Click or Upload Image',
                                                  )
                                                : Text(
                                                    'Click or Upload Image',
                                                    style: TextStyle(
                                                        color: AppColors.error),
                                                  ),
                                            trailing: Icon(Icons.camera_alt,
                                                color: AppColors.onBackground),
                                            onTap: () {
                                              showModalBottomSheet(
                                                  backgroundColor:
                                                      AppColors.primary,
                                                  context: context,
                                                  builder: ((builder) =>
                                                      inPersonQuantitativeController
                                                          .bottomSheet(
                                                              context, 1)));
                                            }),
                                      ),
                                      ErrorText(
                                        isVisible: validateRegister,
                                        message: 'Register Image Required',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),

                                      inPersonQuantitativeController
                                              .multipleImage.isNotEmpty
                                          ? Container(
                                              width: responsive.responsiveValue(
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
                                                  inPersonQuantitativeController
                                                          .multipleImage.isEmpty
                                                      ? Center(
                                                          child: Text(
                                                              'No images selected.'),
                                                        )
                                                      : ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              inPersonQuantitativeController
                                                                  .multipleImage
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return SizedBox(
                                                              height: 200,
                                                              width: 200,
                                                              child: Column(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        CustomImagePreview.showImagePreview(
                                                                            inPersonQuantitativeController.multipleImage[index].path,
                                                                            context);
                                                                      },
                                                                      child: Image
                                                                          .file(
                                                                        File(inPersonQuantitativeController
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
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        inPersonQuantitativeController
                                                                            .multipleImage
                                                                            .removeAt(index);
                                                                      });
                                                                    },
                                                                    child: Icon(
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
                                          : SizedBox(),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            'No of Enrolled Students as of date',
                                        astrick: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),

                                      CustomTextFormField(
                                        textController:
                                            inPersonQuantitativeController
                                                .noOfEnrolledStudentAsOnDateController,
                                        labelText: 'Enter Enrolled number',
                                        textInputType: TextInputType.number,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(3),
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
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
                                      CustomButton(
                                        title: 'Next',
                                        onPressedButton: () {
                                          final isRadioValid1 =
                                              inPersonQuantitativeController
                                                  .validateRadioSelection(
                                                      'udiCode');
                                          setState(() {
                                            validateRegister =
                                                inPersonQuantitativeController
                                                    .multipleImage.isEmpty;
                                          });

                                          if (_formKey.currentState!
                                                  .validate() &&
                                              isRadioValid1 &&
                                              !validateRegister) {
                                            setState(() {
                                              inPersonQuantitativeController
                                                  .showBasicDetails = false;
                                              inPersonQuantitativeController
                                                  .showBasicDetails = false;
                                              inPersonQuantitativeController
                                                  .showDigiLabSchedule = true;
                                            });
                                          }
                                        },
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ],
                                    // Ends of Add Basic Details
                                    if (inPersonQuantitativeController
                                        .showDigiLabSchedule) ...[
                                      LabelText(
                                        // Start of DigiLab Schedule
                                        label: 'DigiLab Schedule',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '1. Is DigiLab Schedule/timetable available?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth *
                                                0.1), // Responsive padding

                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'digiLabSchedule'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'digiLabSchedule',
                                                        value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth *
                                                0.1), // Responsive padding

                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'digiLabSchedule'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'digiLabSchedule',
                                                        value);
                                                if (value == 'No') {
                                                  inPersonQuantitativeController
                                                      .clearRadioValue(
                                                          'class2Hours');
                                                }
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError(
                                              'digiLabSchedule'))
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
                                      if (inPersonQuantitativeController
                                              .getSelectedValue(
                                                  'digiLabSchedule') ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '1.1. Each class scheduled for 2 hours per week?',
                                          astrick: true,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: screenWidth *
                                                  0.1), // Responsive padding

                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'Yes',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'class2Hours'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'class2Hours', value);
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
                                          padding: EdgeInsets.only(
                                              right: screenWidth *
                                                  0.1), // Responsive padding

                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'No',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'class2Hours'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'class2Hours', value);
                                                },
                                              ),
                                              Text('No'),
                                            ],
                                          ),
                                        ),
                                        if (inPersonQuantitativeController
                                            .getRadioFieldError('class2Hours'))
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

                                      LabelText(
                                        label:
                                            '1.1.1 Describe in brief instructions provided regarding class scheduling',
                                        astrick: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      CustomTextFormField(
                                        textController:
                                            inPersonQuantitativeController
                                                .instructionProvidedRegardingClassSchedulingController,
                                        maxlines: 2,
                                        labelText: 'Write Description',
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please fill this field';
                                          }

                                          if (value.length < 25) {
                                            return 'Description must be at least 25 characters long';
                                          }
                                          return null;
                                        },
                                        showCharacterCount: true,
                                      ),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),

                                      Row(
                                        children: [
                                          CustomButton(
                                              title: 'Back',
                                              onPressedButton: () {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                      .showBasicDetails = true;
                                                  inPersonQuantitativeController
                                                          .showDigiLabSchedule =
                                                      false;
                                                });
                                              }),
                                          Spacer(),
                                          CustomButton(
                                            title: 'Next',
                                            onPressedButton: () {
                                              // Get the value of the 'digiLabSchedule' radio button
                                              final digiLabScheduleValue =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'digiLabSchedule');

                                              bool isRadioValid3 =
                                                  true; // Default to true

                                              // Only validate 'class2Hours' if 'digiLabSchedule' is 'yes'
                                              if (inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'digiLabSchedule') ==
                                                  'Yes') {
                                                isRadioValid3 =
                                                    inPersonQuantitativeController
                                                        .validateRadioSelection(
                                                            'class2Hours');
                                              }

                                              // Validate form and radio button conditions
                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  digiLabScheduleValue !=
                                                      null &&
                                                  isRadioValid3) {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showDigiLabSchedule =
                                                      false;
                                                  inPersonQuantitativeController
                                                          .showTeacherCapacity =
                                                      true;
                                                });
                                              }
                                            },
                                          )
                                        ],
                                      ),

                                      // Ends of DigiLab Schedule
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ],
                                    // Start of Teacher Capacity
                                    if (inPersonQuantitativeController
                                        .showTeacherCapacity) ...[
                                      LabelText(
                                        label: 'Teacher Capacity',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label: '1. Is DigiLab admin appointed?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth *
                                                0.1), // Responsive padding

                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'isDigiLabAdminAppointed'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'isDigiLabAdminAppointed',
                                                        value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth *
                                                0.1), // Responsive padding

                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'isDigiLabAdminAppointed'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'isDigiLabAdminAppointed',
                                                        value);
                                                if (value == 'No') {
                                                  inPersonQuantitativeController
                                                      .clearRadioValue(
                                                          'isDigiLabAdminTrained');
                                                  inPersonQuantitativeController
                                                      .digiLabAdminNameController
                                                      .clear();
                                                  inPersonQuantitativeController
                                                      .digiLabAdminPhoneNumberController
                                                      .clear();
                                                }
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError(
                                              'isDigiLabAdminAppointed'))
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
                                      if (inPersonQuantitativeController
                                              .getSelectedValue(
                                                  'isDigiLabAdminAppointed') ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '1.1. Is Digilab admin trained?',
                                          astrick: true,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: screenWidth *
                                                  0.1), // Responsive padding

                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'Yes',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'isDigiLabAdminTrained'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'isDigiLabAdminTrained',
                                                          value);
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
                                          padding: EdgeInsets.only(
                                              right: screenWidth *
                                                  0.1), // Responsive padding

                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'No',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'isDigiLabAdminTrained'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'isDigiLabAdminTrained',
                                                          value);
                                                },
                                              ),
                                              Text('No'),
                                            ],
                                          ),
                                        ),
                                        if (inPersonQuantitativeController
                                            .getRadioFieldError(
                                                'isDigiLabAdminTrained'))
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
                                          label: '1.1.1 Name of DigiLab admin?',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                              inPersonQuantitativeController
                                                  .digiLabAdminNameController,
                                          labelText: 'Name of admin',
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Write Admin Name';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: '1.1.2 Phone number of admin?',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                              inPersonQuantitativeController
                                                  .digiLabAdminPhoneNumberController,
                                          labelText: 'Phone number of admin',
                                          textInputType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly, // Restrict input to only digits
                                          ],
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Write Admin Name';
                                            }

                                            // Regex for validating Indian phone number
                                            String pattern = r'^[6-9]\d{9}$';
                                            RegExp regex = RegExp(pattern);

                                            if (!regex.hasMatch(value)) {
                                              return 'Enter a valid phone number';
                                            }

                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                      ],
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '2. Are all the subject teacher trained?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth *
                                                0.1), // Responsive padding

                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'areAllTeacherTrained'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'areAllTeacherTrained',
                                                        value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth *
                                                0.1), // Responsive padding

                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'areAllTeacherTrained'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'areAllTeacherTrained',
                                                        value);
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError(
                                              'areAllTeacherTrained'))
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
                                      LabelText(
                                        label:
                                            '3. Have teacher Ids been created and used on the tabs?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'idHasBeenCreated'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'idHasBeenCreated',
                                                        value);
                                                setState(
                                                    () {}); // Triggers UI update
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'idHasBeenCreated'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'idHasBeenCreated',
                                                        value);
                                                if (value == 'No') {
                                                  inPersonQuantitativeController
                                                      .clearRadioValue(
                                                          'teacherUsingTablet');
                                                }
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError(
                                              'idHasBeenCreated'))
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
                                      if (inPersonQuantitativeController
                                              .getSelectedValue(
                                                  'idHasBeenCreated') ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '3.1. Are the teachers comfortable using the tabs and navigating the content?',
                                          astrick: true,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: screenWidth * 0.1),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'Yes',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'teacherUsingTablet'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'teacherUsingTablet',
                                                          value);
                                                  setState(
                                                      () {}); // Triggers UI update
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
                                          padding: EdgeInsets.only(
                                              right: screenWidth * 0.1),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'No',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'teacherUsingTablet'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'teacherUsingTablet',
                                                          value);
                                                  setState(
                                                      () {}); // Triggers UI update
                                                },
                                              ),
                                              Text('No'),
                                            ],
                                          ),
                                        ),
                                        if (inPersonQuantitativeController
                                            .getRadioFieldError(
                                                'teacherUsingTablet'))
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
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      Row(
                                        children: [
                                          CustomButton(
                                            title: 'Back',
                                            onPressedButton: () {
                                              setState(() {
                                                inPersonQuantitativeController
                                                    .showDigiLabSchedule = true;
                                                inPersonQuantitativeController
                                                        .showTeacherCapacity =
                                                    false;
                                              });
                                            },
                                          ),
                                          Spacer(),
                                          CustomButton(
                                            title: 'Next',
                                            onPressedButton: () {
                                              final isRadioValid4 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'isDigiLabAdminAppointed');

                                              bool isRadioValid5 =
                                                  true; // Default to true

                                              // Only validate 'class2Hours' if 'digiLabSchedule' is 'yes'
                                              if (inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'isDigiLabAdminAppointed') ==
                                                  'Yes') {
                                                isRadioValid5 =
                                                    inPersonQuantitativeController
                                                        .validateRadioSelection(
                                                            'isDigiLabAdminTrained');
                                              }

                                              final isRadioValid6 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'areAllTeacherTrained');

                                              final isRadioValid7 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'idHasBeenCreated');

                                              bool isRadioValid8 =
                                                  true; // Default to true

                                              // Only validate 'class2Hours' if 'digiLabSchedule' is 'yes'
                                              if (inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'idHasBeenCreated') ==
                                                  'Yes') {
                                                isRadioValid8 =
                                                    inPersonQuantitativeController
                                                        .validateRadioSelection(
                                                            'teacherUsingTablet');
                                              }

                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  isRadioValid4 &&
                                                  isRadioValid5 &&
                                                  isRadioValid6 &&
                                                  isRadioValid7 &&
                                                  isRadioValid8) {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showTeacherCapacity =
                                                      false;
                                                  inPersonQuantitativeController
                                                          .showSchoolRefresherTraining =
                                                      true;
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ],

                                    // Start of In School Refresher Training
                                    if (inPersonQuantitativeController
                                        .showSchoolRefresherTraining) ...[
                                      LabelText(
                                        label: 'In School Refresher Training',
                                      ),
                                      CustomSizedBox(value: 20, side: 'height'),

                                      LabelText(
                                          label:
                                              '1. How many staff attended the training?',
                                          astrick: true),
                                      CustomSizedBox(value: 20, side: 'height'),
                                      CustomTextFormField(
                                        textController:
                                            inPersonQuantitativeController
                                                .staafAttendedTrainingController,
                                        labelText: 'Number of Staffs',
                                        textInputType: TextInputType.number,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(
                                              3), // Limit to 3 digits
                                          FilteringTextInputFormatter
                                              .digitsOnly, // Allow only digits
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please fill this field';
                                          }
                                          if (int.tryParse(value) == 0) {
                                            return 'Please enter a number greater than 0';
                                          }
                                          return null; // No error
                                        },
                                        onChanged:
                                            _handleStaffAttendedChange, // Update state on change
                                        showCharacterCount: true,
                                      ),
                                      CustomSizedBox(value: 20, side: 'height'),
                                      if (int.tryParse(
                                                  inPersonQuantitativeController
                                                      .staafAttendedTrainingController
                                                      .text) !=
                                              null &&
                                          int.tryParse(
                                                  inPersonQuantitativeController
                                                      .staafAttendedTrainingController
                                                      .text)! >
                                              0) ...[
                                        Row(
                                          children: [
                                            LabelText(
                                                label:
                                                    '1.1 Add Participants Details'),
                                            CustomSizedBox(
                                                value: 10, side: 'width'),
                                            IconButton(
                                              icon: Icon(Icons.add),
                                              iconSize: 40,
                                              color: Color.fromARGB(
                                                  255, 141, 13, 21),
                                              onPressed:
                                                  _addParticipants, // Trigger add participants function
                                            ),
                                          ],
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        participants.isEmpty
                                            ? Center(child: Text('No records'))
                                            : ListView.builder(
                                                shrinkWrap:
                                                    true, // Use space efficiently
                                                physics:
                                                    NeverScrollableScrollPhysics(), // Disable scrolling
                                                itemCount: participants.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title: Text(
                                                      '${index + 1}. Name: ${participants[index].nameOfParticipants}\n    Designation: ${participants[index].designation}',
                                                    ),
                                                    trailing: IconButton(
                                                      icon: Icon(Icons.delete),
                                                      color: Colors
                                                          .red, // Set the icon color to red
                                                      onPressed: () =>
                                                          _deleteParticipants(
                                                              index), // Delete participant
                                                    ),
                                                  );
                                                },
                                              ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        // Show error if participants count does not match staff attended
                                      ],
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            'Click Image of Refresher Training?',
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
                                            color: _isImageUploaded2 == false
                                                ? AppColors.primary
                                                : AppColors.error,
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            'Click or Upload Image',
                                            style: TextStyle(
                                              color: _isImageUploaded2 == false
                                                  ? Colors.black
                                                  : AppColors.error,
                                            ),
                                          ),
                                          trailing: Icon(Icons.camera_alt,
                                              color: AppColors.onBackground),
                                          onTap: () {
                                            showModalBottomSheet(
                                              backgroundColor:
                                                  AppColors.primary,
                                              context: context,
                                              builder: (builder) =>
                                                  inPersonQuantitativeController
                                                      .bottomSheet(context, 2),
                                            );
                                          },
                                        ),
                                      ),
                                      ErrorText(
                                        isVisible: validateRegister2,
                                        message: 'Image Required',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      inPersonQuantitativeController
                                              .multipleImage2.isNotEmpty
                                          ? Container(
                                              width: responsive.responsiveValue(
                                                small: 600.0,
                                                medium: 900.0,
                                                large: 1400.0,
                                              ),
                                              height:
                                                  responsive.responsiveValue(
                                                small: 170.0,
                                                medium: 170.0,
                                                large: 170.0,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    inPersonQuantitativeController
                                                        .multipleImage2.length,
                                                itemBuilder: (context, index) {
                                                  return SizedBox(
                                                    height: 200,
                                                    width: 200,
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              CustomImagePreview
                                                                  .showImagePreview(
                                                                inPersonQuantitativeController
                                                                    .multipleImage2[
                                                                        index]
                                                                    .path,
                                                                context,
                                                              );
                                                            },
                                                            child: Image.file(
                                                              File(inPersonQuantitativeController
                                                                  .multipleImage2[
                                                                      index]
                                                                  .path),
                                                              width: 190,
                                                              height: 120,
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              inPersonQuantitativeController
                                                                  .multipleImage2
                                                                  .removeAt(
                                                                      index);
                                                            });
                                                          },
                                                          child: Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : SizedBox(),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '2. What were the topics covered in the refresher training?',
                                        astrick: true,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue1,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue1 = value!;
                                          });
                                        },
                                        title: Text('Operating DigiLab'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue2,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue2 = value!;
                                          });
                                        },
                                        title: Text('Operating tablets'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue3,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue3 = value!;
                                          });
                                        },
                                        title: Text('Creating students IDs'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue4,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue4 = value!;
                                          });
                                        },
                                        title: Text(
                                            'Grade Wise DigiLab subjects & Chapters'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue5,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue5 = value!;
                                          });
                                        },
                                        title: Text(
                                            'Importance of completing post test'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue6,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue6 = value!;
                                          });
                                        },
                                        title: Text(
                                            'Saving and submitting data(Send Report)'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue7,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue7 = value!;
                                          });
                                        },
                                        title: Text('Syncing data with Pi'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue8,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue8 = value!;
                                            // Clear the text field if the checkbox is unchecked
                                            if (!inPersonQuantitativeController
                                                .checkboxValue8) {
                                              inPersonQuantitativeController
                                                  .otherTopicsController
                                                  .clear();
                                            }
                                          });
                                        },
                                        title: Text('Any other'),
                                        activeColor: Colors.green,
                                      ),

                                      if (inPersonQuantitativeController
                                          .checkBoxError)
                                        Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select at least one topic',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (inPersonQuantitativeController
                                          .checkboxValue8) ...[
                                        // Conditionally show the text field
                                        LabelText(
                                          label:
                                              '2.1 Please specify what the other topics',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                              inPersonQuantitativeController
                                                  .otherTopicsController,
                                          maxlines: 2,
                                          labelText:
                                              'Please Specify what the other topics',
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please fill this field';
                                            }
                                            // Regex pattern for validating Indian vehicle number plate

                                            if (value.length < 25) {
                                              return 'Please enter at least 25 characters';
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
                                      // Give me complete code only for the selectbox error field and the onpressed on next for the selectbox
                                      LabelText(
                                        label: '3. Was a practical demo given?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'practicalDemo'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'practicalDemo', value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'practicalDemo'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'practicalDemo', value);
                                                if (value == 'No') {
                                                  inPersonQuantitativeController
                                                      .reasonForNotGivenpracticalDemoController
                                                      .clear();
                                                }
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('practicalDemo'))
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
                                      if (inPersonQuantitativeController
                                              .getSelectedValue(
                                                  'practicalDemo') ==
                                          'No') ...[
                                        // Conditionally show the text field
                                        LabelText(
                                          label:
                                              '3.1 Give the reason for not providing demo',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                              inPersonQuantitativeController
                                                  .reasonForNotGivenpracticalDemoController,
                                          labelText: 'Give Reason',
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please fill this field';
                                            }
                                            // Regex pattern for validating Indian vehicle number plate

                                            if (value.length < 25) {
                                              return 'Please enter at least 25 characters';
                                            }
                                            return null;
                                          },
                                          maxlines: 2,
                                          showCharacterCount: true,
                                        ),
                                      ],

// Section for adding issues and resolutions
                                      Row(
                                        children: [
                                          // Use Flexible to make the LabelText take remaining space
                                          Flexible(
                                            flex: 2,
                                            child: LabelText(
                                              label:
                                                  '4. Add Major Issues and Resolution',
                                            ),
                                          ),
                                          SizedBox(
                                              width: screenWidth *
                                                  0.02), // Responsive spacing between widgets
                                          // CustomSizedBox width adjusted for screen size
                                          CustomSizedBox(
                                            value: screenWidth *
                                                0.03, // Adjust width based on screen size
                                            side: 'width',
                                          ),
                                          // IconButton with responsive size
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            iconSize: screenWidth *
                                                0.1, // Adjust icon size based on screen width
                                            color: Color.fromARGB(
                                                255, 141, 13, 21),
                                            onPressed: _addIssue,
                                          ),
                                        ],
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),

                                      issues.isEmpty
                                          ? Center(child: Text('No records'))
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: issues.length,
                                              itemBuilder: (context, index) {
                                                return ListTile(
                                                  title: Text(
                                                      '${index + 1}. Issue: ${issues[index].issue}\n    Resolution: ${issues[index].resolution}'),
                                                  trailing: IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors
                                                          .red, // Set the icon color to red
                                                    ),
                                                    onPressed: () =>
                                                        _deleteIssue(index),
                                                  ),
                                                );
                                              },
                                            ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                          label:
                                              '5. Additional comments on teacher capacity'),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),

                                      CustomTextFormField(
                                        textController:
                                            inPersonQuantitativeController
                                                .additionalCommentOnteacherCapacityController,
                                        maxlines: 2,
                                        labelText: 'Write your comments if any',
                                        showCharacterCount: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      Row(
                                        children: [
                                          CustomButton(
                                              title: 'Back',
                                              onPressedButton: () {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showTeacherCapacity =
                                                      true;
                                                  inPersonQuantitativeController
                                                          .showSchoolRefresherTraining =
                                                      false;
                                                });
                                              }),
                                          Spacer(),
                                          CustomButton(
                                            title: 'Next',
                                            onPressedButton: () {
                                              _onNextPressed;
                                              final totalStaff = int.tryParse(
                                                      inPersonQuantitativeController
                                                          .staafAttendedTrainingController
                                                          .text) ??
                                                  0;

                                              // Check if the number of participants is equal to the total staff attended
                                              if (participants.length !=
                                                  totalStaff) {
                                                // Show an error message if they do not match
                                                customSnackbar(
                                                  'Error', // Title
                                                  'The number of participants must equal the number of staff attended.', // Subtitle
                                                  AppColors
                                                      .error, // Background color, you can replace it with your preferred color
                                                  AppColors
                                                      .onPrimary, // Text color
                                                  Icons.error, // Icon
                                                );
                                                return; // Exit the function if the counts do not match
                                              }
                                              // Check if at least one checkbox is selected
                                              bool isCheckboxSelected = inPersonQuantitativeController.checkboxValue1 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue2 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue3 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue4 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue5 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue6 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue7 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue8;

                                              if (!isCheckboxSelected) {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                      .checkBoxError = true;
                                                });
                                              } else {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                      .checkBoxError = false;
                                                });
                                              }
                                              // Check if a value for _selectedValue9 is selected
                                              final isRadioValid9 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'practicalDemo');

                                              // Validate the form and other conditions
                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  isRadioValid9 &&
                                                  !inPersonQuantitativeController
                                                      .checkBoxError &&
                                                  !validateRegister2 && // This line ensures the error is bypassed if the image is uploaded
                                                  !showError) {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showSchoolRefresherTraining =
                                                      false;
                                                  inPersonQuantitativeController
                                                          .showDigiLabClasses =
                                                      true;
                                                });
                                              } else {
                                                setState(() {
                                                  validateRegister2 =
                                                      inPersonQuantitativeController
                                                          .multipleImage2
                                                          .isEmpty; // Only show the image error if no image is uploaded
                                                });
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ],

                                    // Starting of digilab classes
                                    if (inPersonQuantitativeController
                                        .showDigiLabClasses) ...[
                                      LabelText(
                                        label: 'DigiLab Classes',
                                        astrick: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '1. Are the children comfortable using the tabs and navigating the content?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'childrenComfortable'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'childrenComfortable',
                                                        value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'childrenComfortable'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'childrenComfortable',
                                                        value);
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError(
                                              'childrenComfortable'))
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
                                      LabelText(
                                        label:
                                            '2. Are the children able to understand the content?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'childrenContent'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'childrenContent',
                                                        value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'childrenContent'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'childrenContent',
                                                        value);
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError(
                                              'childrenContent'))
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
                                      LabelText(
                                        label:
                                            '3. Are post-tests being completed by children at the end of each chapter?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'postTeacher'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'postTeacher', value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'postTeacher'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'postTeacher', value);
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('postTeacher'))
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
                                      LabelText(
                                        label:
                                            '4. Are the teachers able to help children resolve doubts or issues during the DigiLab classes?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'teacherHelp'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'teacherHelp', value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'teacherHelp'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'teacherHelp', value);
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('teacherHelp'))
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
                                      LabelText(
                                        label:
                                            '5.  Are the digiLab logs being filled?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'digiLabLog'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'digiLabLog', value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'digiLabLog'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'digiLabLog', value);
                                                if (value == 'No') {
                                                  inPersonQuantitativeController
                                                      .clearRadioValue(
                                                          'logFilled');
                                                }
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('digiLabLog'))
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
                                      if (inPersonQuantitativeController
                                              .getSelectedValue('digiLabLog') ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '5.1  If yes,are the logs being filled correctly?',
                                          astrick: true,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: screenWidth * 0.1),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'Yes',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'logFilled'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'logFilled', value);
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
                                          padding: EdgeInsets.only(
                                              right: screenWidth * 0.1),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'No',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'logFilled'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'logFilled', value);
                                                },
                                              ),
                                              Text('No'),
                                            ],
                                          ),
                                        ),
                                        if (inPersonQuantitativeController
                                            .getRadioFieldError('logFilled'))
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
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '6. Is "Send Report" being done on each used tab at the end of the day?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'sendReport'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'sendReport', value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'sendReport'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'sendReport', value);
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('sendReport'))
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
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '7. Is Facilitator App installed and functioning on HMs/Admins phone?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'facilatorApp'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'facilatorApp', value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'facilatorApp'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'facilatorApp', value);
                                                if (value == 'No') {
                                                  inPersonQuantitativeController
                                                      .howOftenDataBeingSyncedController
                                                      .clear();
                                                  inPersonQuantitativeController
                                                      .dateController
                                                      .clear();
                                                }
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('facilatorApp'))
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
                                      if (inPersonQuantitativeController
                                              .getSelectedValue(
                                                  'facilatorApp') ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '7.1 How often is the data being synced?',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                              inPersonQuantitativeController
                                                  .howOftenDataBeingSyncedController,
                                          labelText: 'Number of Days',
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(2),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          textInputType: TextInputType.number,
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
                                        LabelText(
                                          label:
                                              '7.2 When was the data last synced on the Facilitator App?',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        TextField(
                                          controller:
                                              inPersonQuantitativeController
                                                  .dateController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: 'Select Date',
                                            errorText:
                                                inPersonQuantitativeController
                                                        .dateFieldError
                                                    ? 'Date is required'
                                                    : null,
                                            suffixIcon: IconButton(
                                              icon: Icon(Icons.calendar_today),
                                              onPressed: () {
                                                _selectDate(context);
                                              },
                                            ),
                                          ),
                                          onTap: () {
                                            _selectDate(context);
                                          },
                                        ),
                                      ],
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      Row(
                                        children: [
                                          CustomButton(
                                              title: 'Back',
                                              onPressedButton: () {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showSchoolRefresherTraining =
                                                      true;
                                                  inPersonQuantitativeController
                                                          .showDigiLabClasses =
                                                      false;
                                                });
                                              }),
                                          Spacer(),
                                          CustomButton(
                                            title: 'Next',
                                            onPressedButton: () {
                                              // Validate radio selections
                                              final isRadioValid10 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'childrenComfortable');
                                              final isRadioValid11 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'childrenContent');
                                              final isRadioValid12 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'postTeacher');
                                              final isRadioValid13 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'teacherHelp');
                                              final isRadioValid14 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'digiLabLog');

                                              bool isRadioValid15 =
                                                  true; // Default to true
                                              // Only validate 'logFilled' if 'digiLabLog' is 'Yes'
                                              if (inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'digiLabLog') ==
                                                  'Yes') {
                                                isRadioValid15 =
                                                    inPersonQuantitativeController
                                                        .validateRadioSelection(
                                                            'logFilled');
                                              }

                                              final isRadioValid16 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'sendReport');
                                              final isRadioValid17 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'facilatorApp');

                                              // Conditionally validate the date field if 'facilatorApp' is 'Yes'
                                              bool _dateFieldError = false;
                                              if (inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'facilatorApp') ==
                                                  'Yes') {
                                                _dateFieldError =
                                                    inPersonQuantitativeController
                                                        .dateController
                                                        .text
                                                        .isEmpty;
                                              }

                                              setState(() {
                                                // Update the state to reflect whether the date field has an error
                                                this
                                                        .inPersonQuantitativeController
                                                        .dateFieldError =
                                                    _dateFieldError;
                                              });

                                              // Validate form and all conditions
                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  isRadioValid10 &&
                                                  isRadioValid11 &&
                                                  isRadioValid12 &&
                                                  isRadioValid13 &&
                                                  isRadioValid14 &&
                                                  isRadioValid15 &&
                                                  isRadioValid16 &&
                                                  isRadioValid17 &&
                                                  !_dateFieldError) {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showDigiLabClasses =
                                                      false;
                                                  inPersonQuantitativeController
                                                      .showLibrary = true;
                                                });
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ],
                                    //   Ending of DigiLab Classes
                                    // Starting of library
                                    if (inPersonQuantitativeController
                                        .showLibrary) ...[
                                      LabelText(
                                        label: 'Library',
                                        astrick: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '1. Is a Library timetable available?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'libTmeTable'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'libTmeTable', value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'libTmeTable'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'libTmeTable', value);
                                                if (value == 'No') {
                                                  inPersonQuantitativeController
                                                      .clearRadioValue(
                                                          'followedTimeTable');
                                                }
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('libTmeTable'))
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
                                      if (inPersonQuantitativeController
                                              .getSelectedValue(
                                                  'libTmeTable') ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '1.1 is the timetable being followed?',
                                          astrick: true,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: screenWidth * 0.1),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'Yes',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'followedTimeTable'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'followedTimeTable',
                                                          value);
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
                                          padding: EdgeInsets.only(
                                              right: screenWidth * 0.1),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'No',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'followedTimeTable'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'followedTimeTable',
                                                          value);
                                                },
                                              ),
                                              Text('No'),
                                            ],
                                          ),
                                        ),
                                        if (inPersonQuantitativeController
                                            .getRadioFieldError(
                                                'followedTimeTable'))
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
                                      LabelText(
                                        label:
                                            '2. Is the Library register updated?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'updatedLibrary'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'updatedLibrary',
                                                        value);
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
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'updatedLibrary'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'updatedLibrary',
                                                        value);
                                              },
                                            ),
                                            Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('updatedLibrary'))
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
                                      LabelText(
                                        label:
                                            '3. Additional observations on Library',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      CustomTextFormField(
                                        textController:
                                            inPersonQuantitativeController
                                                .additionalObservationOnLibraryController,
                                        maxlines: 2,
                                        labelText: 'Write Comments if any',
                                        showCharacterCount: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      Row(
                                        children: [
                                          CustomButton(
                                              title: 'Back',
                                              onPressedButton: () {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showDigiLabClasses =
                                                      true;
                                                  inPersonQuantitativeController
                                                      .showLibrary = false;
                                                });
                                              }),
                                          Spacer(),
                                          CustomButton(
                                            title: 'Submit',
                                            onPressedButton: () async {
                                              final isRadioValid18 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'libTmeTable');

                                              bool isRadioValid19 =
                                                  true; // Default to true
                                              // Only validate 'logFilled' if 'digiLabLog' is 'Yes'
                                              if (inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'libTmeTable') ==
                                                  'Yes') {
                                                isRadioValid19 =
                                                    inPersonQuantitativeController
                                                        .validateRadioSelection(
                                                            'followedTimeTable');
                                              }

                                              final isRadioValid20 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'updatedLibrary');

                                              setState(() {
                                                inPersonQuantitativeController
                                                    .checkBoxError = !(inPersonQuantitativeController
                                                        .checkboxValue1 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue2 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue3 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue4 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue5 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue6 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue7 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue8);

                                                validateRegister =
                                                    !_isImageUploaded;
                                              });

                                              if (!inPersonQuantitativeController
                                                  .checkBoxError) {
                                                // Combine all checkbox values into a single string
                                                String refresherTrainingTopic =
                                                    [
                                                  inPersonQuantitativeController
                                                          .checkboxValue1
                                                      ? 'Operating DigiLab'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue2
                                                      ? 'Operating tablets'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue3
                                                      ? 'Creating students IDs'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue4
                                                      ? 'Grade Wise DigiLab subjects & Chapters'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue5
                                                      ? 'Importance of completing post test'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue6
                                                      ? 'Saving and submitting data(Send Report)'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue7
                                                      ? 'Syncing data with Pi'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue8
                                                      ? 'Any other'
                                                      : null,
                                                ]
                                                        .where((value) =>
                                                            value != null)
                                                        .join(', ');

                                                if (_formKey.currentState!
                                                        .validate() &&
                                                    isRadioValid18 &&
                                                    isRadioValid19 &&
                                                    isRadioValid20) {
                                                  // Combine participants data into a single string
                                                  String participantsDataJson =
                                                      jsonEncode(participants
                                                          .map((participant) {
                                                    return {
                                                      'Name': participant
                                                          .nameOfParticipants,
                                                      'Designation': participant
                                                          .designation,
                                                    };
                                                  }).toList());
                                                  final selectController =
                                                      Get.put(
                                                          SelectController());
                                                  String? lockedTourId =
                                                      selectController
                                                          .lockedTourId;

                                                  // Use lockedTourId if it is available, otherwise use the selected tour ID from schoolEnrolmentController
                                                  String tourIdToInsert =
                                                      lockedTourId ??
                                                          inPersonQuantitativeController
                                                              .tourValue ??
                                                          '';
                                                  // Convert issues data to JSON
                                                  String
                                                      issueAndResolutionJson =
                                                      jsonEncode(
                                                          issues.map((issue) {
                                                    return {
                                                      'Issue': issue.issue,
                                                      'Resolution':
                                                          issue.resolution,
                                                      'IsResolved':
                                                          issue.isResolved
                                                              ? "Yes"
                                                              : "No",
                                                    };
                                                  }).toList());
                                                  print(
                                                      'Office on pressed ${widget.office} ');

                                                  DateTime now = DateTime.now();
                                                  String formattedDate =
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(now);

                                                  String generateUniqueId(
                                                      int length) {
                                                    const _chars =
                                                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                                                    Random _rnd = Random();
                                                    return String.fromCharCodes(
                                                        Iterable.generate(
                                                            length,
                                                            (_) => _chars
                                                                .codeUnitAt(_rnd
                                                                    .nextInt(_chars
                                                                        .length))));
                                                  }

                                                  List<File> imgPathFiles = [];
                                                  for (var imagePath
                                                      in inPersonQuantitativeController
                                                          .imagePaths) {
                                                    imgPathFiles.add(File(
                                                        imagePath)); // Convert image path to File
                                                  }

                                                  List<File> training_picFiles =
                                                      [];
                                                  for (var imagePath2
                                                      in inPersonQuantitativeController
                                                          .imagePaths2) {
                                                    training_picFiles.add(File(
                                                        imagePath2)); // Convert image path to File
                                                  }

                                                  print(
                                                      'Image Paths: ${imgPathFiles.map((file) => file.path).toList()}');
                                                  print(
                                                      'Training Image Paths: ${training_picFiles.map((file) => file.path).toList()}');

                                                  String imgPathFilesPaths =
                                                      imgPathFiles
                                                          .map((file) =>
                                                              file.path)
                                                          .join(',');
                                                  String
                                                      training_picFilesPaths =
                                                      training_picFiles
                                                          .map((file) =>
                                                              file.path)
                                                          .join(',');

                                                  String uniqueId =
                                                      generateUniqueId(6);

                                                  // Concatenate values if "Yes" is selected for teacher IDs
                                                  String
                                                      teacherIdsCreatedValue =
                                                      inPersonQuantitativeController
                                                              .getSelectedValue(
                                                                  'idHasBeenCreated') ??
                                                          '';
                                                  String
                                                      teacherComfortableValue =
                                                      teacherIdsCreatedValue ==
                                                              'Yes'
                                                          ? (inPersonQuantitativeController
                                                                  .getSelectedValue(
                                                                      'teacherUsingTablet') ??
                                                              '')
                                                          : '';

                                                  String concatenatedValue =
                                                      '$teacherIdsCreatedValue $teacherComfortableValue';

                                                  // Create enrolment collection object
                                                  InPersonQuantitativeRecords
                                                      enrolmentCollectionObj =
                                                      InPersonQuantitativeRecords(
                                                    tourId: tourIdToInsert,
                                                    school:
                                                        inPersonQuantitativeController
                                                                .schoolValue ??
                                                            '',
                                                    udicevalue:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'udiCode') ??
                                                            '',
                                                    correct_udice:
                                                        inPersonQuantitativeController
                                                            .correctUdiseCodeController
                                                            .text,
                                                    imgpath: imgPathFilesPaths,
                                                    no_enrolled:
                                                        inPersonQuantitativeController
                                                            .noOfEnrolledStudentAsOnDateController
                                                            .text,
                                                    timetable_available:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'digiLabSchedule') ??
                                                            '',
                                                    class_scheduled:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'class2Hours') ??
                                                            '',
                                                    remarks_scheduling:
                                                        inPersonQuantitativeController
                                                            .instructionProvidedRegardingClassSchedulingController
                                                            .text,

                                                    admin_appointed:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'isDigiLabAdminAppointed') ??
                                                            '',
                                                    admin_trained:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'isDigiLabAdminTrained') ??
                                                            '',
                                                    admin_name:
                                                        inPersonQuantitativeController
                                                            .digiLabAdminNameController
                                                            .text,
                                                    admin_phone:
                                                        inPersonQuantitativeController
                                                            .digiLabAdminPhoneNumberController
                                                            .text,
                                                    sub_teacher_trained:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'areAllTeacherTrained') ??
                                                            '',
                                                    teacher_ids:
                                                        concatenatedValue, // Use the concatenated value here

                                                    no_staff:
                                                        inPersonQuantitativeController
                                                            .staafAttendedTrainingController
                                                            .text,
                                                    training_pic:
                                                        training_picFilesPaths,
                                                    specifyOtherTopics:
                                                        inPersonQuantitativeController
                                                            .otherTopicsController
                                                            .text,
                                                    practical_demo:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'practicalDemo') ??
                                                            '',
                                                    reason_demo:
                                                        inPersonQuantitativeController
                                                            .reasonForNotGivenpracticalDemoController
                                                            .text,
                                                    comments_capacity:
                                                        inPersonQuantitativeController
                                                            .additionalCommentOnteacherCapacityController
                                                            .text,
                                                    children_comfortable:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'teacherUsingTablet') ??
                                                            '',
                                                    children_understand:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'childrenContent') ??
                                                            '',
                                                    post_test:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'postTeacher') ??
                                                            '',
                                                    resolved_doubts:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'teacherHelp') ??
                                                            '',
                                                    logs_filled:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'digiLabLog') ??
                                                            '',
                                                    filled_correctly:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'logFilled') ??
                                                            '',
                                                    send_report:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'sendReport') ??
                                                            '',
                                                    app_installed:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'facilatorApp') ??
                                                            '',
                                                    data_synced:
                                                        inPersonQuantitativeController
                                                            .howOftenDataBeingSyncedController
                                                            .text,
                                                    last_syncedDate:
                                                        inPersonQuantitativeController
                                                            .dateController
                                                            .text,
                                                    lib_timetable:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'libTmeTable') ??
                                                            '',
                                                    timetable_followed:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'followedTimeTable') ??
                                                            '',
                                                    registered_updated:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'updatedLibrary') ??
                                                            '',
                                                    observation_comment:
                                                        inPersonQuantitativeController
                                                            .additionalObservationOnLibraryController
                                                            .text,
                                                    topicsCoveredInTraining:
                                                        refresherTrainingTopic,
                                                    submitted_by: widget.userid
                                                        .toString(),
                                                    participant_name:
                                                        participantsDataJson,
                                                    major_issue:
                                                        issueAndResolutionJson,
                                                    created_at: formattedDate
                                                        .toString(),
                                                    unique_id: uniqueId,
                                                    office: widget.office ??
                                                        'Default Office',
                                                  );
                                                  print(
                                                      'Office value: ${widget.office}'); // Debugging line

                                                  // Save data to local database
                                                  int result = await LocalDbController()
                                                      .addData(
                                                          inPersonQuantitativeRecords:
                                                              enrolmentCollectionObj);
                                                  print(result);
                                                  if (result > 0) {
                                                    inPersonQuantitativeController
                                                        .clearFields();

                                                    String jsonData1 = jsonEncode(
                                                        enrolmentCollectionObj
                                                            .toJson());

                                                    try {
                                                      JsonFileDownloader
                                                          downloader =
                                                          JsonFileDownloader();
                                                      String? filePath =
                                                          await downloader
                                                              .downloadJsonFile(
                                                        jsonData1,
                                                        uniqueId,
                                                        imgPathFiles,
                                                        training_picFiles,
                                                      );
                                                      // Notify user of success
                                                      customSnackbar(
                                                        'File Downloaded Successfully',
                                                        'File saved at $filePath',
                                                        AppColors.primary,
                                                        AppColors.onPrimary,
                                                        Icons.download_done,
                                                      );
                                                    } catch (e) {
                                                      customSnackbar(
                                                        'Error',
                                                        e.toString(),
                                                        AppColors.primary,
                                                        AppColors.onPrimary,
                                                        Icons.error,
                                                      );
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
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ]
                                  ] // End of main Column
                                      );
                                }));
                      }),
                ],
              ),
            ),
          ),
        ));
  }
}

class Issue {
  String issue;
  String resolution;
  bool isResolved;

  Issue({
    required this.issue,
    required this.resolution,
    required this.isResolved,
  });
}

class AddIssueBottomSheet extends StatefulWidget {
  @override
  _AddIssueBottomSheetState createState() => _AddIssueBottomSheetState();
}

class _AddIssueBottomSheetState extends State<AddIssueBottomSheet> {
  final TextEditingController writeIssueController = TextEditingController();
  final TextEditingController writeResolutionController =
      TextEditingController();
  String? isResolved;

  // Key to manage the state of the form
  final _formKey = GlobalKey<FormState>();

  // Variable to track if an error should be shown for the radio buttons
  bool showRadioError = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  LabelText(
                    label: 'Write issue',
                    astrick: true,
                  ),
                  CustomSizedBox(
                    value: 20,
                    side: 'height',
                  ),
                  CustomTextFormField(
                    textController: writeIssueController,
                    labelText: 'Write your issue',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the issue';
                      }
                      return null;
                    },
                  ),
                  CustomSizedBox(
                    value: 20,
                    side: 'height',
                  ),
                  LabelText(
                    label: 'Write your resolution',
                    astrick: true,
                  ),
                  CustomSizedBox(
                    value: 20,
                    side: 'height',
                  ),
                  CustomTextFormField(
                    textController: writeResolutionController,
                    labelText: 'Write your resolution',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the resolution';
                      }
                      return null;
                    },
                  ),
                  CustomSizedBox(
                    value: 20,
                    side: 'height',
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 80),
                    child: Column(
                      children: [
                        LabelText(
                          label: 'Is the issue resolved or not?',
                          astrick: true,
                        ),
                        ListTile(
                          title: Text('Yes'),
                          leading: Radio<String>(
                            value: 'Yes',
                            groupValue: isResolved,
                            onChanged: (String? value) {
                              setState(() {
                                isResolved = value;
                                showRadioError =
                                    false; // Reset the error display
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: Text('No'),
                          leading: Radio<String>(
                            value: 'No',
                            groupValue: isResolved,
                            onChanged: (String? value) {
                              setState(() {
                                isResolved = value;
                                showRadioError =
                                    false; // Reset the error display
                              });
                            },
                          ),
                        ),
                        if (showRadioError) // Show error only after submission attempt
                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Please select if the issue is resolved or not',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    title: 'Cancel',
                    onPressedButton: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Spacer(),
                  CustomButton(
                    title: 'Add',
                    onPressedButton: () {
                      // Validate the form fields
                      bool isValid = _formKey.currentState!.validate();

                      // Check if the radio button is selected
                      if (isResolved == null) {
                        setState(() {
                          showRadioError = true;
                        });
                        isValid = false;
                      }

                      if (isValid) {
                        final issue = Issue(
                          issue: writeIssueController.text,
                          resolution: writeResolutionController.text,
                          isResolved: isResolved == 'Yes',
                        );

                        // Clear the fields after adding the issue
                        setState(() {
                          writeIssueController.clear();
                          writeResolutionController.clear();
                          isResolved = null;
                          showRadioError = false;
                        });

                        Navigator.of(context).pop(issue);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Participants {
  String nameOfParticipants;
  String designation;

  Participants({required this.nameOfParticipants, required this.designation});
}

class AddParticipantsBottomSheet extends StatefulWidget {
  final List<String> existingRoles;

  AddParticipantsBottomSheet({required this.existingRoles});

  @override
  _AddParticipantsBottomSheetState createState() =>
      _AddParticipantsBottomSheetState();
}

class _AddParticipantsBottomSheetState
    extends State<AddParticipantsBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final InPersonQuantitativeController inPersonQuantitativeController =
      Get.put(InPersonQuantitativeController());
  String? _selectedDesignation;

  @override
  void initState() {
    super.initState();
    if (widget.existingRoles.isNotEmpty) {
      _selectedDesignation =
          widget.existingRoles.first; // Default to the first role for editing
      _selectedDesignation = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LabelText(label: 'Participants Name', astrick: true),
              CustomSizedBox(value: 20, side: 'height'),
              CustomTextFormField(
                textController:
                    inPersonQuantitativeController.participantsNameController,
                labelText: 'Participants Name',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter participant name';
                  }
                  return null;
                },
              ),
              CustomSizedBox(value: 20, side: 'height'),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Participants Designation',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDesignation,
                items: [
                  DropdownMenuItem(
                    value: 'Teacher',
                    child: Text('Teacher'),
                  ),
                  DropdownMenuItem(
                    value: 'HeadMaster',
                    child: Text('HeadMaster'),
                  ),
                  DropdownMenuItem(
                    value: 'DigiLab Admin',
                    child: Text('DigiLab Admin'),
                  ),
                  DropdownMenuItem(
                    value: 'In charge',
                    child: Text('In charge'),
                  ),
                  DropdownMenuItem(
                    value: 'Temporary Teacher',
                    child: Text('Temporary Teacher'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDesignation = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a designation';
                  }
                  return null;
                },
              ),
              CustomSizedBox(value: 20, side: 'height'),
              CustomButton(
                title: 'Add',
                onPressedButton: () {
                  if (_formKey.currentState!.validate()) {
                    final participant = Participants(
                      nameOfParticipants: inPersonQuantitativeController
                          .participantsNameController.text,
                      designation: _selectedDesignation!,
                    );

                    // Clear the text field and reset designation
                    inPersonQuantitativeController.participantsNameController
                        .clear();
                    setState(() {
                      _selectedDesignation = null; // Clear selected designation
                    });

                    Navigator.pop(context, participant);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Function to save JSON data to a file
class JsonFileDownloader {
  // Method to download JSON data to the Downloads directory
  Future<String?> downloadJsonFile(
    String jsonData,
    String uniqueId,
    List<File> imgPathFiles,
    List<File> trainingPicFiles,
  ) async {
    Directory? downloadsDirectory;

    if (Platform.isAndroid) {
      downloadsDirectory = await _getAndroidDirectory();
    } else if (Platform.isIOS) {
      downloadsDirectory = await getApplicationDocumentsDirectory();
    } else {
      downloadsDirectory = await getDownloadsDirectory();
    }

    if (downloadsDirectory != null) {
      // Prepare file path to save the JSON
      String filePath =
          '${downloadsDirectory.path}/inPerson_Quantitative_form_$uniqueId.txt';
      File file = File(filePath);

      // Convert images to Base64 for each image list
      Map<String, dynamic> jsonObject = jsonDecode(jsonData);
      jsonObject['base64_imagePathFiles'] =
          await _convertImagesToBase64(imgPathFiles);
      jsonObject['base64_trainingPicFiles'] =
          await _convertImagesToBase64(trainingPicFiles);

      // Write the updated JSON data to the file
      await file.writeAsString(jsonEncode(jsonObject));

      // Return the file path for further use if needed
      return filePath;
    } else {
      throw Exception('Could not find the download directory');
    }
  }

  // Helper function to convert a list of image files to Base64 strings separated by commas
  Future<String> _convertImagesToBase64(List<File> imageFiles) async {
    List<String> base64Images = [];

    for (File image in imageFiles) {
      if (await image.exists()) {
        List<int> imageBytes = await image.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        base64Images.add(base64Image);
      }
    }

    // Return Base64-encoded images as a comma-separated string
    return base64Images.join(',');
  }

  // Method to get the correct directory for Android based on version
  Future<Directory?> _getAndroidDirectory() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;

      // Android 11+ (API level 30 and above) - Use manage external storage
      if (androidInfo.version.sdkInt >= 30 &&
          await Permission.manageExternalStorage.isGranted) {
        return Directory('/storage/emulated/0/Download');
      }
      // Android 10 and below - Use external storage directory
      else if (await Permission.storage.isGranted) {
        return await getExternalStorageDirectory();
      }
    }
    return null;
  }
}
