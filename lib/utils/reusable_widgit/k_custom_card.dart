import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Color myColor;
  final String containerTextDigit;
  final String containerTextOne;
  final String containerTextTwo;
  final Color textColor;

  const CustomCard(
      {super.key,
      required this.myColor,
      required this.containerTextDigit,
      required this.containerTextOne,
      required this.containerTextTwo,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double cardHeight = size.height * 0.12; // 12% of screen height
    final double cardWidth = size.width * 0.25; // 25% of screen width
    final double fontSizeDigit = size.width * 0.045; // responsive font size
    final double fontSizeText = size.width * 0.03;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 94,
        width:cardWidth,
        decoration: BoxDecoration(
          color: myColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                containerTextDigit,
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Column(
                children: [
                  Text(
                    containerTextOne,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.normal, // Make the text bold
                      fontSize: 12,
                      color: textColor,
                      // Adjust size if needed
                    ),
                  ),
                  Text(
                    containerTextTwo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.normal, // Make the text bold
                      fontSize: 12,
                      color: textColor,
                      // Adjust size if needed
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
