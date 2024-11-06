import 'package:app17000ft_new/constants/color_const.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define breakpoints for different screen sizes (optional, based on testing)
    final isSmallScreen = screenWidth < 360; // e.g., small phones
    final isLargeScreen = screenWidth > 600; // e.g., tablets or larger devices

    return AppBar(
      title: Text(
        title,
        style: AppStyles.appBarTitle(
          context,
          AppColors.onPrimary,
        ).copyWith(
          fontSize: isSmallScreen
              ? 16 // Fixed smaller font size for small devices
              : isLargeScreen
              ? 24 // Larger font size for larger screens
              : screenWidth * 0.05, // Default for mid-range screens
        ),
      ),
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(
        color: AppColors.onPrimary,
      ),
      // Dynamically adjust the toolbar height
      toolbarHeight: isSmallScreen
          ? kToolbarHeight * 1.2 // Slightly smaller toolbar for small devices
          : isLargeScreen
          ? kToolbarHeight * 1.5 // Larger toolbar for larger devices
          : screenHeight * 0.1, // Default responsive height
      // You can also adjust padding based on screen size
      titleSpacing: isSmallScreen ? 8.0 : 16.0, // Example of responsive padding
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
