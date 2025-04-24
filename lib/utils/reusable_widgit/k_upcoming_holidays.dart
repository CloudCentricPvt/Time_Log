import 'package:flutter/material.dart';
import 'package:time_log/utils/constants/k_fonts.dart';

import '../constants/k_colors.dart';

class KUpcomingHolidays extends StatefulWidget {
  final List<Map<String, dynamic>> upcomingItems;

  const KUpcomingHolidays({super.key, required this.upcomingItems});

  @override
  State<KUpcomingHolidays> createState() => _KUpcomingHolidaysState();
}

class _KUpcomingHolidaysState extends State<KUpcomingHolidays> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.upcomingItems.length,
      itemBuilder: (context, index) {
        final item = widget.upcomingItems[index];

        return Container(
          width: screenWidth *0.8,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item['color'] ?? Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['title'] ?? '',
                      maxLines: 1,
                      style: KFonts.normalBoldWithWhite,
                    ),
                    SizedBox(height: 2,),
                    Text(
                        item['consumed'],
                        style: KFonts.thinWithWhite,
                      maxLines: 2,
                    ),
                    SizedBox(height: 6,),
                    Text(
                        "${item['date']} days",
                        style: KFonts.thinWithWhite,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      item['icons'],
                      height: 66,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }
}
