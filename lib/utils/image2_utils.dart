import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

// Change the return type from void to Image
Image displayBase64Image(String base64String) {
  // Remove any whitespace/newline characters
  String cleanBase64 = base64String.replaceAll(RegExp(r'\s+'), '');

  // Decode the Base64 string to bytes
  Uint8List imageBytes = base64Decode(cleanBase64);

  // Convert bytes to an image widget
  return Image.memory(imageBytes); // Return the Image widget
}
