import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart'; // for MediaType
import 'package:app17000ft_new/components/custom_appBar.dart';
import 'package:app17000ft_new/components/custom_dialog.dart';
import 'package:app17000ft_new/components/custom_snackbar.dart';
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/forms/fln_observation_form/fln_observation_controller.dart';

import 'package:app17000ft_new/helper/database_helper.dart';
import 'package:app17000ft_new/services/network_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class FlnObservationSync extends StatefulWidget {
  const FlnObservationSync({super.key});

  @override
  State<FlnObservationSync> createState() => _FlnObservationSync();
}

class _FlnObservationSync extends State<FlnObservationSync> {
  final FlnObservationController _flnObservationController =
      Get.put(FlnObservationController());
  final NetworkManager _networkManager = Get.put(NetworkManager());
  var isLoading = false.obs;
  var syncProgress = 0.0.obs; // Progress variable for syncing
  var hasError = false.obs; // Variable to track if syncing failed

  @override
  void initState() {
    super.initState();
    _flnObservationController.fetchData();
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: const CustomAppbar(title: 'FLN Observation Sync'),
        body: GetBuilder<FlnObservationController>(
          builder: (flnObservationController) {
            if (flnObservationController.flnObservationList.isEmpty) {
              return const Center(
                child: Text(
                  'No Records Found',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
              );
            }

            return Obx(() => isLoading.value
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                            color: AppColors.primary),
                        const SizedBox(height: 20),
                        Text(
                          'Syncing: ${(syncProgress.value * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (hasError.value)
                          const Text(
                            'Syncing failed. Please try again.',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                          itemCount: flnObservationController
                              .flnObservationList.length,
                          itemBuilder: (context, index) {
                            final item = flnObservationController
                                .flnObservationList[index];
                            return ListTile(
                              title: LayoutBuilder(
                                builder: (context, constraints) {
                                  // Adjust font size based on screen width, ensuring it scales well for tablets and mobile
                                  double fontSize = constraints.maxWidth *
                                      0.04; // Example calculation for responsive font size

                                  // Optional: Set a minimum and maximum font size to maintain readability on smaller and larger devices
                                  if (fontSize < 16) {
                                    fontSize = 16; // Minimum font size
                                  } else if (fontSize > 24) {
                                    fontSize = 24; // Maximum font size
                                  }

                                  return Text(
                                    "${index + 1}. Tour ID: ${item.tourId}\n"
                                    "School.: ${item.school}\n",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign
                                        .left, // Adjust text alignment if needed
                                    maxLines:
                                        2, // Limit the lines, or remove this if you don't want a limit
                                    overflow: TextOverflow
                                        .ellipsis, // Handles overflow gracefully
                                  );
                                },
                              ),
                              trailing: Obx(() => IconButton(
                                    color:
                                        _networkManager.connectionType.value ==
                                                0
                                            ? Colors.grey
                                            : AppColors.primary,
                                    icon: const Icon(Icons.sync),
                                    onPressed: _networkManager
                                                .connectionType.value ==
                                            0
                                        ? null
                                        : () async {
                                            // Proceed with sync logic when online
                                            IconData icon = Icons.check_circle;
                                            showDialog(
                                              context: context,
                                              builder: (_) => Confirmation(
                                                iconname: icon,
                                                title: 'Confirm',
                                                yes: 'Confirm',
                                                no: 'Cancel',
                                                desc:
                                                    'Are you sure you want to Sync?',
                                                onPressed: () async {
                                                  setState(() {
                                                    isLoading.value =
                                                        true; // Show loading spinner
                                                    syncProgress.value =
                                                        0.0; // Reset progress
                                                    hasError.value =
                                                        false; // Reset error state
                                                  });

                                                  if (_networkManager
                                                              .connectionType
                                                              .value ==
                                                          1 ||
                                                      _networkManager
                                                              .connectionType
                                                              .value ==
                                                          2) {
                                                    for (int i = 0;
                                                        i <= 100;
                                                        i++) {
                                                      await Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  50));
                                                      syncProgress.value = i /
                                                          100; // Update progress
                                                    }

                                                    // Call the insert function
                                                    var rsp =
                                                        await insertFlnObservation(
                                                      item.tourId,
                                                      item.school,
                                                      item.udiseValue,
                                                      item.correctUdise,
                                                      item.noStaffTrained,
                                                      item.imgNurTimeTable,
                                                      item.imgLKGTimeTable,
                                                      item.imgUKGTimeTable,
                                                      item.lessonPlanValue,
                                                      item.activityValue,
                                                      item.imgActivity,
                                                      item.imgTLM,
                                                      item.baselineValue,
                                                      item.baselineGradeReport,
                                                      item.flnConductValue,
                                                      item.flnGradeReport,
                                                      item.imgFLN,
                                                      item.refresherValue,
                                                      item.numTrainedTeacher,
                                                      item.imgTraining,
                                                      item.readingValue,
                                                      item.libGradeReport,
                                                      item.imgLib,
                                                      item.methodologyValue,
                                                      item.imgClass,
                                                      item.observation,
                                                      item.created_by,
                                                      item.createdAt,
                                                      item.office,
                                                      item.id,
                                                      (progress) {
                                                        syncProgress.value =
                                                            progress; // Update sync progress
                                                      },
                                                    );

                                                    if (rsp['status'] == 1) {
                                                      _flnObservationController
                                                          .removeRecordFromList(
                                                              item.id!);

                                                      customSnackbar(
                                                        'Successfully',
                                                        "${rsp['message']}",
                                                        AppColors.secondary,
                                                        AppColors.onSecondary,
                                                        Icons.check,
                                                      );
                                                    } else {
                                                      hasError.value =
                                                          true; // Set error state if sync fails
                                                      customSnackbar(
                                                        "Error",
                                                        "${rsp['message']}",
                                                        AppColors.error,
                                                        AppColors.onError,
                                                        Icons.warning,
                                                      );
                                                    }
                                                    setState(() {
                                                      isLoading.value =
                                                          false; // Hide loading spinner
                                                    });
                                                  }
                                                },
                                              ),
                                            );
                                          },
                                  )),
                              onTap: () {
                                flnObservationController
                                    .flnObservationList[index].tourId;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ));
          },
        ),
      ),
    );
  }
}

