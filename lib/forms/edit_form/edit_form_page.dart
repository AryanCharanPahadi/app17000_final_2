import 'dart:convert';
import 'package:app17000ft_new/components/custom_labeltext.dart';
import 'package:app17000ft_new/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../components/custom_appBar.dart';
import '../../components/custom_confirmation.dart';
import '../../components/custom_dropdown.dart';
import '../../components/custom_sizedBox.dart';
import '../../helper/database_helper.dart';
import '../../home/home_screen.dart';
import '../../tourDetails/tour_controller.dart';
import '../school_enrolment/school_enrolment.dart';
import '../school_enrolment/school_enrolment_controller.dart';
import '../school_facilities_&_mapping_form/SchoolFacilitiesForm.dart';
import '../school_facilities_&_mapping_form/school_facilities_modals.dart';
import '../school_staff_vec_form/school_vec_from.dart';
import '../school_staff_vec_form/school_vec_modals.dart';
import 'edit controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For checking network status
import 'package:dropdown_search/dropdown_search.dart';
import '../../helper/responsive_helper.dart';
import '../school_enrolment/school_enrolment_model.dart';

class EditFormPage extends StatefulWidget {
  String? userid;

  EditFormPage({
    super.key,
    this.userid,
  });

  @override
  State<EditFormPage> createState() => _EditFormPageState();
}

