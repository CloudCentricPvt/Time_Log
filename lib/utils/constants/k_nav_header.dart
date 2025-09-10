import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'k_colors.dart';

class KCustomDrawer {
  static PreferredSizeWidget customDrawer({
    required BuildContext context,
    required String title,
    bool hello = false,
    String? subtitle,
    bool showBellIcon = false,
    bool showProfileIcon = false,
    List<Widget>? actions,
    Color backgroundColor = KColors.appPrimary, // Default AppBar Color
    Color titleColor = KColors.appColorWhite, // Default Title Color
    ValueNotifier<bool>? isBottomNavVisible,
    double topPaddingFactor = 0.06,
  }) {
    return AppBar(
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: kToolbarHeight + MediaQuery.of(context).size.height * 0.03,
      flexibleSpace: Padding(
        padding:  EdgeInsets.only(
          top: MediaQuery.of(context).size.height * topPaddingFactor,
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.04,),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Builder(
              builder: (context) => IconButton(
                icon: Container(
                  height: MediaQuery.of(context).size.height * 0.04,
                  width: MediaQuery.of(context).size.height * 0.04,

                  decoration: BoxDecoration(
                    color: KColors.appColorWhite,
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
                  isBottomNavVisible?.value = false;
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),

             SizedBox(
              width: MediaQuery.of(context).size.height * 0.01,
             ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  hello
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
                            fontSize: 17,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: title,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 16,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                      : Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 14,
                        fontFamily: "Poppins",
                        letterSpacing: 0.2,
                      ),
                    ),
                ],
              ),
            ),

            // Actions
            if (showBellIcon)
              Container(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.height * 0.05,
                margin:  EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width * 0.001,),
                decoration: const BoxDecoration(
                  color: KColors.appColorWhite,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/notification_icon.svg',
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notification_screen');
                  },
                ),
              ),
            SizedBox( width: MediaQuery.of(context).size.height * 0.01,),
            if (showProfileIcon)
              Container(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.height * 0.05,
                margin: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width * 0.001,),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: InkWell(
                  child: CircleAvatar(
                    radius: 30,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: KColors.colorGray,
                    ),
                  ),
                  onTap: () {
                    Future.delayed(const Duration(milliseconds: 10), () {
                      Navigator.pushNamed(
                        context,
                        '/home_screen',
                        arguments: 3,
                      );
                    });
                  },
                ),
              ),
            if (actions != null) ...actions,
          ],
        ),
      ),
    );

  }
}
