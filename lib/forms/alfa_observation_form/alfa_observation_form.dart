import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app17000ft_new/components/custom_appBar.dart';
import 'package:app17000ft_new/components/custom_button.dart';
import 'package:app17000ft_new/components/custom_imagepreview.dart';
import 'package:app17000ft_new/components/custom_snackbar.dart';
import 'package:app17000ft_new/components/custom_textField.dart';
import 'package:app17000ft_new/components/error_text.dart';
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/forms/alfa_observation_form/alfa_obervation_modal.dart';
import 'package:app17000ft_new/helper/database_helper.dart';
import 'package:app17000ft_new/helper/responsive_helper.dart';
import 'package:app17000ft_new/tourDetails/tour_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:app17000ft_new/base_client/base_client.dart';
import 'package:app17000ft_new/components/custom_dropdown.dart';
import 'package:app17000ft_new/components/custom_labeltext.dart';
import 'package:app17000ft_new/components/custom_sizedBox.dart';
import 'package:app17000ft_new/forms/school_enrolment/school_enrolment_controller.dart';
import 'package:app17000ft_new/home/home_screen.dart';

import '../../components/custom_confirmation.dart';
import '../select_tour_id/select_controller.dart';
import 'alfa_observation_controller.dart';


class AlfaObservationForm extends StatefulWidget {
  String? userid;
  String? office;
  AlfaObservationForm({
    super.key, this.userid, this.office
  });

  @override
  State<AlfaObservationForm> createState() => _AlfaObservationFormState();
}

