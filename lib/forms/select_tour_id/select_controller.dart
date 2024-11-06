import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../base_client/baseClient_controller.dart';
import '../../tourDetails/tour_controller.dart';

class SelectController extends GetxController with BaseController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ScrollController scrollController = ScrollController();

  String? selectedRadioTourId; // Track the selected tour ID from radio buttons
  String? lockedTourId; // For showing the locked tour ID
  List<String>? lockedSchools; // For showing the locked schools
  List<String> splitSchoolLists = []; // School list based on tour selection
  String? _tourValue;
  String? get tourValue => _tourValue;
  String? _schoolValue;
  String? get schoolValue => _schoolValue;

  final FocusNode _tourIdFocusNode = FocusNode();
  FocusNode get tourIdFocusNode => _tourIdFocusNode;

  final FocusNode _schoolFocusNode = FocusNode();
  FocusNode get schoolFocusNode => _schoolFocusNode;

  final TourController tourController = Get.put(TourController());

  @override
  void onInit() {
    super.onInit();
    _loadLockedTourAndSchool();
  }

  // Set the tour value
  void setTour(String? value) {
    _tourValue = value;
    update();
  }

  // Set the school value
  void setSchool(String? value) {
    _schoolValue = value;
    update();
  }

  // Clear fields
  void clearFields() {
    _tourValue = null;
    _schoolValue = null;
    selectedRadioTourId = null;
    splitSchoolLists.clear();
    update();
  }

  // Load locked tour ID and schools when the form is initialized
  Future<void> _loadLockedTourAndSchool() async {
    final prefs = await SharedPreferences.getInstance();
    lockedTourId = prefs.getString('lockedTourId');
    lockedSchools = prefs.getStringList('lockedSchools');
    selectedRadioTourId = lockedTourId; // Pre-select the locked tour ID
    update();
  }

  // Lock the selected tour ID and schools
  Future<void> lockTourAndSchools(String tourId, List<String> schools) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lockedTourId', tourId);
    await prefs.setStringList('lockedSchools', schools);
    lockedTourId = tourId;
    lockedSchools = schools;
    update();
  }

  // Unlock the tour and schools
  Future<void> unlockTourAndSchools() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lockedTourId');
    await prefs.remove('lockedSchools');
    clearFields(); // Clear the values in the controller
  }

  // Update the school list based on selected tour ID
  void updateSchoolList(String? tourId) {
    if (tourId != null) {
      splitSchoolLists = tourController.getLocalTourList
          .where((e) => e.tourId == tourId)
          .map((e) => e.allSchool!.split(',').map((s) => s.trim()).toList())
          .expand((x) => x)
          .toList();
      update();
    }
  }
}
