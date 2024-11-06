import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:app17000ft_new/home/home_screen.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart'; // Import the plugin

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app17000ft_new/components/custom_appBar.dart';
import 'package:app17000ft_new/components/custom_button.dart';
import 'package:app17000ft_new/components/custom_imagepreview.dart';
import 'package:app17000ft_new/components/custom_textField.dart';
import 'package:app17000ft_new/components/error_text.dart';
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/forms/cab_meter_tracking_form/cab_meter_tracing_controller.dart';
import 'package:app17000ft_new/helper/responsive_helper.dart';
import 'package:app17000ft_new/tourDetails/tour_controller.dart';
import 'package:app17000ft_new/components/custom_dropdown.dart';
import 'package:app17000ft_new/components/custom_labeltext.dart';
import 'package:app17000ft_new/components/custom_sizedBox.dart';

import '../../components/custom_snackbar.dart';
import '../../helper/database_helper.dart';
import '../select_tour_id/select_controller.dart';
import 'cab_meter_tracing_modal.dart';
import 'cab_meter_tracing_sync.dart';

class CabMeterTracingForm extends StatefulWidget {
  String? userid;
  String? office;
  CabMeterTracingForm({super.key, this.userid, this.office});

  @override
  State<CabMeterTracingForm> createState() => _CabMeterTracingFormState();
}

class _CabMeterTracingFormState extends State<CabMeterTracingForm> {
  bool _isImageUploaded = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  bool validateRegister = false;
  List<String> splitSchoolLists = [];

  var jsonData = <String, Map<String, String>>{};

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final responsive = Responsive(context);
    return Scaffold(
      appBar: const CustomAppbar(
        title: 'Cab Meter Tracing Form',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              GetBuilder<CabMeterTracingController>(
                init: CabMeterTracingController(),
                builder: (cabMeterController) {
                  return Form(
                    key: _formKey,
                    child:GetBuilder<TourController>(
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
                            cabMeterController.tourValue;

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
                                focusNode: cabMeterController
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
                                    cabMeterController
                                        .setSchool(null);
                                    cabMeterController
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
                            label: 'Place Visited',
                            astrick: true,
                          ),
                          CustomSizedBox(
                            value: 20,
                            side: 'height',
                          ),
                          CustomTextFormField(
                            textController:
                                cabMeterController.placeVisitedController,
                            labelText: 'Place Visited',
                            textCapitalization: TextCapitalization
                                .characters, // This makes the keyboard capitalize all characters
                            onChanged: (value) {
                              // Automatically convert the input to uppercase
                              cabMeterController.placeVisitedController.value =
                                  TextEditingValue(
                                text: value.toUpperCase(),
                                selection: cabMeterController
                                    .placeVisitedController.selection,
                              );
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please Enter Place Visited';
                              }
                              return null;
                            },
                          ),
                          CustomSizedBox(
                            value: 20,
                            side: 'height',
                          ),
                          LabelText(
                            label: 'Vehicle Number',
                            astrick: true,
                          ),
                          CustomSizedBox(
                            value: 20,
                            side: 'height',
                          ),
                          CustomTextFormField(
                            textController:
                                cabMeterController.vehicleNumberController,
                            labelText: 'Vehicle Number',
                            textCapitalization: TextCapitalization
                                .characters, // Keyboard will show capital letters
                            inputFormatters: [
                              UpperCaseTextFormatter(), // This will ensure text input is converted to uppercase
                            ],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please Enter Vehicle Number';
                              }
                              // Regex pattern for validating Indian vehicle number plate
                              final regExp =
                                  RegExp(r"^[A-Z]{2}[A-Z0-9]*[0-9]{4}$");
                              if (!regExp.hasMatch(value)) {
                                return 'Please Enter a valid Vehicle Number';
                              }
                              return null;
                            },
                          ),

                          CustomSizedBox(
                            value: 20,
                            side: 'height',
                          ),
                          LabelText(
                            label: 'Driver Name',
                            astrick: true,
                          ),
                          CustomSizedBox(
                            value: 20,
                            side: 'height',
                          ),
                          CustomTextFormField(
                            textController:
                                cabMeterController.driverNameController,
                            textCapitalization: TextCapitalization
                                .characters, // Keyboard will show capital letters
                            inputFormatters: [
                              UpperCaseTextFormatter(), // This will ensure text input is converted to uppercase
                            ],

                            labelText: 'Driver Name',
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please Enter Driver Name';
                              }
                              return null;
                            },
                          ),
                          CustomSizedBox(
                            value: 20,
                            side: 'height',
                          ),
                          LabelText(
                            label: 'Meter reading',
                            astrick: true,
                          ),
                          CustomSizedBox(
                            value: 20,
                            side: 'height',
                          ),

