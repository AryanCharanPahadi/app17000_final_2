import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:app17000ft_new/forms/edit_form/edit%20controller.dart';
import 'package:app17000ft_new/forms/school_enrolment/school_enrolment_sync.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart'; // For a safer directory path handling

import 'package:app17000ft_new/components/custom_appBar.dart';
import 'package:app17000ft_new/components/custom_button.dart';
import 'package:app17000ft_new/components/custom_imagepreview.dart';
import 'package:app17000ft_new/components/custom_snackbar.dart';
import 'package:app17000ft_new/components/custom_textField.dart';
import 'package:app17000ft_new/components/error_text.dart';
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/forms/school_enrolment/school_enrolment_model.dart';
import 'package:app17000ft_new/helper/database_helper.dart';
import 'package:app17000ft_new/helper/responsive_helper.dart';
import 'package:app17000ft_new/tourDetails/tour_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:app17000ft_new/components/custom_dropdown.dart';
import 'package:app17000ft_new/components/custom_labeltext.dart';
import 'package:app17000ft_new/components/custom_sizedBox.dart';
import 'package:app17000ft_new/forms/school_enrolment/school_enrolment_controller.dart';
import 'package:app17000ft_new/home/home_screen.dart';

import '../../components/custom_confirmation.dart';
import '../select_tour_id/select_controller.dart';

class SchoolEnrollmentForm extends StatefulWidget {
  String? userid;
  final EnrolmentCollectionModel? existingRecord;
  String? tourId; // Add this line
  String? school; // Add this line for school
  String? office;

  SchoolEnrollmentForm({
    super.key,
    this.userid,
    this.existingRecord,
    this.school,
    this.office,
    this.tourId, // Update the constructor to accept tourId
  });

  @override
  State<SchoolEnrollmentForm> createState() => _SchoolEnrollmentFormState();
}

class _SchoolEnrollmentFormState extends State<SchoolEnrollmentForm> {
  // Map to store boys and girls count for each class
  bool validateRegister = false; // for the nursery timetable
  final bool _isImageUploaded = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  List<String> splitSchoolLists = [];
  final EditController editController = Get.put(EditController());
  // Define lists to hold the controllers and total notifiers for each grade

  final List<TextEditingController> boysControllers = [];
  final List<TextEditingController> girlsControllers = [];
  bool validateEnrolmentRecords = false;
  final List<ValueNotifier<int>> totalNotifiers = [];

  bool validateEnrolmentData() {
    for (int i = 0; i < grades.length; i++) {
      if (boysControllers[i].text.isNotEmpty ||
          girlsControllers[i].text.isNotEmpty) {
        return true; // At least one record is present
      }
    }
    return false; // No records present
  }

  final List<String> grades = [
    'Nursery',
    'L.K.G',
    'U.K.G',
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
    '6th',
    '7th',
    '8th',
    '9th',
    '10th',
    '11th',
    '12th'
  ];
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

  @override
  void initState() {
    super.initState();
    print('Office init ${widget.office}');
    print('UserId init ${widget.userid}');

    _initializeController();
    _setupControllers();
    _loadExistingRecordData();

  }

  void _initializeController() {
    if (!Get.isRegistered<SchoolEnrolmentController>()) {
      Get.put(SchoolEnrolmentController());
    }
  }

  void _setupControllers() {
    // Initialize controllers for all grades if not yet initialized
    for (int i = boysControllers.length; i < grades.length; i++) {
      boysControllers.add(TextEditingController(text: '0'));
      girlsControllers.add(TextEditingController(text: '0'));
      totalNotifiers.add(ValueNotifier<int>(0));
    }

    // Add listeners for data collection and total updates
    for (int i = 0; i < grades.length; i++) {
      boysControllers[i].addListener(() {
        updateTotal(i);
        collectData();
      });
      girlsControllers[i].addListener(() {
        updateTotal(i);
        collectData();
      });
    }
  }

  void _loadExistingRecordData() {
    final schoolEnrolmentController = Get.find<SchoolEnrolmentController>();

    if (widget.existingRecord == null) {
      print("No existing record found.");
      return;
    }

    final existingRecord = widget.existingRecord!;
    schoolEnrolmentController.setTour(existingRecord.tourId);
    schoolEnrolmentController.setSchool(existingRecord.school);
    schoolEnrolmentController.remarksController.text =
        existingRecord.remarks ?? '';

    _parseEnrolmentData(existingRecord.enrolmentData);
  }