var baseurl = "https://mis.17000ft.org/apis/fast_apis/insert_fln.php";

Future<Map<String, dynamic>> insertFlnObservation(
  String? tourId,
  String? school,
  String? udiseValue,
  String? correctUdise,
  String? noStaffTrained,
  String? imgNurTimeTable,
  String? imgLKGTimeTable,
  String? imgUKGTimeTable,
  String? lessonPlanValue,
  String? activityValue,
  String? imgActivity,
  String? imgTLM,
  String? baselineValue,
  String? baselineGradeReport,
  String? flnConductValue,
  String? flnGradeReport,
  String? imgFLN,
  String? refresherValue,
  String? numTrainedTeacher,
  String? imgTraining,
  String? readingValue,
  String? libGradeReport,
  String? imgLib,
  String? methodologyValue,
  String? imgClass,
  String? observation,
  String? created_by,
  String? createdAt,
  String? office,
  int? id,
  Function(double) updateProgress,
) async {
  print('Inserting FLN Observation Data');
  print('tourId: $tourId');
  print('school: $school');
  print('No. of Staff Trained: $noStaffTrained');

  var request = http.MultipartRequest('POST', Uri.parse(baseurl));
  request.headers["Accept"] = "application/json";

  // Add fields
  request.fields.addAll({
    'tourId': tourId ?? '',
    'school': school ?? '',
    'udiseValue': udiseValue ?? '',
    'correctUdise': correctUdise ?? '',
    'noStaffTrained': noStaffTrained ?? '',
    'lessonPlanValue': lessonPlanValue ?? '',
    'activityValue': activityValue ?? '',
    'baselineValue': baselineValue ?? '',
    'baselineGradeReport': baselineGradeReport ?? '',
    'flnConductValue': flnConductValue ?? '',
    'flnGradeReport': flnGradeReport ?? '',
    'refresherValue': refresherValue ?? '',
    'numTrainedTeacher': numTrainedTeacher ?? '',
    'readingValue': readingValue ?? '',
    'libGradeReport': libGradeReport ?? '',
    'methodologyValue': methodologyValue ?? '',
    'observation': observation ?? '',
    'created_by': created_by ?? '',
    'createdAt': createdAt ?? '',
    'office': office ?? '',
  });

// Function to handle image uploads
  Future<void> _attachImages(String? imagePaths, String fieldName) async {
    if (imagePaths != null && imagePaths.isNotEmpty) {
      List<String> images = imagePaths.split(',');
      for (String path in images) {
        print('Processing image for field $fieldName: $path'); // Debug log

        File imageFile = File(path.trim());
        if (imageFile.existsSync()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              '$fieldName[]', // Use array-like name for multiple images
              imageFile.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
          print("Image file $path attached successfully for $fieldName.");
        } else {
          print('Image file does not exist at the path: $path for $fieldName');
          throw Exception("Image file not found at $path for $fieldName.");
        }
      }
    } else {
      print('No image file path provided for $fieldName');
    }
  }

// Attach all image files and handle missing ones
  try {
    await _attachImages(imgNurTimeTable, 'imgNurTimeTable');
    await _attachImages(imgLKGTimeTable, 'imgLKGTimeTable');
    await _attachImages(imgUKGTimeTable, 'imgUKGTimeTable');
    await _attachImages(imgActivity, 'imgActivity');
    await _attachImages(imgTLM, 'imgTLM');
    await _attachImages(imgFLN, 'imgFLN');
    await _attachImages(imgTraining, 'imgTraining');
    await _attachImages(imgLib, 'imgLib');
    await _attachImages(imgClass, 'imgClass');
  } catch (e) {
    print('Error attaching images: $e');
    return {"status": 0, "message": e.toString()};
  }

// Send the request to the server
  var response = await request.send();
  var responseBody = await response.stream.bytesToString();

  print('Server Response Body: $responseBody');

  if (response.statusCode == 200) {
    try {
      var parsedResponse = json.decode(responseBody);
      if (parsedResponse['status'] == 1) {
        // Delete local record if sync is successful
        await SqfliteDatabaseHelper().queryDelete(
          arg: id.toString(),
          table: 'flnObservation',
          field: 'id',
        );
        print("Record with id $id deleted from local database.");

        // Refresh data
        await Get.put(FlnObservationController()).fetchData();
        return parsedResponse;
      } else {
        print('Error: ${parsedResponse['message']}');
        return {
          "status": 0,
          "message": parsedResponse['message'] ?? 'Failed to insert data'
        };
      }
    } catch (e) {
      print('Error parsing response: $e');
      return {"status": 0, "message": "Invalid response format"};
    }
  } else {
    print('Server error: ${response.statusCode}');
    return {"status": 0, "message": "Server returned error $responseBody"};
  }
}