                          CustomTextFormField(
                            textController:
                                cabMeterController.meterReadingController,
                            textInputType: TextInputType.number,
                            labelText: 'Meter Reading',
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly, // Restrict input to only digits
                            ],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please Enter Meter Reading';
                              }
                              if (double.tryParse(value) == 0) {
                                return 'Meter Reading cannot be 0';
                              }
                              return null;
                            },
                          ),

                          CustomSizedBox(
                            value: 20,
                            side: 'height',
                          ),
                          LabelText(
                            label: 'Click Images:',
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
                                        style:
                                            TextStyle(color: AppColors.error),
                                      ),
                                trailing: const Icon(Icons.camera_alt,
                                    color: AppColors.onBackground),
                                onTap: () {
                                  showModalBottomSheet(
                                      backgroundColor: AppColors.primary,
                                      context: context,
                                      builder: ((builder) => cabMeterController
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

                          cabMeterController.multipleImage.isNotEmpty
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
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: cabMeterController
                                          .multipleImage.isEmpty
                                      ? const Center(
                                          child: Text('No images selected.'),
                                        )
                                      : ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: cabMeterController
                                              .multipleImage.length,
                                          itemBuilder: (context, index) {
                                            return SizedBox(
                                              height: 200,
                                              width: 200,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        CustomImagePreview
                                                            .showImagePreview(
                                                                cabMeterController
                                                                    .multipleImage[
                                                                        index]
                                                                    .path,
                                                                context);
                                                      },
                                                      child: Image.file(
                                                        File(cabMeterController
                                                            .multipleImage[
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
                                                        cabMeterController
                                                            .multipleImage
                                                            .removeAt(index);
                                                      });
                                                    },
                                                    child: const Icon(
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
                              : const SizedBox(),
                          CustomSizedBox(
                            value: 20,
                            side: 'height',
                          ),
                          LabelText(
                            label: 'Choose Options:',
                            astrick: true,
                          ),
                          CustomSizedBox(
                            value: 20,
                            side: 'height',
                          ),
                              Padding(
                                padding: EdgeInsets.only(right: screenWidth * 0.1), // Responsive padding
                                child: Row(
                                  children: [
                                    Radio(
                                      value: 'Start',
                                      groupValue: cabMeterController.getSelectedValue('meter'),
                                      onChanged: (value) {
                                        cabMeterController.setRadioValue('meter', value);
                                      },
                                    ),
                                    const Text('Start'),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: screenWidth * 0.4, // Adjust width of CustomSizedBox
                              ),
                              // Make it so the user can also edit the tourId and school
                              Padding(
                                padding: EdgeInsets.only(right: screenWidth * 0.1), // Responsive padding
                                child: Row(
                                  children: [
                                    Radio(
                                      value: 'End',
                                      groupValue: cabMeterController.getSelectedValue('meter'),
                                      onChanged: (value) {
                                        cabMeterController.setRadioValue('meter', value);
                                      },
                                    ),
                                    const Text('End'),
                                  ],
                                ),
                              ),
                              if (cabMeterController.getRadioFieldError('meter'))
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Please select an option',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                          CustomSizedBox(
                            value: 20,
                            side: 'height',
                          ),
                          LabelText(
                            label: 'Remarks',
                          ),
                          CustomSizedBox(
                            value: 20,
                            side: 'height',
                          ),
                          CustomTextFormField(
                            textController:
                                cabMeterController.remarksController,
                            labelText: 'Remarks Here',
                            maxlines: 2,

                          ),
                          CustomSizedBox(
                            value: 20,
                            side: 'height',
                          ),
                          CustomButton(
                            title: 'Submit',
                            onPressedButton: () async {
                              final isRadioValid1 = cabMeterController
                                  .validateRadioSelection('meter');
                              setState(() {
                                validateRegister =
                                    cabMeterController.multipleImage.isEmpty;
                              });

                              if (_formKey.currentState!.validate() &&
                                  !validateRegister &&
                                  isRadioValid1) {
                                List<File> cabImageFiles = [];
                                for (var imagePath
                                    in cabMeterController.imagePaths) {
                                  cabImageFiles.add(File(
                                      imagePath)); // Convert image path to File
                                }
                                final selectController =
                                Get.put(SelectController());
                                String? lockedTourId =
                                    selectController.lockedTourId;

                                // Use lockedTourId if it is available, otherwise use the selected tour ID from schoolEnrolmentController
                                String tourIdToInsert =
                                    lockedTourId ??
                                        cabMeterController
                                            .tourValue ??
                                        '';
                                // Generate a unique ID
                                String generateUniqueId(int length) {
                                  const _chars =
                                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                                  Random _rnd = Random();
                                  return String.fromCharCodes(Iterable.generate(
                                      length,
                                      (_) => _chars.codeUnitAt(
                                          _rnd.nextInt(_chars.length))));
                                }

                                String uniqueId = generateUniqueId(6);
                                DateTime now = DateTime.now();
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(now);

                                String cabImageFilePaths = cabImageFiles
                                    .map((file) => file.path)
                                    .join(',');

                                // Create CabMeterTracingRecords object
                                CabMeterTracingRecords enrolmentCollectionObj =
                                    CabMeterTracingRecords(
                                  status: cabMeterController
                                          .getSelectedValue('meter') ??
                                      '',
                                  place_visit: cabMeterController
                                      .placeVisitedController.text,
                                  remarks:
                                      cabMeterController.remarksController.text,
                                  vehicle_num: cabMeterController
                                      .vehicleNumberController.text,
                                  driver_name: cabMeterController
                                      .driverNameController.text,
                                  meter_reading: cabMeterController
                                      .meterReadingController.text,
                                  image: cabImageFilePaths,
                                  user_id: widget.userid ?? '',
                                  office: widget.office ?? '',
                                  tour_id: tourIdToInsert,
                                  created_at: formattedDate,
                                  uniqueId: uniqueId,
                                );
                                print("Office: ${widget.office ?? 'N/A'}");

                                // Save data to local database
                                int result = await LocalDbController().addData(
                                  cabMeterTracingRecords:
                                      enrolmentCollectionObj,
                                );

                                if (result > 0) {
                                  cabMeterController.clearFields();
                                  setState(() {
                                    _isImageUploaded = false;
                                  });

                                  String jsonData = jsonEncode(
                                      enrolmentCollectionObj.toJson());

                                  try {
                                    JsonFileDownloader downloader =
                                        JsonFileDownloader();
                                    String? filePath =
                                        await downloader.downloadJsonFile(
                                            jsonData,
                                            uniqueId,
                                            cabImageFiles); // Pass the cabImageFiles

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

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                  );
                                  customSnackbar(
                                    'Submitted Successfully',
                                    'submitted',
                                    AppColors.primary,
                                    AppColors.onPrimary,
                                    Icons.verified,
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
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          )
                        ]);
                      },
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
class JsonFileDownloader {
  // Method to download JSON data to the Downloads directory
  Future<String?> downloadJsonFile(
      String jsonData, String uniqueId, List<File> imageFiles) async {
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
          '${downloadsDirectory.path}/cab_meter_data_$uniqueId.txt';
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