class _EditFormPageState extends State<EditFormPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> splitSchoolLists = [];
  final SqfliteDatabaseHelper dbHelper = SqfliteDatabaseHelper();
  String selectedFormLabel = ''; // Empty string for the default state
  Map<String, dynamic> formData = {}; // Store fetched form data
  String selectedSchool = '';
  late EditController editController;
  List<String> tourIds = []; // List to store available tour IDs
  bool isOfflineMode = false; // Track if the app is in offline mode
  String? lockedTourId; // Store locked Tour ID if available
  final schoolEnrolmentController = Get.put(SchoolEnrolmentController());
  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  HomeController homeController = Get.put(HomeController());
  @override
  void initState() {
    super.initState();
    editController = Get.put(EditController());
    loadLockedTourId(); // Load the locked Tour ID if available
    setState(() {
      selectedFormLabel = '';
    });
  }

  // Load the locked Tour ID from shared preferences
  Future<void> loadLockedTourId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedLockedTourId = prefs.getString('lockedTourId');

    if (storedLockedTourId != null) {
      setState(() {
        lockedTourId = storedLockedTourId; // Set the locked Tour ID
        editController.setTour(lockedTourId); // Set it in the EditController
        fetchData(lockedTourId!); // Fetch data for the locked Tour ID
      });
    }
  }

  Future<void> fetchData(String tourId, [String? school]) async {
    bool isConnected = await _isConnected();

    // Check if the data for this tour ID is already saved in the local database
    bool dataExists = await dbHelper.checkTourDataExists(tourId);
    if (dataExists) {
      // If data exists, load it directly from local storage
      List<String> allSchools = await dbHelper.getSchoolsForTourId(tourId);
      if (school != null) {
        // Fetch specific school data from local DB if a school is selected
        formData = await getFormDataFromLocalDB(tourId, school);
      }

      // Update the UI with local data
      setState(() {
        splitSchoolLists = allSchools;
        selectedSchool = school ?? '';
      });
      return; // Exit since data is already loaded
    }

    if (isConnected) {
      // If online, fetch data from the API if it doesn't exist locally
      final url =
          'https://mis.17000ft.org/apis/fast_apis/pre-fill-data.php?id=$tourId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data != null && data.isNotEmpty) {
          List<String> allSchools = [];

          // Loop through each school in the API response
          for (var schoolName in data.keys) {
            allSchools.add(schoolName);
            var schoolData = data[schoolName];

            if (schoolData != null) {
              // Save each school's form data to the local database
              await saveFormDataToLocalDB(tourId, schoolName, schoolData);
            }
          }

          // Update the UI with the newly fetched school list
          setState(() {
            splitSchoolLists = allSchools;
            formData = {}; // Clear previous form data
          });

          // Store the selected Tour ID locally for offline access
          await saveTourIdToLocal(tourId);

          // Fetch specific school data if a school is selected
          if (school != null) {
            formData = await getFormDataFromLocalDB(tourId, school);
          }
        }
      }
    } else {
      // Offline handling (load data if needed)
    }
  }

  Future<void> saveFormDataToLocalDB(
      String tourId, String school, Map<String, dynamic> formData) async {
    try {
      await dbHelper.insertFormData(tourId, school, formData);
    } catch (e) {
      print("Error saving data to SQLite: $e");
    }
  }

  Future<Map<String, dynamic>> getFormDataFromLocalDB(
      String tourId, String school) async {
    return await SqfliteDatabaseHelper.instance.getFormData(tourId, school);
  }

  // Save the selected Tour ID to the local database (or shared preferences)
  Future<void> saveTourIdToLocal(String tourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> existingIds = prefs.getStringList('selectedTourIds') ?? [];
    if (!existingIds.contains(tourId)) {
      existingIds.add(tourId);
      await prefs.setStringList('selectedTourIds', existingIds);
    }
  }

  // Load all Tour IDs from local database (or shared preferences) in offline mode
  Future<void> _loadTourIdsFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedTourIds = prefs.getStringList('selectedTourIds');

    if (storedTourIds != null) {
      setState(() {
        tourIds = storedTourIds; // Show all stored Tour IDs
      });
    } else {
      setState(() {
        tourIds = []; // If no Tour ID is stored, keep the list empty
      });
    }
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
          title: 'Edit Form',
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                GetBuilder<TourController>(
                  init: TourController(),
                  builder: (tourController) {
                    if (!isOfflineMode && lockedTourId == null) {
                      tourController
                          .fetchTourDetails(); // Fetch online tour list if online
                    }
                    return Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          LabelText(label: 'Select Tour ID'),
                          CustomSizedBox(value: 20, side: 'height'),
                          // Dropdown to show locked Tour ID or all IDs
                          CustomDropdownFormField(
                            focusNode: editController.tourIdFocusNode,
                            options: lockedTourId != null
                                ? [
                                    lockedTourId!
                                  ] // If locked, show only the locked ID
                                : isOfflineMode
                                    ? tourIds // Show all stored Tour IDs in offline mode
                                    : tourController.getLocalTourList
                                        .map((e) => e.tourId!)
                                        .toList(),
                            selectedOption:
                                lockedTourId ?? editController.tourValue,
                            onChanged: lockedTourId ==
                                    null // Disable dropdown if tour is locked
                                ? (value) {
                                    if (value != null) {
                                      fetchData(value);
                                      setState(() {
                                        editController.setTour(value);
                                      });
                                    }
                                  }
                                : null, // Disable if tour is locked
                            labelText: "Select Tour ID",
                          ),
                          CustomSizedBox(value: 20, side: 'height'),
                          LabelText(label: 'School', astrick: true),
                          CustomSizedBox(value: 20, side: 'height'),
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
                              scrollbarProps: ScrollbarProps(
                                thickness: 2,
                                radius: Radius.circular(10),
                                thumbColor: Colors.black87,
                                thumbVisibility: true,
                              ),
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  hintText: 'Search School',
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            items: splitSchoolLists,
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "Select School",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedSchool = value;
                                  editController.setSchool(value);
                                  fetchData(editController.tourValue!,
                                      value); // Pass the selected school to fetchData
                                });
                              }
                            },
                            selectedItem: editController.schoolValue,
                          ),
                          CustomSizedBox(value: 20, side: 'height'),
                          LabelText(label: 'Select Form'),
                          CustomSizedBox(value: 20, side: 'height'),
                          DropdownButtonFormField<String>(
                            value: selectedFormLabel.isEmpty
                                ? null
                                : selectedFormLabel,
                            items: [
                              'School Enrollment Form',
                              'School Staff & SMC/VEC Details',
                              'School Facilities Mapping Form'
                            ]
                                .map((label) => DropdownMenuItem(
                                      value: label,
                                      child: Text(label.toUpperCase()),
                                    ))
                                .toList(),
                            decoration: InputDecoration(
                              labelText: 'Select Form',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                selectedFormLabel = value ?? '';
                                // Clear form data when changing form
                                formData = {};
                                // Fetch data relevant to the selected form
                                if (selectedSchool.isNotEmpty &&
                                    editController.tourValue != null) {
                                  fetchData(editController.tourValue!,
                                      selectedSchool);
                                }
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a form';
                              }
                              return null;
                            },
                          ),
                          CustomSizedBox(value: 30, side: 'height'),
                        ],
                      ),
                    );
                  },
                ),
                // Show data based on the selected form
                if (formData.isNotEmpty)
                  Card(
                    elevation: 8,
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            'Selected School: $selectedSchool',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          // Display only relevant data based on selected form
                          ...formData.entries.map((entry) {
                            switch (selectedFormLabel) {
                              case 'School Enrollment Form':
                                if (entry.key == 'enrollment') {
                                  final enrollmentFetch =
                                      formData['enrollment'];

                                  if (enrollmentFetch is Map &&
                                      enrollmentFetch.isNotEmpty) {
                                    List<Widget> classRows = [];

                                    // Add headers row
                                    classRows.add(
                                      Row(
                                        children: const [
                                          Expanded(
                                            child: Text(
                                              'Class',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Boys',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Girls',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    // Adding class data rows
                                    enrollmentFetch.forEach((className, data) {
                                      if (data is Map &&
                                          data.containsKey('boys') &&
                                          data.containsKey('girls')) {
                                        final boys = int.tryParse(
                                                data['boys']?.toString() ??
                                                    '0') ??
                                            0;
                                        final girls = int.tryParse(
                                                data['girls']?.toString() ??
                                                    '0') ??
                                            0;

                                        classRows.add(
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(className,
                                                    style: const TextStyle(
                                                        fontSize: 14)),
                                              ),
                                              Expanded(
                                                child: Text('$boys',
                                                    style: const TextStyle(
                                                        fontSize: 14)),
                                              ),
                                              Expanded(
                                                child: Text('$girls',
                                                    style: const TextStyle(
                                                        fontSize: 14)),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    });

                                    // Display the enrollment data in a card with headers
                                    return Card(
                                      elevation: 4,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(children: classRows),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                final enrolmentDataMap =
                                                    <String,
                                                        Map<String, String>>{};

                                                enrollmentFetch
                                                    .forEach((className, data) {
                                                  if (data is Map &&
                                                      data.containsKey(
                                                          'boys') &&
                                                      data.containsKey(
                                                          'girls')) {
                                                    enrolmentDataMap[
                                                        className] = {
                                                      'boys': data['boys']
                                                              ?.toString() ??
                                                          '0',
                                                      'girls': data['girls']
                                                              ?.toString() ??
                                                          '0',
                                                    };
                                                  }
                                                });

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SchoolEnrollmentForm(
                                                      userid: homeController
                                                          .empId, // Pass the user ID here
                                                      office: homeController
                                                          .office, // Pass the office here
                                                      existingRecord:
                                                          EnrolmentCollectionModel(
                                                        enrolmentData: jsonEncode(
                                                            enrolmentDataMap),
                                                        remarks: enrollmentFetch[
                                                                    'remarks']
                                                                ?.toString() ??
                                                            '',
                                                        tourId: editController
                                                            .tourValue,
                                                        school: editController
                                                            .schoolValue,
                                                      ),
                                                      tourId: editController
                                                              .tourValue ??
                                                          'Not Provided',
                                                      school: editController
                                                              .schoolValue ??
                                                          'Not Provided',
                                                    ),
                                                  ),
                                                );
                                              },
                                              child:
                                                  const Text('Edit Form Data'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    // No enrollment data available, show the "Add Data" option
                                    return Column(
                                      children: [
                                        const Text('No data available'),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Navigate to the form for adding new enrollment data
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SchoolEnrollmentForm(),
                                              ),
                                            );
                                          },
                                          child: const Text('Add New Data'),
                                        ),
                                      ],
                                    );
                                  }
                                }
                                break;
                              case 'School Staff & SMC/VEC Details':
                                if (entry.key == 'vec') {
                                  // Check if the 'vec' entry is a list and contains data
                                  if (entry.value is List &&
                                      (entry.value as List).isNotEmpty) {
                                    List<dynamic> vecData = entry.value;
                                    return Column(
                                      children: [
                                        // Display data cards
                                        ...vecData.map((vecEntry) {
                                          return Card(
                                            elevation: 8,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'School: ${vecEntry['school'] ?? 'N/A'}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const Divider(),
                                                  Text(
                                                      'State: ${vecEntry['state'] ?? 'N/A'}'),
                                                  Text(
                                                      'District: ${vecEntry['district'] ?? 'N/A'}'),
                                                  Text(
                                                      'Block: ${vecEntry['block'] ?? 'N/A'}'),
                                                  Text(
                                                      'Tour ID: ${vecEntry['tourId'] ?? 'N/A'}'),
                                                  Text(
                                                      'UDISE Value: ${vecEntry['udiseValue'] ?? 'N/A'}'),
                                                  Text(
                                                      'Correct UDISE: ${vecEntry['correctUdise'] ?? 'N/A'}'),
                                                  const SizedBox(height: 8),
                                                  Text('Head Information',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      'Name: ${vecEntry['headName'] ?? 'N/A'}'),
                                                  Text(
                                                      'Gender: ${vecEntry['headGender'] ?? 'N/A'}'),
                                                  Text(
                                                      'Mobile: ${vecEntry['headMobile'] ?? 'N/A'}'),
                                                  Text(
                                                      'Email: ${vecEntry['headEmail'] ?? 'N/A'}'),
                                                  Text(
                                                      'Designation: ${vecEntry['headDesignation'] ?? 'N/A'}'),
                                                  const SizedBox(height: 8),
                                                  Text('Staff Information',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      'Total Teaching Staff: ${vecEntry['totalTeachingStaff'] ?? 'N/A'}'),
                                                  Text(
                                                      'Total Non-Teaching Staff: ${vecEntry['totalNonTeachingStaff'] ?? 'N/A'}'),
                                                  Text(
                                                      'Total Staff: ${vecEntry['totalStaff'] ?? 'N/A'}'),
                                                  const SizedBox(height: 8),
                                                  Text('VEC Information',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      'SMC/VEC Name: ${vecEntry['SmcVecName'] ?? 'N/A'}'),
                                                  Text(
                                                      'Gender: ${vecEntry['genderVec'] ?? 'N/A'}'),
                                                  Text(
                                                      'Mobile: ${vecEntry['vecMobile'] ?? 'N/A'}'),
                                                  Text(
                                                      'Email: ${vecEntry['vecEmail'] ?? 'N/A'}'),
                                                  Text(
                                                      'Qualification: ${vecEntry['vecQualification'] ?? 'N/A'}'),
                                                  Text(
                                                      'Total Members: ${vecEntry['vecTotal'] ?? 'N/A'}'),
                                                  Text(
                                                      'Meeting Duration: ${vecEntry['meetingDuration'] ?? 'N/A'}'),
                                                  const SizedBox(height: 8),
                                                  Text('Other Information',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      'Other Qualification: ${vecEntry['otherQual'] ?? 'N/A'}'),
                                                  Text(
                                                      'Created By: ${vecEntry['createdBy'] ?? 'N/A'}'),
                                                  Text(
                                                      'Created At: ${vecEntry['createdAt'] ?? 'N/A'}'),
                                                  Text(
                                                      'Submitted At: ${vecEntry['submittedAt'] ?? 'N/A'}'),
                                                  const SizedBox(height: 8),

                                                  // Display the "Edit" button if data exists
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        // Navigate to the SchoolFacilitiesForm and pass the selected facility record
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                SchoolStaffVecForm(
                                                              userid: homeController
                                                                  .empId, // Pass the user ID here
                                                              office: homeController
                                                                  .office, // Pass the office here

                                                              existingRecord:
                                                                  SchoolStaffVecRecords(
                                                                headName: vecEntry[
                                                                    'headName'],
                                                                tourId:
                                                                    editController
                                                                        .tourValue,
                                                                // Pass the selected Tour ID here
                                                                school: editController
                                                                    .schoolValue,
                                                                // Pass the selected school here

                                                                // Pass created_by here
                                                                headGender:
                                                                    vecEntry[
                                                                        'headGender'],
                                                                udiseValue:
                                                                    vecEntry[
                                                                        'udiseValue'],
                                                                correctUdise:
                                                                    vecEntry[
                                                                        'correctUdise'],
                                                                headMobile:
                                                                    vecEntry[
                                                                        'headMobile'],
                                                                headEmail: vecEntry[
                                                                    'headEmail'],
                                                                headDesignation:
                                                                    vecEntry[
                                                                        'headDesignation'],
                                                                totalTeachingStaff:
                                                                    vecEntry[
                                                                        'totalTeachingStaff'],
                                                                totalNonTeachingStaff:
                                                                    vecEntry[
                                                                        'totalNonTeachingStaff'],
                                                                totalStaff:
                                                                    vecEntry[
                                                                        'totalStaff'],
                                                                SmcVecName:
                                                                    vecEntry[
                                                                        'SmcVecName'],
                                                                genderVec: vecEntry[
                                                                    'genderVec'],
                                                                vecMobile: vecEntry[
                                                                    'vecMobile'],
                                                                vecEmail: vecEntry[
                                                                    'vecEmail'],
                                                                vecQualification:
                                                                    vecEntry[
                                                                        'vecQualification'],
                                                                vecTotal: vecEntry[
                                                                    'vecTotal'],
                                                                meetingDuration:
                                                                    vecEntry[
                                                                        'meetingDuration'],

                                                                createdAt: vecEntry[
                                                                    'createdAt'],
                                                                other: vecEntry[
                                                                    'other'],
                                                                otherQual: vecEntry[
                                                                    'otherQual'],
                                                              ),
                                                              tourId: editController
                                                                      .tourValue ??
                                                                  'Not Provided',
                                                              // Pass the selected Tour ID here
                                                              school: editController
                                                                      .schoolValue ??
                                                                  'Not provided', // Pass the selected school here
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                          'Edit Data'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      children: [
                                        const Text('No data available'),

                                        // Display the "Add Data" button if no data exists
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Navigate to the form for adding new VEC data
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SchoolStaffVecForm(),
                                              ),
                                            );
                                          },
                                          child: const Text('Add New Data'),
                                        ),
                                      ],
                                    );
                                  }
                                }
                                break;

                              case 'School Facilities Mapping Form':
                                if (entry.key == 'facilities') {
                                  // Check if the 'facilities' entry is a list and contains data
                                  if (entry.value is List &&
                                      (entry.value as List).isNotEmpty) {
                                    List<dynamic> facilitiesData = entry.value;
                                    return Column(
                                      children: [
                                        // Display data cards
                                        ...facilitiesData.map((facilityEntry) {
                                          return Card(
                                            elevation: 8,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'School: ${facilityEntry['school'] ?? 'N/A'}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const Divider(),
                                                  Text(
                                                      'State: ${facilityEntry['state'] ?? 'N/A'}'),
                                                  Text(
                                                      'District: ${facilityEntry['district'] ?? 'N/A'}'),
                                                  Text(
                                                      'Block: ${facilityEntry['block'] ?? 'N/A'}'),
                                                  Text(
                                                      'Tour ID: ${facilityEntry['tourId'] ?? 'N/A'}'),
                                                  Text(
                                                      'UDISE Value: ${facilityEntry['udiseValue'] ?? 'N/A'}'),
                                                  Text(
                                                      'Correct UDISE: ${facilityEntry['correctUdise'] ?? 'N/A'}'),
                                                  const SizedBox(height: 8),
                                                  Text('Facilities Information',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      'Residential: ${facilityEntry['residentialValue'] ?? 'N/A'}'),
                                                  Text(
                                                      'Electricity: ${facilityEntry['electricityValue'] ?? 'N/A'}'),
                                                  Text(
                                                      'Internet: ${facilityEntry['internetValue'] ?? 'N/A'}'),
                                                  Text(
                                                      'Projector: ${facilityEntry['projectorValue'] ?? 'N/A'}'),
                                                  Text(
                                                      'Smart Class: ${facilityEntry['smartClassValue'] ?? 'N/A'}'),
                                                  Text(
                                                      'Functional Classrooms: ${facilityEntry['numFunctionalClass'] ?? 'N/A'}'),
                                                  const SizedBox(height: 8),
                                                  Text('Playground',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      'Playground Available: ${facilityEntry['playgroundValue'] ?? 'N/A'}'),
                                                  const SizedBox(height: 8),
                                                  Text('Library',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      'Library Available: ${facilityEntry['libValue'] ?? 'N/A'}'),
                                                  Text(
                                                      'Library Location: ${facilityEntry['libLocation'] ?? 'N/A'}'),
                                                  Text(
                                                      'Librarian Name: ${facilityEntry['librarianName'] ?? 'N/A'}'),
                                                  Text(
                                                      'Librarian Trained: ${facilityEntry['librarianTraining'] ?? 'N/A'}'),
                                                  Text(
                                                      'Library Register Available: ${facilityEntry['libRegisterValue'] ?? 'N/A'}'),
                                                  const SizedBox(height: 8),
                                                  Text('Images',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      'Playground Images: ${facilityEntry['playImg'] ?? 'N/A'}'),
                                                  Text(
                                                      'Library Register Images: ${facilityEntry['imgRegister'] ?? 'N/A'}'),
                                                  const SizedBox(height: 8),
                                                  Text('Other Information',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      'Created By: ${facilityEntry['created_by'] ?? 'N/A'}'),
                                                  Text(
                                                      'Created At: ${facilityEntry['created_at'] ?? 'N/A'}'),
                                                  Text(
                                                      'Submitted At: ${facilityEntry['submitted_at'] ?? 'N/A'}'),
                                                  const SizedBox(height: 8),

                                                  // Display the "Edit" button if data exists
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        // Navigate to the SchoolFacilitiesForm and pass the selected facility record
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                SchoolFacilitiesForm(
                                                              userid: homeController
                                                                  .empId, // Pass the user ID here
                                                              office: homeController
                                                                  .office, // Pass the office here

                                                              existingRecord:
                                                                  SchoolFacilitiesRecords(
                                                                residentialValue:
                                                                    facilityEntry[
                                                                        'residentialValue'],
                                                                tourId:
                                                                    editController
                                                                        .tourValue,
                                                                // Pass the selected Tour ID here
                                                                school: editController
                                                                    .schoolValue,
                                                                // Pass the selected school here
                                                                electricityValue:
                                                                    facilityEntry[
                                                                        'electricityValue'],
                                                                internetValue:
                                                                    facilityEntry[
                                                                        'internetValue'],
                                                                udiseCode:
                                                                    facilityEntry[
                                                                        'udiseValue'],
                                                                correctUdise:
                                                                    facilityEntry[
                                                                        'correctUdise'],
                                                                // school: facilityEntry['school'],
                                                                projectorValue:
                                                                    facilityEntry[
                                                                        'projectorValue'],
                                                                smartClassValue:
                                                                    facilityEntry[
                                                                        'smartClassValue'],
                                                                numFunctionalClass:
                                                                    facilityEntry[
                                                                        'numFunctionalClass'],
                                                                playgroundValue:
                                                                    facilityEntry[
                                                                        'playgroundValue'],
                                                                libValue:
                                                                    facilityEntry[
                                                                        'libValue'],
                                                                libLocation:
                                                                    facilityEntry[
                                                                        'libLocation'],
                                                                librarianName:
                                                                    facilityEntry[
                                                                        'librarianName'],
                                                                librarianTraining:
                                                                    facilityEntry[
                                                                        'librarianTraining'],
                                                                libRegisterValue:
                                                                    facilityEntry[
                                                                        'libRegisterValue'],

                                                                created_at:
                                                                    facilityEntry[
                                                                        'created_at'],
                                                              ),
                                                              tourId: editController
                                                                      .tourValue ??
                                                                  'Not Provided',
                                                              // Pass the selected Tour ID here
                                                              school: editController
                                                                      .schoolValue ??
                                                                  'Not provided', // Pass the selected school here
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                          'Edit Form Data'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      children: [
                                        const Text(
                                            'School Facilities Mapping Form'),

                                        // Display the "Add Data" button if no data exists
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Navigate to the form for adding new facilities data
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SchoolFacilitiesForm(),
                                              ),
                                            );
                                          },
                                          child: const Text('Add New Data'),
                                        ),
                                      ],
                                    );
                                  }
                                }
                                break;

                              default:
                                return SizedBox.shrink(); // No data to show
                            }
                            return SizedBox.shrink(); // No data to show
                          }).toList(),
                        ],
                      ),
                    ),
                  )
                else
                  Text(''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
