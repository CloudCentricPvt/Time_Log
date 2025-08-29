import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AttendanceController{

  List<dynamic> dayWiseData = [];
  List<dynamic> hourWiseData = [];
  List<Map<String, dynamic>> thisWeekData = [];
  List<Map<String, dynamic>> thisMonthData = [];
  bool isLoading = false;

  static const String dayWiseApi = "https://68a05fa66e38a02c5818843b.mockapi.io/daywise/daywise";
  static const String hourWiseApi = "https://68a5683c2a3deed2960d6067.mockapi.io/hoursdata/hoursdata";
  static const String listOfThisWeekMonth = "https://68a4028ac123272fb9b1002f.mockapi.io/s";

  Future<List<dynamic>>getAttendanceDayWiseDetails() async{
    try{
      final response = await http.get(Uri.parse(dayWiseApi));
      if(response.statusCode == 200){
        print("Code12");
        dayWiseData = jsonDecode(response.body);
        return dayWiseData;
      }
      else{
        print("Code13");
        throw Exception("Failed to load Data");
      }
    }catch(e){
      print("Code14");
      throw Exception("Error: $e");
    }finally{
      //  isLoading = false;
    }
  }

  Future<List<dynamic>>getAttendanceHourWiseDetails() async{
    try{
      final response = await http.get(Uri.parse(hourWiseApi));
      if(response.statusCode == 200){
        print("Code1");
        hourWiseData = jsonDecode(response.body);
        return hourWiseData;
      }else{
        print("Code2");
        throw Exception("Failed to load Data");
      }
    }catch(e){
      print("Code3");
      throw Exception("Error: $e");
    }finally{
      print("Code4");
    }
  }

  Future<List<dynamic>>getThisWeekThisMonthDetails() async{
    try{
      final response = await http.get(Uri.parse(listOfThisWeekMonth));
      if(response.statusCode == 200){
        List<dynamic> apiDataOfMonth = jsonDecode(response.body);
        thisMonthData = List<Map<String,dynamic>>.from(apiDataOfMonth);
        DateTime now =DateTime.now();
        int currentWeekDay = now.weekday;  // 1 = Mon, 7 = Sun
        DateTime startOfWeek = now.subtract(Duration(days: currentWeekDay - 1));
        DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
        thisWeekData =thisMonthData.where((item){
          final dateString = item["date"]; // e.g. "05 May,2025"
          final parsedDate = DateFormat("dd MMM,yyyy").parse(dateString);
          return parsedDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              parsedDate.isBefore(endOfWeek.add(const Duration(days: 1)));
        }).toList();
        print("this week data :$thisWeekData");
        return apiDataOfMonth;
      }else{
        throw Exception("Failed to load Data");
      }
    }catch(e){
      throw Exception("Error: $e");
    }
  }



}