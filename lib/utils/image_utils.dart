import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  final ImagePicker _picker = ImagePicker();

  // Method to pick an image and convert it to Base64
  Future<String?> imageToBase64() async {
    // Pick an image from the gallery
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Get the file
      File imageFile = File(pickedFile.path);

      // Read the image file as bytes
      List<int> imageBytes = await imageFile.readAsBytes();

      // Convert bytes to Base64
      return base64Encode(imageBytes);
    }
    return null; // Return null if no image is picked
  }
}
