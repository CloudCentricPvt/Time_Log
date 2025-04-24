import 'package:flutter/material.dart';
import 'package:time_log/utils/constants/k_fonts.dart';

import '../constants/k_colors.dart';

class KUpcomingEvents extends StatefulWidget {
  final List<Map<String, dynamic>> upcomingItems;

  const KUpcomingEvents({super.key, required this.upcomingItems});

  @override
  State<KUpcomingEvents> createState() => _KUpcomingEventsState();
}

class _KUpcomingEventsState extends State<KUpcomingEvents> {
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
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: item['color'] ?? Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
          child: SizedBox(
            height: 80, // <- Set fixed height to avoid overflow
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        item['icons'],
                        height: 50,
                        width: 45,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item['title'] ?? '',
                        style: KFonts.normalHeading,
                      ),
                      SizedBox(height: 5,),
                      Text(
                        item['consumed'],
                        style: KFonts.thin
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 15,),

                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 2,
                        height: 30,
                        color: KColors.colorGray,
                      ),
                      SizedBox(width: 10,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${item['days']}",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: KColors.appPrimary,fontFamily: 'Poppins'),
                          ),
                          Text('Days'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
