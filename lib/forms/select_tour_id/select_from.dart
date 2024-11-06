import 'package:app17000ft_new/forms/select_tour_id/select_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For checking network status
import 'dart:convert'; // For jsonDecode
import 'package:http/http.dart' as http; // For HTTP requests
import '../../components/custom_appBar.dart';
import '../../components/custom_labeltext.dart';
import '../../components/custom_sizedBox.dart';
import '../../helper/database_helper.dart';
import '../../home/home_screen.dart';

class SelectForm extends StatefulWidget {
  const SelectForm({super.key});

  @override
  _SelectFormState createState() => _SelectFormState();
}

class _SelectFormState extends State<SelectForm> {
  bool isConnected = true; // To track network connection status

  @override
  void initState() {
    super.initState();
    _checkConnectivity(); // Initial connectivity check
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Listen for connectivity changes and update UI
      setState(() {
        isConnected = (result != ConnectivityResult.none);
      });
    });
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isConnected = (connectivityResult != ConnectivityResult.none);
    });
  }

  Future<void> fetchData(
      String tourId, List<String> schools, BuildContext context) async {
    if (isConnected) {
      // Fetch data from the API when online
      final url =
          'https://mis.17000ft.org/apis/fast_apis/pre-fill-data.php?id=$tourId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data != null && data.isNotEmpty) {
          List<String> allSchools = [];

          // Loop through each school in the response
          for (var schoolName in data.keys) {
            allSchools.add(schoolName);
            var schoolData = data[schoolName];

            if (schoolData != null) {
              // Save each school's form data to the local DB
              await saveFormDataToLocalDB(tourId, schoolName, schoolData);
            }
          }
        }
      }
    }
  }

  Future<void> saveFormDataToLocalDB(
      String tourId, String school, Map<String, dynamic> formData) async {
    try {
      final dbHelper = SqfliteDatabaseHelper();
      await dbHelper.insertFormData(tourId, school, formData);
    } catch (e) {
      print("Error saving data to SQLite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        title: 'Select Tour Id',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: Get.put(SelectController()).scrollController,
          child: Column(
            children: [
              GetBuilder<SelectController>(
                init: SelectController(),
                builder: (selectController) {
                  selectController.tourController.fetchTourDetails();

                  // Get the list of tour IDs
                  List<String?> tourIds = selectController
                      .tourController.getLocalTourList
                      .map((e) => e.tourId)
                      .toList();

                  return Form(
                    key: selectController.formKey,
                    child: Column(
                      children: [
                        CustomSizedBox(value: 20, side: 'height'),

                        // Display "You are offline" message when offline
                        // Display "You are offline" message when offline
                        if (!isConnected)
                          Center(
                            child: Text(
                              'You are offline',
                              style: TextStyle(
                                fontSize:
                                    20, // Larger font size for better visibility
                                color: Colors.black, // Red color for emphasis
                                fontWeight:
                                    FontWeight.bold, // Make the text bold
                              ),
                              textAlign:
                                  TextAlign.center, // Align text to the center
                            ),
                          ),

                        // Show radio buttons and submit button when online
                        if (isConnected) ...[
                          LabelText(label: 'Select Tour Id', astrick: false),
                          CustomSizedBox(value: 20, side: 'height'),
                          // Radio buttons for selecting a tour ID
                          Column(
                            children: tourIds.map((tourId) {
                              return RadioListTile<String?>(
                                title: Text(tourId ?? ''),
                                value: tourId,
                                groupValue:
                                    selectController.selectedRadioTourId,
                                onChanged: (value) {
                                  selectController.selectedRadioTourId = value;
                                  selectController.setTour(value);
                                  selectController.updateSchoolList(value);
                                },
                              );
                            }).toList(),
                          ),
                          CustomSizedBox(value: 20, side: 'height'),

                          // Submit button
                          ElevatedButton(
                            onPressed: () async {
                              if (selectController.selectedRadioTourId !=
                                  null) {
                                // If no specific school is selected, lock all schools
                                List<String> schoolsToLock =
                                    selectController.schoolValue != null
                                        ? [selectController.schoolValue!]
                                        : selectController.splitSchoolLists;

                                // Lock the selected tour ID and schools
                                selectController.lockTourAndSchools(
                                  selectController.selectedRadioTourId!,
                                  schoolsToLock,
                                );

                                // Fetch and save data in the background without navigating
                                await fetchData(
                                    selectController.selectedRadioTourId!,
                                    schoolsToLock,
                                    context);

                                // Navigate to the HomeScreen after data is fetched and saved
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()),
                                );
                              } else {
                                // Handle the case where no tour ID is selected
                              }
                            },
                            child: const Text('Submit'),
                          )
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