class _AlfaObservationFormState extends State<AlfaObservationForm> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> splitSchoolLists = [];
// Start of Basic Details

  bool showBasicDetails = true; // For show Basic Details
  bool showAlfamoduleActivities = false; // For show Basic Details
  bool showReferesherTraining = false; // For show Basic Details
  bool showLibraryReading = false; // For show Basic Details
  bool showClassroomObservation = false; // For show Basic Details

  // End of BasicDetails

  // For the image
  bool validateNursery = false; // for the nursery timetable
  final bool _isImageUploadedNursery = false; // for the nursery timetable

  bool validateLkg = false; // for the LKG timetable
  final bool _isImageUploadedLkg = false; // for the LKG timetable

  bool validateUkg = false; // for the UKG timetable
  final bool _isImageUploadedUkg = false; // for the UKG timetable

  bool validateAlfamodule = false; // for the UKG timetable
  final bool _isImageUploadedAlfaModule = false; // for the UKG timetable

  bool validateTeacherTraining = false; // for the UKG timetable
  final bool _isImageUploadedTeacherTraining = false; // for the UKG timetable

  bool validateReadingActivities = false; // for the UKG timetable
  final bool _isImageUploadedReadingActivities = false; // for the UKG timetable

  bool validateTlmKit = false; // for the UKG timetable
  final bool _isImageUploadedTlmKit = false; // for the UKG timetable

  Map<String, Map<String, int>> staffData = {};
  final List<TextEditingController> teachingStaffControllers = [];
  final List<TextEditingController> nonTeachingStaffControllers = [];
  bool validateStaffData = false;

  final List<ValueNotifier<int>> staffTotalNotifiers = [];

  final ValueNotifier<int> grandTotalTeachingStaff = ValueNotifier<int>(0);
  final ValueNotifier<int> grandTotalNonTeachingStaff = ValueNotifier<int>(0);
  final ValueNotifier<int> grandTotalStaff = ValueNotifier<int>(0);
  var staffJsonData = <String, Map<String, String>>{};

  final List<String> staffRoles = ['1st', '2nd', '3rd'];

  Map<String, Map<String, int>> classData = {};
  final List<TextEditingController> boysControllers = [];
  final List<TextEditingController> girlsControllers = [];
  bool validateEnrolmentRecords = false;

  final List<ValueNotifier<int>> totalNotifiers = [];
  // Method to validate enrolment data
  bool validateEnrolmentData() {
    for (int i = 0; i < grades.length; i++) {
      if (boysControllers[i].text.isNotEmpty ||
          girlsControllers[i].text.isNotEmpty) {
        return true; // At least one record is present
      }
    }
    return false; // No records present
  }

  final List<String> grades = ['1st', '2nd', '3rd'];
  bool isInitialized = false;

  // ValueNotifiers for the grand totals
  final ValueNotifier<int> grandTotalBoys = ValueNotifier<int>(0);
  final ValueNotifier<int> grandTotalGirls = ValueNotifier<int>(0);
  final ValueNotifier<int> grandTotal = ValueNotifier<int>(0);
  var jsonData = <String, Map<String, String>>{};

  // Function to collect data and convert to JSON
  void collectData() {
    final data = <String, Map<String, String>>{};
    for (int i = 0; i < grades.length; i++) {
      data[grades[i]] = {
        'boys': boysControllers[i].text,
        'girls': girlsControllers[i].text,
      };
    }
    jsonData = data;
  }

  // Collecting Staff Data
  void collectStaffData() {
    final data = <String, Map<String, String>>{};
    for (int i = 0; i < staffRoles.length; i++) {
      data[staffRoles[i]] = {
        'boys': teachingStaffControllers[i].text,
        'girls': nonTeachingStaffControllers[i].text,
      };
    }
    staffJsonData = data;
  }

  @override
  void initState() {
    super.initState();
widget.office.toString();
print(widget.office.toString()
);
    // Initialize controllers and notifiers for Staff Details
    for (int i = 0; i < staffRoles.length; i++) {
      final teachingStaffController = TextEditingController(text: '0');
      final nonTeachingStaffController = TextEditingController(text: '0');
      final totalNotifier = ValueNotifier<int>(0);

      teachingStaffController.addListener(() {
        updateStaffTotal(i);
        collectStaffData();
      });
      nonTeachingStaffController.addListener(() {
        updateStaffTotal(i);
        collectStaffData();
      });

      teachingStaffControllers.add(teachingStaffController);
      nonTeachingStaffControllers.add(nonTeachingStaffController);
      staffTotalNotifiers.add(totalNotifier);
    }

    // Initialize controllers, notifiers, and add listeners
    for (int i = 0; i < grades.length; i++) {
      final boysController = TextEditingController(text: '0');
      final girlsController = TextEditingController(text: '0');
      final totalNotifier = ValueNotifier<int>(0);

      boysController.addListener(() {
        updateTotal(i);
        collectData();
      });
      girlsController.addListener(() {
        updateTotal(i);
        collectData();
      });

      boysControllers.add(boysController);
      girlsControllers.add(girlsController);
      totalNotifiers.add(totalNotifier);
    }

    // Set the initialization flag to true after all controllers and notifiers are initialized
    setState(() {
      isInitialized = true;
    });
  }

  void updateStaffTotal(int index) {
    final teachingCount =
        int.tryParse(teachingStaffControllers[index].text) ?? 0;
    final nonTeachingCount =
        int.tryParse(nonTeachingStaffControllers[index].text) ?? 0;
    staffTotalNotifiers[index].value = teachingCount + nonTeachingCount;

    updateGrandStaffTotal();
  }

  void updateGrandStaffTotal() {
    int teachingSum = 0;
    int nonTeachingSum = 0;

    for (int i = 0; i < staffRoles.length; i++) {
      teachingSum += int.tryParse(teachingStaffControllers[i].text) ?? 0;
      nonTeachingSum += int.tryParse(nonTeachingStaffControllers[i].text) ?? 0;
    }

    grandTotalTeachingStaff.value = teachingSum;
    grandTotalNonTeachingStaff.value = nonTeachingSum;
    grandTotalStaff.value = teachingSum + nonTeachingSum;
  }

  void updateTotal(int index) {
    final boysCount = int.tryParse(boysControllers[index].text) ?? 0;
    final girlsCount = int.tryParse(girlsControllers[index].text) ?? 0;
    totalNotifiers[index].value = boysCount + girlsCount;

    updateGrandTotal();
  }

  void updateGrandTotal() {
    int boysSum = 0;
    int girlsSum = 0;

    for (int i = 0; i < grades.length; i++) {
      boysSum += int.tryParse(boysControllers[i].text) ?? 0;
      girlsSum += int.tryParse(girlsControllers[i].text) ?? 0;
    }

    grandTotalBoys.value = boysSum;
    grandTotalGirls.value = girlsSum;
    grandTotal.value = boysSum + girlsSum;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();

    // Dispose controllers and notifiers
    for (var controller in boysControllers) {
      controller.dispose();
    }
    for (var controller in girlsControllers) {
      controller.dispose();
    }
    for (var notifier in totalNotifiers) {
      notifier.dispose();
    }
    grandTotalBoys.dispose();
    grandTotalGirls.dispose();
    grandTotal.dispose();

    for (var controller in teachingStaffControllers) {
      controller.dispose();
    }
    for (var controller in nonTeachingStaffControllers) {
      controller.dispose();
    }
    for (var notifier in staffTotalNotifiers) {
      notifier.dispose();
    }
    grandTotalTeachingStaff.dispose();
    grandTotalNonTeachingStaff.dispose();
    grandTotalStaff.dispose();
  }

  TableRow tableRowMethod(String classname, TextEditingController boyController,
      TextEditingController girlController, ValueNotifier<int> totalNotifier) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle, // Align vertically to middle

          child: Center(
            child: Text(
              classname,
              style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle, // Align vertically to middle

          child: TextFormField(
            controller: boyController,
            decoration:  InputDecoration(border: InputBorder.none),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly, // Allow only digits
              LengthLimitingTextInputFormatter(3), // Limit to 3 digits
            ],
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle, // Align vertically to middle

          child: TextFormField(
            controller: girlController,
            decoration:  InputDecoration(border: InputBorder.none),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly, // Allow only digits
              LengthLimitingTextInputFormatter(3), // Limit to 3 digits
            ],
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle, // Align vertically to middle

          child: ValueListenableBuilder<int>(
            valueListenable: totalNotifier,
            builder: (context, total, child) {
              return Center(
                child: Text(
                  total.toString(),
                  style:  TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  TableRow staffTableRowMethod(
      String roleName,
      TextEditingController teachingController,
      TextEditingController nonTeachingController,
      ValueNotifier<int> totalNotifier) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle, // Align vertically to middle

          child: Center(
              child: Text(roleName,
                  style:  TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold))),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle, // Align vertically to middle

          child: TextFormField(
            controller: teachingController,
            keyboardType: TextInputType.number, // Set keyboard type to number
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allow only digits
              LengthLimitingTextInputFormatter(3), // Limit to 3 digits
            ],
            decoration:  InputDecoration(border: InputBorder.none),
            textAlign: TextAlign.center,
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle, // Align vertically to middle

          child: TextFormField(
            controller: nonTeachingController,
            keyboardType: TextInputType.number, // Set keyboard type to number
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allow only digits
              LengthLimitingTextInputFormatter(3), // Limit to 3 digits
            ],
            decoration:  InputDecoration(border: InputBorder.none),
            textAlign: TextAlign.center,
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle, // Align vertically to middle

          child: ValueListenableBuilder<int>(
            valueListenable: totalNotifier,
            builder: (context, total, child) {
              return Center(
                  child: Text(total.toString(),
                      style:  TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)));
            },
          ),
        ),
      ],
    );
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
            appBar:  CustomAppbar(
              title: 'ALFA Observation Form',
            ),
            body: Padding(
                padding:  EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(children: [
                      GetBuilder<AlfaObservationController>(
                          init: AlfaObservationController(),
                          builder: (alfaObservationController) {
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
                                          alfaObservationController.tourValue;

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
                                            if (showBasicDetails) ...[
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
                                                focusNode: alfaObservationController
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
                                                    alfaObservationController
                                                        .setSchool(null);
                                                    alfaObservationController
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
                                                    alfaObservationController
                                                        .setSchool(value);
                                                  });
                                                },
                                                selectedItem:
                                                alfaObservationController.schoolValue,
                                              ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label:
                                                'Is this UDISE code is correct?',
                                            astrick: true,
                                          ),
                                          Padding(
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'Yes',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'udiCode'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'udiCode', value);
                                                    if (value == 'Yes') {
                                                      alfaObservationController
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
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'No',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'udiCode'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'udiCode', value);
                                                  },
                                                ),
                                                 Text('No'),
                                              ],
                                            ),
                                          ),
                                          if (alfaObservationController
                                              .getRadioFieldError('udiCode'))
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
                                          if (alfaObservationController
                                                  .getSelectedValue(
                                                      'udiCode') ==
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
                                                  alfaObservationController
                                                      .correctUdiseCodeController,
                                              textInputType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(
                                                    13),
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              labelText:
                                                  'Enter correct UDISE code',
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
                                            label:
                                                'Number of Staff trained on ALFA by Master Trainer?',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          CustomTextFormField(
                                            textController:
                                                alfaObservationController
                                                    .noOfStaffTrainedController,
                                            textInputType: TextInputType.number,
                                            labelText: 'Enter Number',
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
                                                'Upload photo of NURSERY timetable',
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
                                                      _isImageUploadedNursery ==
                                                              false
                                                          ? AppColors.primary
                                                          : AppColors.error),
                                            ),
                                            child: ListTile(
                                                title:
                                                    _isImageUploadedNursery ==
                                                            false
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
                                                          alfaObservationController
                                                              .bottomSheet(
                                                                  context,1)));
                                                }),
                                          ),
                                          ErrorText(
                                            isVisible: validateNursery,
                                            message: 'Register Image Required',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),

                                          alfaObservationController
                                                  .multipleImage.isNotEmpty
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
                                                      alfaObservationController
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
                                                                  alfaObservationController
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
                                                                            CustomImagePreview.showImagePreview(alfaObservationController.multipleImage[index].path,
                                                                                context);
                                                                          },
                                                                          child:
                                                                              Image.file(
                                                                            File(alfaObservationController.multipleImage[index].path),
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
                                                                            alfaObservationController.multipleImage.removeAt(index);
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
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label:
                                                'Upload photo of LKG timetable',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10.0),
                                              border: Border.all(
                                                width: 2,
                                                color: _isImageUploadedLkg == false
                                                    ? AppColors.primary
                                                    : AppColors.error,
                                              ),
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                'Click or Upload Image',
                                                style: TextStyle(
                                                  color: _isImageUploadedLkg == false
                                                      ? Colors.black
                                                      : AppColors.error,
                                                ),
                                              ),
                                              trailing:  Icon(Icons.camera_alt, color: AppColors.onBackground),
                                              onTap: () {
                                                showModalBottomSheet(
                                                  backgroundColor: AppColors.primary,
                                                  context: context,
                                                  builder: (builder) => alfaObservationController.bottomSheet(context, 2),
                                                );
                                              },
                                            ),
                                          ),
                                          ErrorText(
                                            isVisible: validateLkg,
                                            message: 'Library Register Image Required',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          alfaObservationController.multipleImage2.isNotEmpty
                                              ? Container(
                                            width: responsive.responsiveValue(
                                              small: 600.0,
                                              medium: 900.0,
                                              large: 1400.0,
                                            ),
                                            height: responsive.responsiveValue(
                                              small: 170.0,
                                              medium: 170.0,
                                              large: 170.0,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: alfaObservationController.multipleImage2.length,
                                              itemBuilder: (context, index) {
                                                return SizedBox(
                                                  height: 200,
                                                  width: 200,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:  EdgeInsets.all(8.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            CustomImagePreview.showImagePreview(
                                                              alfaObservationController.multipleImage2[index].path,
                                                              context,
                                                            );
                                                          },
                                                          child: Image.file(
                                                            File(alfaObservationController.multipleImage2[index].path),
                                                            width: 190,
                                                            height: 120,
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            alfaObservationController.multipleImage2.removeAt(index);
                                                          });
                                                        },
                                                        child:  Icon(
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
                                              :  SizedBox(),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label:
                                                'upload photo of UKG timetable',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10.0),
                                              border: Border.all(
                                                width: 2,
                                                color: _isImageUploadedUkg == false
                                                    ? AppColors.primary
                                                    : AppColors.error,
                                              ),
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                'Click or Upload Image',
                                                style: TextStyle(
                                                  color: _isImageUploadedUkg == false
                                                      ? Colors.black
                                                      : AppColors.error,
                                                ),
                                              ),
                                              trailing:  Icon(Icons.camera_alt, color: AppColors.onBackground),
                                              onTap: () {
                                                showModalBottomSheet(
                                                  backgroundColor: AppColors.primary,
                                                  context: context,
                                                  builder: (builder) => alfaObservationController.bottomSheet(context, 3),
                                                );
                                              },
                                            ),
                                          ),
                                          ErrorText(
                                            isVisible: validateUkg,
                                            message: 'Library Register Image Required',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          alfaObservationController.multipleImage3.isNotEmpty
                                              ? Container(
                                            width: responsive.responsiveValue(
                                              small: 600.0,
                                              medium: 900.0,
                                              large: 1400.0,
                                            ),
                                            height: responsive.responsiveValue(
                                              small: 170.0,
                                              medium: 170.0,
                                              large: 170.0,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: alfaObservationController.multipleImage3.length,
                                              itemBuilder: (context, index) {
                                                return SizedBox(
                                                  height: 200,
                                                  width: 200,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:  EdgeInsets.all(8.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            CustomImagePreview.showImagePreview(
                                                              alfaObservationController.multipleImage3[index].path,
                                                              context,
                                                            );
                                                          },
                                                          child: Image.file(
                                                            File(alfaObservationController.multipleImage3[index].path),
                                                            width: 190,
                                                            height: 120,
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            alfaObservationController.multipleImage3.removeAt(index);
                                                          });
                                                        },
                                                        child:  Icon(
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
                                              :  SizedBox(),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label:
                                                'Is ALFA English booklet period in the school timetable?',
                                            astrick: true,
                                          ),
                                          Padding(
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'Yes',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'alfaEnglishBooklet'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'alfaEnglishBooklet',
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
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'No',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'alfaEnglishBooklet'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'alfaEnglishBooklet',
                                                            value);
                                                  },
                                                ),
                                                 Text('No'),
                                              ],
                                            ),
                                          ),
                                          if (alfaObservationController
                                              .getRadioFieldError(
                                                  'alfaEnglishBooklet'))
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
                                                'Which module are the children learning in the English booklet?',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          CustomTextFormField(
                                            textController:
                                                alfaObservationController
                                                    .moduleEnglishController,
                                            textInputType: TextInputType.number,
                                            labelText:
                                                'Enter number between 1-80',
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly, // Only allow digits
                                              LengthLimitingTextInputFormatter(
                                                  2), // Limit input length to 2 digits
                                              NumericRangeTextInputFormatter(
                                                  min: 1,
                                                  max:
                                                      80), // Custom input formatter for range
                                            ],
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
                                                'Is ALFA Numeracy booklet period in the school timetable?',
                                            astrick: true,
                                          ),
                                          Padding(
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'Yes',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'alfaNumeracy'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'alfaNumeracy',
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
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'No',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'alfaNumeracy'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'alfaNumeracy',
                                                            value);
                                                  },
                                                ),
                                                 Text('No'),
                                              ],
                                            ),
                                          ),
                                          if (alfaObservationController
                                              .getRadioFieldError(
                                                  'alfaNumeracy'))
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
                                                'Which module are children learning in the Numeracy booklet?',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          CustomTextFormField(
                                            textController:
                                                alfaObservationController
                                                    .alfaNumercyController,
                                            textInputType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly, // Only allow digits
                                              LengthLimitingTextInputFormatter(
                                                  2), // Limit input length to 2 digits
                                              NumericRangeTextInputFormatter(
                                                  min: 1,
                                                  max:
                                                      48), // Custom input formatter for range
                                            ],
                                            labelText:
                                                'Enter number between 1-48',
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
                                                'Are the children learning in pairs?',
                                            astrick: true,
                                          ),
                                          Padding(
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'Yes',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'childrenPairs'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'childrenPairs',
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
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'No',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'childrenPairs'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'childrenPairs',
                                                            value);
                                                  },
                                                ),
                                                 Text('No'),
                                              ],
                                            ),
                                          ),
                                          if (alfaObservationController
                                              .getRadioFieldError(
                                                  'childrenPairs'))
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
                                          CustomButton(
                                            title: 'Next',
                                            onPressedButton: () {
                                              // Perform radio button validations
                                              final isRadioValid1 =
                                                  alfaObservationController
                                                      .validateRadioSelection(
                                                          'udiCode');
                                              final isRadioValid2 =
                                                  alfaObservationController
                                                      .validateRadioSelection(
                                                          'alfaEnglishBooklet');
                                              final isRadioValid3 =
                                                  alfaObservationController
                                                      .validateRadioSelection(
                                                          'alfaNumeracy');
                                              final isRadioValid4 =
                                                  alfaObservationController
                                                      .validateRadioSelection(
                                                          'childrenPairs');
                                              setState(() {
                                                validateNursery =
                                                    alfaObservationController
                                                        .multipleImage.isEmpty;
                                                validateLkg =
                                                    alfaObservationController
                                                        .multipleImage2.isEmpty;
                                                validateUkg =
                                                    alfaObservationController
                                                        .multipleImage3.isEmpty;
                                              });

                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  isRadioValid1 &&
                                                  isRadioValid2 &&
                                                  isRadioValid3 &&
                                                  isRadioValid4 &&
                                                  !validateNursery &&
                                                  !validateLkg &&
                                                  !validateUkg) {
                                                setState(() {
                                                  showBasicDetails = false;
                                                  showAlfamoduleActivities =
                                                      true;
                                                });
                                              }
                                            },
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ], // end of the basic details

                                        // start of alfamoduleActivities
                                        if (showAlfamoduleActivities) ...[
                                          LabelText(
                                            label: 'ALFA Module Activities',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label:
                                                'ALFA module Activities conducted?',
                                            astrick: true,
                                          ),

                                          Padding(
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'Yes',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'alfaModuleActivities'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'alfaModuleActivities',
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
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'No',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'alfaModuleActivities'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'alfaModuleActivities',
                                                            value);
                                                  },
                                                ),
                                                 Text('No'),
                                              ],
                                            ),
                                          ),
                                          if (alfaObservationController
                                              .getRadioFieldError(
                                                  'alfaModuleActivities'))
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
                                          if (alfaObservationController
                                                  .getSelectedValue(
                                                      'alfaModuleActivities') ==
                                              'Yes') ...[
                                            Column(
                                              children: [
                                                Table(
                                                  border: TableBorder.all(),
                                                  children: [
                                                     TableRow(
                                                      children: [
                                                        TableCell(
                                                            verticalAlignment:
                                                            TableCellVerticalAlignment
                                                                .middle, // Align vertically to middle
                                                            child: Center(
                                                                child: Text(
                                                                    'Grade',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                        TableCell(
                                                            verticalAlignment:
                                                            TableCellVerticalAlignment
                                                                .middle, // Align vertically to middle
                                                            child: Center(
                                                                child: Text(
                                                                    'Boys',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                        TableCell(
                                                            verticalAlignment:
                                                            TableCellVerticalAlignment
                                                                .middle, // Align vertically to middle
                                                            child: Center(
                                                                child: Text(
                                                                    'Girls',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                        TableCell(
                                                            verticalAlignment:
                                                            TableCellVerticalAlignment
                                                                .middle, // Align vertically to middle
                                                            child: Center(
                                                                child: Text(
                                                                    'Total',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                      ],
                                                    ),
                                                    for (int i = 0;
                                                        i < grades.length;
                                                        i++)
                                                      tableRowMethod(
                                                        grades[i],
                                                        boysControllers[i],
                                                        girlsControllers[i],
                                                        totalNotifiers[i],
                                                      ),
                                                    TableRow(
                                                      children: [
                                                         TableCell(
                                                            verticalAlignment:
                                                            TableCellVerticalAlignment
                                                                .middle, // Align vertically to middle
                                                            child: Center(
                                                                child: Text(
                                                                    'Grand Total',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                        TableCell(
                                                          verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .middle, // Align vertically to middle
                                                          child:
                                                              ValueListenableBuilder<
                                                                  int>(
                                                            valueListenable:
                                                                grandTotalBoys,
                                                            builder: (context,
                                                                total, child) {
                                                              return Center(
                                                                  child: Text(
                                                                      total
                                                                          .toString(),
                                                                      style:  TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold)));
                                                            },
                                                          ),
                                                        ),
                                                        TableCell(
                                                          verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .middle, // Align vertically to middle
                                                          child:
                                                              ValueListenableBuilder<
                                                                  int>(
                                                            valueListenable:
                                                                grandTotalGirls,
                                                            builder: (context,
                                                                total, child) {
                                                              return Center(
                                                                  child: Text(
                                                                      total
                                                                          .toString(),
                                                                      style:  TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold)));
                                                            },
                                                          ),
                                                        ),
                                                        TableCell(
                                                          verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .middle, // Align vertically to middle
                                                          child:
                                                              ValueListenableBuilder<
                                                                  int>(
                                                            valueListenable:
                                                                grandTotal,
                                                            builder: (context,
                                                                total, child) {
                                                              return Center(
                                                                  child: Text(
                                                                      total
                                                                          .toString(),
                                                                      style:  TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold)));
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            ErrorText(
                                              isVisible:
                                                  validateEnrolmentRecords,
                                              message:
                                                  'Atleast one enrolment record is required',
                                            ),
                                            CustomSizedBox(
                                              value: 40,
                                              side: 'height',
                                            ),
                                             Divider(),
                                            CustomSizedBox(
                                                side: 'height', value: 10),
                                          ],

                                          LabelText(
                                            label: 'Upload Activities photos',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10.0),
                                              border: Border.all(
                                                width: 2,
                                                color: _isImageUploadedAlfaModule == false
                                                    ? AppColors.primary
                                                    : AppColors.error,
                                              ),
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                'Click or Upload Image',
                                                style: TextStyle(
                                                  color: _isImageUploadedAlfaModule == false
                                                      ? Colors.black
                                                      : AppColors.error,
                                                ),
                                              ),
                                              trailing:  Icon(Icons.camera_alt, color: AppColors.onBackground),
                                              onTap: () {
                                                showModalBottomSheet(
                                                  backgroundColor: AppColors.primary,
                                                  context: context,
                                                  builder: (builder) => alfaObservationController.bottomSheet(context, 4),
                                                );
                                              },
                                            ),
                                          ),
                                          ErrorText(
                                            isVisible: validateAlfamodule,
                                            message: 'Library Register Image Required',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          alfaObservationController.multipleImage4.isNotEmpty
                                              ? Container(
                                            width: responsive.responsiveValue(
                                              small: 600.0,
                                              medium: 900.0,
                                              large: 1400.0,
                                            ),
                                            height: responsive.responsiveValue(
                                              small: 170.0,
                                              medium: 170.0,
                                              large: 170.0,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: alfaObservationController.multipleImage4.length,
                                              itemBuilder: (context, index) {
                                                return SizedBox(
                                                  height: 200,
                                                  width: 200,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:  EdgeInsets.all(8.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            CustomImagePreview.showImagePreview(
                                                              alfaObservationController.multipleImage4[index].path,
                                                              context,
                                                            );
                                                          },
                                                          child: Image.file(
                                                            File(alfaObservationController.multipleImage4[index].path),
                                                            width: 190,
                                                            height: 120,
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            alfaObservationController.multipleImage4.removeAt(index);
                                                          });
                                                        },
                                                        child:  Icon(
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
                                              :  SizedBox(),
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
                                                      showBasicDetails = true;
                                                      showAlfamoduleActivities =
                                                          false;
                                                    });
                                                  }),
                                               Spacer(),
                                              CustomButton(
                                                title: 'Next',
                                                onPressedButton: () {
                                                  final isRadioValid5 =
                                                      alfaObservationController
                                                          .validateRadioSelection(
                                                              'alfaModuleActivities');

                                                  setState(() {
                                                    // Validate enrolment records only when 'refresherTrainingOnALFA' is 'Yes'
                                                    if (alfaObservationController
                                                            .getSelectedValue(
                                                                'alfaModuleActivities') ==
                                                        'Yes') {
                                                      validateEnrolmentRecords =
                                                          jsonData.isEmpty;
                                                    } else {
                                                      validateEnrolmentRecords =
                                                          false; // Skip validation
                                                    }

                                                    validateAlfamodule =
                                                        alfaObservationController
                                                            .multipleImage4
                                                            .isEmpty;
                                                  });

                                                  if (_formKey.currentState!
                                                          .validate() &&
                                                      isRadioValid5 &&
                                                      !validateEnrolmentRecords &&
                                                      !validateAlfamodule) {
                                                    // Include image validation here
                                                    setState(() {
                                                      showAlfamoduleActivities =
                                                          false;
                                                      showReferesherTraining =
                                                          true;
                                                    });
                                                  }
                                                },
                                              ),
                                            ],
                                          ),

                                          // Ends of DigiLab Schedule
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ], //  End of alfamoduleActivities

                                        //Start of refresher training

                                        if (showReferesherTraining) ...[
                                          LabelText(
                                            label: 'Refresher Training (ALFA)',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label:
                                                'Refresher Training on ALFA program conducted?',
                                            astrick: true,
                                          ),

                                          Padding(
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'Yes',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'refresherTrainingOnALFA'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'refresherTrainingOnALFA',
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
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'No',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'refresherTrainingOnALFA'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'refresherTrainingOnALFA',
                                                            value);
                                                    if (value == 'No') {
                                                      alfaObservationController
                                                          .noOfTeacherTrainedController
                                                          .clear();
                                                      alfaObservationController
                                                          .multipleImage5
                                                          .clear();
                                                    }
                                                  },
                                                ),
                                                 Text('No'),
                                              ],
                                            ),
                                          ),
                                          if (alfaObservationController
                                              .getRadioFieldError(
                                                  'refresherTrainingOnALFA'))
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
                                          if (alfaObservationController
                                                  .getSelectedValue(
                                                      'refresherTrainingOnALFA') ==
                                              'Yes') ...[
                                            LabelText(
                                              label:
                                                  'Number of Teacher Trained',
                                              astrick: true,
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            CustomTextFormField(
                                              textController:
                                                  alfaObservationController
                                                      .noOfTeacherTrainedController,
                                              textInputType:
                                                  TextInputType.number,
                                              labelText: 'Enter Number',
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
                                              label: 'Upload Training photos',
                                              astrick: true,
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            Container(
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10.0),
                                                border: Border.all(
                                                  width: 2,
                                                  color: _isImageUploadedTeacherTraining == false
                                                      ? AppColors.primary
                                                      : AppColors.error,
                                                ),
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  'Click or Upload Image',
                                                  style: TextStyle(
                                                    color: _isImageUploadedTeacherTraining == false
                                                        ? Colors.black
                                                        : AppColors.error,
                                                  ),
                                                ),
                                                trailing:  Icon(Icons.camera_alt, color: AppColors.onBackground),
                                                onTap: () {
                                                  showModalBottomSheet(
                                                    backgroundColor: AppColors.primary,
                                                    context: context,
                                                    builder: (builder) => alfaObservationController.bottomSheet(context, 5),
                                                  );
                                                },
                                              ),
                                            ),
                                            ErrorText(
                                              isVisible: validateTeacherTraining,
                                              message: 'Library Register Image Required',
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            alfaObservationController.multipleImage5.isNotEmpty
                                                ? Container(
                                              width: responsive.responsiveValue(
                                                small: 600.0,
                                                medium: 900.0,
                                                large: 1400.0,
                                              ),
                                              height: responsive.responsiveValue(
                                                small: 170.0,
                                                medium: 170.0,
                                                large: 170.0,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: alfaObservationController.multipleImage5.length,
                                                itemBuilder: (context, index) {
                                                  return SizedBox(
                                                    height: 200,
                                                    width: 200,
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:  EdgeInsets.all(8.0),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              CustomImagePreview.showImagePreview(
                                                                alfaObservationController.multipleImage5[index].path,
                                                                context,
                                                              );
                                                            },
                                                            child: Image.file(
                                                              File(alfaObservationController.multipleImage5[index].path),
                                                              width: 190,
                                                              height: 120,
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              alfaObservationController.multipleImage5.removeAt(index);
                                                            });
                                                          },
                                                          child:  Icon(
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
                                                :  SizedBox(),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                          ],

                                          Row(
                                            children: [
                                              CustomButton(
                                                  title: 'Back',
                                                  onPressedButton: () {
                                                    setState(() {
                                                      showAlfamoduleActivities =
                                                          true;
                                                      showReferesherTraining =
                                                          false;
                                                    });
                                                  }),
                                               Spacer(),
                                              CustomButton(
                                                title: 'Next',
                                                onPressedButton: () {
                                                  final isRadioValid6 =
                                                      alfaObservationController
                                                          .validateRadioSelection(
                                                              'refresherTrainingOnALFA');

                                                  setState(() {
                                                    if (isRadioValid6 &&
                                                        alfaObservationController
                                                                .getSelectedValue(
                                                                    'refresherTrainingOnALFA') ==
                                                            'Yes') {
                                                      validateTeacherTraining =
                                                          alfaObservationController
                                                              .multipleImage5
                                                              .isEmpty;
                                                    } else {
                                                      validateTeacherTraining =
                                                          false; // Skip validation
                                                    }
                                                  });

                                                  // Proceed only if form is valid, radio selection is valid, and (if needed) teacher training validation passes
                                                  if (_formKey.currentState!
                                                          .validate() &&
                                                      isRadioValid6 &&
                                                      !validateTeacherTraining) {
                                                    setState(() {
                                                      showReferesherTraining =
                                                          false;
                                                      showLibraryReading = true;
                                                    });
                                                  }
                                                },
                                              ),
                                            ],
                                          ),

                                          // Ends of DigiLab Schedule
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ], //end of refresher training

//Start of Library Reading

                                        if (showLibraryReading) ...[
                                          LabelText(
                                            label: 'Library Reading',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                            label:
                                                'Reading Activities conducted?',
                                          ),

                                          Padding(
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'Yes',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'readingActivities'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'readingActivities',
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
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'No',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'readingActivities'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'readingActivities',
                                                            value);
                                                    if (value == 'No') {
                                                      alfaObservationController
                                                          .multipleImage6
                                                          .clear();
                                                    }
                                                  },
                                                ),
                                                 Text('No'),
                                              ],
                                            ),
                                          ),
                                          if (alfaObservationController
                                              .getRadioFieldError(
                                                  'readingActivities'))
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

                                          if (alfaObservationController
                                                  .getSelectedValue(
                                                      'readingActivities') ==
                                              'Yes') ...[
                                            Column(
                                              children: [
                                                // New Staff Details Table

                                                Table(
                                                  border: TableBorder.all(),
                                                  children: [
                                                     TableRow(
                                                      children: [
                                                        TableCell(
                                                            verticalAlignment:
                                                            TableCellVerticalAlignment
                                                                .middle, // Align vertically to middle
                                                            child: Center(
                                                                child: Text(
                                                                    'Grade',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                        TableCell(
                                                            verticalAlignment:
                                                            TableCellVerticalAlignment
                                                                .middle, // Align vertically to middle
                                                            child: Center(
                                                                child: Text(
                                                                    'Boys',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                        TableCell(
                                                            verticalAlignment:
                                                            TableCellVerticalAlignment
                                                                .middle, // Align vertically to middle
                                                            child: Center(
                                                                child: Text(
                                                                    'Girls',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                        TableCell(
                                                            verticalAlignment:
                                                            TableCellVerticalAlignment
                                                                .middle, // Align vertically to middle
                                                            child: Center(
                                                                child: Text(
                                                                    'Total',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                      ],
                                                    ),
                                                    for (int i = 0;
                                                        i < staffRoles.length;
                                                        i++)
                                                      staffTableRowMethod(
                                                        staffRoles[i],
                                                        teachingStaffControllers[
                                                            i],
                                                        nonTeachingStaffControllers[
                                                            i],
                                                        staffTotalNotifiers[i],
                                                      ),
                                                    TableRow(
                                                      children: [
                                                         TableCell(
                                                            verticalAlignment:
                                                            TableCellVerticalAlignment
                                                                .middle, // Align vertically to middle
                                                            child: Center(
                                                                child: Text(
                                                                    'Grand Total',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                        TableCell(
                                                          verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .middle, // Align vertically to middle
                                                          child:
                                                              ValueListenableBuilder<
                                                                  int>(
                                                            valueListenable:
                                                                grandTotalTeachingStaff,
                                                            builder: (context,
                                                                total, child) {
                                                              return Center(
                                                                  child: Text(
                                                                      total
                                                                          .toString(),
                                                                      style:  TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold)));
                                                            },
                                                          ),
                                                        ),
                                                        TableCell(
                                                          verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .middle, // Align vertically to middle
                                                          child:
                                                              ValueListenableBuilder<
                                                                  int>(
                                                            valueListenable:
                                                                grandTotalNonTeachingStaff,
                                                            builder: (context,
                                                                total, child) {
                                                              return Center(
                                                                  child: Text(
                                                                      total
                                                                          .toString(),
                                                                      style:  TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold)));
                                                            },
                                                          ),
                                                        ),
                                                        TableCell(
                                                          verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .middle, // Align vertically to middle
                                                          child:
                                                              ValueListenableBuilder<
                                                                  int>(
                                                            valueListenable:
                                                                grandTotalStaff,
                                                            builder: (context,
                                                                total, child) {
                                                              return Center(
                                                                  child: Text(
                                                                      total
                                                                          .toString(),
                                                                      style:  TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold)));
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            ErrorText(
                                              isVisible: validateStaffData,
                                              message:
                                                  'Atleast one enrolment record is required',
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            LabelText(
                                              label:
                                                  'Upload photo of Library Reading',
                                              astrick: true,
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            Container(
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10.0),
                                                border: Border.all(
                                                  width: 2,
                                                  color: _isImageUploadedReadingActivities == false
                                                      ? AppColors.primary
                                                      : AppColors.error,
                                                ),
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  'Click or Upload Image',
                                                  style: TextStyle(
                                                    color: _isImageUploadedReadingActivities == false
                                                        ? Colors.black
                                                        : AppColors.error,
                                                  ),
                                                ),
                                                trailing:  Icon(Icons.camera_alt, color: AppColors.onBackground),
                                                onTap: () {
                                                  showModalBottomSheet(
                                                    backgroundColor: AppColors.primary,
                                                    context: context,
                                                    builder: (builder) => alfaObservationController.bottomSheet(context, 6),
                                                  );
                                                },
                                              ),
                                            ),
                                            ErrorText(
                                              isVisible: validateReadingActivities,
                                              message: 'Library Register Image Required',
                                            ),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                            alfaObservationController.multipleImage6.isNotEmpty
                                                ? Container(
                                              width: responsive.responsiveValue(
                                                small: 600.0,
                                                medium: 900.0,
                                                large: 1400.0,
                                              ),
                                              height: responsive.responsiveValue(
                                                small: 170.0,
                                                medium: 170.0,
                                                large: 170.0,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: alfaObservationController.multipleImage6.length,
                                                itemBuilder: (context, index) {
                                                  return SizedBox(
                                                    height: 200,
                                                    width: 200,
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:  EdgeInsets.all(8.0),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              CustomImagePreview.showImagePreview(
                                                                alfaObservationController.multipleImage6[index].path,
                                                                context,
                                                              );
                                                            },
                                                            child: Image.file(
                                                              File(alfaObservationController.multipleImage6[index].path),
                                                              width: 190,
                                                              height: 120,
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              alfaObservationController.multipleImage6.removeAt(index);
                                                            });
                                                          },
                                                          child:  Icon(
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
                                                :  SizedBox(),
                                            CustomSizedBox(
                                              value: 20,
                                              side: 'height',
                                            ),
                                          ],

                                          Row(
                                            children: [
                                              CustomButton(
                                                  title: 'Back',
                                                  onPressedButton: () {
                                                    setState(() {
                                                      showReferesherTraining =
                                                          true;
                                                      showLibraryReading =
                                                          false;
                                                    });
                                                  }),
                                               Spacer(),
                                              CustomButton(
                                                title: 'Next',
                                                onPressedButton: () {
                                                  final isRadioValid6 =
                                                      alfaObservationController
                                                          .validateRadioSelection(
                                                              'readingActivities');

                                                  setState(() {
                                                    if (isRadioValid6 &&
                                                        alfaObservationController
                                                                .getSelectedValue(
                                                                    'readingActivities') ==
                                                            'Yes') {
                                                      validateStaffData =
                                                          staffJsonData.isEmpty;
                                                      validateReadingActivities =
                                                          alfaObservationController
                                                              .multipleImage6
                                                              .isEmpty;
                                                    } else {
                                                      validateStaffData =
                                                          false; // Skip validation
                                                      validateReadingActivities =
                                                          false; // Skip validation
                                                    }
                                                  });

                                                  // Proceed only if form is valid, radio selection is valid, and conditional validations pass
                                                  if (_formKey.currentState!
                                                          .validate() &&
                                                      isRadioValid6 &&
                                                      !validateStaffData &&
                                                      !validateReadingActivities) {
                                                    setState(() {
                                                      showLibraryReading =
                                                          false;
                                                      showClassroomObservation =
                                                          true;
                                                    });
                                                  }
                                                },
                                              ),
                                            ],
                                          ),

                                          // Ends of DigiLab Schedule
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                        ], //End of Library Reading

                                        // Start of Classroom Observation

                                        if (showClassroomObservation) ...[
                                          LabelText(
                                            label: 'Classroom Observation',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          LabelText(
                                              label:
                                                  'Note** Observe an English or Maths class being conducted in Grade 1 , 2 or 3 by a Teacher who has attended Centralized Training conducted by 17000ft',
                                              textColor: Colors.purple),

                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),

                                          LabelText(
                                            label:
                                                'Is the teacher using the ALFA booklet and TLM kit??',
                                            astrick: true,
                                          ),

                                          Padding(
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'Yes',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'tlmKit'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'tlmKit', value);
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
                                            padding:  EdgeInsets.only(
                                                 right: screenWidth * 0.1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 'No',
                                                  groupValue:
                                                      alfaObservationController
                                                          .getSelectedValue(
                                                              'tlmKit'),
                                                  onChanged: (value) {
                                                    alfaObservationController
                                                        .setRadioValue(
                                                            'tlmKit', value);
                                                  },
                                                ),
                                                 Text('No'),
                                              ],
                                            ),
                                          ),
                                          if (alfaObservationController
                                              .getRadioFieldError('tlmKit'))
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
                                            label: 'Upload photo of Class',
                                            astrick: true,
                                          ),

                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10.0),
                                              border: Border.all(
                                                width: 2,
                                                color: _isImageUploadedTlmKit == false
                                                    ? AppColors.primary
                                                    : AppColors.error,
                                              ),
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                'Click or Upload Image',
                                                style: TextStyle(
                                                  color: _isImageUploadedTlmKit == false
                                                      ? Colors.black
                                                      : AppColors.error,
                                                ),
                                              ),
                                              trailing:  Icon(Icons.camera_alt, color: AppColors.onBackground),
                                              onTap: () {
                                                showModalBottomSheet(
                                                  backgroundColor: AppColors.primary,
                                                  context: context,
                                                  builder: (builder) => alfaObservationController.bottomSheet(context, 7),
                                                );
                                              },
                                            ),
                                          ),
                                          ErrorText(
                                            isVisible: validateTlmKit,
                                            message: 'Library Register Image Required',
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          alfaObservationController.multipleImage7.isNotEmpty
                                              ? Container(
                                            width: responsive.responsiveValue(
                                              small: 600.0,
                                              medium: 900.0,
                                              large: 1400.0,
                                            ),
                                            height: responsive.responsiveValue(
                                              small: 170.0,
                                              medium: 170.0,
                                              large: 170.0,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: alfaObservationController.multipleImage7.length,
                                              itemBuilder: (context, index) {
                                                return SizedBox(
                                                  height: 200,
                                                  width: 200,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:  EdgeInsets.all(8.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            CustomImagePreview.showImagePreview(
                                                              alfaObservationController.multipleImage7[index].path,
                                                              context,
                                                            );
                                                          },
                                                          child: Image.file(
                                                            File(alfaObservationController.multipleImage7[index].path),
                                                            width: 190,
                                                            height: 120,
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            alfaObservationController.multipleImage7.removeAt(index);
                                                          });
                                                        },
                                                        child:  Icon(
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
                                              :  SizedBox(),

                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),

                                          LabelText(
                                            label:
                                                'Observation without teaching methods used and student response',
                                            astrick: true,
                                          ),
                                          CustomSizedBox(
                                            value: 20,
                                            side: 'height',
                                          ),
                                          CustomTextFormField(
                                            textController:
                                                alfaObservationController
                                                    .remarksController,
                                            labelText: 'Write here..',
                                            maxlines: 3,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please fill this field';
                                              }

                                              if (value.length < 25) {
                                                return 'Must be at least 25 characters long';
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
                                                      showLibraryReading = true;
                                                      showClassroomObservation =
                                                          false;
                                                    });
                                                  }),
                                               Spacer(),
                                              CustomButton(
                                                  title: 'Submit',
                                                  onPressedButton: () async {
                                                    final isRadioValid7 =
                                                        alfaObservationController
                                                            .validateRadioSelection(
                                                                'tlmKit');
                                                    setState(() {
                                                      validateTlmKit =
                                                          alfaObservationController
                                                              .multipleImage7
                                                              .isEmpty;
                                                    });

                                                    if (_formKey.currentState!
                                                            .validate() &&
                                                        isRadioValid7 &&
                                                        !validateTlmKit) {


                                                      List<File>
                                                          nurTimeTableFiles =
                                                          [];
                                                      for (var imagePath
                                                          in alfaObservationController
                                                              .imagePaths) {
                                                        nurTimeTableFiles.add(File(
                                                            imagePath)); // Convert image path to File
                                                      }

                                                      final selectController =
                                                      Get.put(SelectController());
                                                      String? lockedTourId =
                                                          selectController.lockedTourId;

                                                      // Use lockedTourId if it is available, otherwise use the selected tour ID from schoolEnrolmentController
                                                      String tourIdToInsert =
                                                          lockedTourId ??
                                                              alfaObservationController
                                                                  .tourValue ??
                                                              '';

                                                      List<File>
                                                          lkgTimeTableFiles =
                                                          [];
                                                      for (var imagePath2
                                                          in alfaObservationController
                                                              .imagePaths2) {
                                                        lkgTimeTableFiles.add(File(
                                                            imagePath2)); // Convert image path to File
                                                      }

                                                      List<File>
                                                          ukgTimeTableFiles =
                                                          [];
                                                      for (var imagePath3
                                                          in alfaObservationController
                                                              .imagePaths3) {
                                                        ukgTimeTableFiles.add(File(
                                                            imagePath3)); // Convert image path to File
                                                      }

                                                      List<File> alfaImgFiles =
                                                          [];
                                                      for (var imagePath4
                                                          in alfaObservationController
                                                              .imagePaths4) {
                                                        alfaImgFiles.add(File(
                                                            imagePath4)); // Convert image path to File
                                                      }

                                                      List<File>
                                                          trainingImgFiles = [];
                                                      for (var imagePath5
                                                          in alfaObservationController
                                                              .imagePaths5) {
                                                        trainingImgFiles.add(File(
                                                            imagePath5)); // Convert image path to File
                                                      }

                                                      List<File> libImgFiles =
                                                          [];
                                                      for (var imagePath6
                                                          in alfaObservationController
                                                              .imagePaths6) {
                                                        libImgFiles.add(File(
                                                            imagePath6)); // Convert image path to File
                                                      }

                                                      List<File> tlmImgFiles =
                                                          [];
                                                      for (var imagePath7
                                                          in alfaObservationController
                                                              .imagePaths7) {
                                                        tlmImgFiles.add(File(
                                                            imagePath7)); // Convert image path to File
                                                      }

                                                      DateTime now =
                                                          DateTime.now();
                                                      String formattedDate =
                                                          DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(now);

                                                      String
                                                          nurTimeTableFilePaths =
                                                          nurTimeTableFiles
                                                              .map((file) =>
                                                                  file.path)
                                                              .join(',');
                                                      String
                                                          lkgTimeTableFilePaths =
                                                          lkgTimeTableFiles
                                                              .map((file) =>
                                                                  file.path)
                                                              .join(',');
                                                      String
                                                          ukgTimeTableFilePaths =
                                                          ukgTimeTableFiles
                                                              .map((file) =>
                                                                  file.path)
                                                              .join(',');
                                                      String alfaImgFilesPaths =
                                                          alfaImgFiles
                                                              .map((file) =>
                                                                  file.path)
                                                              .join(',');
                                                      String
                                                          trainingImgFilesPaths =
                                                          trainingImgFiles
                                                              .map((file) =>
                                                                  file.path)
                                                              .join(',');
                                                      String libImgFilesPaths =
                                                          libImgFiles
                                                              .map((file) =>
                                                                  file.path)
                                                              .join(',');
                                                      String tlmImgFilesPaths =
                                                          tlmImgFiles
                                                              .map((file) =>
                                                                  file.path)
                                                              .join(',');

                                                      // Convert `jsonData` to a JSON string
                                                      String alfaGradeReport =
                                                          jsonEncode(
                                                              jsonData); // Ensure the JSON data is properly encoded
                                                      String libGradeReport =
                                                          jsonEncode(
                                                              staffJsonData); // Ensure the JSON data is properly encoded

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
                                                                    .nextInt(
                                                                    _chars
                                                                        .length))));
                                                      }
                                                      String uniqueId =
                                                      generateUniqueId(6);

                                                      // Create the enrolment collection object
                                                      AlfaObservationModel
                                                          alfaObservationObj =
                                                          AlfaObservationModel(
                                                              tourId: tourIdToInsert,
                                                              school: alfaObservationController.schoolValue ??
                                                                  '',
                                                              udiseValue:
                                                                  alfaObservationController.getSelectedValue('udiCode') ??
                                                                      '',
                                                              correctUdise: alfaObservationController
                                                                  .correctUdiseCodeController
                                                                  .text,
                                                              noStaffTrained:
                                                                  alfaObservationController
                                                                      .noOfStaffTrainedController
                                                                      .text,
                                                              imgNurTimeTable:
                                                                  nurTimeTableFilePaths, // Convert list to a single string
                                                              imgLKGTimeTable:
                                                                  lkgTimeTableFilePaths, // Convert list to a single string
                                                              imgUKGTimeTable:
                                                                  ukgTimeTableFilePaths, // Convert list to a single string
                                                              bookletValue:
                                                                  alfaObservationController.getSelectedValue('alfaEnglishBooklet') ??
                                                                      '',
                                                              moduleValue: alfaObservationController
                                                                  .moduleEnglishController
                                                                  .text,
                                                              numeracyBooklet:
                                                                  alfaObservationController.getSelectedValue('alfaNumeracy') ??
                                                                      '',
                                                              numeracyValue: alfaObservationController
                                                                  .alfaNumercyController
                                                                  .text,
                                                              pairValue:
                                                                  alfaObservationController.getSelectedValue('childrenPairs') ??
                                                                      '',
                                                              alfaActivityValue:
                                                                  alfaObservationController.getSelectedValue('alfaModuleActivities') ??
                                                                      '',
                                                              alfaGradeReport:
                                                                  alfaGradeReport,
                                                              imgAlfa: alfaImgFilesPaths, // Convert list to a single string
                                                              refresherTrainingValue: alfaObservationController.getSelectedValue('refresherTrainingOnALFA') ?? '',
                                                              noTrainedTeacher: alfaObservationController.noOfTeacherTrainedController.text,
                                                              imgTraining: trainingImgFilesPaths, // Convert list to a single string
                                                              readingValue: alfaObservationController.getSelectedValue('readingActivities') ?? '',
                                                              libGradeReport: libGradeReport,
                                                              imgLibrary: libImgFilesPaths, // Convert list to a single string
                                                              tlmKitValue: alfaObservationController.getSelectedValue('tlmKit') ?? '',
                                                              imgTlm: tlmImgFilesPaths, // Convert list to a single string
                                                              classObservation: alfaObservationController.remarksController.text,
                                                              createdAt: formattedDate.toString(),
                                                              office: widget.office ?? 'Default Office',

                                                              createdBy: widget.userid.toString());
                                                      print('Office value: ${widget.office}'); // Debugging line



                                                      int result =
                                                          await LocalDbController()
                                                              .addData(
                                                                  alfaObservationModel:
                                                                      alfaObservationObj);
                                                      if (result > 0) {
                                                        alfaObservationController
                                                            .clearFields();
                                                        setState(() {
                                                          jsonData = {};
                                                          staffJsonData = {};
                                                        });
                                                        String jsonData1 =
                                                        jsonEncode(
                                                            alfaObservationObj
                                                                .toJson());

                                                        try {
                                                          JsonFileDownloader
                                                          downloader =
                                                          JsonFileDownloader();
                                                          String? filePath = await downloader
                                                              .downloadJsonFile(
                                                              jsonData1,
                                                              uniqueId,
                                                              nurTimeTableFiles,
                                                              lkgTimeTableFiles,
                                                              ukgTimeTableFiles,

                                                              tlmImgFiles,

                                                              trainingImgFiles,libImgFiles,alfaImgFiles

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
                                                            'Submitted',
                                                            AppColors.primary,
                                                            AppColors.onPrimary,
                                                            Icons.verified);

                                                        // Navigate to HomeScreen
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                   HomeScreen()),
                                                        );
                                                      } else {
                                                        customSnackbar(
                                                            'Error',
                                                            'Something went wrong',
                                                            AppColors.error,
                                                            Colors.white,
                                                            Icons.error);
                                                      }
                                                    } else {
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              FocusNode());
                                                    }
                                                  }),
                                            ],
                                          ),
                                        ] // End of Classroom Observation
                                      ]);
                                    }));
                          })
                    ])))));
  }
}

