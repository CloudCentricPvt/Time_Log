import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_log/utils/constants/k_colors.dart';
import '../../utils/constants/k_drawer_menu.dart';
import '../../utils/constants/k_fonts.dart';
import '../../utils/constants/k_nav_header.dart';
import '../../utils/reusable_widgit/k_info_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.red, // Change this to your desired color
        statusBarIconBrightness: Brightness.light, // Light icons on dark status bar
      ));
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: KCustomDrawer.customDrawer(
        context: context,
        title:"Profile",
        titleColor:KColors.appBlackColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        showBellIcon: true,  // Show Bell Icon
        showProfileIcon: false,  // Hide Profile Icon
      ),
      drawer: CustomDrawerMenu(context: context),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16,right: 16,bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 40,),
              const Center(
                child: CircleAvatar(
                  radius: 65, // Adjust size
                  backgroundImage: AssetImage('assets/images/profile_img.jpeg'), // Directly load the image
                ),
              ),
              const SizedBox(height: 10,),
               Text("SABIR HUSSAIN ANSARI",style: KFonts.heading),
              const Text("Android Developer | CCC0241",style: TextStyle(fontSize: 15,color: KColors.appSecondary),),

              ///--- Personal details
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Personal Details",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600,color: KColors.textColorGray,fontFamily: 'Poppins'),),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 32,
                      decoration: BoxDecoration(color: KColors.appColorWhite,borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: SvgPicture.asset(
                                'assets/icons/edit_profile.svg'),
                          ),
                          const SizedBox(width: 6,),
                          const Text("Edit",style: TextStyle(fontSize: 15,color: KColors.textColorGray))
                        ],
                      ),
                    ),
                    onTap: (){Navigator.pushNamed(context, '/edit_profile_screen');},
                  ),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 32,
                      decoration: BoxDecoration(color: KColors.appColorWhite,borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: SvgPicture.asset(
                                'assets/icons/change_pass.svg'),
                          ),
                          const SizedBox(width: 6,),
                          const Text("Change Pass",style: TextStyle(fontSize: 15,color: KColors.textColorGray))
                        ],
                      ),
                    ),
                    onTap: (){Navigator.pushNamed(context, '/change_password_screen');},
                  ),
                ],
              ),
              ///--- Design Profile Details
              const SizedBox(height: 10,),
              KInfoCard(
                children: [
                  buildRowForProfile("Name:", "Sabir Hussain", context,color:KColors.appBlackColor,fontWeight: FontWeight.w600,fontFamily: 'Poppins'),
                  buildRowForProfile("Gender:", "Male", context, color:KColors.textColorGray,fontFamily: 'Poppins',),
                  buildRowForProfile("Phone:", "+917388043661", context, color: KColors.appSecondary, fontFamily: 'Poppins'),
                  buildRowForProfile("Email:", "sabir@cccinfotech.com", context, color: KColors.appSecondary, fontFamily: 'Poppins'),
                  buildRowForProfile("DOB:", "01-01-0000", context,color:KColors.textColorGray, fontFamily: 'Poppins'),
                  buildRowForProfile("Anniversary date:", "01-01-2025", context, color:KColors.textColorGray,fontFamily: 'Poppins'),
                  buildRowForProfile("Address:", "Noida sec-63, GB Nagar UP-201306", context, color:KColors.textColorGray,fontFamily: 'Poppins'),
                ],
              ),

              ///--- Company Details
              const SizedBox(height: 10,),
              const Align(
                alignment: Alignment.centerLeft, // Aligns text to the start (left)
                child: Text(
                  "Company Details",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: KColors.textColorGray,
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              KInfoCard(
                children: [
                  buildRowForCompany("Department:", "Information Technology(IT)", context,color:KColors.appBlackColor,fontFamily: 'Poppins'),
                  buildRowForCompany("Employee Id:", "CCC0241", context, color: KColors.appSecondary, fontFamily: 'Poppins'),
                  buildRowForCompany("Designation:", "Software Engineer", context,color: KColors.textColorGray, fontFamily: 'Poppins'),
                  buildRowForCompany("Joining date:", "01-04-2024", context,color: KColors.textColorGray, fontFamily: 'Poppins'),
                ],
              ),

              ///--- Manager Details
              const SizedBox(height: 10,),
              const Align(
                alignment: Alignment.centerLeft, // Aligns text to the start (left)
                child: Text(
                  "Manager Details",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: KColors.textColorGray,
                  ),
                ),
              ),

              const SizedBox(height: 10,),
              KInfoCard(
                children: [
                  buildRowForManager("Manager Name:", "Rohit Sharma", context,color:KColors.appBlackColor,fontFamily: 'Poppins'),
                  buildRowForManager("Manager Email:", "rohit@cccinfotech.com", context, color: KColors.appSecondary),
                  buildRowForManager("Manager Phone:", "96325555441", context, color: KColors.appSecondary),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget buildRowForProfile(String label, String value, BuildContext context, {Color? color,  String? fontFamily,FontWeight? fontWeight,}) {
    double labelWidth = MediaQuery.of(context).size.width * 0.3; // 30% of screen width

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth, // Dynamic width based on screen size
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,color: KColors.textColorGray, fontFamily: 'Poppins',letterSpacing: 0.12,),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: color ?? Colors.black,
                letterSpacing: 0.12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRowForCompany(String label, String value, BuildContext context, {Color? color, required String  fontFamily}) {
    double labelWidth = MediaQuery.of(context).size.width * 0.3; // 30% of screen width

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth, // Dynamic width based on screen size
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,color: KColors.textColorGray, fontFamily: 'Poppins',letterSpacing: 0.12,),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: color ?? Colors.black,
                letterSpacing: 0.12,
              ),

            ),
          ),
        ],
      ),
    );
  }

  Widget buildRowForManager(String label, String value, BuildContext context, {Color? color,String? fontFamily}) {
    double labelWidth = MediaQuery.of(context).size.width * 0.3; // 30% of screen width

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth, // Dynamic width based on screen size
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,color: KColors.textColorGray, fontFamily: 'Poppins'),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black,
                letterSpacing: 0.12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
