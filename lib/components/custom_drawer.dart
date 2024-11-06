
import 'package:app17000ft_new/user_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../constants/color_const.dart';
import '../forms/alfa_observation_form/alfa_observation_sync.dart';
import '../forms/cab_meter_tracking_form/cab_meter_tracing_sync.dart';
import '../forms/edit_form/edit_form_page.dart';
import '../forms/fln_observation_form/fln_observation_sync.dart';
import '../forms/inPerson_qualitative_form/inPerson_qualitative_sync.dart';
import '../forms/in_person_quantitative/in_person_quantitative_sync.dart';
import '../forms/issue_tracker/issue_tracker_sync.dart';
import '../forms/school_enrolment/school_enrolment_sync.dart';
import '../forms/school_facilities_&_mapping_form/school_facilities_sync.dart';
import '../forms/school_recce_form/school_recce_sync.dart';
import '../forms/school_staff_vec_form/school_vec_sync.dart';
import '../forms/select_tour_id/select_controller.dart';
import '../forms/select_tour_id/select_from.dart';
import '../helper/responsive_helper.dart';
import '../helper/shared_prefernce.dart';
import '../change_password/change_pasword.dart';
import '../home/home_controller.dart';
import '../home/home_screen.dart';
import '../login/login_screen.dart';
import 'custom_snackbar.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final UserController _userController = Get.put(UserController());
  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          GestureDetector(
            onTap: _userController.loadUserData, // Refresh user data on tap
            child: Container(
              color: AppColors.primary,
              height: responsive.responsiveValue(
                  small: 250.0, medium: 260.0, large: 280.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Username Text
                    Obx(() => Text(
                      _userController.username.value.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.responsiveValue(
                            small: 18, medium: 20, large: 22),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    )),
                    const SizedBox(height: 8),

                    // Office Name Text
                    Obx(() => Text(
                      _userController.officeName.value.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.responsiveValue(
                            small: 16, medium: 18, large: 20),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    )),
                    const SizedBox(height: 8),

                    // Version Text
                    Text(
                      '4.0.0',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: responsive.responsiveValue(
                            small: 14, medium: 16, large: 18),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Drawer menu items
          buildDrawerMenu(
            title: 'Home',
            icon: const FaIcon(FontAwesomeIcons.home),
            onPressed: () => navigateTo(const HomeScreen()),
          ),
          buildDrawerMenu(
            title: 'Change Password',
            icon: const FaIcon(FontAwesomeIcons.key),  // or use FontAwesomeIcons.lock
            onPressed: () {
              if (homeController.empId != null && homeController.empId!.isNotEmpty) {
                // Ensure empId is not null or empty before navigating
                handleSyncNavigation(ChangePassword(userid: homeController.empId!));
              } else {
                print("empId is null or empty, cannot navigate to ChangePassword.");
              }
            },
          ),

          buildDrawerMenu(
            title: 'Edit Form',
            icon: const FaIcon(FontAwesomeIcons.penToSquare),
            onPressed: () => navigateTo(EditFormPage()),
          ),
          buildDrawerMenu(
            title: 'Select Tour Id',
            icon: const FaIcon(FontAwesomeIcons.penToSquare),
            onPressed: () => navigateTo(SelectForm()),
          ),
          buildDrawerMenu(
            title: 'Enrollment Sync',
            icon: const FaIcon(FontAwesomeIcons.database),
            onPressed: () => handleSyncNavigation(const EnrolmentSync()),
          ),
          buildDrawerMenu(
            title: 'Cab Meter Tracing Sync',
            icon: const FaIcon(FontAwesomeIcons.database),
            onPressed: () => handleSyncNavigation(const CabTracingSync()),
          ),
          buildDrawerMenu(
            title: 'In Person Quantitative Sync',
            icon: const FaIcon(FontAwesomeIcons.database),
            onPressed: () => handleSyncNavigation(const InPersonQuantitativeSync()),
          ),
          buildDrawerMenu(
            title: 'School Facilities Mapping Form Sync',
            icon: const FaIcon(FontAwesomeIcons.database),
            onPressed: () => handleSyncNavigation(const SchoolFacilitiesSync()),
          ),
          buildDrawerMenu(
            title: 'School Staff & SMC/VEC Details Sync',
            icon: const FaIcon(FontAwesomeIcons.database),
            onPressed: () => handleSyncNavigation(const SchoolStaffVecSync()),
          ),
          buildDrawerMenu(
            title: 'Issue Tracker Sync',
            icon: const FaIcon(FontAwesomeIcons.database),
            onPressed: () => handleSyncNavigation(const FinalIssueTrackerSync()),
          ),
          buildDrawerMenu(
            title: 'Alfa Observation Sync',
            icon: const FaIcon(FontAwesomeIcons.database),
            onPressed: () => handleSyncNavigation(const AlfaObservationSync()),
          ),
          buildDrawerMenu(
            title: 'FLN Observation Sync',
            icon: const FaIcon(FontAwesomeIcons.database),
            onPressed: () => handleSyncNavigation(const FlnObservationSync()),
          ),
          buildDrawerMenu(
            title: 'IN-Person Qualitative Sync',
            icon: const FaIcon(FontAwesomeIcons.database),
            onPressed: () => handleSyncNavigation(const InpersonQualitativeSync()),
          ),
          buildDrawerMenu(
            title: 'School Recce Sync',
            icon: const FaIcon(FontAwesomeIcons.database),
            onPressed: () => handleSyncNavigation(const SchoolRecceSync()),
          ),


          buildDrawerMenu(
            title: 'Logout',
            icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
            onPressed: handleLogout,
          ),
        ],
      ),
    );
  }

  void navigateTo(Widget screen) {
    Navigator.pop(context);
    Get.to(() => screen);
  }

  Future<void> handleSyncNavigation(Widget syncScreen) async {
    try {
      await SharedPreferencesHelper.logout();
      navigateTo(syncScreen);
    } catch (e) {
      print("Error during sync navigation: $e");
      customSnackbar(
        'Error',
        'Failed to navigate to sync screen.',
        AppColors.error, // Replace with your error color constant
        AppColors.onError, // Replace with your on error color constant
        Icons.error,
      );
    }
  }

  Future<void> handleLogout() async {
    try {
      // Obtain the UserController instance and clear its values
      if (Get.isRegistered<UserController>()) {
        final UserController userController = Get.find<UserController>();
        userController.clearUserData(); // Clear user data in the controller
      }

      // Clear user data from SharedPreferences
      await SharedPreferencesHelper.logout(); // Complete logout and clear session

      // Clear previous navigation stack and navigate to LoginScreen
      Get.offAll(() => const LoginScreen());

      // Display a confirmation snackbar
      customSnackbar(
        'Success',
        'You have been logged out successfully.',
        AppColors.secondary,
        AppColors.onSecondary,
        Icons.verified,
      );
    } catch (e) {
      print("Error during logout: $e");
      customSnackbar(
        'Error',
        'Failed to log out. Please try again.',
        AppColors.error,
        AppColors.onError,
        Icons.error,
      );
    }
  }


  DrawerMenu buildDrawerMenu({
    required String title,
    required FaIcon icon,
    required Function onPressed,
  }) {
    return DrawerMenu(
      title: title,
      icons: icon,
      onPressed: () => onPressed(),
    );
  }
}

class DrawerMenu extends StatelessWidget {
  final String? title;
  final FaIcon? icons;
  final Function? onPressed;

  const DrawerMenu({
    super.key,
    this.title,
    this.icons,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icons,
      title: Text(title ?? '',
          style: TextStyle(
              color: AppColors.onBackground,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
      onTap: () {
        if (onPressed != null) {
          onPressed!(); // Call the function using parentheses
        }
      },
    );
  }
}
