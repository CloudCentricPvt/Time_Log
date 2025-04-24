import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_log/utils/constants/k_colors.dart';

class KLoader extends StatelessWidget {
  const KLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(KColors.appPrimaryRed),
              strokeWidth: 3,
            ),
          ),
        ],
      ),
    );
  }
}
