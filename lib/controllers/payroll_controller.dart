import 'dart:convert';

import 'package:http/http.dart' as http;

class PayrollController{

  List<dynamic> thisYearData = [];
  List<dynamic> lastYearData = [];
  List<dynamic> thisYearPaySlipData = [];
  List<dynamic> lastYearPaySlipData = [];

  static const String thisYearApi = "https://68a5c9162a3deed2960edc06.mockapi.io/payroll/payroll";
  static const String lastYearApi = "https://68a5cbc72a3deed2960ee847.mockapi.io/lastyear/payroll";
  static const String thisYearPaySlipsApi = "https://68a621f6639c6a54e99e084c.mockapi.io/payslips/payslips";
  static const String lastYearPaySlipsApi = "https://68a6316b639c6a54e99e319b.mockapi.io/payslips/payslipsLastYear";

  Future<List<dynamic>>getThisYearWisePayroll() async{
    try{
      final response = await http.get(Uri.parse(thisYearApi));
      if(response.statusCode == 200){
        thisYearData = jsonDecode(response.body);
        return thisYearData;
      }
      else{
        throw Exception("Failed to load Data");
      }
    }catch(e){
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>>getLastYearWisePayroll() async{
    try{
      final response = await http.get(Uri.parse(lastYearApi));
      if(response.statusCode == 200){
        lastYearData = jsonDecode(response.body);
        return lastYearData;
      }else{
        throw Exception("Failed to load Data");
      }
    }catch(e){
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>>getThisYearPaySlips() async{
    try{
      final response = await http.get(Uri.parse(thisYearPaySlipsApi));
      if(response.statusCode == 200){
        thisYearPaySlipData = jsonDecode(response.body);
        print("lastYearPaySlips: $thisYearPaySlipData");
        return thisYearPaySlipData;
      }else{
        throw Exception("Failed to load Data");
      }
    }catch(e){
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>>getLastYearPaySlips() async{
    try{
      final response = await http.get(Uri.parse(lastYearPaySlipsApi));
      if(response.statusCode == 200){
        lastYearPaySlipData = jsonDecode(response.body);
        return lastYearPaySlipData;
      }else{
        throw Exception("Failed to load Data");
      }
    }catch(e){
      throw Exception("Error: $e");
    }
  }



}