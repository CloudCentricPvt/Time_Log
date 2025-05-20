import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:time_log/utils/constants/k_asstes.dart';
import 'package:time_log/utils/constants/k_fonts.dart';

import '../../models/dashboard_res.dart';
import '../constants/k_colors.dart';

class KUpcomingEvents extends StatefulWidget {


  const KUpcomingEvents({super.key});

  @override
  State<KUpcomingEvents> createState() => _KUpcomingEventsState();
}

class _KUpcomingEventsState extends State<KUpcomingEvents> {
  List<Event> eventsList = [];

  @override
  void initState() {
   _fetchEventsList();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: eventsList.length,
      itemBuilder: (context, index) {
        final item = eventsList[index];

        return Container(
          width: screenWidth *0.8,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: KColors.appColorWhite,
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
                        item.eventName =="Birthday"? KAssets.birthday_image : KAssets.aniversary_image,
                        height: 40,
                        width: 40,
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
                        item.personName ?? '',
                        style: KFonts.normalHeading,
                      ),
                      SizedBox(height: 5,),
                      Text(
                        item.eventName ?? '',
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
                            item.remainingDays.toString() ?? '',
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

  Future<void> _fetchEventsList() async{
    final response = await getDashboard(context);
    print('EVENTS_RES1:$response');
    if(response is DashboardResponse){
      setState(() {
        eventsList = response.data.events;
        print('EVENTS_RES2:$eventsList');
      });
    }
  }

}
