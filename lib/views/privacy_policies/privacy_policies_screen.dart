import 'package:flutter/material.dart';

import '../../utils/constants/k_colors.dart';
import '../../utils/reusable_widgit/k_custom_app_bar.dart';
import '../../utils/reusable_widgit/k_size_box.dart';
class PrivacyPoliciesScreen extends StatefulWidget {
  const PrivacyPoliciesScreen({super.key});

  @override
  State<PrivacyPoliciesScreen> createState() => _PrivacyPoliciesScreenState();
}

class _PrivacyPoliciesScreenState extends State<PrivacyPoliciesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.appPrimary,
        title: const KCustomAppBar(screenTitle: 'Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KSizedBox.w30,
            const Text('Company Privacy Policy',style: TextStyle(fontFamily: 'Poppins',fontWeight:FontWeight.w700,color: KColors.textHeadingColor),),
            const Text('This leave policy ensures that employees are aware of their entitlements regarding various types of leave, maintaining a balance between work responsibilities and personal needs.',style: TextStyle(fontFamily: 'Poppins',fontWeight:FontWeight.w400,color: KColors.textHeadingColor),),
          ],
        ),
      ),
    );
  }
}
