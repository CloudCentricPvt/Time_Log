import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../popups/k_material_dialog.dart';
import 'k_colors.dart';

class KCustomDrawer {
  static PreferredSizeWidget customDrawer({
    required BuildContext context,
    required String title, // Required Title
    bool hello = false,
    String? subtitle, // Optional Subtitle (nullable)
    bool showBellIcon = false, // Optional Bell Icon
    bool showProfileIcon = false, // Optional Profile Icon
    List<Widget>? actions, // Additional Actions
    Color backgroundColor = KColors.appPrimary, // Default AppBar Color
    Color titleColor = KColors.appColorWhite, // Default Title Color
    ValueNotifier<bool>? isBottomNavVisible, // 👈 Add this
  }) {
    return AppBar(
      backgroundColor: backgroundColor,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Container(
            height: 32,
            width: 32,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SvgPicture.asset(
              'assets/icons/drawer_menu_icon.svg',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
          onPressed: () {
            isBottomNavVisible?.value = false; // 👈 hide nav bar
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              hello == true
                  ? RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          letterSpacing: 1,
                        ),
                        children: [
                          TextSpan(
                            text: 'Hello ',
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: title,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Expanded(
                flex: 6,
                    child: Text(
                        title,
                        style: TextStyle(
                            color: titleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                            letterSpacing: 0.5),
                      ),
                  ),
            ],
          ),
          SizedBox(
            width: 4,
          ),
          if (subtitle != null &&
              subtitle.isNotEmpty) // Only show subtitle if it's provided
            Text(
              subtitle,
              style: TextStyle(
                  color: titleColor.withOpacity(0.8),
                  fontSize: 14,
                  letterSpacing: 0.5),
            ),
        ],
      ),
      centerTitle: false,
      actions: [
        if (showBellIcon)
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.grey),
              onPressed: () {
              //  Navigator.pushNamed(context, '/notification_screen');
                KMaterialDialogs.sessionTimeOut(
                  context,
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK", style: TextStyle(color: Colors.red)),
                  ),
                  "Alert!!",
                  "Right Now Notification Part is in Pending.",
                );
              },
            ),
          ),
        if (showProfileIcon)
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: InkWell(
              /*child: const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/profile_img.jpeg'),
              ),*/
              child: CircleAvatar(
                radius: 30,
                backgroundColor: KColors.appColorWhite,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                Future.delayed(const Duration(milliseconds: 10), () {
                  Navigator.pushNamed(
                    context,
                    '/home_screen',
                    arguments: 3,  // 👉 Pass index 3 here
                  );
                });
                //Navigator.pushNamed(context, '/profile_screen');
              },
            ),
          ),
        if (actions != null) ...actions,
        const SizedBox(width: 10),
      ],
    );
  }
}
