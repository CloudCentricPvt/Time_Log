import 'package:flutter/material.dart';

class KAppBar extends StatelessWidget {
  const KAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) => GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: Image.asset(
            alignment: Alignment.centerLeft,
              fit: BoxFit.contain,
              width: 80,
              height: 40,
              "assets/images/subnex_logo.png"),
        ));
  }
}