class JsonFileDownloader {
  // Method to download JSON data to the Downloads directory
  Future<String?> downloadJsonFile(

      String jsonData,
      String uniqueId,
      List<File> nurTimeTableFiles,
      List<File> lkgTimeTableFiles,
      List<File> ukgTimeTableFiles,
      List<File> alfaImgFiles,
      List<File> trainingImgFiles,
      List<File> libImgFiles,
      List<File> tlmImgFiles,
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
          '${downloadsDirectory.path}/alfa_observation_form_$uniqueId.txt';
      File file = File(filePath);

      // Convert images to Base64 for each image list
      Map<String, dynamic> jsonObject = jsonDecode(jsonData);

      jsonObject['base64_nurTimeTableImages'] =
      await _convertImagesToBase64(nurTimeTableFiles);
      jsonObject['base64_lkgTimeTableImages'] =
      await _convertImagesToBase64(lkgTimeTableFiles);
      jsonObject['base64_ukgTimeTableImages'] =
      await _convertImagesToBase64(ukgTimeTableFiles);
      jsonObject['base64_alfaImages'] =
      await _convertImagesToBase64(alfaImgFiles);
      jsonObject['base64_tlmImages'] =
      await _convertImagesToBase64(tlmImgFiles);
      jsonObject['base64_trainingImages'] =
      await _convertImagesToBase64(trainingImgFiles);
      jsonObject['base64_libImages'] =
      await _convertImagesToBase64(libImgFiles);

      // Write the updated JSON data to the file
      await file.writeAsString(jsonEncode(jsonObject));

      // Return the file path for further use if needed
      return filePath;
    } else {
      throw Exception('Could not find the download directory');
    }
  }

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


class NumericRangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  NumericRangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue; // Allow empty input
    }

    final int? newValueInt = int.tryParse(newValue.text);
    if (newValueInt != null && (newValueInt < min || newValueInt > max)) {
      return oldValue; // Prevent entering numbers outside the range
    }

    return newValue; // Allow valid input
  }
}
