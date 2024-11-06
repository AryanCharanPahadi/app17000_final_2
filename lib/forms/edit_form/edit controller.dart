import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../base_client/baseClient_controller.dart';
import '../../home/home_controller.dart';
import 'edit_modal.dart';

class EditController extends GetxController with BaseController {
  var counterText = ''.obs;

  // Tour and school values
  String? _tourValue;
  String? get tourValue => _tourValue;

  String? _schoolValue;
  String? get schoolValue => _schoolValue;

  // User and office details
  String? _userId;
  String? get userId => _userId;

  String? _office;
  String? get office => _office;

  // Focus nodes
  final FocusNode _tourIdFocusNode = FocusNode();
  FocusNode get tourIdFocusNode => _tourIdFocusNode;

  final FocusNode _schoolFocusNode = FocusNode();
  FocusNode get schoolFocusNode => _schoolFocusNode;

  // Method to set school value
  void setSchool(String? value) {
    _schoolValue = value;
    update();
  }

  // Method to set tour value
  void setTour(String? value) {
    _tourValue = value;
    update();
  }

  // Method to set userId and office
  void setUserDetails(String? userId, String? office) {
    _userId = userId;
    _office = office;
    update();
  }

  // Clear fields
  void clearFields() {
    _tourValue = null;
    _schoolValue = null;
    _userId = null;
    _office = null;
    update();
  }
}
