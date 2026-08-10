import 'package:flutter/material.dart';

class KInfoCard extends StatefulWidget {
  const KInfoCard({
    super.key,
    required this.children,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
    this.backgroundColor = Colors.white,
  });

  final List<Widget> children;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  State<KInfoCard> createState() => _KInfoCardState();
}

class _KInfoCardState extends State<KInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 1, // Elevation * 2 for blur
              offset: Offset.zero, // Slight downward offset
              spreadRadius: 1 / 10, // Minimal spread
            )
          ]),
      child: Padding(
        padding: widget.padding,
        child: Column(children: widget.children),
      ),
    );
  }
}
