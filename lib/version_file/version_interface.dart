import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'version_controller.dart'; // Import your controller

class VersionCheckPage extends StatelessWidget {
  final VersionController versionController = Get.put(VersionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Version Check'),
      ),
      body: Obx(() {
        if (versionController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(
            child: Text(
              'Current Version: ${versionController.version.value}',
              style: TextStyle(fontSize: 20),
            ),
          );
        }
      }),
    );
  }
}