  void _parseEnrolmentData(String? enrolmentDataString) {
    if (enrolmentDataString == null || enrolmentDataString.isEmpty) {
      print("Enrolment data string is null or empty.");
      return;
    }

    try {
      final correctedJsonString = enrolmentDataString.replaceAllMapped(
          RegExp(r'(\w+):'), (match) => '"${match[1]}":');
      final parsedData =
      jsonDecode(correctedJsonString) as Map<String, dynamic>;

      print("Corrected Parsed Data: $parsedData");

      // Populate controllers with parsed data for each grade
      for (int i = 0; i < grades.length; i++) {
        final grade = grades[i];
        if (parsedData.containsKey(grade)) {
          boysControllers[i].text =
              parsedData[grade]?['boys']?.toString() ?? '0';
          girlsControllers[i].text =
              parsedData[grade]?['girls']?.toString() ?? '0';
          updateTotal(i); // Update total for each grade
        } else {
          print("Grade '$grade' not found in parsed data.");
        }
      }
      updateGrandTotal(); // Update grand total after loading data
    } catch (e) {
      print("Error parsing corrected JSON: $e");
    }
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
  }

  TableRow tableRowMethod(String classname, TextEditingController boyController,
      TextEditingController girlController, ValueNotifier<int> totalNotifier) {
    return TableRow(
      children: [
        // Classname
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Adjust font size based on screen width
              double fontSize = constraints.maxWidth < 600 ? 14 : 18;
              return Center(
                child: Text(
                  classname,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),

        // Boy Count Input
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Adjust padding based on screen width
              double padding = constraints.maxWidth < 600 ? 8 : 16;
              return Padding(
                padding: EdgeInsets.all(padding),
                child: TextFormField(
                  controller: boyController,
                  decoration: const InputDecoration(border: InputBorder.none),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(3), // Limit to 3 digits
                  ],
                ),
              );
            },
          ),
        ),

