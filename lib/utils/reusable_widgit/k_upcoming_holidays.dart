import 'package:flutter/material.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/constants/k_fonts.dart';

import '../../models/upcoming_holidays_res.dart';
import '../constants/k_colors.dart';

class KUpcomingHolidays extends StatefulWidget {


  const KUpcomingHolidays({super.key});

  @override
  State<KUpcomingHolidays> createState() => _KUpcomingHolidaysState();
}

class _KUpcomingHolidaysState extends State<KUpcomingHolidays> {
  List<Holiday> upcomingHolidays = [];

  @override
  void initState() {
    fetchHolidaysList();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: upcomingHolidays.length,
      itemBuilder: (context, index) {
        final item = upcomingHolidays[index];

        return Container(
          width: screenWidth *0.8,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: KColors.appPrimary,
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
                      item.holidayTitle ?? '',
                      maxLines: 1,
                      style: KTextStyle.normalBoldWithWhite,
                    ),
                    SizedBox(height: 2,),
                    Text(
                        item.holidayDescription ?? '',
                        style: KTextStyle.thinWithWhite,
                      maxLines: 2,
                    ),
                    SizedBox(height: 10,),
                    Text(
                        item.formattedDate ?? '',
                        style: KTextStyle.thinWithWhite,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),

             /* Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      KAssets.holidaysList,
                      height: 66,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),*/
              const SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> fetchHolidaysList() async{
    var result = await getUpcomingHolidays(context);
    if(result is UpcomingHolidaysResponse){
      setState(() {
        upcomingHolidays = result.holidays;
        print('upcoming_Holidays:$upcomingHolidays');

      });

    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No upcoming Holidays found.")),
      );
      print('Holidays list not found');
    }
  }
}