        // Girl Count Input
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double padding = constraints.maxWidth < 600 ? 8 : 16;
              return Padding(
                padding: EdgeInsets.all(padding),
                child: TextFormField(
                  controller: girlController,
                  decoration: const InputDecoration(border: InputBorder.none),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(3), // Limit to 3 digits
                  ],
                ),
              );
            },
          ),
        ),

        // Total
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: ValueListenableBuilder<int>(
            valueListenable: totalNotifier,
            builder: (context, total, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Adjust total display size based on screen width
                  double fontSize = constraints.maxWidth < 600 ? 14 : 18;
                  return Center(
                    child: Text(
                      total.toString(),
                      style: TextStyle(
                          fontSize: fontSize, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              // Close the dialog and return true
              Navigator.of(context).pop(true);
            },
          ),
        );

        // If the user confirmed exit, navigate to HomeScreen
        if (shouldExit == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }

        // Return false to prevent the default back navigation
        return false;
      },
      child: Scaffold(
        appBar: const CustomAppbar(
          title: 'School Enrollment Form',
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                GetBuilder<SchoolEnrolmentController>(
                    init: SchoolEnrolmentController(),
                    builder: (schoolEnrolmentController) {
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
                                    schoolEnrolmentController.tourValue;

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
                                    LabelText(
                                      label: 'Tour ID',
                                      astrick: true,
                                    ),
                                    CustomSizedBox(
                                      value: 20,
                                      side: 'height',
                                    ),
                                    CustomDropdownFormField(
                                      focusNode: schoolEnrolmentController
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
                                                schoolEnrolmentController
                                                    .setSchool(null);
                                                schoolEnrolmentController
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
                                          const DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "Select School",
                                          hintText: "Select School",
                                        ),
                                      ),
                                      onChanged: (value) {
                                        // Set the selected school
                                        setState(() {
                                          schoolEnrolmentController
                                              .setSchool(value);
                                        });
                                      },
                                      selectedItem:
                                          schoolEnrolmentController.schoolValue,
                                    ),

                                    CustomSizedBox(
                                      value: 20,
                                      side: 'height',
                                    ),
                                    LabelText(
                                      label: 'Upload or Click Register Photo',
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
                                              ? const Text(
                                                  'Click or Upload Image',
                                                )
                                              : const Text(
                                                  'Click or Upload Image',
                                                  style: TextStyle(
                                                      color: AppColors.error),
                                                ),
                                          trailing: const Icon(Icons.camera_alt,
                                              color: AppColors.onBackground),
                                          onTap: () {
                                            showModalBottomSheet(
                                                backgroundColor:
                                                    AppColors.primary,
                                                context: context,
                                                builder: ((builder) =>
                                                    schoolEnrolmentController
                                                        .bottomSheet(context)));
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

                                    schoolEnrolmentController
                                            .multipleImage.isNotEmpty
                                        ? Container(
                                            width: responsive.responsiveValue(
                                                small: 600.0,
                                                medium: 900.0,
                                                large: 1400.0),
                                            height: responsive.responsiveValue(
                                                small: 170.0,
                                                medium: 170.0,
                                                large: 170.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: schoolEnrolmentController
                                                    .multipleImage.isEmpty
                                                ? const Center(
                                                    child: Text(
                                                        'No images selected.'),
                                                  )
                                                : ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        schoolEnrolmentController
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
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  CustomImagePreview.showImagePreview(
                                                                      schoolEnrolmentController
                                                                          .multipleImage[
                                                                              index]
                                                                          .path,
                                                                      context);
                                                                },
                                                                child:
                                                                    Image.file(
                                                                  File(schoolEnrolmentController
                                                                      .multipleImage[
                                                                          index]
                                                                      .path),
                                                                  width: 190,
                                                                  height: 120,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  schoolEnrolmentController
                                                                      .multipleImage
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              },
                                                              child: const Icon(
                                                                Icons.delete,
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
                                        : const SizedBox(),
                                    CustomSizedBox(
                                      value: 40,
                                      side: 'height',
                                    ),

                                    // const MyTable(),
                                    Column(
                                      children: [
                                        Table(
                                          border: TableBorder.all(),
                                          children: [
                                            const TableRow(
                                              children: [
                                                TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .middle, // Align vertically to middle
                                                    child: Center(
                                                        child: Text('Grade',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)))),
                                                TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .middle, // Align vertically to middle
                                                    child: Center(
                                                        child: Text('Boys',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)))),
                                                TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .middle, // Align vertically to middle
                                                    child: Center(
                                                        child: Text('Girls',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)))),
                                                TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .middle, // Align vertically to middle
                                                    child: Center(
                                                        child: Text('Total',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)))),
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
                                                const TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .middle, // Align vertically to middle
                                                    child: Center(
                                                        child: Text(
                                                            'Grand Total',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)))),
                                                TableCell(
                                                  verticalAlignment:
                                                      TableCellVerticalAlignment
                                                          .middle, // Align vertically to middle
                                                  child: ValueListenableBuilder<
                                                      int>(
                                                    valueListenable:
                                                        grandTotalBoys,
                                                    builder: (context, total,
                                                        child) {
                                                      return Center(
                                                          child: Text(
                                                              total.toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)));
                                                    },
                                                  ),
                                                ),
                                                TableCell(
                                                  verticalAlignment:
                                                      TableCellVerticalAlignment
                                                          .middle, // Align vertically to middle
                                                  child: ValueListenableBuilder<
                                                      int>(
                                                    valueListenable:
                                                        grandTotalGirls,
                                                    builder: (context, total,
                                                        child) {
                                                      return Center(
                                                          child: Text(
                                                              total.toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)));
                                                    },
                                                  ),
                                                ),
                                                TableCell(
                                                  verticalAlignment:
                                                      TableCellVerticalAlignment
                                                          .middle, // Align vertically to middle
                                                  child: ValueListenableBuilder<
                                                      int>(
                                                    valueListenable: grandTotal,
                                                    builder: (context, total,
                                                        child) {
                                                      return Center(
                                                          child: Text(
                                                              total.toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)));
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
                                      isVisible: validateEnrolmentRecords,
                                      message:
                                          'Atleast one enrolment record is required',
                                    ),
                                    CustomSizedBox(
                                      value: 40,
                                      side: 'height',
                                    ),

                                    const Divider(),

                                    CustomSizedBox(side: 'height', value: 10),
                                    LabelText(
                                      label: 'Remarks',
                                    ),
                                    CustomSizedBox(side: 'height', value: 20),
                                    CustomTextFormField(
                                      textController: schoolEnrolmentController
                                          .remarksController,
                                      labelText: 'Write your comments..',
                                      maxlines: 2,
                                    ),
                                    CustomSizedBox(
                                      value: 20,
                                      side: 'height',
                                    ),
                                    CustomButton(
                                      title: 'Submit',
                                      onPressedButton: () async {
                                        // Perform validation
                                        setState(() {
                                          validateRegister =
                                              schoolEnrolmentController
                                                  .multipleImage.isEmpty;
                                          validateEnrolmentRecords =
                                              jsonData.isEmpty;
                                        });

                                        if (schoolEnrolmentController
                                            .multipleImage.isEmpty) {
                                          customSnackbar(
                                            'Error',
                                            'Please upload or capture a register photo',
                                            AppColors.error,
                                            Colors.white,
                                            Icons.error,
                                          );
                                          return;
                                        }

                                        if (validateEnrolmentRecords) {
                                          customSnackbar(
                                            'Error',
                                            'At least one enrollment record is required',
                                            AppColors.error,
                                            Colors.white,
                                            Icons.error,
                                          );
                                          return;
                                        }

                                        if (_formKey.currentState!.validate()) {
                                          DateTime now = DateTime.now();
                                          String formattedDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(now);

                                          // Convert image paths to File format
                                          List<File> registerImageFiles = [];
                                          for (var imagePath
                                              in schoolEnrolmentController
                                                  .imagePaths) {
                                            registerImageFiles.add(File(
                                                imagePath)); // Convert image path to File
                                          }
                                          String generateUniqueId(int length) {
                                            const _chars =
                                                'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                                            Random _rnd = Random();
                                            return String.fromCharCodes(
                                                Iterable.generate(
                                                    length,
                                                    (_) => _chars.codeUnitAt(
                                                        _rnd.nextInt(
                                                            _chars.length))));
                                          }

                                          String uniqueId = generateUniqueId(6);
                                          // Check if the image files have been created correctly
                                          if (registerImageFiles.isEmpty) {
                                            customSnackbar(
                                              'Error',
                                              'Image files could not be found',
                                              AppColors.error,
                                              Colors.white,
                                              Icons.error,
                                            );
                                            return;
                                          }

                                          // Prepare image file paths to store in the database (comma-separated)
                                          String registerImageFilePaths =
                                              registerImageFiles
                                                  .map((file) => file.path)
                                                  .join(',');

                                          // Convert `jsonData` to a JSON string for enrolment records
                                          String enrolmentDataJson = jsonEncode(
                                              jsonData); // Ensure the JSON data is properly encoded
                                          // Get locked tour ID from SelectController
                                          final selectController =
                                              Get.put(SelectController());
                                          String? lockedTourId =
                                              selectController.lockedTourId;

                                          // Use lockedTourId if it is available, otherwise use the selected tour ID from schoolEnrolmentController
                                          String tourIdToInsert =
                                              lockedTourId ??
                                                  schoolEnrolmentController
                                                      .tourValue ??
                                                  '';
                                          // Create the enrolment collection object
                                          EnrolmentCollectionModel
                                              enrolmentCollectionObj =
                                              EnrolmentCollectionModel(
                                            tourId:
                                                tourIdToInsert, // Insert locked tour ID or selected tour ID
                                            school: schoolEnrolmentController
                                                    .schoolValue ??
                                                '',
                                            registerImage:
                                                registerImageFilePaths, // Store file paths instead of converting to Base64
                                            enrolmentData:
                                                enrolmentDataJson, // Store as valid JSON string
                                            remarks: schoolEnrolmentController
                                                    .remarksController.text ??
                                                '',
                                            createdAt: formattedDate,
                                            submittedBy:
                                                widget.userid.toString(),
                                            office: widget.office ?? '',
                                          );

                                          // Insert the data into the local database
                                          int result =
                                              await LocalDbController().addData(
                                            enrolmentCollectionModel:
                                                enrolmentCollectionObj,
                                          );

                                          if (result > 0) {
                                            // Clear form fields upon successful insertion
                                            schoolEnrolmentController
                                                .clearFields();
                                            schoolEnrolmentController
                                                .remarksController
                                                .clear();
                                            editController.clearFields();
                                            // Reset any additional variables (like jsonData) in the current state
                                            setState(() {
                                              jsonData =
                                                  {}; // Resetting JSON data if required
                                            });

                                            String jsonData1 = jsonEncode(
                                                enrolmentCollectionObj
                                                    .toJson());

                                            try {
                                              JsonFileDownloader downloader =
                                                  JsonFileDownloader();
                                              String? filePath = await downloader
                                                  .downloadJsonFile(
                                                      jsonData1,
                                                      uniqueId,
                                                      registerImageFiles); // Pass the registerImageFiles
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
                                              print(e);
                                            }
                                            customSnackbar(
                                              'Submitted Successfully',
                                              'Your data has been submitted',
                                              AppColors.primary,
                                              AppColors.onPrimary,
                                              Icons.verified,
                                            );

                                            // Navigate to HomeScreen
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomeScreen(),
                                              ),
                                            );
                                          } else {
                                            customSnackbar(
                                              'Error',
                                              'Something went wrong',
                                              AppColors.error,
                                              Colors.white,
                                              Icons.error,
                                            );
                                          }
                                        } else {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                        }
                                      },
                                    )
                                  ],
                                );
                              }));
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class JsonFileDownloader {
  // Method to download JSON data to the Downloads directory
  Future<String?> downloadJsonFile(
    String jsonData,
    String uniqueId,
    List<File> imageFiles,
  ) async {
    // Request storage permission

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
          '${downloadsDirectory.path}/school_enrollment_form_$uniqueId.txt';
      File file = File(filePath);

      // Convert images to Base64
      List<String> base64Images = [];
      for (var image in imageFiles) {
        List<int> imageBytes = await image.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        base64Images.add(base64Image);
      }

      // Add Base64 image data to the JSON object
      Map<String, dynamic> jsonObject = jsonDecode(jsonData);
      jsonObject['images'] = base64Images;

      // Write the updated JSON data to the file
      await file.writeAsString(jsonEncode(jsonObject));

      // Return the file path for further use if needed
      return filePath;
    } else {
      throw Exception('Could not find the download directory');
    }
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
